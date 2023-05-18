{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (ps: with ps; [
      rustup
      zlib
      openssl.dev
      pkg-config
    ]);
    extensions = with pkgs.vscode-extensions; [
      arcticicestudio.nord-visual-studio-code
      # brian-anders.sublime-duplicate-text
      # Cardinal90.multi-cursor-case-preserve
      denoland.vscode-deno
      esbenp.prettier-vscode
      firefox-devtools.vscode-firefox-debug
      golang.go
      # jallen7usa.vscode-cue-fmt
      jnoortheen.nix-ide
      matklad.rust-analyzer
      # maximus136.change-string-case
      # ms-python.isort
      ms-python.python
      ms-python.vscode-pylance
      ms-vscode.cpptools
      ms-vscode.makefile-tools
      # nico-castell.linux-desktop-file
      redhat.vscode-yaml
      tomoki1207.pdf
      # xoronic.pestfile
    ];
  };
}
