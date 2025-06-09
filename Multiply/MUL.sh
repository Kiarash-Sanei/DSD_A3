#!/bin/bash

iverilog -o out MUL.v MULTB.v
vvp out
rm out