{{- define "members" -}}
  {{- range .GetMembers -}}
    {{- if not .Hidden }}
        {{ .FieldName }} = mkOption {
          {{ if .HasComment -}}
          description = ''
{{ .GetComment 12 }}
            '';
          {{ end -}}
          type = {{ .GetType.DisplayName }};
        }; 
    {{- end -}}
  {{- end -}}
{{ end }}
