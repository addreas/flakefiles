DEVICE=/dev/nvme0n1

parted --script ${DEVICE} \
                mklabel gpt \
                mkpart esp fat32 1MiB 512MiB \
                mkpart os btrfs 512MiB 100% \
                set 1 esp on \
                set 1 boot on

mkfs.fat -F 32 ${DEVICE}p1
mkfs.btrfs ${DEVICE}p2

P2=${DEVICE}p2
mount -t btrfs "$P2" /mnt/
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@varlog
btrfs subvolume create /mnt/@varlib
umount /mnt

mount -t btrfs -o noatime,compress=zstd,subvol=@ "$P2" /mnt
mkdir /mnt/{boot,home,nix,var/log,var/lib}
mount -t vfat  -o defaults,noatime ${DEVICE}p1 /mnt/boot
mount -t btrfs -o noatime,compress=zstd,subvol=@home "$P2" /mnt/home
mount -t btrfs -o noatime,compress=zstd,subvol=@nix "$P2" /mnt/nix
mount -t btrfs -o noatime,compress=zstd,subvol=@varlib "$P2" /mnt/var/lib
mount -t btrfs -o noatime,compress=zstd,subvol=@varlog "$P2" /mnt/var/log

nixos-generate-config --root /mnt
git clone https://github.com/addreas/flakefiles /mnt/etc/nixos
nixos-install --flake /mnt/etc/nixos#$(hostname)
reboot
