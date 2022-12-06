{ pkgs, lib, ... }:
let
  opts = [
    # from oh-my-zsh
    "always_to_end" #If a completion is performed with the cursor within a word, and a full completion is inserted, the cursor is moved to the end of the word. That is, the cursor is moved to the end of the word if either a single match is inserted or menu completion is performed.
    "auto_cd" #If a command is issued that can’t be executed as a normal command, and the command is the name of a directory, perform the cd command to that directory. This option is only applicable if the option SHIN_STDIN is set, i.e. if commands are being read from standard input. The option is designed for interactive use; it is recommended that cd be used explicitly in scripts to avoid ambiguity.
    "auto_pushd" #Make cd push the old directory onto the directory stack.
    "complete_in_word" #If unset, the cursor is set to the end of the word if completion is started. Otherwise it stays there and completion is done from both ends.
    # "no_flow_control" #If this option is unset, output flow control via start/stop characters (usually assigned to ^S/^Q) is disabled in the shell’s editor.
    "hist_verify" #Whenever the user enters a line with history expansion, don’t execute the line directly; instead, perform history expansion and reload the line into the editing buffer.
    "interactive_comments" #Allow comments even in interactive shells.
    "long_list_jobs" #Print job notifications in the long format by default.
    "prompt_subst" #If set, parameter expansion, command substitution and arithmetic expansion are performed in prompts. Substitutions within prompts do not affect the command status.
    "pushd_ignore_dups" #Don’t push multiple copies of the same directory onto the directory stack.
    "pushd_minus" #Exchanges the meanings of ‘+’ and ‘-’ when used with a number to specify a directory in the stack.


    # complete
    "auto_param_slash" #If a parameter is completed whose content is the name of a directory, then add a trailing slash instead of a space.
    "auto_menu" #Automatically use menu completion after the second consecutive request for completion, for example by pressing the tab key repeatedly. This option is overridden by MENU_COMPLETE.
    "glob_complete" #When the current word has a glob pattern, do not insert all the words resulting from the expansion but generate matches as for completion and cycle through them like MENU_COMPLETE. The matches are generated as if a ‘*’ was added to the end of the word, or inserted at the cursor when COMPLETE_IN_WORD is set. This actually uses pattern matching, not globbing, so it works not only for files but for any completion, such as options, user names, etc.

    # history
    "hist_save_no_dups" #When writing out the history file, older commands that duplicate newer ones are omitted.
    "share_history" #This option both imports new commands from the history file, and also causes your typed commands to be appended to the history file (the latter is like specifying INC_APPEND_HISTORY, which should be turned off if this option is in effect). The history lines are also output with timestamps ala EXTENDED_HISTORY (which makes it easier to find the spot where we left off reading the file after it gets re-written).
  ];

  bindkey = {
    # https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/key-bindings.zsh
    "^X^E" = "edit-command-line";

    "^[OA" = "up-line-or-beginning-search";
    "^[OB" = "down-line-or-beginning-search";

    "^[[1;5C" = "forward-word";
    "^[[1;5D" = "backward-word";

    "^[[3;5~" = "kill-word";

    "^[[5~" = "up-line-or-history";
    "^[[6~" = "down-line-or-history";

    "^[[Z" = "reverse-menu-complete ";
  };
in
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

    initExtra = ''
      autoload -U edit-command-line
      zle -N edit-command-line
      autoload -U  up-line-or-beginning-search
      zle -N up-line-or-beginning-search
      autoload -U  down-line-or-beginning-search
      zle -N down-line-or-beginning-search

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
