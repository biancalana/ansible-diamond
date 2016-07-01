#!/usr/bin/env bats

load yaml
load error
load output
load assert

setup () {
  eval $(parse_yaml defaults/main.yml)
}

@test 'Redis Collector' {
  run cat $diamond_conf_dir/collectors/RedisCollector.conf
  assert_success

  assert_line "enabled = $diamond_collector_Redis_enabled"
  assert_line "byte_unit = $diamond_collector_Redis_byte_unit"
  assert_line "measure_collector_time = $diamond_collector_Redis_measure_collector_time"
  assert_line "auth = $diamond_collector_Redis_auth"
  assert_line "databases = $diamond_collector_Redis_databases"
  assert_line "db = $diamond_collector_Redis_db"
  assert_line "host = $diamond_collector_Redis_host"
  assert_line "port = $diamond_collector_Redis_port"
  assert_line "timeout = $diamond_collector_Redis_timeout"
  assert_line 'instances = nick1@host:port, nick2@:port, nick3@host'
  assert_line 'metrics_whitelist = ".*\.(this|is|sparta)"'
  refute_output -p 'metrics_blacklist ='
}
