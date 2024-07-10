TOPNAME = top

# work dir
WORK_DIR  = simpleide
BUILD_DIR = $(WORK_DIR)/build
OBJ_DIR   = $(BUILD_DIR)/obj_dir
BIN       = $(BUILD_DIR)/$(TOPNAME)

# verilator
VERILATOR = verilator
VERILATOR_FLAGS := -MMD --build -cc
VERILATOR_FLAGS += -trace
VERILATOR_FLAGS += -O3 --x-assign fast --x-initial fast --noassert

# Include files for include
INCFLAGS  = $(addprefix -I, $(abspath $(WORK_DIR)/include))
CXXFLAGS += $(INCFLAGS)
LDFLAGS  += -lreadline

# Source code file
VSRCS_DIR = $(WORK_DIR)/vsrc
CSRCS_DIR = $(WORK_DIR)/csrc
VSRCS = $(shell find $(abspath $(VSRCS_DIR)) -name "*.sv")
CSRCS = $(shell find $(abspath $(CSRCS_DIR)) -name "*.c")
CXXSRCS = # NULL
SRCS  = $(VSRCS) $(CSRCS) $(CXXSRCS)

# Include all filelist.mk to merge file lists
FILELIST_MK = $(shell find -L . -name "filelist.mk")
include $(FILELIST_MK)

# Include rules for simple-ide
include $(WORK_DIR)/scripts/native.mk

# Include rules for tools
include $(WORK_DIR)/scripts/tools.mk