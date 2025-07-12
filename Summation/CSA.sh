#!/bin/bash

iverilog -o out CSA.v FA.v HF.v A.v M.v SM.v CSATB.v

if vvp out > "CSA.txt"; then
    rm out
    if grep -q "All PASS!" "CSA.txt"; then
        exit 0
    else
        exit 1
    fi
else
    rm -f out
    exit 1
fi