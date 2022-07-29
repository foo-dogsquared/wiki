#/usr/bin/env bash
n=$1
valid=0
function is_factor {
    local factor=$1
    shift

    local msg=$@

    [[ $(( $n % $factor )) -eq 0 ]] && printf $msg && valid=1
}

is_factor 3 "Pling"
is_factor 5 "Plang"
is_factor 7 "Plong"

[[ $valid -eq 0 ]] && echo $n || printf '\n'
