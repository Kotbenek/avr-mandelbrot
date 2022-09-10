#!/bin/bash

BIN_DIR="./bin"

MCU="atmega8"
PROGRAMMER="avrispmkII"
PORT="/dev/ttyUSB0"
SPEED="1MHz"

avrdude -p $MCU -c $PROGRAMMER -P $PORT -B $SPEED -U flash:w:$BIN_DIR/main.hex

