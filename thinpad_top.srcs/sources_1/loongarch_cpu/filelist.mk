CPUCORE_DIR = /home/rhacker/nscscc-2024-loongarch/thinpad_top.srcs/sources_1/loongarch_cpu
CPUCORE_SRCS = $(shell find $(CPUCORE_DIR) -name "*.sv")
VSRCS += $(filter-out $(CPUCORE_DIR)/ram_uart_ctrl.sv $(CPUCORE_DIR)/define.sv, $(CPUCORE_SRCS))
VERILATOR_FLAGS += -I$(CPUCORE_DIR)
