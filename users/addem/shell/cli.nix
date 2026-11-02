{ pkgs, ... }:
{
  programs.fzf.enable = true;
  programs.ripgrep.enable = true;

  # z auto jump thing, would i use it?
  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;
  # programs.pazi.enable = true;

  # filemanagers, yazi + broot frankenstein wouldbe cool
  # programs.yazi.enable = true;
  # programs.broot.enable = true;
  # programs.joshuto.enable = true;

  home.packages = with pkgs; [
    tcpdump
    tree
  ];

  home.file.digrc = {
    target = ".digrc";
    text = ''
      +nostats +nocomments +nocmd +noquestion +recurse
    '';
  };
}
