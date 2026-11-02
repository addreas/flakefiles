{
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      # https://jvns.ca/blog/2024/02/16/popular-git-config-options
      user.name = "Andreas Mårtensson";
      user.email = "andreas@addem.se";
      merge.conflictstyle = "zdiff3";
      push.default = "current";
      pull.rebase = true;
      fetch.prune = true;
      init.defaultBranch = "main";
      rerere.enabled = true;
      help.autocorrect = "prompt";
      diff.algorithm = "histogram";
      diff.colorMoved = true;
      branch.autosetupmerge = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "decorations";
      line-numbers = true;
      right-arrow = "⟶";
      relative-paths = true;
      navigate = true;
      # hyperlinks = true;

      decorations = {
        file-decoration-style = "ul ol";
        hunk-header-style = "syntax";
        hunk-header-decoration-style = "none";
      };
    };
  };
}
