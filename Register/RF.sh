#!/bin/bash

iverilog -o out RF.v RFTB.v

if vvp out > "RF.txt"; then
    rm out
    if grep -q "All PASS!" "RF.txt"; then
        exit 0
    else
        exit 1
    fi
else
    rm -f out
    exit 1
fi 