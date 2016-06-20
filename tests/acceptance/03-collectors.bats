#!/usr/bin/env bats

load yaml
load error
load output
load assert

setup () {
  eval $(parse_yaml defaults/main.yml)
}

@test 'CPU Collector' {
  run cat $diamond_conf_dir/collectors/CPUCollector.conf

  assert_output -p 'enabled = True'
  assert_output -p "path_suffix = $diamond_collector_CPU_path_suffix"
  assert_output -p "ttl_multiplier = $diamond_collector_CPU_ttl_multiplier"
  assert_output -p "measure_collector_time = $diamond_collector_CPU_measure_collector_time"
  assert_output -p "byte_unit = $diamond_collector_CPU_byte_unit"
  assert_output -p "simple = $diamond_collector_CPU_simple"
  assert_output -p "normalize = $diamond_collector_CPU_normalize"
  assert_output -p "percore = $diamond_collector_CPU_percore"
}

@test 'DiskSpace Collector' {
  run cat $diamond_conf_dir/collectors/DiskSpaceCollector.conf
  assert_line 'filesystems = this, is, sparta'
}

@test 'DiskUsage Collector' {
  run cat $diamond_conf_dir/collectors/DiskUsageCollector.conf
  assert_line 'metrics_whitelist = ".*\.(this|is|sparta)$"'
}

@test 'LoadAverage Collector' {
  run cat $diamond_conf_dir/collectors/LoadAverageCollector.conf
  assert_success
}

@test 'Network Collector' {
  run cat $diamond_conf_dir/collectors/NetworkCollector.conf
  assert_line 'metrics_whitelist = ".*\.(this|is|sparta)$"'
}

@test 'Memory Collector' {
  run cat $diamond_conf_dir/collectors/MemoryCollector.conf
  assert_line 'metrics_whitelist = ".*(this|is|sparta)"'
}

@test 'VMStat Collector' {
  run cat $diamond_conf_dir/collectors/VMStatCollector.conf
  assert_success
}
