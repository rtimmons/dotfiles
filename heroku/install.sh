#!/usr/bin/env bash

set -euo pipefail

brew trust --formula heroku/brew/heroku
brew tap heroku/brew
brew install --quiet heroku/brew/heroku
