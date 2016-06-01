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
  assert_output -p 'enabled = True
path_suffix =
ttl_multiplier = 2
measure_collector_time = False
byte_unit = byte
simple = True
normalize = False
percore = False'
}
