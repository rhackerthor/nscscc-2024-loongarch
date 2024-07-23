module IC (
  IcacheIterface U_IC,
  IFInterface    U_IF,
  RamInterface   U_RAM
);

  always @(posedge U_IC.clk) begin
  end

  always @(*) begin
    if (U_IF.next_pc) begin
    end
  end

endmodule