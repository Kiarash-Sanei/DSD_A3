#!/bin/bash

iverilog -o out ../Summation/CSA.v ../Summation/A.v ../Summation/FA.v ../Summation/HF.v ../Summation/M.v ../Summation/SM.v ../Multiply/K.v ../Multiply/SAM.v ../Division/RD.v ALU.v ALUTB.v

if vvp out > "ALU.txt"; then
    rm out
    if grep -q "All PASS!" "ALU.txt"; then
        exit 0
    else
        exit 1
    fi
else
    rm -f out
    exit 1
fi 