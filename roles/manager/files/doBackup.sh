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
backup_file="backup-{{ backup_script.service }}-$(date +%Y%m%d%H%M%S).{{ backup_script.ext }}"
message "START backup {{ backup_script.service }} into $backup_file"
if docker exec {{ backup_script.container }} {{ backup_script.backup_command }} > "$backup_file"; then
  message "END backup for {{ backup_script.service }} from $backup_file"
  message "LINK backup-{{ backup_script.service }}-latest to $backup_file"
  rm -f "backup-{{ backup_script.service }}-latest"
  ln -s "$backup_file" "backup-{{ backup_script.service }}-latest"
else
  message "FAIL backup for host {{ backup_script.service }}"
fi

{% endfor %}
