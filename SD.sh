#!/bin/bash

echo "=== Synthesizing Datapath Module D.v ==="

cat > SD.ys << 'EOF'
# Read all Verilog files
read_verilog ./Control.Unit/CU.v
read_verilog ./Register/RF.v
read_verilog ./Memory/M.v
read_verilog ./Arithmetic.and.Logical.Unit/ALU.v
read_verilog ./Summation/CSA.v
read_verilog ./Summation/A.v
read_verilog ./Summation/FA.v
read_verilog ./Summation/HF.v
read_verilog ./Summation/M.v
read_verilog ./Summation/SM.v
read_verilog ./Multiply/K.v
read_verilog ./Multiply/SAM.v
read_verilog ./Multiply/DFF.v
read_verilog ./Division/RD.v
read_verilog ./Datapath/D.v

# Elaborate the top module
hierarchy -top D

# Check for errors
check

# Generate statistics before synthesis
stat

# Synthesize to generic gates
synth -top D

# Optimize the design
opt

# Generate statistics after synthesis
stat

# Write the synthesized netlist
write_verilog SD.v

# Write JSON format for further processing
write_json SD.json

# Generate a simple report
tee -o R.txt << 'REPORT'
=== Datapath Synthesis Report ===
Top Module: D
Synthesis Tool: Yosys
Date: $(date)

Module Hierarchy:
- D (top)
  - CU (Control Unit)
  - RF (Register File)
  - M (Memory)
  - ALU (Arithmetic Logic Unit)
    - CSA (Carry Save Adder)
    - K (Multiplier)
    - RD (Divider)

The synthesis has been completed successfully.
Check SD.v for the synthesized netlist.
Check SD.json for JSON format.
REPORT
EOF

if yosys SD.ys; then
    echo "✅ Synthesis completed successfully!"
    echo "📁 Generated files:"
    echo "   - SD.v (synthesized netlist)"
    echo "   - SD.json (JSON format)"
    echo "   - R.txt (synthesis report)"
    
    
    exit 0
else
    echo "❌ Synthesis failed!"
    exit 1
fi 

rm -f SD.ys