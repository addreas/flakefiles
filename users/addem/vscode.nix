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
  };
}
