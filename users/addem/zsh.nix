{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    defaultKeymap = "emacs"; #  "vicmd", "viins"

    history.extended = true;
    history.expireDuplicatesFirst = true;
    historySubstringSearch.enable = true;

    shellGlobalAliases = {
      "..." = "../..";
      "...." = "../../..";
      "....." = "../../../..";
      "......" = "../../../../..";
    };
  };
}
