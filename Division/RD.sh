#!/bin/bash

iverilog -o out RD.v RDTB.v
vvp out
rm out 