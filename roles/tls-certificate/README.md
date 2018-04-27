# README.md
# Ansible Role: ca

 TLS Server Certificate

## Role Variables

Available variables are listed below, along with default values:

target_CN: commonName
target_C: countryName
target_EMail: emailAddress
target_L: localityName
target_O: organizationName
target_OU: organizationalUnitName
target_ST: stateOrProvinceName
target_FQDN: FQDN
target_IP: IP
target_valid_in: certificate must still be valid in valid_in seconds from now.

## Setup
need privledged

become: true

## Example Playbook
https://qiita.com/abacl7/items/f7f1e32137aafddc6683

## License

MIT
