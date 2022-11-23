#!/usr/bin/env bash
n=$1
valid=0
function is_factor {
    local factor=$1 msg=$2

    (( n % factor == 0 )) && printf $msg && valid=1
}

is_factor 3 "Pling"
is_factor 5 "Plang"
is_factor 7 "Plong"

(( valid == 0 )) && echo $n || printf '\n'
