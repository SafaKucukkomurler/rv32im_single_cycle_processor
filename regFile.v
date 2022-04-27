module regFile (
    input [4:0] addr_rs1_i, 
    input [4:0] addr_rs2_i, 
    input [4:0] addr_rd_i,
    output [31:0] rs1_o, 
    output [31:0] rs2_o,
    input [31:0] rd_i,
    input write_enable_i,
    input reset_i,
    input clk
  );

  reg [31:0] registers [31:0];

  integer i = 0;
  initial
  begin
    for (i = 0; i < 32 ; i = i + 1)
    begin
      registers[i] <= 0;
    end
  end

  assign rs1_o = registers[addr_rs1_i];
  assign rs2_o = registers[addr_rs2_i];

  always @(posedge clk)
  begin
    if (reset_i)
    begin
      for (i = 0; i < 32 ; i = i + 1)
      begin
        registers[i] <= 0;
      end
    end
    else if (write_enable_i && addr_rd_i != 0)
    begin
      registers[addr_rd_i] <= rd_i;
    end
  end

endmodule
