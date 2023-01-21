{ pkgs, lib, ... }:
let
  opts = [
    # cd
    "auto_cd" #If a command is issued that can’t be executed as a normal command, and the command is the name of a directory, perform the cd command to that directory. This option is only applicable if the option SHIN_STDIN is set, i.e. if commands are being read from standard input. The option is designed for interactive use; it is recommended that cd be used explicitly in scripts to avoid ambiguity.
    "auto_pushd" #Make cd push the old directory onto the directory stack.
    "pushd_ignore_dups" #Don’t push multiple copies of the same directory onto the directory stack.
    # complete
    "always_to_end" #If a completion is performed with the cursor within a word, and a full completion is inserted, the cursor is moved to the end of the word. That is, the cursor is moved to the end of the word if either a single match is inserted or menu completion is performed.
    "auto_param_slash" #If a parameter is completed whose content is the name of a directory, then add a trailing slash instead of a space.
    "complete_in_word" #If unset, the cursor is set to the end of the word if completion is started. Otherwise it stays there and completion is done from both ends.
    # history
    "hist_verify" #Whenever the user enters a line with history expansion, don’t execute the line directly; instead, perform history expansion and reload the line into the editing buffer.
    "hist_save_no_dups" #When writing out the history file, older commands that duplicate newer ones are omitted.
    "share_history" #This option both imports new commands from the history file, and also causes your typed commands to be appended to the history file (the latter is like specifying INC_APPEND_HISTORY, which should be turned off if this option is in effect). The history lines are also output with timestamps ala EXTENDED_HISTORY (which makes it easier to find the spot where we left off reading the file after it gets re-written).
    #io
    "interactive_comments" #Allow comments even in interactive shells.
    #job control
    "long_list_jobs" #Print job notifications in the long format by default.
    #prompting
    "prompt_subst" #If set, parameter expansion, command substitution and arithmetic expansion are performed in prompts. Substitutions within prompts do not affect the command status.
  ];

  # terminfo = code: "\${terminfo[${code}]}";

  bindkey = {
    "^X^E" = "edit-command-line"; # ctrl-x ctrl-e

    # "^W" = "backward-kill-word"; # ctrl-w
    "^[[3;5~" = "kill-word"; # ctrl-delete

    "^[[1;5C" = "forward-word"; # ctrl-right
    "^[[1;5D" = "backward-word"; # ctrl-left

    "^[[5~" = "up-line-or-history"; # page up
    "^[[6~" = "down-line-or-history"; #  page down

    "^I" = "fzf-tab-complete";
  };
in
{

  home.packages = with pkgs; [
    zsh-completions
    nix-zsh-completions
  ];

  programs.fzf.enable = true;
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    history.extended = true;
    history.expireDuplicatesFirst = true;
    historySubstringSearch = {
      enable = true;
      searchUpKey = "^[OA";
      searchDownKey = "^[OB";
    };

    shellAliases = {
      k = "kubectl";
      which = "whence -vas";
    };

    shellGlobalAliases = {
      "..." = "../..";
      "...." = "../../..";
      "....." = "../../../..";
      "......" = "../../../../..";
    };

    #TODO: kubectl completions
    #TODO: kubens kubectx kubie

    plugins = [
      {
        name = "zsh-fzf-tab";
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
        src = pkgs.zsh-fzf-tab;
      }
      {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.5.0";
            sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
          };
      }
    ];

    initExtra = ''
      # open command line in $EDITOR with ctrl-x ctrl-e
      autoload -U edit-command-line
      zle -N edit-command-line

      # make ctrl-w stop at / instead of only whitespace
      autoload -U select-word-style
      select-word-style bash

      # not-only prefixbased completion
      zstyle ':completion:*' completer _complete
      zstyle ':completion:*' matcher-list "" 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'

      # open menu when multiple options (redundant with zsh-fzf-tab)
      # zstyle ':completion:*' menu select

      ${lib.strings.concatMapStringsSep "\n" (opt: "setopt ${opt}") opts}

      ${lib.strings.concatStringsSep
        "\n"
        (lib.attrsets.mapAttrsToList
          (key: cmd: "bindkey \"${key}\" ${cmd}")
          bindkey
        )}
      '';
  };
}
