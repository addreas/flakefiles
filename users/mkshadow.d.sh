#!/bin/sh
# usage: ./mkpasswd.sh addem
# usage: ./mkpasswd.sh addem /mnt

USER=$1
ROOT=$2

sudo mkdir -p $ROOT/etc/shadow.d
sudo chown root:shadow $ROOT/etc/shadow.d
sudo chmod 600 $ROOT/etc/shadow.d

echo -n $USER ''
mkpasswd -m sha-512 | sudo tee $ROOT/etc/shadow.d/$USER