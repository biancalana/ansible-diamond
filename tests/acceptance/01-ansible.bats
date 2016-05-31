#!/usr/bin/env bats

load error
load output
load assert

setup() {
  export PLAYBOOK=tests/test.yml
  export INVENTORY=tests/inventory
}

teardown() {
  service diamond stop
}

@test 'check playbook syntax' {
  run ansible-playbook-wrapper --syntax-check
}

@test 'check playbook idempotence' {
  run ansible-playbook-wrapper
  echo "$output" | grep -q 'changed=0.*failed=0'
}
