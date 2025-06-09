#!/bin/bash

iverilog -o out CSA.v FA.v HF.v A.v M.v SM.v CSATB.v
vvp out
rm out