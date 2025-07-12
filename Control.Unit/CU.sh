#!/bin/bash

iverilog -o out CU.v CUTB.v

if vvp out > "CU.txt"; then
    rm out
    if grep -q "All PASS!" "CU.txt"; then
        exit 0
    else
        exit 1
    fi
else
    rm -f out
    exit 1
fi 