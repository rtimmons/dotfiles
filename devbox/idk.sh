#!/usr/bin/env bash

set -eou pipefail

sudo mkdir "${BREW_PREFIX}/../devbox"
sudo chown "$(whoami)":staff "${BREW_PREFIX}/../devbox"

wget "https://get.jetpack.io/devbox"
chmod +x ./devbox
# change to
# readonly INSTALL_DIR="/usr/local/devbox/bin"
#    OR
# readonly INSTALL_DIR="/opt/devbox/bin"

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
