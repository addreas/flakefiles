{ pkgs, lib, ... }:
{
  programs.helix.enable = true;
  programs.helix.settings = {
    theme = "bogster";
    editor.scrolloff = 5;
    editor.file-picker.hidden = false;
    editor.whitespace.render = {
      tab = "all";
      newline = "all";
    };
    editor.lsp.display-messages = true;
  };
}
