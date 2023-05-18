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
    red = "#BF616A";
    orange = "#FFCC80";
    yellow = "#FFEB3B";
    faint = "#666";
  };
in
{
  programs.oh-my-posh.enable = true;
  programs.oh-my-posh.enableZshIntegration = true;
  programs.oh-my-posh.settings = {
    "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
    version = 2;
    final_space = true;
    blocks = [{
      alignment = "left";
      type = "prompt";
      segments = [
        (mkSeg "exit" {
          foreground = colors.light_green;
          foreground_templates = [ "{{ if gt .Code 0 }}${colors.red}{{ end }}" ];
          properties.always_enabled = true;
          template = "➜ ";
        })
        (mkSeg "session" {
          foreground = colors.orange;
          template = "{{ if .SSHSession }}${ucode "F817"}{{ .HostName }} {{ end }}";
        })
        (mkSeg "path" {
          foreground = colors.light_blue;
          properties.style = "letter";
          template = "{{ .Path }}";
        })
      ];
    }
      {
        alignment = "right";
        type = "rprompt";
        segments = [
          (mkSeg "exit" {
            foreground_templates = [ "{{ if gt .Code 0 }}${colors.red}{{ end }}" ];
            template = "{{ if gt .Code 0 }}${ucode "f00d"} {{ trimPrefix \"SIG\" .Meaning }}{{ end }} ";
          })
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
              "{{ if and (gt .Ahead 0) (gt .Behind 0) }}${colors.orange}{{ end }}"
              "{{ if gt .Ahead 0 }}${colors.yellow}{{ end }}"
              "{{ if gt .Behind 0 }}${colors.yellow}{{ end }}"
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
              "<${colors.red}>"
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
              "{{ .StashCount }}"
              "{{ end }}"
            ];
            properties = {
              fetch_status = true;
              fetch_stash_count = true;
              fetch_upstream_icon = true;
            };
          })
          (mkSeg "kubectl" {
            foreground = colors.dark_blue;
            template = lib.strings.concatStrings [
              " ${ucode "fd31"}("
              "<${colors.light_blue}>"
              "{{if eq .Context \"nucles\"}}${ucode "f015"}"
              "{{else if eq .Context \"dev.aurora\"}}dev${ucode "f110"}"
              "{{else if eq .Context \"app.aurora\"}}app${ucode "f110"}"
              "{{else if eq .Context \"canary.aurora\"}}canary${ucode "f110"}"
              "{{else if eq .Context \"support.aurora\"}}support${ucode "f110"}"
              "{{else}}{{.Context}}"
              "{{end}}"
              "</>"
              "{{if .Namespace}}"
              "<${colors.faint}>:</>"
              "<${colors.light_blue}>{{.Namespace}}</>"
              "{{end}})"
            ];
            parse_kubeconfig = true;
          })
          (mkSeg "time" {
            foreground = colors.faint;
            properties.time_format = "15:04:05";
          })
        ];
      }];
    secondary_prompt = {
      foreground = colors.faint;
      template = "➜ ";
    };
  };
}
