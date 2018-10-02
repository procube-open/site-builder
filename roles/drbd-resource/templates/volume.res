resource {{ item.name }} {
  device    {{ item.device }};
  disk      {{ drbd_resource.disk }};
  meta-disk internal;
{% for host in groups[item.group] %}
  on {{ host }} {
    address   {{ hostvars[host].private_ip }}:{{ item.port }};
  }
{% endfor %}
  connection-mesh {
    hosts {{ groups[item.group] | join(' ') }};
    net {
        use-rle no;
    }
  }
}