DEVICE=/dev/nvme0n1

MNT=/mnt

set -e
set -x

sudo umount $MNT/boot $MNT/home $MNT/nix $MNT/var/lib $MNT/var/log $MNT

sudo parted --script ${DEVICE} \
                mklabel gpt \
                mkpart esp fat32 1MiB 512MiB \
                mkpart os btrfs 512MiB 20GiB \
                mkpart data ext4 50% 100% \
                set 1 esp on \
                set 1 boot on

sudo mkfs.fat -F 32 ${DEVICE}p1
sudo mkfs.btrfs ${DEVICE}p2 -f
sudo mkfs.ext4 ${DEVICE}p3

P2=${DEVICE}p2
sudo mount -t btrfs "$P2" $MNT/
sudo btrfs subvolume create "$MNT/@"
sudo btrfs subvolume create "$MNT/@home"
sudo btrfs subvolume create "$MNT/@nix"
sudo btrfs subvolume create "$MNT/@varlog"
sudo btrfs subvolume create "$MNT/@varlib"
sudo umount "$MNT"

sudo mount -t btrfs -o noatime,compress=zstd,subvol=@ "$P2" "$MNT"
sudo mkdir -p $MNT/{boot,home,nix,var/log,var/lib,var/lib/longhorn}
sudo mount -t vfat  -o noatime,defaults ${DEVICE}p1 "$MNT/boot"
sudo mount -t btrfs -o noatime,compress=zstd,subvol=@home "$P2" "$MNT/home"
sudo mount -t btrfs -o noatime,compress=zstd,subvol=@nix "$P2" "$MNT/nix"
sudo mount -t btrfs -o noatime,compress=zstd,subvol=@varlib "$P2" "$MNT/var/lib"
sudo mount -t btrfs -o noatime,compress=zstd,subvol=@varlog "$P2" "$MNT/var/log"
sudo mount -t ext4  -o noatime,defaults ${DEVICE}p3 "$MNT/var/lib/longhorn"

sudo nixos-generate-config --root $MNT

sudo mkdir -p "$MNT/home/addem"
ssh-keygen -t ed25519 -C "addem@$(hostname)" -f "$MNT/home/addem/.ssh/id_ed25519" -N ""

until git clone git@github.com:addreas/flakefiles.git $MNT/home/addem; do
  echo
  echo Need to add deploy key to https://github.com/addreas/flakefiles.git
  echo =============================================================================================
  echo $MNT/home/addem/id_ed25519.pub
  echo =============================================================================================
  echo If this was syslogged it would be very easy to copy...
  sleep 60
  #curl \
  #  -X POST \
  #  -H "Accept: application/vnd.github+json" \
  #  -H "Authorization: Bearer <YOUR-TOKEN>"\
  #  -H "X-GitHub-Api-Version: 2022-11-28" \
  #  https://api.github.com/repos/OWNER/REPO/keys \
  #  -d '{"title":"octocat@octomac","key":"ssh-rsa AAA...","read_only":true}'
done

cp "$MNT/etc/nixos/hardware-configuration.nix" "$MNT/home/addem/flakefiles/machines/nucles/$(hostname)"
sudo ln -s -r "$MNT/home/addem/flakefiles/flake.nix" "/etc/nixos"

sudo nixos-install --flake "$MNT/home/addem/flakefiles#$(hostname)" --root $MNT --no-root-password

(
  cd $MNT/home/addem
  git commit -am "add newly generated hardware-configuration.nix for $(hostname)"
  git push
)

reboot
