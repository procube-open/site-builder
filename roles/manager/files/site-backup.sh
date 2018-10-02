#!/bin/bash
HOSTSDIR=hosts.d
BACKUPDIR=backups.d
BASEDIR=$(pwd)
LOGGER=${0##*/}

function message () {
  echo "INFO: $LOGGER:" $*
}

function error () {
  echo "ERROR: $LOGGER:" $* 1>&2
  exit 1
}

mode=Backup
if [ "$#" -eq 1 -a "$1" == "-r" ]; then
  mode=Restore
elif [ "$#" -gt 1 ]; then
  error "invalid arguments $*"
fi

for hostdir in $(find $HOSTSDIR -maxdepth 1 -mindepth 1 -type d); do
  pushd $hostdir >& /dev/null
  if [ -x "do$mode" ]; then
    message "DO $mode for host ${hostdir##*/}"
    backupdir="../../backup"
    mkdir -p "$backupdir"
    if "./do$mode" "$backupdir"; then
      message "DONE $mode for host ${hostdir##*/}"
    else
      message "FAIL $mode for host ${hostdir##*/}"
    fi
  else
    message "SKIP host ${hostdir##*/} which does not have do$mode script"
  fi
  popd >& /dev/null
done
