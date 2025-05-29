#!/usr/bin/env bash
#
# intended to be run on debian based 'head' node
#
# 1. get golang if needed
# 2. install warewulf from source
# 3. set node profile
# see https://warewulf.org/docs/main/getting-started/debian-quickstart.html
#

! [[ $UID == 0 ]] && echo "run as root/with sudo" && exit 1
dryrun() { [ -z "${DRYRUN:-}" ] && DRYRUN= || DRYRUN="echo";  $DRYRUN "$@"; return $?; }

# depends. NB. skipping firewalld for now
command -v  go ||
  dryrun apt install \
    nfs-kernel-server tftpd-hpa isc-dhcp-server \
    build-essential curl unzip \
    git golang libnfs-utils libgpgme-dev libassuan-dev \
    slurm

# dhcpcd in qemu failing
# > No subnet declaration for enp1s0 (10.0.2.15).
# # dpkg-reconfigure isc-dhcp-server # dont use this? updated by warefulf
#   journalctl -xeu isc-dhcp-server.service

# update go
export PATH="$HOME/go/bin:$PATH"
if ! [[ $(go version) =~ 1.23.9 ]] ; then 
   dryrun go install golang.org/dl/go1.23.9@latest
   ln -fs $HOME/go/bin/go1.23.9 $HOME/go/bin/go
   go download
fi

# get warewulf
if ! test -d ~/warewulf; then
   git clone https://github.com/warewulf/warewulf.git ~/warewulf
   cd ~/warewulf
   git checkout main
   make all && dryrun make install
fi

# config, only if out of date
dryrun make /usr/local/etc/warewulf/warewulf.conf
# start
dryrun systemctl enable --now warewulfd
#
dryrun wwctl configure --all

# nodes get debian image from pxe on boot
if ! wwctl profile list -j | jq '.default."image name"' | grep debian; then
  dryrun wwctl image import docker://ghcr.io/warewulf/warewulf-debian:12.0 debian-12.0
  dryrun wwctl profile set default --image=debian-12.0
fi

IF=enp1s0 #eth0
GW=10.141.0.0 # CHECK ME. matches warewulf.conf
dryrun wwctl profile set \
	--yes --netdev $IF \
	--netmask 255.255.255.0 \
	--gateway $GW "default"

dryrun wwctl node add node01.cluster --ipaddr 10.141.0.1 --discoverable true
