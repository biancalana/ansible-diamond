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
  assert_success
}

@test 'DiskUsage Collector' {
  run cat $diamond_conf_dir/collectors/DiskUsageCollector.conf
  assert_success
}

@test 'LoadAverage Collector' {
  run cat $diamond_conf_dir/collectors/LoadAverageCollector.conf
  assert_success
}

@test 'Network Collector' {
  run cat $diamond_conf_dir/collectors/NetworkCollector.conf
  assert_success
}

@test 'Memory Collector' {
  run cat $diamond_conf_dir/collectors/MemoryCollector.conf
  assert_success
}

@test 'VMStat Collector' {
  run cat $diamond_conf_dir/collectors/VMStatCollector.conf
  assert_success
}
