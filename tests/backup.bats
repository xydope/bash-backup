#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  SOURCE_DIR="$TEST_DIR/source"
  DESTINATION_DIR="$TEST_DIR/backup"
  RESTORE_DIR="$TEST_DIR/restore"

  mkdir -p "$SOURCE_DIR"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "fails when source and destination are not provided" {
  run ./backup.sh

  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "fails when source directory does not exist" {
  run ./backup.sh "$TEST_DIR/nonexistent" "$DESTINATION_DIR"

  [ "$status" -ne 0 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "creates destination directory if it does not exist" {
  run ./backup.sh "$SOURCE_DIR" "$DESTINATION_DIR"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION_DIR" ]
}

@test "backup filename contains timestamp in expected format" {
  run ./backup.sh "$SOURCE_DIR" "$DESTINATION_DIR"

  [ "$status" -eq 0 ]

  backup_file=$(find "$DESTINATION_DIR" -type f -name "*.tar.gz")

  [[ "$backup_file" =~ $(basename "$SOURCE_DIR")_[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}\.tar\.gz$ ]]
}
