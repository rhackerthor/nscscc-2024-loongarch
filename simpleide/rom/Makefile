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

all: image

$(ELF): ./asm/$(IMG)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(FLAGS) -Ttext 0x80000000 -Iinclude $^ -o $@

image: $(ELF)
	$(OBJDUMP) -d $^ > $(TXT)
	$(OBJCOPY) -j .text -O binary $^ $(BIN)
