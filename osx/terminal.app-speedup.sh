#!/usr/bin/env bash

# `login` on Terminal.app got you down?
# This speeds things up like you wouldn't believe.

# http://osxdaily.com/2010/05/06/speed-up-a-slow-terminal-by-clearing-log-files/

sudo rm -rf /private/var/log/asl/*.asl

