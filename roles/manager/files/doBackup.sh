#!/bin/bash
LOGGER=${0##*/}@{{ inventory_hostname }}
BACKUPDIR=${1:-$HOME/backup}

function message () {
  echo "INFO: $LOGGER:" $*
}

cd $BACKUPDIR
export DOCKER_TLS_VERIFY=1

{%  for backup_script in backup_scripts %}
export DOCKER_HOST=tcp://{{ inventory_hostname }}:2376
{% if backup_script.service is defined %}
container_name=$(docker service ps {{ backup_script.service }}_{{ backup_script.container }} --format {% raw %}"{{.Name}}.{{.ID}}"{% endraw %} --filter desired-state=running --no-trunc | head -1)
export DOCKER_HOST=$(docker service ps {{ backup_script.service }}_{{ backup_script.container }} --format {% raw %}"{{.Node}}"{% endraw %} --filter desired-state=running --no-trunc | head -1):2376
if [ -z "$container_name" ]; then
  message "NO Process for service: {{ backup_script.service }}_{{ backup_script.container }}, so skip it."
else

{% else %}
container_name={{ backup_script.container }}
{% endif %}
message "ENTER CONTANER $container_name@$DOCKER_HOST"
{% if backup_script.batch_scripts is defined %}
  {% for batch_script in backup_script.batch_scripts %}
message "START batch: {{ batch_script }}"
if docker exec $container_name sh -l -c '{{ batch_script }}' 1>&2 ; then
  message "END batch: {{ batch_script }}"
else
  message "FAIL batch: {{ batch_script }}"
fi
  {% endfor %}
{% endif %}
{% if backup_script.backup_command is defined or  backup_script.directory is defined %}
# for backup {{ backup_script.name }}
backup_file="backup-{{ backup_script.name }}-$(date +%Y%m%d%H%M%S).{{ backup_script.ext | default('tar.gz')}}"
message "START backup {{ backup_script.name }} into $backup_file"
  {% if backup_script.backup_command is defined %}
    {% if backup_script.backup_file is defined %}
if docker exec $container_name sh -l -c '{{ backup_script.backup_command }}' 1>&2 ; then
  docker cp $container_name:{{ backup_script.backup_file }} $backup_file
    {% else %}
if docker exec $container_name sh -l -c '{{ backup_script.backup_command }}' > "$backup_file"; then
    {% endif %}
  {% elif backup_script.directory is defined %}
if docker exec $container_name sh -l -c 'cd {{backup_script.directory}}; tar czf - $(find . -maxdepth 1 | grep -v '^.$')' > "$backup_file"; then
  {% endif %}
  message "END backup for {{ backup_script.name }} from $backup_file"
  message "LINK backup-{{ backup_script.name }}-latest.{{ backup_script.ext | default('tar.gz')}} to $backup_file"
  rm -f "backup-{{ backup_script.name }}-latest.{{ backup_script.ext | default('tar.gz')}}"
  ln -s "$backup_file" "backup-{{ backup_script.name }}-latest.{{ backup_script.ext | default('tar.gz')}}"
else
  message "FAIL backup for host {{ backup_script.name }}"
fi
{% endif %}
message "LEAVE CONTANER $container_name@$DOCKER_HOST"
{% if backup_script.service is defined %}
fi
{% endif %}
{% endfor %}
