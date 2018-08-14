# README.md
# Ansible Role: Dango

Build docker swarm mode and drbd9+drbdmanage cluster on Centos 7.x

## Requirements

- more than 3 servers
- CentOS or RHEL 7.x
- permit ssh logon as root

## Tags for partial execution

Available tags to process partial are listed below.

    install : install software
    build_cluster : building cluster

## Tags for skip
Available tags to skip tasks are listed below.

    iptables : setup /etc/sysconfig/iptables
    ssh_root : setup ssh config for drbdmanage add-node
    reboot, reboot2 : reboot all server
    setup_etc_hosts : edit /etc/hosts for ip address of host

## Role Variables

Available variables are listed below, along with default values:

    private_ip : IP adrress which can be used to communiate with another cluster node(host specifc, mandatory)
    reboot_delay : timeout in second for waiting ssh port avilable after reboot (default:20)
    drbd_device_name : device name for drbd resource pool(default:/dev/sdb)
    drbd_device_number : device number for drbd resource pool(default:1)
    ntp_servers : ntp servers fqdn list (default is chrony default)

### for image builder
#### global
    registry_size  : size of local docker repository(default:3000)

## Dependencies

## Example Playbook

--
- name: "build Dango cluster site"
  hosts: all
  become: yes
  vars_files:
    - vars.yml

  roles:
    - dango

## License

MIT
