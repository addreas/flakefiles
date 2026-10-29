{ pkgs, lib, ... }:
{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
      "toml"
      "cue"
      "make"
      "dockerfile"
      "elixir"
      "gleam"
    ];

    # mutableUserSettings = false;

    userSettings = {
      auto_update = false;

      cli_default_open_behavior = "new_window";

      ui_font_size = 14;
      buffer_font_size = 12;
      unnecessary_code_fade = 0.25;

      theme = {
        mode = "system";
        # mode = "dark";
        light = "Ayu Light";
        dark = "Ayu Dark";
      };
      # toolbar = {
      #   code_actions = true;
      #   agent_review = false;
      # };
      # minimap = {
      #   show = "auto";
      #   max_width_columns = 40;
      #   thumb_border = "left_only";
      # };
      colorize_brackets = true;
      soft_wrap = "none";

      # project_panel.dock = "left";
      # outline_panel.dock = "left";
      # collaboration_panel.dock = "left";
      # git_panel.dock = "left";
      # agent.dock = "right";

      lsp = let getExe = lib.getExe; in with pkgs; {
        nixd.binary.path = getExe nixd;
        pyright.binary.path = getExe pyright;
        gopls.binary.path = getExe gopls;
        deno.binary.path = getExe deno;
        elixir-ls.binary.path = getExe beamPackages.elixir-ls;
        gleam.binary = {
          path = getExe gleam;
          arguments = ["lsp"];
        };
        cuelsp.binary = {
          path =  getExe cue;
          arguments = ["lsp"];
        };
        rust-analyzer.binary.path = getExe rust-analyzer;
        package-version-server.binary.path = getExe package-version-server;
        nil.binary.path = getExe nil;
      };
      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      show_whitespaces = "all";
      # show_signature_help_after_edits = true;
      # show_edit_predictions = false;
      # diagnostics.inline = {
      #   enabled = true;
      #   min_column = 80;
      # };
      # inlay_hints.enabled = false;
      vim.use_system_clipboard = "never"; # on_yank?

      languages.CUE.hard_tabs = true;

      base_keymap = "SublimeText";
      helix_mode = true;

      language_models."llama.cpp".api_url = "http://llm.qb/";

      edit_predictions = {
        provider = "open_ai_compatible_api";
        mode = "subtle";
        open_ai_compatible_api = {
          prompt_format = "zeta";
          model = "zeta-2.1";
          api_url = "https://llm.qb/v1";
        };
      };
    };
  };
}
