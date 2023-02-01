package main

import (
	"fmt"
	"os"
	"reflect"
	"regexp"
	"sort"
	"strings"
	"unicode"

	"k8s.io/gengo/types"
	"k8s.io/klog/v2"
)

// apiPackage is a collection of Go packages where API type definitions are found.
type apiPackage struct {
	apiGroup   string
	apiVersion string

	// The Go packages related to this API package. There can be more than one
	// Go package related to the same API package.
	GoPackages []*types.Package

	// List of Types defined. Note that multiple 'types.Package's can define
	// Types for the same apiVersion.
	Types []*apiType

	// Title is set from config
	Title string
}

// DisplayName returns the full name of the API package
func (p *apiPackage) DisplayName() string {
	return fmt.Sprintf("%s/%s", p.apiGroup, p.apiVersion)
}

// GroupName returns the API group the package contains.
func (p *apiPackage) GroupName() string {
	return p.apiGroup
}

// VisibleTypes enumerates all visible types contained in a package.
func (p *apiPackage) VisibleTypes() []*apiType {
	var result []*apiType
	for _, t := range sortTypes(p.Types) {
		if !t.isHidden() {
			result = append(result, t)
		}
	}
	return result
}

func (p *apiPackage) HasComment() bool {
	return len(p.GoPackages[0].DocComments) > 0
}

// GetComment returns the rendered HTML format of the package comment.
func (p *apiPackage) GetComment(indent int) string {
	comments := p.GoPackages[0].DocComments
	return renderComments(comments, indent)
}

// apiMember is a wrapper of types.Member
type apiMember struct {
	types.Member
}

// IsOptional tests if the apiMember is an optional one.
func (m *apiMember) IsOptional() bool {
	tags := types.ExtractCommentTags("+", m.CommentLines)
	_, ok := tags["optional"]
	return ok
}

// FieldName returns the member name when used in serialized format.
func (m *apiMember) FieldName() string {
	v := reflect.StructTag(m.Tags).Get("json")
	v = strings.TrimSuffix(v, ",omitempty")
	v = strings.TrimSuffix(v, ",inline")
	if v != "" {
		return v
	}
	return m.Name
}

// GetType translates the Type field of an apiMember to an apiType reference
func (m *apiMember) GetType() *apiType {
	return &apiType{*m.Type}
}

// Test if a field is an inline one
func (m *apiMember) IsInline() bool {
	return strings.Contains(reflect.StructTag(m.Tags).Get("json"), ",inline")
}

// Test if a member is supposed to be hidden.
func (m *apiMember) Hidden() bool {
	for _, v := range config.HiddenMemberFields {
		if m.Name == v {
			return true
		}
	}
	return false
}

func (m *apiMember) HasComment() bool {
	return len(m.CommentLines) > 0
}

// GetComment returns the rendered HTML output from the field comment.
func (m *apiMember) GetComment(indent int) string {
	return renderComments(m.CommentLines, indent)
}

// apiType is a wrapper of type.Type
type apiType struct {
	types.Type
}

// isLocal tests if the type should be treated as a local definition
func (t *apiType) isLocal() bool {
	t = t.deref()
	if t.Kind == types.Builtin {
		return false
	}
	_, ok := typePkgMap[t.String()]
	return ok
}

// isHidden tests if a type is supposed to be hidden.
func (t *apiType) isHidden() bool {
	for _, pattern := range config.HideTypePatterns {
		if regexp.MustCompile(pattern).MatchString(t.Name.String()) {
			return true
		}
	}
	if !t.IsExported() && unicode.IsLower(rune(t.Name.Name[0])) {
		// types that start with lowercase
		return true
	}
	return false
}

// typeId returns the type Identifier in the format of PackagePath.Name
func (t *apiType) typeId() string {
	t = t.deref()
	return t.Name.String()
}

// deref returns the underlying type when t is a pointer, map, or slice.
func (t *apiType) deref() *apiType {
	if t.Elem != nil {
		return &apiType{*t.Elem}
	}
	return t
}

// GetMembers returns a list of apiMembers each of which is from Type.Members
func (t *apiType) GetMembers() []*apiMember {
	var result []*apiMember
	for _, m := range t.Members {
		member := &apiMember{m}
		result = append(result, member)
	}
	return result
}

// IsExported tests if a type is exported
func (t *apiType) IsExported() bool {
	comments := strings.Join(t.SecondClosestCommentLines, "\n")
	if strings.Contains(comments, "+genclient") {
		return true
	}

	if strings.Contains(comments, "+k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object") {
		return true
	}

	// There are cases where this comment is not the "second closest".
	// Check this again.
	comments = strings.Join(t.CommentLines, "\n")
	if strings.Contains(comments, "+genclient") {
		return true
	}

	if strings.Contains(comments, "+k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object") {
		return true
	}

	return false
}

// Referenced tests if the API type is referenced anywhere in the package
func (t *apiType) Referenced() bool {
	typeName := t.String()
	_, found := references[typeName]
	return found
}

// APIGroup looks up API group for the given type
func (t *apiType) APIGroup() string {
	t = t.deref()

	p := typePkgMap[t.String()]
	if p == nil {
		klog.Warningf("Cannot read apiVersion for %s from type=>pkg map", t.Name.String())
		return "<UNKNOWN_API_GROUP>"
	}

	return p.DisplayName()
}

// DisplayName deterimines how a type is displayed in the docs.
func (t *apiType) DisplayName() string {
	s := t.typeId()
	if t.isLocal() {
		s = t.deref().Name.Name
	}
	if t.Kind == types.Pointer {
		s = strings.TrimLeft(s, "*")
	}

	switch t.Kind {
	case types.Struct,
		types.Interface,
		types.Alias:
		// noop
	case types.Builtin:
		if s == "string" {
			return "str"
		} else if strings.HasPrefix(s, "int") {
			return "int"
		} else if strings.HasPrefix(s, "float") {
			return "float"
		} else if s == "bool" {
			return "bool"
		} else {
			klog.Warningln("unmatched type", s)
		}
	case types.Pointer:
		return t.deref().DisplayName()
	case types.Map: // return original name
		return "(attrsOf " + t.deref().DisplayName() + ")"
	case types.Slice:
		return "(listOf " + t.deref().DisplayName() + ")"
	default:
		klog.Warningf("Type '%s' has kind='%v' which is unhandled", t.Name, t.Kind)
	}

	// strip prefix if desired
	for _, prefix := range config.StripPrefix {
		if strings.HasPrefix(s, prefix) {
			s = strings.Replace(s, prefix, "", 1)
		}
	}

	if replacement, ok := config.Mappings[s]; ok {
		return replacement
	}

	return s
}

func (t *apiType) HasComment() bool {
	return len(t.CommentLines) > 0
}

// GetComment returns the rendered comment doc for the type.
func (t *apiType) GetComment(indent int) string {
	return renderComments(t.CommentLines, indent)
}

// groupName extracts the "//+groupName" meta-comment from the specified
// package's comments, or returns empty string if it cannot be found.
func groupName(gopkg *types.Package) string {
	p := gopkg.Constants["GroupName"]
	if p != nil {
		return *p.ConstValue
	}
	m := types.ExtractCommentTags("+", gopkg.Comments)
	v := m["groupName"]
	if len(v) == 1 {
		return v[0]
	}
	return ""
}

// isVendorPackage determines if package is coming from vendor/ dir.
func isVendorPackage(gopkg *types.Package) bool {
	vendorPattern := string(os.PathSeparator) + "vendor" + string(os.PathSeparator)
	return strings.Contains(gopkg.SourcePath, vendorPattern)
}

// sortTypes is a utility function for sorting types in alphabetic order
func sortTypes(typs []*apiType) []*apiType {
	sort.Slice(typs, func(i, j int) bool {
		t1, t2 := typs[i], typs[j]
		if t1.IsExported() && !t2.IsExported() {
			return true
		} else if !t1.IsExported() && t2.IsExported() {
			return false
		}
		return t1.Name.Name < t2.Name.Name
	})
	return typs
}

// renderComments is a utility function for processing a list of strings into
// safe and valid HTML snippets.
func renderComments(comments []string, indent int) string {
	// var res string
	// filter out tags in comments
	var list []string
	prefix := strings.Repeat(" ", indent)
	for _, v := range comments {
		if !strings.HasPrefix(strings.TrimSpace(v), "+") {
			list = append(list, prefix+v)
		}
	}
	return strings.Join(list, "\n")
}

// containsString checks if a given string is a member of the string list
func containsString(sl []string, str string) bool {
	for _, s := range sl {
		if str == s {
			return true
		}
	}
	return false
}
