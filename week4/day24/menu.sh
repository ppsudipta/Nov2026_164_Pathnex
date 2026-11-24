#!/bin/bash

echo "1) Show date"
echo "2) Show uptime"
echo "3) Show users"

read -p "Choose option: " opt

case $opt in
  1) date ;;
  2) uptime ;;
  3) who ;;
  *) echo "Invalid choice" ;;
esac
