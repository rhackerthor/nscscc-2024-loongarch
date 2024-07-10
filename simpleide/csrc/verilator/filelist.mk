CXXSRCS_DIR += $(CSRCS_DIR)/verilator
CXXSRCS += $(shell find $(abspath $(CXXSRCS_DIR)) -name "*.cc")