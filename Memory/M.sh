#!/bin/bash

iverilog -o out M.v MTB.v

if vvp out > "M.txt"; then
    rm out
    if grep -q "All PASS!" "M.txt"; then
        exit 0
    else
        exit 1
    fi
else
    rm -f out
    exit 1
fi 