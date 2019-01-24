#!/usr/bin/env python3

import sys

files = [
    "types.cl",
    "curve25519-constants.cl",
    "curve25519-constants2.cl",
    "curve25519.cl",
    "sha/inc_hash_functions.cl",
    "sha/sha256.cl",
    "sha/sha512.cl",
    "sha_bindings.cl",
    "bip39.cl",
    "lisk.cl",
    "entry.cl",
]

for f_name in files:
    with open("src/opencl/" + f_name, "r") as f:
        for line in f:
            sys.stdout.write(line)
