decode:
	$(MAKE) -C $(WORK_DIR)/inst-interpreter

simplecpu:
	$(MAKE) -C $(WORK_DIR)/simplecpu run

simplecpu-clean:
	$(MAKE) -C $(WORK_DIR)/simplecpu clean

la32gcc:
	$(MAKE) -C $(ROM_DIR) clean
	$(MAKE) -C $(ROM_DIR) IMG=$(IMG)