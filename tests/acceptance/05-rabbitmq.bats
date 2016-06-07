#!/usr/bin/env bats

load yaml
load error
load output
load assert

setup () {
  eval $(parse_yaml defaults/main.yml)
}

@test 'RabbitMQ Collector' {
  run cat $diamond_conf_dir/collectors/RabbitMQCollector.conf

  assert_line "enabled = $diamond_collector_RabbitMQ_enabled"
  assert_line "byte_unit = $diamond_collector_RabbitMQ_byte_unit"
  assert_line "cluster = $diamond_collector_RabbitMQ_cluster"
  assert_line "host  = $diamond_collector_RabbitMQ_host"
  assert_line "user = $diamond_collector_RabbitMQ_user"
  assert_line "password = $diamond_collector_RabbitMQ_password"
  assert_line "measure_collector_time  = $diamond_collector_RabbitMQ_measure_collector_time"
  assert_line "queues = $diamond_collector_RabbitMQ_queues"
  assert_line "queues_ignored = $diamond_collector_RabbitMQ_queues_ignored"
  assert_line "replace_dot = $diamond_collector_RabbitMQ_replace_dot"
  assert_line "replace_slash = $diamond_collector_RabbitMQ_replace_slash"
  assert_line "vhosts = $diamond_collector_RabbitMQ_vhosts"
  refute_line 'metrics_whitelist ='
  refute_line 'metrics_blacklist ='
}
