#!/bin/bash

iverilog -o out \
    ../Control.Unit/CU.v \
    ../Register/RF.v \
    ../Memory/M.v \
    ../Arithmetic.and.Logical.Unit/ALU.v \
    ../Summation/CSA.v \
    ../Summation/A.v \
    ../Summation/FA.v \
    ../Summation/HF.v \
    ../Summation/M.v \
    ../Summation/SM.v \
    ../Multiply/K.v \
    ../Multiply/SAM.v \
    ../Division/RD.v \
    D.v \
    DTB.v

if vvp out > "D.txt"; then
    rm out
    if grep -q "All Tests PASSED!" "D.txt"; then
        exit 0
    else
        exit 1
    fi
else
    rm -f out
    exit 1
fi 