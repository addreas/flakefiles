{ config, lib, pkgs, modulesPath, ... }:

let
  btrfsDataHDD = {
    device = "/dev/disk/by-uuid/d5f05d68-2761-4262-af48-af7b221daea5";
    fsType = "btrfs";
  };
  btrfsDataSSD = {
    device = "/dev/disk/by-uuid/660b83df-c44d-4265-b293-272127aabf22";
    fsType = "btrfs";
  };
in
{
  fileSystems."/mnt/data" = btrfsDataHDD // { };
  fileSystems."/mnt/videos" = btrfsDataHDD // { options = [ "subvol=videos" ]; };
  fileSystems."/mnt/pictures" = btrfsDataHDD // { options = [ "subvol=pictures" ]; };
  fileSystems."/mnt/minio-objects" = btrfsDataHDD // { options = [ "subvol=minio-objects" ]; };
  fileSystems."/mnt/longhorn-backup" = btrfsDataHDD // { options = [ "subvol=longhorn-backup" ]; };
  fileSystems."/mnt/backups" = btrfsDataHDD // { options = [ "subvol=backups" ]; };

  fileSystems."/export/pictures" = btrfsDataHDD // { options = [ "subvol=pictures" ]; };
  fileSystems."/export/minio-objects" = btrfsDataHDD // { options = [ "subvol=minio-objects" ]; };
  fileSystems."/export/backups" = btrfsDataHDD // { options = [ "subvol=backups" ]; };
  fileSystems."/export/longhorn-backup" = btrfsDataHDD // { options = [ "subvol=longhorn-backup" ]; };
  fileSystems."/export/videos" = btrfsDataHDD // { options = [ "subvol=videos" ]; };

  fileSystems."/mnt/plex-config" = btrfsDataSSD // { options = [ "subvol=plex-config" ]; };
}
