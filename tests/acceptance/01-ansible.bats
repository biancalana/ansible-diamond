#!/usr/bin/env bats

load error
load output
load assert

setup() {
  export PLAYBOOK=tests/test.yml
  export INVENTORY=tests/inventory
}

@test 'playbook syntax' {
  run ansible-playbook-wrapper --syntax-check
  assert_success
}

@test 'check playbook execution' {
  run ansible-playbook-wrapper
  assert_success
}

@test 'check playbook idempotence' {
  run ansible-playbook-wrapper
  assert_success
  assert_output -e 'changed=0.*failed=0'
}
