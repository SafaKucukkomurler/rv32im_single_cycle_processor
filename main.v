`timescale 1ns / 1ps

module main(
    //input clk,
    //input reset
  );
  
//-----------------------------------------------------------------
//  The following function calculates the address width based on specified RAM depth
//-----------------------------------------------------------------
function integer clogb2;
input integer depth;
	for (clogb2=0; depth>0; clogb2=clogb2+1)
		depth = depth >> 1;
endfunction
//-----------------------------------------------------------------	

  reg clk = 0;
  reg reset = 0;
  
  localparam RAM_DEPTH = 16;

  always begin #5 clk = ~clk; end

  wire [31:0] inst_rom_addr;
  wire [31:0] instruction;

  wire [clogb2(RAM_DEPTH-1)-1:0] data_ram_addr;
  wire [31:0] data_ram_in_from_cpu;
  wire data_ram_we;
  wire [31:0] data_ram_out_to_cpu;

  core #(.RAM_DEPTH(RAM_DEPTH)) 
	cpu(
         .inst_rom_addr_o(inst_rom_addr),
         .instruction_i(instruction),
         .clk(clk),
         .data_ram_addr_o(data_ram_addr),
         .data_ram_i(data_ram_out_to_cpu),
         .data_ram_we_reg_o(data_ram_we),
         .data_ram_o(data_ram_in_from_cpu),
         .reset_i(reset)
       );

  ROM inst_rom(
        .clk(clk),
        .address_i(inst_rom_addr),
        .data_o(instruction)
      );

  RAM #(.RAM_DEPTH(RAM_DEPTH))
	data_ram(
        .address_i(data_ram_addr),
        .data_i(data_ram_in_from_cpu),
        .we_i(data_ram_we),
        .clk(clk),
        .reset_i(reset),
        .data_o(data_ram_out_to_cpu)
      );

endmodule
