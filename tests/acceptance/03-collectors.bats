#!/usr/bin/env bats

load yaml
load error
load output
load assert

setup () {
  eval $(parse_yaml defaults/main.yml)
}

@test 'count the collectors' {
  run echo $(ls $diamond_conf_dir/collectors/*.conf | wc -l)
  grep Collector ./defaults/main.yml | wc -l | assert_output
}

@test 'CPU Collector' {
  run cat $diamond_conf_dir/collectors/CPUCollector.conf

  assert_output -p 'enabled = True'
  assert_output -p 'path_suffix ='
  assert_output -p 'ttl_multiplier = 2'
  assert_output -p 'measure_collector_time = False'
  assert_output -p 'byte_unit = byte'
  assert_output -p 'simple = True'
  assert_output -p 'normalize = False'
  assert_output -p 'percore = False'
}
