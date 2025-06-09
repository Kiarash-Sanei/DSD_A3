#!/bin/bash

iverilog -o out N.v TC.v TCTB.v CSA.v FA.v HF.v A.v M.v SM.v
vvp out
rm out