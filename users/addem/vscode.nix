{ pkgs, ... }:
let
  nixpkgs-extensions = with pkgs.vscode-extensions; [
    arcticicestudio.nord-visual-studio-code
    denoland.vscode-deno
    esbenp.prettier-vscode
    editorconfig.editorconfig
    firefox-devtools.vscode-firefox-debug
    golang.go
    jnoortheen.nix-ide
    matklad.rust-analyzer
    ms-python.python
    ms-python.vscode-pylance
    ms-vscode.cpptools
    # ms-vscode.makefile-tools
    redhat.vscode-xml
    redhat.vscode-yaml
    ryu1kn.partial-diff
    tomoki1207.pdf
  ];
  market-extensions = with pkgs.vscode-marketplace; [
    brian-anders.sublime-duplicate-text
    cardinal90.multi-cursor-case-preserve
    # pkgs.vscode-marketplace."cuelang.org".cue
    pgourlain.erlang
    jakebecker.elixir-ls
    jallen7usa.vscode-cue-fmt
    maximus136.change-string-case
    ms-python.isort
    ms-vscode.sublime-keybindings
    nico-castell.linux-desktop-file
    # platformio.platformio-ide
    unifiedjs.vscode-mdx
    # VisualStudioExptTeam.vscodeintellicode
    xoronic.pestfile
  ];
in
{
  programs.vscode = {
    enable = true;
    extensions = nixpkgs-extensions ++ market-extensions;
    userSettings = {
      "editor.bracketPairColorization.enabled" = true;
      "editor.codeActionsOnSave" = [ ];
      "editor.fontFamily" = "'Hack Nerd Font', 'Hack', 'Segoe UI Emoji', 'Segoe UI Symbol'";
      "editor.fontSize" = 12;
      "editor.formatOnPaste" = false;
      "editor.formatOnSave" = false;
      "editor.lightbulb.enabled" = false;
      "editor.minimap.enabled" = false;
      "editor.multiCursorModifier" = "ctrlCmd";
      "editor.snippetSuggestions" = "bottom";
      "editor.suggest.localityBonus" = true;
      "editor.suggestSelection" = "first";
      "emmet.showExpandedAbbreviation" = "never";
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "files.insertFinalNewline" = true;
      "files.trimTrailingWhitespace" = true;
      "go.buildOnSave" = "off";
      "go.formatTool" = "goimports";
      "go.gopath" = "~/.go";
      "go.toolsManagement.autoUpdate" = true;
      "go.useLanguageServer" = true;
      "gopls"."usePlaceholders" = true;
      "redhat.telemetry.enabled" = false;
      "search.mode" = "reuseEditor";
      "telemetry.telemetryLevel" = "off";
      "terminal.integrated.fontFamily" = "'Hack Nerd Font', 'Hack', 'Segoe UI Emoji', 'Segoe UI Symbol'";
      "terminal.integrated.fontSize" = 12;
      "typescript.enablePromptUseWorkspaceTsdk" = true;
      "typescript.format.semicolons" = "remove";
      "typescript.surveys.enabled" = false;
      "update.mode" = "manual";
      "vsintellicode.modify.editor.suggestSelection" = "automaticallyOverrodeDefaultValue";
      "workbench.colorTheme" = "Nord";
      "workbench.startupEditor" = "newUntitledFile";
      "yaml.validate" = true;
      "yaml.completion" = true;
      "yaml.hover" = true;
      "json.validate.enable" = true;
      "json.schemaDownload.enable" = true;
      "yaml.schemaStore.enable" = true;
      "[cue]" = {
        "editor.formatOnPaste" = true;
        "editor.formatOnSave" = true;
      };
      "[go]" = {
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave"."source.organizeImports" = true;
        "editor.snippetSuggestions" = "none";
      };
      "[go.mod]" = {
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave"."source.organizeImports" = true;
      };
      "[html]" = {
        "editor.defaultFormatter" = "vscode.html-language-features";
      };
      "[json]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[jsonc]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[markdown]" = {
        "editor.wordWrap" = "wordWrapColumn";
        "editor.wordWrapColumn" = 120;
      };
      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[typescriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[yaml]" = {
        "editor.tabSize" = 2;
        "editor.quickSuggestions" = {
          "other" = true;
          "comments" = false;
          "strings" = true;
        };
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "vs-kubernetes" = {
        "vs-kubernetes.crd-code-completion" = "disabled";
        "vs-kubernetes.ignore-recommendations" = true;
      };
    };
  };
}
