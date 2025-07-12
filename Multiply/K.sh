#!/bin/bash

iverilog -o out SAM.v KTB.v DFF.v K.v 

if vvp out > "K.txt"; then
    rm out
    if grep -q "All PASS!" "K.txt"; then
        exit 0
    else
        exit 1
    fi
else
    rm -f out
    exit 1
fi