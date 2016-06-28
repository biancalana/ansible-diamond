#!/usr/bin/env bats

load yaml
load error
load output
load assert

setup () {
  eval $(parse_yaml defaults/main.yml)
}

@test 'Memcached Collector' {
  run cat $diamond_conf_dir/collectors/MemcachedCollector.conf

  assert_line "enabled = $diamond_collector_Memcached_enabled"
  assert_line "byte_unit = $diamond_collector_Memcached_byte_unit"
  assert_line "measure_collector_time = $diamond_collector_Memcached_measure_collector_time"
  assert_line "hosts = $diamond_collector_Memcached_hosts"
  assert_line "publish = $diamond_collector_Memcached_publish"
  assert_line 'metrics_whitelist = ".*\.(this|is|sparta)"'
  refute_output -p 'metrics_blacklist ='
}
