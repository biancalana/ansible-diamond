#!/usr/bin/env bats

load yaml
load error
load output
load assert

setup () {
  eval $(parse_yaml defaults/main.yml)
}

@test 'LibvirtKVM Collector' {
  run cat $diamond_conf_dir/collectors/LibvirtKVMCollector.conf

  assert_line "enabled = $diamond_collector_LibvirtKVM_enabled"
  assert_line "path = $diamond_collector_LibvirtKVM_path"
  assert_line "ttl_multiplier = $diamond_collector_LibvirtKVM_ttl_multiplier"
  assert_line "measure_collector_time = $diamond_collector_LibvirtKVM_measure_collector_time"
  assert_line "byte_unit = $diamond_collector_LibvirtKVM_byte_unit"

  assert_line 'format_name_using_metadata = "${owner_project}_${owner_project_uuid}.${instance}_${instance_uuid}"'
}
