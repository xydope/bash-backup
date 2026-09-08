#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  SOURCE_DIR="$TEST_DIR/source"
  BACKUP_FILE="$TEST_DIR/backup.tar.gz"
  RESTORE_DIR="$TEST_DIR/restore"

  mkdir -p "$SOURCE_DIR"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "backup succeeds with valid arguments" {
  run ./backup.sh "$SOURCE_DIR" "$BACKUP_FILE"

  [ "$status" -eq 0 ]
}

@test "backup fails when source directory does not exist" {
  run ./backup.sh "$TEST_DIR/nonexistent" "$BACKUP_FILE"

  [ "$status" -ne 0 ]
}

@test "backup fails when no arguments are provided" {
  run ./backup.sh

  [ "$status" -ne 0 ]
}

@test "backup file is created" {
  run ./backup.sh "$SOURCE_DIR" "$BACKUP_FILE"

  [ "$status" -eq 0 ]
  [ -f "$BACKUP_FILE" ]
}

@test "backup contains source file" {
  echo "Hello from backup test" > "$SOURCE_DIR/hello.txt"

  run ./backup.sh "$SOURCE_DIR" "$BACKUP_FILE"

  [ "$status" -eq 0 ]

  mkdir -p "$RESTORE_DIR"
  tar -xzf "$BACKUP_FILE" -C "$RESTORE_DIR"

  [ -f "$RESTORE_DIR/hello.txt" ]
}

@test "backup preserves file content" {
  echo "Hello from backup test" > "$SOURCE_DIR/hello.txt"

  run ./backup.sh "$SOURCE_DIR" "$BACKUP_FILE"

  [ "$status" -eq 0 ]

  mkdir -p "$RESTORE_DIR"
  tar -xzf "$BACKUP_FILE" -C "$RESTORE_DIR"

  [ "$(cat "$RESTORE_DIR/hello.txt")" = "Hello from backup test" ]
}

@test "backup handles empty directory" {
  run ./backup.sh "$SOURCE_DIR" "$BACKUP_FILE"

  [ "$status" -eq 0 ]
  [ -f "$BACKUP_FILE" ]
}

@test "backup contains multiple files" {
  echo "File 1" > "$SOURCE_DIR/file1.txt"
  echo "File 2" > "$SOURCE_DIR/file2.txt"
  echo "File 3" > "$SOURCE_DIR/file3.txt"

  run ./backup.sh "$SOURCE_DIR" "$BACKUP_FILE"

  [ "$status" -eq 0 ]

  mkdir -p "$RESTORE_DIR"
  tar -xzf "$BACKUP_FILE" -C "$RESTORE_DIR"

  [ -f "$RESTORE_DIR/file1.txt" ]
  [ -f "$RESTORE_DIR/file2.txt" ]
  [ -f "$RESTORE_DIR/file3.txt" ]
}
