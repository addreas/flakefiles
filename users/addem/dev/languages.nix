{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    go
    ko
    go-jsonnet
    jsonnet-bundler
    cue

    beamPackages.elixir_1_19
    beamPackages.elixir-ls
    gleam
    beam27Packages.erlang
    rebar3

    nodejs
    pnpm
    deno

    python3
    rustup
  ];

  programs.go = {
    enable = true;
    env.GOPATH = [ "${config.home.homeDirectory}/.go" ];
  };
}
