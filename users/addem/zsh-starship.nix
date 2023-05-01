{ lib, ... }: {
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
  programs.starship.settings = {
    format = lib.concatStrings [
      "$character"
      # "$username"
      "$hostname"
      "$shlvl"
      "$directory"
    ];
    # right_format = "$all";
    right_format = lib.concatStrings [
      "$status" "$cmd_duration"
      "$sudo" "$package" "$c" "$cmake" "$cobol" "$daml" "$dart" "$deno" "$dotnet" "$elixir" "$elm" "$erlang" "$fennel" "$golang" "$guix_shell" "$haskell" "$haxe" "$helm" "$java" "$julia" "$kotlin" "$gradle" "$lua" "$nim" "$nodejs" "$ocaml" "$opa" "$perl" "$php" "$pulumi" "$purescript" "$python" "$raku" "$rlang" "$red" "$ruby" "$rust" "$scala" "$swift" "$terraform" "$vlang" "$vagrant" "$zig" "$buf" "$nix_shell" "$conda" "$meson" "$spack" "$memory_usage" "$aws" "$gcloud" "$openstack" "$azure" "$env_var" "$crystal"
      "$git_branch" "$git_commit" "$git_state" "$git_metrics" "$git_status"
      "$kubernetes"
      "$time"
      "$battery"
    ];
    add_newline = false;
    scan_timeout = 100;
    palette = "custom";
    palettes.custom = {
      blue = "#9db8e9";
      green = "#98C379";
      red = "#BF616A";
      orange = "#FFCC80";
      yellow = "#FFEB3B";
      faint = "#666";
    };
    # continuation_prompt = "[➜](dimmed faint)";

    character = {
      success_symbol = "[➜](bold green)";
      error_symbol = "[➜](bold red)";
    };
    hostname = {
      ssh_symbol = "";
      format = "[$ssh_symbol$hostname]($style)";
      style = "bold dimmed orange";
    };
    shlvl = {
      disabled = false;
      symbol = "";
      style = "dimmed blue";
    };
    directory = {
      style = "bold blue";
      truncate_to_repo = false;
      before_repo_root_style = "dimmed";
      repo_root_style = "bold bright-blue";
      truncation_length = 6;
      truncation_symbol = "…/";
    };

    status = {
      disabled = false;
      format = "[$symbol$common_meaning$maybe_int$signal_name$signal_number]($style) ";
    };
    cmd_duration = {
      format = "[$duration]($style) ";
      style = " faint";
      show_notifications = true;
    };

    package.format = "[$symbol($version)]($style) ";

    crystal.format = "[$symbol($version)]($style) ";
    elixir.format = "[$symbol($version)]($style) ";
    erlang.format = "[$symbol($version)]($style) ";
    golang.format = "[$symbol($version)]($style) ";
    haskell.format = "[$symbol($version)]($style) ";
    lua.format = "[$symbol($version)]($style) ";
    python.format = "[$symbol($version)]($style) ";
    rust.format = "[$symbol($version)]($style) ";

    golang.symbol = " ";
    elixir.symbol = " ";

    elixir.detect_extensions = ["ex" "exs"];
    erlang.detect_extensions = ["erl"];
    nodejs.detect_extensions = ["cjs" "cts"];

    nix_shell.disabled = true;

    git_branch = {
      style = "yellow";
      symbol = "";
      format = "[$symbol$branch(:$remote_branch)]($style) ";
    };
    git_commit = {};
    git_state = {};
    git_metrics = { disabled = false; };
    git_status = {
      format = ''(\[$staged$conflicted$deleted$renamed$modified$ahead_behind$untracked$stashed\] )'';

      conflicted = "[ﲍ$count](bright-red)";
      ahead = "[⇡$count](dimmed green)";
      behind = "[⇣$count](dimmed red)";
      diverged = "[⇕⇡$ahead_count⇣$behind_count](red)";
      untracked = "[?$count](dimmed red)";
      stashed = "[$count](dimmed yellow)";
      modified = "[$count](orange)";
      staged = "[$count](green)";
      renamed = "[»$count](orange)";
      deleted = "[✘$count](red)";
    };

    kubernetes = {
      disabled = false;
      symbol = "ﴱ";
      format = ''[$symbol](bold blue)\([$context](blue)(:[$namespace](dimmed blue))\) '';
      context_aliases = {
        nucles = "";
      };
      detect_extensions = ["yaml" "cue"];
      # detect_folders = ["homelab"];
    };

    time = {
      format = "[$time]($style)";
      style = "dimmed";
      disabled = false;
    };
  };
}