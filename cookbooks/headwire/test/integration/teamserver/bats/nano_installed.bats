#!/usr/bin/env bats

@test "nano binary is found in PATH" {
  run which nano
  [ "$status" -eq 0 ]
}

