#!/usr/bin/env bats

load yaml
load error
load output
load assert

setup () {
  eval $(parse_yaml defaults/main.yml)
}

@test 'HAProxy Collector' {
  run cat $diamond_conf_dir/collectors/HAProxyCollector.conf

  assert_line "enabled = $diamond_collector_HAProxy_enabled"
  assert_line "byte_unit = $diamond_collector_HAProxy_byte_unit"
  assert_line "measure_collector_time = $diamond_collector_HAProxy_measure_collector_time"
  assert_line "ignore_servers = $diamond_collector_HAProxy_ignore_servers"
  assert_line "method = $diamond_collector_HAProxy_method"
  assert_line "pass = $diamond_collector_HAProxy_pass"
  assert_line "sock = $diamond_collector_HAProxy_sock"
  assert_line "url = $diamond_collector_HAProxy_url"
  assert_line "user = $diamond_collector_HAProxy_user"
  assert_line 'metrics_whitelist = ".*\.(this|is|sparta)"'
  refute_output -p 'metrics_blacklist'
}
