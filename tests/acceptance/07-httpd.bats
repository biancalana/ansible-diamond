#!/usr/bin/env bats

load yaml
load error
load output
load assert

setup () {
  eval $(parse_yaml defaults/main.yml)
}

@test 'Httpd Collector' {
  run cat $diamond_conf_dir/collectors/HttpdCollector.conf

  assert_line "enabled = $diamond_collector_Httpd_enabled"
  assert_line "byte_unit = $diamond_collector_Httpd_byte_unit"
  assert_line "measure_collector_time = $diamond_collector_Httpd_measure_collector_time"
  assert_line 'urls = "localhost, otherhost"'
  assert_line 'metrics_whitelist = ".*\.(this|is|sparta)"'
  refute_output -p 'metrics_blacklist ='
}
