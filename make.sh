#!/bin/bash

SRC_DIR="./src"
BIN_DIR="./bin"

if [ -d $BIN_DIR ]; then rm -rf $BIN_DIR; fi
mkdir $BIN_DIR

avra -I "/usr/share/avra" -I $SRC_DIR $SRC_DIR/main.asm
find $SRC_DIR -type f -not -name "*.asm" -exec mv '{}' $BIN_DIR \;

