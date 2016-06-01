#!/usr/bin/env bats

load yaml
load error
load output
load assert

setup () {
  eval $(parse_yaml defaults/main.yml)
}

@test 'check diamond package' {
  run rpm -q diamond-dualtec
  assert_success
}

@test 'check diamond service' {
  run systemctl status diamond
  assert_output 'system statistics collector for graphite'
}

@test 'check diamond config' {
  assert [ -e "$diamond_conf_dir/diamond.conf" ]
}
