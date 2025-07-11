#!/bin/bash

iverilog -o out RD.v RDTB.v ../Multiply/DFF.v

if vvp out > "RD.txt"; then
    rm out
    if grep -q "All PASS!" "RD.txt"; then
        exit 0
    else
        exit 1
    fi
else
    rm -f out
    exit 1
fi
