# README.md
# Ansible Role: ca

Certificate Authority on openssl environment

## Role Variables

Available variables are listed below, all mandatory:

  ca_CN: ccommonName
  ca_C: countryName
  ca_EMail: emailAddress
  ca_L: localityName
  ca_O: organizationName
  ca_OU: organizationalUnitName
  ca_ST: stateOrProvinceName
  ca_valid_in: CA certificate must still be valid in valid_in seconds from now.

## Setup
need privledged

become: true

## Example Playbook
https://qiita.com/abacl7/items/f7f1e32137aafddc6683

## License

MIT
