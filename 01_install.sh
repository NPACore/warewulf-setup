#!/usr/bin/env bash
#
# intended to be run on debian based 'head' node
#
# 1. get golang if needed
# 2. install warewulf from source
#

command -v  go ||
  apt install \
    build-essential curl unzip \
    git golang libnfs-utils libgpgme-dev libassuan-dev

# update go
if ! [[ $(go version) =~ 1.23.9 ]] ; then 
   go install golang.org/dl/go1.23.9@latest
   export PATH="$HOME/go/bin:$PATH"
   ln -fs $HOME/go/bin/go1.23.9 $HOME/go/bin/go
   go download
fi

# get warewulf
if ! test -d warewulf; then
   git clone https://github.com/warewulf/warewulf.git
   cd warewulf
   git checkout main
   make all && make install
fi

# config, only if out of date
make /usr/local/etc/warewulf/warewulf.conf
# start
systemctl enable --now warewulfd
