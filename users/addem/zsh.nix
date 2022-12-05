{ pkgs, lib, ... }:
{
 home.packages = with pkgs; [
    # helix
    # fzf
    # nix-index
  ];

  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;


  programs.zsh = {
    enable = true;
    # enableAutosuggestions = true;
    # enableSyntaxHighlighting = true;
    # defaultKeymap = "emacs"; #  "vicmd", "viins"

    # history.extended = true;
    history.expireDuplicatesFirst = true;
    # historySubstringSearch.enable = true;

    shellGlobalAliases = {
      "..." = "../..";
      "...." = "../../..";
      "....." = "../../../..";
      "......" = "../../../../..";
    };
  };

  programs.oh-my-posh.enable = true;
  programs.oh-my-posh.enableZshIntegration = true;
  # programs.oh-my-posh.useTheme = "robbyrussel";
  programs.oh-my-posh.settings = builtins.fromJSON (builtins.readFile ./addem.omp.json);

  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

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
