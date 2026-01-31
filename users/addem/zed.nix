{ pkgs, lib, ... }:
{
  programs.zed-editor = {
    enable = true;

    extensions = [ "nix" "toml" "elixir" "make" ];
    userSettings = {
      auto_update = false;

      theme = {
        mode = "system";
        light = "Ayu Light";
        dark = "Ayu Dark";
      };

      show_whitespaces = "all";
      
      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      lsp = {
        rust-analyzer.binary.path = lib.getExe pkgs.rust-analyzer;
      };
    };
  };
}
