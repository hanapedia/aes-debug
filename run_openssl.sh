#!/bin/bash
echo -n "0123456789abcdef" | /opt/homebrew/bin/openssl enc -aes-128-ctr \
  -K 000102030405060708090a0b0c0d0e0f \
  -iv 0102030405060708090a0b0c0d0e0f
