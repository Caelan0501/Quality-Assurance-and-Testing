#!/usr/bin/env bats

@test "basic arithmetic works" {
  run bash -c "echo $((2 + 2))"
  [ "$status" -eq 0 ]
  [ "$output" -eq 4 ]
}

@test "my script runs without crashing" {
  run ./Bash_scripts/ArbritraryFile.sh
  [ "$status" -eq 0 ]
}