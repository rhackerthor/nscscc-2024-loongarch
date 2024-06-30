`include "define.sv"
interface PipeLineCtrl (
  input to_if_valid
);

  logic valid_if;
  logic valid_id;
  logic valid_exe;
  logic valid_mem;
  logic valid_wb;

  logic allowin_if;
  logic allowin_id;
  logic allowin_exe;
  logic allowin_mem;
  logic allowin_wb;

  logic ready_go_if;
  logic ready_go_id;
  logic ready_go_exe;
  logic ready_go_mem;
  logic ready_go_wb;

  logic if_to_id_valid;
  logic id_to_exe_valid;
  logic exe_to_mem_valid;
  logic mem_to_wb_valid;

  assign allowin_if  = !valid_if  | ready_go_if  & allowin_id;
  assign allowin_id  = !valid_id  | ready_go_id  & allowin_exe;
  assign allowin_exe = !valid_exe | ready_go_exe & allowin_mem;
  assign allowin_mem = !valid_mem | ready_go_mem;
  assign allowin_wb  = !valid_wb  | ready_go_wb;

  assign if_to_id_valid   = valid_if  & ready_go_if;
  assign id_to_exe_valid  = valid_id  & ready_go_id;
  assign exe_to_mem_valid = valid_exe & ready_go_exe;
  assign mem_to_wb_valid  = valid_mem & ready_go_mem;

  always_ff @(*) begin
    assign ready_go_if  = 1'b1;
    assign ready_go_id  = 1'b1;
    assign ready_go_exe = 1'b1;
    assign ready_go_mem = 1'b1;
    assign ready_go_wb  = 1'b1;
  end
    
endinterface