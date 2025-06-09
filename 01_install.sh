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

# depends. NB. skipping firewalld for now. iptables-persistent for nat forwarding. see cerebro2.iptables
command -v  go ||
  dryrun apt install \
    nfs-kernel-server tftpd-hpa isc-dhcp-server \
    build-essential curl unzip \
    git golang libnfs-utils libgpgme-dev libassuan-dev \
    slurmd slurmctld \
    iptables-persistent

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
if ! test -d /opt/warewulf; then
   git clone https://github.com/warewulf/warewulf.git /opt/warewulf
   cd /opt/warewulf
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
  # 20250602: this wasn't run initially?!
  dryrun wwctl profile set --yes --image debian-12.0 "default"
fi

IF=enp6s0f0 #enp1s0 #eth0
GW=10.141.0.0 # CHECK ME. matches warewulf.conf
dryrun wwctl profile set \
	--yes --netdev $IF \
	--netmask 255.0.0.0 \
	--gateway $GW "default"

dryrun wwctl node add node01 --ipaddr 10.141.0.1 --discoverable=true
dryrun wwctl node add node0[2-4] --ipaddr=10.141.0.2 --discoverable=true
#dryrun wwctl overlay build
# creates debian-12.0.img
#dryrun wwctl image exec debian-12.0 '/bin/ls'

# edit allow root login editting service
#https://kb.ciq.com/article/warewulf/ww-set-root-password
dryrun wwctl image exec debian-12.0 -- /usr/bin/passwd root
# also maybe edit /etc/ssh/sshd_config to PermitRoot yes

dryrun wwctl overlay edit wwclient etc/systemd/system/wwclient.service

wwctl image exec debian-12.0 -- /usr/bin/bash -c '/usr/bin/apt update && usr/bin/apt install slurmd gdisk ignition nano && systemctl enable slurmd'
dryrun wwctl overlay build

dryrun ln -s /etc/passwd /usr/local/etc/
dryrun wwctl image syncuser debian-12 --build

## NAT network
# 20250609 -- this is unnecessary!? route through the siwtch at 10.141.255.254 instead
dryrun sysctl net.ipv4.ip_forward=1
dryrun iptables -t nat -A POSTROUTING -s 10.141.0.0/16 -o enp6s0f1 -j MASQUERADE

# access to zeus through net tag on default network profile
# post-up is a chatgpt hallucination.thought it'd end up in /etc/network/interfaces
# wwctl profile set --nettagadd post-up="ip route add 10.148.0.0/16 via 10.141.255.253" default
dryrun wwctl profile set --nettagadd route1="10.148.0.0/16,10.141.255.253" default
