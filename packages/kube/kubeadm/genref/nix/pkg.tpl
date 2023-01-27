{{ define "packages" -}}
{ lib, ... }:
let
  duration = lib.types.str; # TODO: regex for metav1.Duration
in with lib.types; rec {
  {{ range .packages }}
    {{ if ne .GroupName "" -}}
      {{/* For package with a group name, list all type definitions in it. */}}
      {{ range .VisibleTypes }}
        {{- if or .Referenced .IsExported -}}
  {{ template "type" . }}
        {{- end -}}
      {{ end }}
    {{ else }}
      {{/* For package w/o group name, list only types referenced. */}}
      {{- range .VisibleTypes -}}
        {{- if .Referenced -}}
  {{ template "type" . }}
        {{- end -}}
      {{- end }}
    {{- end }}
  {{- end }}
}

{{- end }}
