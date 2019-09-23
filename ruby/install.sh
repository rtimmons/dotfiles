#!/usr/bin/env bash

brew install rbenv
brew install ruby-build

eval "$(rbenv init -)"

rbenv install -s

rbenv rehash

gem install map_by_method
gem install what_methods
gem install pp
gem install awesome_print
gem install activesupport
gem install business_time
