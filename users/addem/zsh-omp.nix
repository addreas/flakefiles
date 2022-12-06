{ ... }:
let
  mkSeg = (type: opts: {
    type = type;
    style = "plain";
  } // opts);
  unicode = code: builtins.fromJSON "\"\\u${code}\"";
in
{
  programs.oh-my-posh.enable = true;
  programs.oh-my-posh.enableZshIntegration = true;
  # programs.oh-my-posh.useTheme = "robbyrussel";
  programs.oh-my-posh.settings = {
    "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
    blocks = [{
        alignment = "left";
        type = "prompt";
        segments = [
          (mkSeg "text" {
            foreground = "#98C379";
            template = "➜ ";
          })
          (mkSeg "path" {
            foreground = "#56B6C2";
            properties.style = "letter";
            template = "{{ .Path }}";
          })
        ];
      }
      {
        alignment = "right";
        type = "rprompt";
        segments = [
          (mkSeg "exit" { foreground = "#BF616A"; })
          (mkSeg "executiontime" {
            foreground = "#AEA4BF";
            template = "{{ .FormattedMs }} ";
            properties = {
              style = "austin";
              threshold = 150;
            };
          })
          (mkSeg "git" {
            # foreground = "#FC6D27";
            foreground_templates = [
              "{{ if or (.Working.Changed) (.Staging.Changed) }}#FFEB3B{{ end }}"
              "{{ if and (gt .Ahead 0) (gt .Behind 0) }}#FFCC80{{ end }}"
              "{{ if gt .Ahead 0 }}#B388FF{{ end }}"
              "{{ if gt .Behind 0 }}#B388FB{{ end }}"
            ];
            template = "{{ .HEAD }}{{ if .Working.Changed }}${unicode "F044"}{{ end }}";
            properties = {
              fetch_status = true;
              # branch_icon = "<#666>${unicode "e725"}</>";
            };
          })
          (mkSeg "kubectl" {
            foreground = "#3970e4";
            template = " <#666>${unicode "fd31"}</>{{.Context}}{{if .Namespace}}<#666>${unicode "ebbb"}</><#9db8e9>{{.Namespace}}</>{{end}}";
            parse_kubeconfig = true;
          })
          (mkSeg "battery" {
            foreground = "#9B6BDF";
            foreground_templates = [
              "{{if eq \"Charging\" .State.String}}#40c4ff{{end}}"
              "{{if eq \"Discharging\" .State.String}}#ff5722{{end}}"
              "{{if eq \"Full\" .State.String}}#4caf50{{end}}"
            ];
            template = "{{ if not .Error }}{{ .Icon }}{{ .Percentage }}{{ end }}{{ .Error }}";
            properties = {
              charged_icon = "";
              charging_icon = " ${unicode "21e1"}";
              discharging_icon = " ${unicode "21e3"}";
            };
          })
        ];
      }
    ];
    secondary_prompt = {
        background = "transparent";
        foreground = "#666";
        template = "➜ ";
    };
    final_space = true;
    version = 2;
  };
}
