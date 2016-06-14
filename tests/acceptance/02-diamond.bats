#!/usr/bin/env bats

load yaml
load error
load output
load assert

setup () {
  eval $(parse_yaml defaults/main.yml)
  eval $(parse_yaml tests/host_vars/localhost)
}

@test 'check diamond package' {
  run rpm -q diamond-dualtec
  assert_success
}

@test 'check diamond service' {
  run systemctl status diamond

  # FIXME: skip until we can make systemctl run on Docker
  assert_output -p 'Failed to get D-Bus connection' && \
    skip 'systemctl not working in docker'

  assert_output 'system statistics collector for graphite'
}

@test 'check diamond config' {
  run cat "$diamond_conf_dir/diamond.conf"

  assert_line "instance_prefix = $diamond_instance_prefix"
}
