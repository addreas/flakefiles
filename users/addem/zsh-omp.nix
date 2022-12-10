{ lib, ... }:
let
  mkSeg = (type: opts: {
    type = type;
    style = "plain";
  } // opts);
  ucode = code: builtins.fromJSON "\"\\u${code}\"";

  colors = {
    dark_blue = "#3970e4";
    light_blue = "#9db8e9";
    light_green = "#98C379";
    path_blue = "#56B6C2";
    exit_red = "#BF616A";
    conflict_orange = "#FFCC80";
    ahead_purple = "#B388FF";
    behind_purple = "#B388FB";
    edit_yellow = "#FFEB3B";

    faint = "#AEA4BF";
  };
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
            foreground = colors.light_green;
            template = "➜ ";
          })
          (mkSeg "path" {
            foreground = colors.path_blue;
            properties.style = "letter";
            template = "{{ .Path }}";
          })
        ];
      }
      {
        alignment = "right";
        type = "rprompt";
        segments = [
          (mkSeg "exit" { foreground = colors.exit_red; })
          (mkSeg "executiontime" {
            foreground = colors.faint;
            template = "{{ .FormattedMs }} ";
            properties = {
              style = "austin";
              threshold = 150;
            };
          })
          (mkSeg "git" {
            foreground_templates = [
              "{{ if and (gt .Ahead 0) (gt .Behind 0) }}${colors.conflict_orange}{{ end }}"
              "{{ if gt .Ahead 0 }}${colors.ahead_purple}{{ end }}"
              "{{ if gt .Behind 0 }}${colors.behind_purple}{{ end }}"
            ];
            template = lib.strings.concatStrings [
              "{{ .UpstreamIcon }}"
              "{{ .HEAD }}"

              "{{ if or (gt .Ahead 0) (gt .Behind 0) }}"
                "<${colors.faint}>:</>"
                "{{ .BranchStatus }}"
              "{{ end }}"

              "{{ if .Working.Changed }}"
                "<${colors.faint}>:</>"
                "<${colors.exit_red}>"
                (ucode "F044")
                "{{ .Working.String }}"
                "</>"
              "{{ end }}"

              "{{ if .Staging.Changed }}"
                "<${colors.faint}>:</>"
                "<${colors.light_green}>"
                (ucode "F046")
                "{{ .Staging.String }}"
                "</>"
              "{{ end }}"

              "{{ if gt .StashCount 0 }}"
                "<${colors.faint}>:</>"
                (ucode "F692")
                " {{ .StashCount }}"
              "{{ end }}"
            ];
            properties = {
              fetch_status = true;
              fetch_upstream_icon = true;
            };
          })
          (mkSeg "kubectl" {
            foreground = colors.dark_blue;
            template = lib.strings.concatStrings [
              " ${ucode "fd31"}("
              "<>"
                "{{if eq .Context \"nucles\"}}${ucode "f015"}"
                "{{else if eq .Context \"dev.aurora\"}}dev${ucode "f110"}"
                "{{else if eq .Context \"app.aurora\"}}app${ucode "f110"}"
                "{{else if eq .Context \"canary.aurora\"}}canary${ucode "f110"}"
                "{{else if eq .Context \"support.aurora\"}}support${ucode "f110"}"
                "{{else}}"
                  "{{.Context}}"
                "{{end}}"
              "</>"
              "{{if .Namespace}}"
                "<${colors.faint}>:</>"
                "<#9db8e9>{{.Namespace}}</>"
              "{{end}})"
            ];
            parse_kubeconfig = true;
          })
          (mkSeg "session" {
            foreground = "#c386f1";
            template = "{{ if .SSHSession }} ${ucode "F817"}{{ .HostName }}{{ end }}";
          })
        ];
      }
    ];
    secondary_prompt = {
        background = "transparent";
        foreground = colors.faint;
        template = "➜ ";
    };
    final_space = true;
    version = 2;
  };
}
