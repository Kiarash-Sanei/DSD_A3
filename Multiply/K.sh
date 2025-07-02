#!/bin/bash

iverilog -o out SAM.v KTB.v DFF.v K.v ../Adder/CSA.v ../Adder/FA.v ../Adder/HF.v ../Adder/A.v ../Adder/M.v ../Adder/SM.v
vvp out
rm out