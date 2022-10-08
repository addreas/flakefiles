#https://gist.github.com/giuseppe998e/629774863b149521e2efa855f7042418
#https://cnx.srht.site/blog/butter
#https://grahamc.com/blog/erase-your-darlings
#https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/
#https://xeiaso.net/blog/paranoid-nixos-2021-07-18

DEVICE=/dev/nvme0n1

parted --script ${DEVICE} \
                mklabel gpt \
                mkpart esp fat32 1MiB 512MiB \
                mkpart os btrfs 512MiB -16GiB \
                mkpart swap linux-swap 16GiB 100% \
                set 1 esp on \
                set 1 boot on \

mkfs.fat -F 32 ${DEVICE}p1
mkfs.btrfs ${DEVICE}p2
mkswap ${DEVICE}p3

P2=${DEVICE}p2
mount -t btrfs $P2 /mnt/
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@varlog
btrfs subvolume create /mnt/@varlib
umount /mnt

mount -t tmpfs -o noatime,mode=755 none /mnt

mkdir /mnt/{boot,home,nix,var/log,var/lib}

mount -t vfat  -o defaults,noatime ${DEVICE}p1 /mnt/boot
mount -t btrfs -o noatime,compress=zstd,subvol=@home $P2 /mnt/home
mount -t btrfs -o noatime,compress=zstd,subvol=@nix $P2 /mnt/nix
mount -t btrfs -o noatime,compress=zstd,subvol=@varlib $P2 /mnt/var/lib
mount -t btrfs -o noatime,compress=zstd,subvol=@varlog $P2 /mnt/var/log

#environment.etc."machine-id".source = "/nix/persist/etc/machine-id";
#users.mutableUsers = false;
#HASHED_PASSWORD=$(nix-shell -p mkpasswd --run 'mkpasswd -m SHA-512 -s')
#users.users.*USERNAME*.initialHashedPassword = "$HASHED_PASSWORD";

swapon ${DEVICE}p3

nixos-generate-config --root /mnt
nixos-install --no-root-passwd
reboot
