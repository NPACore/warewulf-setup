#!/usr/bin/env bash
# 20250608WF - supermicro IPMI reset via ssh/SMASH command
[[ $* =~ ^-|help ]] && echo "USAGE: $0 1 # reset node 1" && exit 0
! [[ "$1" =~ ^[1-9]$ ]] && echo "ERRO first arg must be a node number 1 to 9" && exit 1
echo 'reset /system1/pwrmgtsvc1' |
  sshpass -p ADMIN ssh  \
    -o KexAlgorithms=+diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa  \
    ADMIN@10.148.0.${1}
