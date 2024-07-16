BUILD_DIR := build
BIN       := $(BUILD_DIR)/simple-cpu-main

INCFLAGS  = $(addprefix -I, $(abspath include))
LDFLAGS  += -lreadline

CSRCS = $(shell find $(abspath ./src) -name "*.c")
SRCS  = $(CSRCS)

IMG   = $(abspath ../rom/build/img.bin)
ARGS  += -t $(BUILD_DIR)/cpu-trace.txt

all: run

$(BIN): $(CSRCS)
	@rm -rf $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)
	@gcc -o $@ $(INCFLAGS) $^ $(LDFLAGS) 

run: $(BIN)
	@echo $(INCFLAGS)
	@./$^ $(ARGS) $(IMG)

clean:
	rm -rf $(BUILD_DIR)
