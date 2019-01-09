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
{% if backup_script.backup_command is defined or  backup_script.directory is defined %}
# for restore {{ backup_script.name }}
backup_file="backup-{{ backup_script.name }}-latest.{{ backup_script.ext | default('tar.gz') }}"
if [ -r $backup_file ]; then
  message "START restore for {{ backup_script.name }} from $backup_file"
  {% if backup_script.restore_command is defined %}
    {% if backup_script.restore_file is defined %}
  docker cp -L $backup_file $container_name:{{ backup_script.restore_file }}
  if docker exec $container_name sh -c '{{ backup_script.restore_command }}'  ; then
    {% else %}
  if docker exec -i $container_name sh -c '{{ backup_script.restore_command }}'  < $backup_file; then
    {% endif %}
  {% elif backup_script.directory is defined %}
  docker cp -L $backup_file {{ backup_script.container }}:/tmp/restore.tar.gz
  if docker exec $container_name sh -c 'cd {{backup_script.directory}}; rm -rf $(find . -maxdepth 1 | grep -v '^.$'); tar xzf /tmp/restore.tar.gz'; then
  {% endif %}
    message "END restore for {{ backup_script.name }}"
  else
    message "FAIL restore for {{ backup_script.name }}"
  fi
else
  message "SKIP restore for {{ backup_script.name }} which does not have backup-{{ backup_script.name }}-latest"
fi
{% endif %}
message "LEAVE CONTANER $container_name@$DOCKER_HOST"
{% if backup_script.service is defined %}
fi
{% endif %}
{% endfor %}
