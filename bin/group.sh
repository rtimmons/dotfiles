#!/bin/bash

##
# Add new users to a group in Mac OS X.
# 
# Adds a user (or many users) to an existing group in NetInfo
##

usage ()
{
  echo "Add a user (or several users) to an existing group"
  echo "Usage: ${0##*/} group user [user...]"
  if [ "$*" != "" ]; then echo "  Error: $*"; fi
  exit 1
}




# Ensure user is root
#
if [ "$USER" != "root" ]; then
  echo "Must be run as root."
  exit 1
fi




# Check parameters
#
if [ $# -lt 2 ]; then
  usage
fi


group=$1


# search NetInfo for the given group - it should exist
str="$(nireport . /groups name | grep -w "$group")"
if [ -z "$str" ]; then
  usage "Group $group does not exist"
fi


# get the group number from the name
gid="$(nireport . /groups gid name | grep "$group" | cut -f 1)"


# Drop the group and loop thro' additional parameters (users) to add to group
#
shift


for user in "$@"; do
  # check if the user exists
  struser="$(nireport . /users name | grep -w "$user")"
  # check if the user already belongs to the group
  stringroup=$(nireport . /groups name users | grep -w "${group}[[:space:]].*$user")
  # check if this is the user's primary group
  strprimary=$(nireport . /users name gid | grep -w "${user}[[:space:]].*$gid")

 
  #echo "user $struser, ingroup $stringroup, primary $strprimary"


  # ensure that the user exists...
  if [ -z "$struser" ]; then
    echo "User $user does not exist"
  # ...and does not already belong to the group...
  elif [ -n "$stringroup" ]; then
    echo "User $user already belongs to group $group - not added again"
  # ...and this is not the user's primary group
  elif [ -n "$strprimary" ]; then
    echo "This is the user's primary group - not added"
  else
    # add user to the group
    dscl . merge "/groups/$group" users "$user" 
    echo "$user added to group $group"
  fi
done


exit 0
