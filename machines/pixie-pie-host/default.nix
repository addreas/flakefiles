{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64-installer.nix")
  ];

  system.stateVersion = "22.11";

  sdImage.compressImage = false;

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # !!! Set to specific linux kernel version
  boot.kernelPackages = pkgs.linuxPackages_5_4;

  # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
  # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
  # On a Raspberry Pi 4 with 4 GB, you should either disable this parameter or increase to at least 64M if you want the USB ports to work.
  boot.kernelParams = [ "cma=256M" ];

  environment.systemPackages = with pkgs; [
    vim
    helix
    curl
    wget
  ];

  services.openssh.enable = true;

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "arrow";
    };
  };

  networking.firewall.enable = true;

  networking.interfaces.eth0.useDHCP = true;

  users.defaultUserShell = pkgs.zsh;
  users.mutableUsers = true;

  users.groups = {
    addem = {
      gid = 1000;
      name = "addem";
    };
  };

  users.users = {
    addem = {
      uid = 1000;
      isNormalUser = true;
      home = "/home/addem";
      name = "addem";
      group = "addem";
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
    };
  };

  services.pixiecore = {
    enable = true;
    mode = "api";
    apiServer = "localhost:8080";
    openFirewall = true;
    dhcpNoBind = true;
  };
}
