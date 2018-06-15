# README.md
# Ansible Role: Kine

Docker registry with web frontend on docker swarm environment Dango.

## Requirements

- Dango cluster Environment

## Role Variables

Available variables are listed below, along with default values:

    registry_size  : size of local docker repository.(default:3000)
    registry_port : port number of docker repository.(default:5000)
    registry_frontend_port : port number of docker repository frontend.(default:80)

## Dependencies

Dango

## Example Playbook

--
- name: "build registry server on Dango cluster site"
  hosts: all
  become: yes
  vars_files:
    - vars.yml

  roles:
    - dango
    - registry

## License

MIT
