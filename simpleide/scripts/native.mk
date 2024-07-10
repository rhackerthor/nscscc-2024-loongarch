$(BIN): $(SRCS)
	@rm -rf $(OBJ_DIR) $(BIN)
	$(VERILATOR) $(VERILATOR_FLAGS) \
		--top-module $(TOPNAME) $^  \
		$(addprefix -CFLAGS , $(CXXFLAGS)) \
		$(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe \
		-o $(abspath $(BIN))

all: default

default: run

# Build image file
ROM_DIR   = $(WORK_DIR)/rom
ROM_BUILD = $(ROM_BUILD)/build
IMG ?= user-sample.s

# Argument
ARGS ?= 
IMG ?=

run: $(BIN)
	@rm -rf $(ROM_BUILD)
	$(MAKE) -C $(ROM_DIR) IMG=$(IMG)
	@$^ $(ARGS) $(ROM_BUILD)/img.bin