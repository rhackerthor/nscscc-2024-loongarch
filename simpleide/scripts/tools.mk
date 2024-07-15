la32gcc:
	$(MAKE) -C $(ROM_DIR) clean
	$(MAKE) -C $(ROM_DIR) IMG=$(IMG)

decode:
	$(MAKE) -C $(WORK_DIR)/inst-interpreter

gettrace:
	$(MAKE) -C $(WORK_DIR)/gettrace 

gettrace-clean:
	$(MAKE) -C $(WORK_DIR)/gettrace clean

simplecpu:
	$(MAKE) -C $(WORK_DIR)/simplecpu run

simplecpu-clean:
	$(MAKE) -C $(WORK_DIR)/simplecpu clean
