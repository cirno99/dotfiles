#!/usr/bin/env bash

USAGE=$(df --output=avail --block-size=1M $HOME | tail -n 1 | tr -d ' ')

df -h --output=avail $HOME | tail -n 1 | tr -d ' '

printf "\n"

if (( $USAGE < 1024 )); then
  printf "critical"
elif (( $USAGE < 5120 )); then
  printf "warning"
fi

