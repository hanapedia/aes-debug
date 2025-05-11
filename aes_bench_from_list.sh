#!/usr/bin/env bash

set -euo pipefail

ALGO_LIST_FILE="aes_algorithms.txt"
OUTPUT_FILE="aes_benchmark_results.csv"
BLOCK_SIZES=("16" "64" "256" "1024" "8192" "16384")

# Write CSV header
{
  echo -n "algorithm"
  for size in "${BLOCK_SIZES[@]}"; do
    echo -n ",${size}bytes"
  done
  echo
} > "$OUTPUT_FILE"

# Read each algorithm from the list
while IFS= read -r ALG; do
  ALG_LOWER=$(echo "$ALG" | tr '[:upper:]' '[:lower:]')

  echo "Benchmarking $ALG_LOWER..."

  # Run OpenSSL speed test
  RESULT=$(openssl speed -evp "$ALG_LOWER" 2>&1 || true)

  if [[ -z "$RESULT" ]]; then
    echo "Skipping $ALG (unsupported)"
    continue
  fi

  # Start new CSV row
  ROW="$ALG"

  # Parse first 6 "Doing ..." lines to get ops count
  while IFS= read -r LINE && [[ "$LINE" == Doing* ]]; do
    # Extract block size and op count from the line
    SIZE=$(echo "$LINE" | awk '{for (i=1; i<=NF; i++) if ($i=="on") print $(i+1)}')
    OPS=$(echo "$LINE" | awk -F ':' '{print $2}' | awk '{print $1}')

    echo "${ALG}: ${SIZE}, ${OPS}"

    # Add to array by matching size
    FOUND=0
    for s in "${BLOCK_SIZES[@]}"; do
      if [[ "$SIZE" == "$s" ]]; then
        ROW+=",${OPS}"
        FOUND=1
        break
      fi
    done
    # If size didn't match one of our 6, skip (or append 0)
    if [[ $FOUND -eq 0 ]]; then
      ROW+=",0"
    fi
  done <<< "$(echo "$RESULT" | head -n 6)"

  echo "$ROW" >> "$OUTPUT_FILE"
done < "$ALGO_LIST_FILE"

echo "Benchmark complete. Results saved to $OUTPUT_FILE"
