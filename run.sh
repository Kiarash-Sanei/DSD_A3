#!/usr/bin/env bash
# run.sh

read -rp "Which bus is being tested? [M/T/E/A] " choice
read -rp "How many bits are being used? [4/8/16/32/64/128/E/A] " bit
read -rp "Which mode is being used? [M/T/X/E/A] " modename

case "$choice" in
  M) name="MUX" ;;
  T) name="Tristate.Buffer" ;;
  E) echo "Simulation stopped!"; exit 1 ;;
  A) name="A" ;;
  *) echo "Invalid choice!"; exit 1 ;;
esac

case "$bit" in
  4|8|16|32|64|128) ;;
  E) echo "Simulation stopped!"; exit 1 ;;
  A) ;;
  *) echo "Invalid bit!"; exit 1 ;;
esac

case "$modename" in
  M) mode="Min";;
  T) mode="Typical";;
  X) mode="Max";;
  E) echo "Simulation stopped!"; exit 1 ;;
  A) ;;
  *) echo "Invalid mode!"; exit 1 ;;
esac

run_sim() {
  local n="$1"
  local b="$2"
  local m="$3"

  if ! iverilog -o out "${n}/${n}.${m}.v" "Testbench/${b}.v" &>/dev/null; then
    echo "Compilation failed for ${n} @ ${b}th bit in ${m}!"
    exit 1
  fi
  vvp out > "${n}/${m}/${b}.txt"
  echo "Simulation complete. Output in ${n}/${folder}/${b}.txt."
  rm -f out
}

all_names=( "MUX" "Tristate.Buffer" )
all_bits=( 4 8 16 32 64 128 )
all_modes=( "Min" "Typical" "Max" )

if [[ $name != A && $bit != A && $modename != A ]]; then
  # One bus, one width, one mode
  run_sim "$name" "$bit" "$mode"

elif [[ $name == A && $bit != A  && $modename != A ]]; then
  # All buses, one width, one mode
  for n in "${all_names[@]}"; do
    run_sim "$n" "$bit" "$mode"
  done

elif [[ $name != A && $bit == A && $modename != A ]]; then
  # One bus, all widths, one mode
  for b in "${all_bits[@]}"; do
    run_sim "$name" "$b" "$mode"
  done

elif [[ $name == A && $bit == A && $modename != A ]]; then
  # All buses, all widths, one mode
  for n in "${all_names[@]}"; do
    for b in "${all_bits[@]}"; do
      run_sim "$n" "$b" "$mode"
    done
  done

elif [[ $name != A && $bit != A && $modename == A ]]; then
  # One bus, one width, all mode
  for m in "${all_modes[@]}"; do
    run_sim "$name" "$bit" "$m"
  done

elif [[ $name == A && $bit != A  && $modename == A ]]; then
  # All buses, one width, all mode
  for m in "${all_modes[@]}"; do
    for n in "${all_names[@]}"; do
      run_sim "$n" "$bit" "$m"
    done
  done

elif [[ $name != A && $bit == A && $modename == A ]]; then
  # One bus, all widths, all mode
  for m in "${all_modes[@]}"; do
    for b in "${all_bits[@]}"; do
      run_sim "$name" "$b" "$m"
    done
  done

else
  # All buses, all widths, all mode
  for m in "${all_modes[@]}"; do
    for n in "${all_names[@]}"; do
      for b in "${all_bits[@]}"; do
        run_sim "$n" "$b" "$m"
      done
    done
  done
fi