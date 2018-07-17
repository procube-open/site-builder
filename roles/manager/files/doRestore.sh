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
# for restore {{ backup_script.name }}
backup_file="backup-{{ backup_script.name }}-latest.{{ backup_script.ext | default('tar.gz') }}"
if [ -r $backup_file ]; then
{% if backup_script.restore_command is defined %}
  message "START restore for {{ backup_script.name }} from $backup_file"
  {% if backup_script.restore_file is defined %}
  docker cp $backup_file {{ backup_script.container }}:{{ backup_script.restore_file }} $backup_file
  if docker exec {{ backup_script.container }} {{ backup_script.restore_command }}  ; then
  {% else %}
  if docker exec {{ backup_script.container }} {{ backup_script.restore_command }}  < $backup_file; then
  {% endif %}
{% elif backup_script.directory is defined %}
  if docker exec {{ backup_script.container }} sh -l -c 'cd {{backup_script.directory}}; rm -rf $(find . -depth 1); tar xzf -' < "$backup_file"; then
{% endif %}
    message "END restore for {{ backup_script.name }}"
  else
    message "FAIL restore for {{ backup_script.name }}"
  fi
else
  message "SKIP restore for {{ backup_script.name }} which does not have backup-{{ backup_script.name }}-latest"
fi
{% endfor %}
