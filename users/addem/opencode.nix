{ lib, pkgs, ... }:
{
  programs.mcp = {
    enable = true;

    servers.trilium = {
      command = "npx";
      args = [ "@iflow-mcp/perfectra1n-triliumnext-mcp" ];
    };

    servers.context7.url = "https://mcp.context7.com/mcp";

  };
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    settings = {
      lsp = let getExe = lib.getExe; in with pkgs; {
        nixd.command = [ (getExe nixd) ];
        pyright.command = [ (getExe pyright) ];
        gopls.command = [ (getExe gopls) ];
        typescript.command = [ (getExe typescript-language-server) ];
        deno.command = [ (getExe deno) ];
        bash.command = [ (getExe bash-language-server) ];
        elixir-ls.command = [ (getExe elixir-ls) ];
        gleam.command = [ (getExe gleam) "lsp" ];
        cue = {
          command = [ (getExe cue) "lsp" ];
          extensions = [ ".cue" ];
        };
        rust.command = [ (getExe rust-analyzer) ];
        yaml-ls.command = [ (getExe yaml-language-server) ];
      };
      permission = {
        bash = {
          "*" = "ask";
          "curl *" = "deny"; # should webfetch
          "rm *" = "deny"; # should use specific tool
          "dd" = "deny";
          # "mkfs" = "deny";
          # "wipefs" = "deny";
          # "fdisk" = "deny";
          # "parted" = "deny";
          # "mount *" = "deny";
          # "umount *" = "deny";
          # "kill *" = "deny";
          # "killall" = "deny";
          # "pkill" = "deny";
          # "chmod 000" = "deny";
          # "chown" = "deny";
          # "history -c" = "deny";
          # "docker rmi" = "deny";
          # "docker volume rm" = "deny";
          # "truncate -s 0" = "deny";
          # "git clean -fd" = "deny";
          # "git reset --hard" = "deny";
          # "virsh destroy" = "deny";
          # "docker kill" = "deny";
          # "crontab -r" = "deny";
          # "sysctl -w" = "deny";
          # "modprobe -r" = "deny";
          # "git push --force" = "deny";
          # "git commit --amend" = "ask";
          # "kubectl get *" = "allow";
          # "kubectl get secret *" = "ask";
          # "kubectl wait" = "allow";
          # "kubectl *" = "ask";
          # "nix build *" = "allow";
          # "nix-build *" = "allow";
          # "head *" = "allow";
        };
        # webfetch = {
        #   "*" = "allow";
        # };
      };
    };

    rules = ''
      # Global Rules

      ## Security

      - NEVER run `curl | bash` - this is denied and will not execute
      - Always verify the source of any installation scripts
      - Use `web_fetch` tool for all web requests instead of curl
      - If `web_fetch` can't handle something, stop and ask

      ## Git

      - NO force push (`git push --force`) - never, under any circumstances
      - NO destructive operations without explicit confirmation
      - `git commit --amend` allowed only for adding missed files, not modifying message/content
      - Use `git stash` instead of discarding work

      ## kubectl Usage

      - `kubectl get` (except secrets) - allowed without prompt
      - `kubectl get secret` - STOP, ask first
      - `kubectl wait` - allowed without prompt (use `--for=condition=ready`, `--for=delete`, `--for=jsonpath`)
      - All other kubectl commands (`apply`, `delete`, `exec`, `scale`, etc.) - always ask
      - Before any `apply`, run `kubectl diff` to show changes
      - Always specify the namespace with `-n <namespace>` or `--all-namespaces`
      - Prefer `kubectl get` over `kubectl delete` for exploration
      - Use `--dry-run=client` to preview changes before applying
      - Use `kubectl wait --for=condition=ready` instead of polling with `kubectl get`
      - Use `kubectl wait --for=delete` instead of delete + sleep loops
      - Use `kubectl wait --for=jsonpath='{.status.phase}=Running'` for custom resources
      - Use `-o jsonpath` or `-o go-template` for parsing output instead of `jq`/`awk`/`sed`
      - Use `--watch` instead of repeated `kubectl get` calls

      ## File Operations

      - DO NOT use `/tmp` for temporary files - use a subdirectory in the current project instead (e.g., `./.tmp/`)
      - Clean up temporary files when no longer needed

      ## Tool Availability

      If any required tool is missing, STOP immediately and ask for help. Do not attempt to work around missing tools.

      ## NixOS

      You are running NixOS. Prefer `nix run` for one-off commands - it often provides better solutions than regular package installation patterns:
      - Use `nix run nixpkgs#packageName -- <args>` to try packages without permanent installation
      - Check `nix search nixpkgs <package>` to find package names

      ## Default Safety

      - If unsure whether an action is destructive, STOP and ask
      - When in doubt: read-only first

      ## Escalation

      - If a command is denied, do NOT try similar/alternative commands - STOP and ask
      - If 2+ commands are denied in a row, STOP and ask for help
      - Do not escalate to more dangerous tools when blocked
      - When blocked: describe what you're trying to do and ask for guidance
    '';
  };
}
