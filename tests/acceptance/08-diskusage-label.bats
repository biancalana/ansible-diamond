#!/usr/bin/env bats

load yaml
load error
load output
load assert

setup () {
  eval $(parse_yaml defaults/main.yml)
}

@test 'Modified DiskUsage Collector' {
  run md5sum $diamond_collectors_path/diskusage/diskusage.py

  assert_output -p "e6d96e88c2b1a6f160efb47264a1183b"
}
