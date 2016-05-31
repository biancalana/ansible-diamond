#!/usr/bin/env bats

setup() {
  export PLAYBOOK=tests/test.yml
  export INVENTORY=tests/inventory
}

@test 'check playbook syntax' {
  ansible-playbook-wrapper --syntax-check
}

@test 'run ansible' {
  ansible-playbook-wrapper
}

@test 'check playbook idempotence' {
  ansible-playbook-wrapper | grep -q 'changed=0.*failed=0'
}
