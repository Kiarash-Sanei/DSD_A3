#!/bin/bash

iverilog -o out SAM.v SAMTB.v

if vvp out > "SAM.txt"; then
    rm out
    if grep -q "All PASS!" "SAM.txt"; then
        exit 0
    else
        exit 1
    fi
else
    rm -f out
    exit 1
fi