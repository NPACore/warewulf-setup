apt install \
  build-essential curl unzip \
  git golang libnfs-utils libgpgme-dev libassuan-dev

# update go
go install golang.org/dl/go1.23.9@latest
export PATH="$HOME/go/bin:$PATH"
ln -fs $HOME/go/bin/go1.23.9 $HOME/go/bin/go
go download

test -d warewulf || git clone https://github.com/warewulf/warewulf.git
cd warewulf
git checkout main
make all && make install
