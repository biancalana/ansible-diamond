#!/usr/bin/env bats

load yaml
load error
load output
load assert

setup () {
  eval $(parse_yaml defaults/main.yml)
}

@test 'Ceph Collector' {
  run cat $diamond_conf_dir/collectors/CephCollector.conf

  assert_line "enabled = $diamond_collector_Ceph_enabled"
  assert_line "path_suffix = $diamond_collector_Ceph_path_suffix"
  assert_line "ttl_multiplier = $diamond_collector_Ceph_ttl_multiplier"
  assert_line "measure_collector_time = $diamond_collector_Ceph_measure_collector_time"
  assert_line "byte_unit = $diamond_collector_Ceph_byte_unit"
  assert_line "ceph_binary = $diamond_collector_Ceph_ceph_binary"
  assert_line "socket_ext = $diamond_collector_Ceph_socket_ext"
  assert_line "socket_path = $diamond_collector_Ceph_socket_path"
  assert_line "socket_prefix = $diamond_collector_Ceph_socket_prefix"
  assert_line 'metrics_whitelist = "(filestore.journal_latency|filestore.journal_queue_bytes|filestore.journal_queue_ops|osd.op_latency|osd.op_r|osd.op_w|osd.recovery_ops)"'
}

@test 'CephStats Collector' {
  run cat $diamond_conf_dir/collectors/CephStatsCollector.conf

  assert_line "enabled = $diamond_collector_CephStats_enabled"
  assert_line "path_suffix = $diamond_collector_CephStats_path_suffix"
  assert_line "ttl_multiplier = $diamond_collector_CephStats_ttl_multiplier"
  assert_line "measure_collector_time = $diamond_collector_CephStats_measure_collector_time"
  assert_line "byte_unit = $diamond_collector_CephStats_byte_unit"
  assert_line "ceph_binary = $diamond_collector_CephStats_ceph_binary"
  assert_line "socket_ext = $diamond_collector_CephStats_socket_ext"
  assert_line "socket_path = $diamond_collector_CephStats_socket_path"
  assert_line "socket_prefix = $diamond_collector_CephStats_socket_prefix"
  refute_output -p 'metrics_whitelist ='
}
