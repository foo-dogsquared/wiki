#!/usr/bin/env bash
set -eo pipefail

function help() {
  echo "Usage: leap.sh <year>"
}
trap 'help' ERR

if test $# -lt 1 || test $# -gt 1
then
  help && exit 1
fi

year=$1

# This is a check whether the input is a year.
# The year is expected to be an integer and printf throws an error if the specifier does not match the input.
# Pretty odd way but it is clever, don't you think?
printf "%d" $year 1>/dev/null 2>/dev/null

if test $(expr $year % 4) -eq 0
then
  if test $(expr $year % 100) -eq 0 && test $(expr $year % 400) -ne 0
    then
      echo "false"
      exit 0
  fi
  echo "true"
else echo "false"
fi
