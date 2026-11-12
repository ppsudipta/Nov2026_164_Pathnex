#!/bin/bash

# Day 12: Backup Directory
SOURCE="/var/log"
DEST="/backup/pathnex-$(date +%F).tar.gz"

mkdir -p /backup 2>/dev/null || true
tar -czf "$DEST" "$SOURCE" 2>/dev/null || tar -czf "$DEST" "$SOURCE"
echo "Backup created at: $DEST"
