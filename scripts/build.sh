#!/bin/bash
# Build all io_uring .mojopkg files.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_DIR"

echo "Removing stale .mojopkg files..."
rm -f *.mojopkg

echo "Building linux_raw..."
mojo package linux_raw -o linux_raw.mojopkg

echo "Building mojix..."
mojo package mojix -o mojix.mojopkg

echo "Building io_uring..."
mojo package io_uring -o io_uring.mojopkg

echo "Building event_loop..."
mojo package event_loop -o event_loop.mojopkg

echo "All packages built."
ls -lh *.mojopkg
