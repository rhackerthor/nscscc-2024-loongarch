GCCPREFIX?=loongarch32r-linux-gnusf-

override FLAGS += -nostdinc -nostdlib -fno-builtin -mabi=ilp32s -g

CC      := $(GCCPREFIX)gcc
LD      := $(GCCPREFIX)ld
AR      := $(GCCPREFIX)ar
OBJCOPY := $(GCCPREFIX)objcopy
OBJDUMP := $(GCCPREFIX)objdump

BUILD_DIR = ./build

ELF := $(BUILD_DIR)/img.elf
BIN := $(BUILD_DIR)/img.bin
TXT := $(BUILD_DIR)/img.txt
MIF := $(BUILD_DIR)/img.mif

INCFLAG := ../include
CSRCS  = $(shell find $(abspath ../csrc/cstd) -name "*.c")

all: $(BIN)

$(ELF): ./asm/$(IMG)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(FLAGS) -Ttext 0x80000000 -Iinclude $^ -o $@

$(BIN): $(ELF)
	$(OBJCOPY) -j .text -O binary $^ $@
	$(OBJDUMP) -d $^ > $(TXT)

clean:
	@rm -rf $(BUILD_DIR)