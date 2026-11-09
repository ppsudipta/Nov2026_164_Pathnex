#!/bin/bash

# Day 09: Check CPU Load
LOAD=$(uptime | awk '{print $10}')

echo "Current CPU Load: $LOAD"
