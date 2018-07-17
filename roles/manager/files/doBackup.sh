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
# for backup {{ backup_script.name }}
backup_file="backup-{{ backup_script.name }}-$(date +%Y%m%d%H%M%S).{{ backup_script.ext | default('tar.gz')}}"
message "START backup {{ backup_script.name }} into $backup_file"
{% if backup_script.backup_command is defined %}
  {% if backup_script.backup_file is defined %}
if docker exec {{ backup_script.container }} sh -l -c '{{ backup_script.backup_command }}' 1>&2 ; then
  docker cp {{ backup_script.container }}:{{ backup_script.backup_file }} $backup_file
  {% else %}
if docker exec {{ backup_script.container }} sh -l -c '{{ backup_script.backup_command }}' > "$backup_file"; then
  {% endif %}
{% elif backup_script.directory is defined %}
if docker exec {{ backup_script.container }} sh -l -c 'cd {{backup_script.directory}}; tar czf - $(find . -depth 1)' > "$backup_file"; then
{% endif %}
  message "END backup for {{ backup_script.name }} from $backup_file"
  message "LINK backup-{{ backup_script.name }}-latest.{{ backup_script.ext }} to $backup_file"
  rm -f "backup-{{ backup_script.name }}-latest.{{ backup_script.ext }}"
  ln -s "$backup_file" "backup-{{ backup_script.name }}-latest.{{ backup_script.ext }}"
else
  message "FAIL backup for host {{ backup_script.name }}"
fi

{% endfor %}
