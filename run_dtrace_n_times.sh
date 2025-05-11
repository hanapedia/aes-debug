#!/bin/bash

# Number of runs per input size
N=50

# Input/output file paths
INPUT_16B="input_16B.bin"
OUTPUT_16B="output_16B.bin"
INPUT_64B="input_64B.bin"
OUTPUT_64B="output_64B.bin"

# Trace output prefix
TRACE_PREFIX_16B="trace_16B"
TRACE_PREFIX_64B="trace_64B"

# OpenSSL base command
OPENSSL_BASE="/opt/homebrew/bin/openssl enc -aes-128-ctr -K 000102030405060708090a0b0c0d0e0f -iv 0102030405060708090a0b0c0d0e0f"

for i in $(seq 1 $N); do
  echo "Run #$i for 64B input..."
  sudo dtrace -x dynvarsize=64m -n '
    pid$target:::entry
    {
        self->ts = timestamp;
    }
    pid$target:::return
    /self->ts/
    {
        @total_time[probefunc] = sum(timestamp - self->ts);
        self->ts = 0;
    }
  ' -c "$OPENSSL_BASE -in $INPUT_64B -out $OUTPUT_64B" > "out/${TRACE_PREFIX_64B}_${i}.out"

  echo "Run #$i for 16B input..."
  sudo dtrace -x dynvarsize=64m -n '
    pid$target:::entry
    {
        self->ts = timestamp;
    }
    pid$target:::return
    /self->ts/
    {
        @total_time[probefunc] = sum(timestamp - self->ts);
        self->ts = 0;
    }
  ' -c "$OPENSSL_BASE -in $INPUT_16B -out $OUTPUT_16B" > "out/${TRACE_PREFIX_16B}_${i}.out"
done

echo "All $N runs completed for both 16B and 64B inputs."
