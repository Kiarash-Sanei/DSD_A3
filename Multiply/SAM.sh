#!/bin/bash

iverilog -o out SAM.v SAMTB.v DFF.v
vvp out
rm out