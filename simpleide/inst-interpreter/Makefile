PY = python3
PIP = pip3

REQUIR = requirements.txt

PYSRC_DIR = src
PYMAIN = $(PYSRC_DIR)/main.py

BUILD_DIR = build
CTRL_DIR = $(BUILD_DIR)/ctrl_signal

all: default
default: run

install:
	$(PIP) install -r $(REQUIR)

run: clean
	@mkdir -p $(CTRL_DIR)
	$(PY) $(PYMAIN) $(BUILD_DIR) $(CTRL_DIR)

clean:
	@rm -rf $(BUILD_DIR)

.PHONY: all default install run clean