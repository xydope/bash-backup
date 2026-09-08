#!/bin/bash

usage() {
  echo "Usage: $0 <source_directory> <destination_directory>"
  echo
  echo "Create a compressed backup archive of a directory."
  echo
  echo "Arguments:"
  echo "  source_directory       Directory to backup"
  echo "  destination_directory  Directory where the backup archive will be stored"
  echo
  echo "Example:"
  echo "  $0 ~/data ~/backups"
}

SOURCE_DIR="$1"
DESTINATION_DIR="$2"

if [[ "$SOURCE_DIR" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! $# -eq 2 ]]; then
  usage
  exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Error: Source directory '$SOURCE_DIR' does not exist."
  exit 1
fi

if ! mkdir -p "$DESTINATION_DIR" 2> /dev/null; then
  echo "Error: Failed to create destination directory '$DESTINATION_DIR'."
  exit 1
fi

bkp_filename="$(basename "$SOURCE_DIR")_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"

if ! tar -czf "$DESTINATION_DIR/$bkp_filename" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" &> /dev/null; then
  echo "Error: Failed to create backup archive '$DESTINATION_DIR/$bkp_filename'."
  exit 1
fi

echo "Backup completed successfully: $DESTINATION_DIR/$bkp_filename"
