#!/usr/bin/env bats

setup() {
  export PLAYBOOK=tests/test.yml
  export INVENTORY=tests/inventory
}

@test 'check playbook syntax' {
  run ansible-playbook-wrapper --syntax-check
}

@test 'run ansible' {
  run ansible-playbook-wrapper
}

@test 'check playbook idempotence' {
  run ansible-playbook-wrapper
  echo "$output" | grep -q 'changed=0.*failed=0'
}
