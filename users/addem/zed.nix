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
    ];
    userSettings = {
      auto_update = false;

      ui_font_size = 14;
      buffer_font_size = 12;
      unnecessary_code_fade = 0.25;

      theme = {
        mode = "system";
        # mode = "dark";
        light = "Ayu Light";
        dark = "Ayu Dark";
      };
      toolbar.code_actions = true;
      minimap.show = "auto";
      colorize_brackets = true;
      soft_wrap = "none";

      lsp = {
        rust-analyzer.binary.path = lib.getExe pkgs.rust-analyzer;
        # cuelsp.binary.path = lib.getExe pkgs.cue;
        package-version-server.binary.path = lib.getExe pkgs.package-version-server;
        nil.binary.path = lib.getExe pkgs.nil;
        nixd.binary.path = lib.getExe pkgs.nixd;
      };
      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      show_whitespaces = "all";
      show_signature_help_after_edits = true;
      show_edit_predictions = false;
      diagnostics.inline = {
        enabled = true;
        min_column = 80;
      };
      vim.use_system_clipboard = "never"; # on_yank?

      base_keymap = "SublimeText";
      helix_mode = true;

      agent.tool_permissions.tools = {
        terminal.always_allow = [
          { pattern = "git (diff|status|show|worktree|ref-log|show-branch|remote|fetch|log|branch|merge|rebase).*"; }
          { pattern = "go mod tidy\s(2>&1)?"; }
          { pattern = "git\\s+(diff|status|show|ref-log|show-branch|remote|fetch|log|branch|merge|rebase).*"; }
          { pattern = "(cd.*)?.*go mod tidy.*"; }
          { pattern = "(cd.*)?go build.*"; }
          { pattern = "^git\\s+worktree(\\s|$)"; }
          { pattern = "^ls\\b"; }
          { pattern = "^cp\\b"; }
          { pattern = "^cat\\b"; }
          { pattern = "^find\\b"; }
          { pattern = "^grep\\b"; }
          { pattern = "^sed\\b"; }
          { pattern = "^head\\b"; }
          { pattern = "^pwd\\b"; }
        ];
      };
    };
  };
}
