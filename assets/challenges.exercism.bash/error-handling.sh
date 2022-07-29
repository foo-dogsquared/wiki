#/usr/bin/env bash
function help() {
    echo "Usage: error_handling.sh <person>"
}

if test ! $# -eq 1; then
    help && exit 1
fi

echo "Hello, $1"
