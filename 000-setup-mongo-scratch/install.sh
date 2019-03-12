#!/usr/bin/env bash

##
# This sets up the $ZSH/mongo-scratch symlink that points to my
# home dir on the 10gen/employees dir
#   (https://github.com/10gen/employees/tree/master/home/ryan.timmons)
##

PROJECTS_HOME="$(cd "$ZSH/.."; pwd -P)"

# All projects live at the same level as the dotfiles repo
if [ ! -e "$PROJECTS_HOME/employees" ]; then
    pushd "$PROJECTS_HOME"
        git clone git@github.com:10gen/employees.git ./employees
    popd
fi

# Doesn't already exist or doesn't point to the right place
if [[ ! -e "$ZSH/mongo-scratch" || "$(readlink "$ZSH/mongo-scratch")" != "$PROJECTS_HOME/employees/home/ryan.timmons" ]]; then
    rm -f "$ZSH/mongo-scratch"
    ln -s "$PROJECTS_HOME/employees/home/ryan.timmons" "$ZSH/mongo-scratch"
fi
