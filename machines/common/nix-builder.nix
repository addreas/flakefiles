{ config, pkgs, lib, ... }:
let
  cache-uploader = pkgs.writeShellScript "post-build.sh" (builtins.readFile ./post-build.sh);
in
{
  nix.settings = {
    secret-key-files = [ "/var/secret/local-nix-secret-key" ];

    post-build-hook = cache-uploader;
    max-jobs = lib.mkDefault 1;
    cores = lib.mkDefault 4;
  };

  nix.daemonCPUSchedPolicy = lib.mkDefault "idle";

  systemd.services.nix-daemon.serviceConfig = {
    CPUQuota = "400%";
    MemoryHigh = "4G";
  };
}

