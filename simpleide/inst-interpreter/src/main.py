from decode import InstDecoder
import sys

def main():
  decoder = InstDecoder()

  build_dir = sys.argv[1]
  ctrl_dir = sys.argv[2]

  decoder.generate_verilog_signal(build_dir + "/verilog.txt")
  decoder.generate_emulator_signal(build_dir + "/emulator.txt")

  """ 生成控制信号 """
  decoder.generate_verilog_ctrl_signal("sel_imm", ctrl_dir, decoder.type_line)
  decoder.generate_verilog_ctrl_signal("rf_we", ctrl_dir, decoder.rf_we_line)
  decoder.generate_verilog_ctrl_signal("rf_oe1", ctrl_dir, decoder.rf_oe1_line)
  decoder.generate_verilog_ctrl_signal("rf_oe2", ctrl_dir, decoder.rf_oe2_line)
  decoder.generate_verilog_ctrl_signal("rf_oe2_is_rd", ctrl_dir, decoder.is_rd_line)
  decoder.generate_verilog_ctrl_signal("sel_alu_in1", ctrl_dir, decoder.sel_alu_in1_line)
  decoder.generate_verilog_ctrl_signal("sel_alu_in2", ctrl_dir, decoder.sel_alu_in2_line)
  decoder.generate_verilog_ctrl_signal("alu_op", ctrl_dir, decoder.alu_op)

if __name__ == "__main__":
  main()