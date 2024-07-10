SRC_DIR := src
BIN_DIR := bin

MCU := atmega8
PROGRAMMER := avrispmkII
PORT := /dev/ttyUSB0
SPEED := 1MHz

all: clean build

$(BIN_DIR):
	@echo Creating $(BIN_DIR) directory
	@mkdir -p $(BIN_DIR)

$(BIN_DIR)/main.hex: | $(BIN_DIR)
	@avra -I "/usr/share/avra" -I ./$(SRC_DIR) ./$(SRC_DIR)/main.asm
	@find ./$(SRC_DIR) -type f -not -name "*.asm" -exec mv '{}' ./$(BIN_DIR) \;

build: $(BIN_DIR)/main.hex

clean:
	@if [ -d ./$(BIN_DIR) ]; then echo Cleaning $(BIN_DIR); rm -f $(BIN_DIR)/*; fi

flash: $(BIN_DIR)/main.hex
	@avrdude -p $(MCU) -c $(PROGRAMMER) -P $(PORT) -B $(SPEED) -U flash:w:$(BIN_DIR)/main.hex
