{{ define "type" }}
  {{ .Name.Name }} = lib.mkOption {
    {{- if .HasComment }}
    description = ''
{{ .GetComment 6 }}
      '';
    {{- end -}}
    {{- if .GetMembers }}
    type = submodule {
      options = {
        {{- template "members" . }}
      };
    };
  {{- end}}
  };
{{- end -}}

