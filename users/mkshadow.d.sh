#!/bin/sh
# usage: ./mkpasswd.sh addem
# usage: ./mkpasswd.sh addem /mnt

USER=$1
ROOT=$2

sudo mkdir /etc/shadow.d
sudo chown root:shadow /etc/shadow.d
sudo chmod 600 /etc/shadow.d

mkpasswd -m sha-512 | sudo tee $ROOT/etc/shadow.d/$USER