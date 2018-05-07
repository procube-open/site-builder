#!/bin/bash
LOGGER=${0##*/}@{{ inventory_hostname }}
BACKUPDIR=$1

function message () {
  echo "INFO: $LOGGER:" $*
}

cd $BACKUPDIR

shopt -s expand_aliases
source ~/.bashrc
dlg-{{ inventory_hostname }}

{%  for backup_script in backup_scripts %}
# for service {{ backup_script.service }}
backup_file="backup-{{ backup_script.service }}-latest"
if [ -r $backup_file ]; then
  message "START restore for {{ backup_script.service }} from $backup_file"
  if docker exec {{ backup_script.container }} {{ backup_script.restore_command }}  < $backup_file; then
    message "END restore for {{ backup_script.service }}"
  else
    message "FAIL restore for {{ backup_script.service }}"
  fi
else
  message "SKIP restore for {{ backup_script.service }} which does not have backup-{{ backup_script.service }}-latest"
fi
{% endfor %}
