#!/usr/bin/env bash

set -eou pipefail

sudo mkdir /usr/local/devbox
sudo chown rtimmons:staff /usr/local/devbox

wget "https://get.jetpack.io/devbox"
# change
# readonly INSTALL_DIR="/usr/local/devbox/bin"

# something-something sonos setup went weird
sudo /usr/bin/dscl . -delete /Users/SonosDMS

wget "https://nixos.org/nix/install"
chmod +x ./install
./install



nix-shell -p nix-info --run "nix-info -m"


# Setting up a project
mkdir some_project
devbox init
devbox add llvm
