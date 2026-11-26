#!/bin/bash

# Day 14: System Metrics - Print CPU, Memory, Disk

echo "=========================================="
echo "       PATHNEX SYSTEM HEALTH REPORT       "
echo "=========================================="
echo "Timestamp: $(date)"
echo ""

echo "--- [1] CPU Metrics ---"
if command -v top &>/dev/null; then
    top -bn1 | grep "Cpu(s)" || uptime
else
    uptime
fi
echo ""

echo "--- [2] Memory Usage ---"
if command -v free &>/dev/null; then
    free -h
else
    echo "free command unavailable"
fi
echo ""

echo "--- [3] Disk Usage ---"
df -h /
echo "=========================================="

