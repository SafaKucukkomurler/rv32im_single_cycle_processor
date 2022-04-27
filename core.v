`include "riscv_defs.v"

module core #(parameter RAM_DEPTH = 512)
(
    output [31:0] inst_rom_addr_o,
    input [31:0] instruction_i,
    input clk,
    output reg [clogb2(RAM_DEPTH-1)-1:0] data_ram_addr_o,
    input [31:0] data_ram_i,
    output reg data_ram_we_reg_o,
    output reg [31:0] data_ram_o,
    input reset_i
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

//-----------------------------------------------------------------
// -- RV32I Instructions
`define LUI       ((instruction_i & `INST_LUI_MASK)    == `INST_LUI  )
`define AUIPC     ((instruction_i & `INST_AUIPC_MASK)  == `INST_AUIPC)
`define JAL       ((instruction_i & `INST_JAL_MASK)    == `INST_JAL  )
`define JALR      ((instruction_i & `INST_JALR_MASK)   == `INST_JALR )
`define BEQ       ((instruction_i & `INST_BEQ_MASK)    == `INST_BEQ  )
`define BNE       ((instruction_i & `INST_BNE_MASK)    == `INST_BNE  )
`define BLT       ((instruction_i & `INST_BLT_MASK)    == `INST_BLT  )
`define BGE       ((instruction_i & `INST_BGE_MASK)    == `INST_BGE  )
`define BLTU      ((instruction_i & `INST_BLTU_MASK)   == `INST_BLTU )
`define BGEU      ((instruction_i & `INST_BGEU_MASK)   == `INST_BGEU )
`define LB        ((instruction_i & `INST_LB_MASK)     == `INST_LB   )
`define LH        ((instruction_i & `INST_LH_MASK)     == `INST_LH   )
`define LW        ((instruction_i & `INST_LW_MASK)     == `INST_LW   )
`define LBU       ((instruction_i & `INST_LBU_MASK)    == `INST_LBU  )
`define LHU       ((instruction_i & `INST_LHU_MASK)    == `INST_LHU  )
`define SB        ((instruction_i & `INST_SB_MASK)     == `INST_SB   )
`define SH        ((instruction_i & `INST_SH_MASK)     == `INST_SH   )
`define SW        ((instruction_i & `INST_SW_MASK)     == `INST_SW   )
`define ADDI      ((instruction_i & `INST_ADDI_MASK)   == `INST_ADDI )
`define SLTI      ((instruction_i & `INST_SLTI_MASK)   == `INST_SLTI )
`define SLTIU     ((instruction_i & `INST_SLTIU_MASK)  == `INST_SLTIU)
`define XORI      ((instruction_i & `INST_XORI_MASK)   == `INST_XORI )
`define ORI       ((instruction_i & `INST_ORI_MASK)    == `INST_ORI  )
`define ANDI      ((instruction_i & `INST_ANDI_MASK)   == `INST_ANDI )
`define SLLI      ((instruction_i & `INST_SLLI_MASK)   == `INST_SLLI )
`define SRLI      ((instruction_i & `INST_SRLI_MASK)   == `INST_SRLI )
`define SRAI      ((instruction_i & `INST_SRAI_MASK)   == `INST_SRAI )
`define ADD       ((instruction_i & `INST_ADD_MASK)    == `INST_ADD  )
`define SUB       ((instruction_i & `INST_SUB_MASK)    == `INST_SUB  )
`define SLL       ((instruction_i & `INST_SLL_MASK)    == `INST_SLL  )
`define SLT       ((instruction_i & `INST_SLT_MASK)    == `INST_SLT  )
`define SLTU      ((instruction_i & `INST_SLTU_MASK)   == `INST_SLTU )
`define XOR       ((instruction_i & `INST_XOR_MASK)    == `INST_XOR  )
`define SRL       ((instruction_i & `INST_SRL_MASK)    == `INST_SRL  )
`define SRA       ((instruction_i & `INST_SRA_MASK)    == `INST_SRA  )
`define OR        ((instruction_i & `INST_OR_MASK)     == `INST_OR   )
`define AND       ((instruction_i & `INST_AND_MASK)    == `INST_AND  )
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// -- RV32M Instructions
`define MUL       ((instruction_i & `INST_MUL_MASK)    == `INST_MUL   )
`define MULH      ((instruction_i & `INST_MULH_MASK)   == `INST_MULH  )
`define MULHSU    ((instruction_i & `INST_MULHSU_MASK) == `INST_MULHSU)
`define MULHU     ((instruction_i & `INST_MULHU_MASK)  == `INST_MULHU )
`define DIV       ((instruction_i & `INST_DIV_MASK)    == `INST_DIV   )
`define DIVU      ((instruction_i & `INST_DIVU_MASK)   == `INST_DIVU  )
`define REM       ((instruction_i & `INST_REM_MASK)    == `INST_REM   )
`define REMU      ((instruction_i & `INST_REMU_MASK)   == `INST_REMU  )
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// -- Grouping of Instructions
wire alu_instructions = (`SLL | `SLLI | `SRL | `SRLI | `SRA | `SRAI | `ADD | `ADDI | `SUB | `XOR | 
                         `XORI | `OR | `ORI | `AND | `ANDI | `SLT | `SLTI | `SLTU | `SLTIU | `MUL | 
                         `MULH | `MULHSU | `MULHU | `DIV | `DIVU | `REM | `REMU);
wire branch_instructions = (`BEQ | `BNE | `BLT | `BGE | `BLTU | `BGEU);
wire store_instructions = (`SB | `SH | `SW);
wire load_instructions = (`LB | `LH | `LW | `LBU | `LHU);
wire jump_instructions = (`JAL | `JALR);
wire i_type_instruction = (instruction_i[6:0] == 7'b0010011) ? 1'b1 : 1'b0;
//-----------------------------------------------------------------

// COMPONENT DEFINITIONS (Immediate Extractor, Alu, RegFile)

//-----------------------------------------------------------------
// -- Immediate Extractor
wire [31:0] immediateValue;
wire [2:0] immediateSelection;
wire [7:0] immediateSelectionInputs;

assign immediateSelectionInputs[0] = 1'b0;
assign immediateSelectionInputs[1] = (`JALR | `ADDI | `SLTI | `SLTIU | `XORI | `ORI | `ANDI | `SLLI | 
                                      `SRLI | `SRAI | `LB | `LH | `LW | `LBU | `LHU);
assign immediateSelectionInputs[2] = (`LUI | `AUIPC);
assign immediateSelectionInputs[3] = (`SB | `SH | `SW);
assign immediateSelectionInputs[4] = (`BEQ | `BNE | `BLT | `BGE | `BLTU | `BGEU);
assign immediateSelectionInputs[5] = `JAL;
assign immediateSelectionInputs[6] = 1'b0;
assign immediateSelectionInputs[7] = 1'b0;
Encoder_8 immediateSelectionEncoder(.input_i(immediateSelectionInputs), 
                                    .output_o(immediateSelection));

immediateExtractor immExtractor(.instruction_i(instruction_i), 
                                .selection_i(immediateSelection), 
                                .value_o(immediateValue)
                                );
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// -- Alu Operation Selection
wire [15:0] aluOpEncoderInputs;
wire [3:0] aluOp;

assign aluOpEncoderInputs[0] =  `ADD    | `ADDI | store_instructions | load_instructions;
assign aluOpEncoderInputs[1] =  `SUB;     
assign aluOpEncoderInputs[2] =  `AND    | `ANDI;
assign aluOpEncoderInputs[3] =  `OR     | `ORI;
assign aluOpEncoderInputs[4] =  `XOR    | `XORI;
assign aluOpEncoderInputs[5] =  `SLL    | `SLLI;
assign aluOpEncoderInputs[6] =  `SRL    | `SRLI;
assign aluOpEncoderInputs[7] =  `SRA    | `SRAI;
assign aluOpEncoderInputs[8] =  `MUL;     
assign aluOpEncoderInputs[9] =  `MULH;    
assign aluOpEncoderInputs[10] = `DIV    | `DIVU;
assign aluOpEncoderInputs[11] = `REM    | `REMU;
assign aluOpEncoderInputs[12] = `SLT    | `SLTI;
assign aluOpEncoderInputs[13] = `SLTU   | `SLTIU;
assign aluOpEncoderInputs[14] = `MULHU;
assign aluOpEncoderInputs[15] = `MULHSU;
Encoder_16 aluOpEncoder(.input_i(aluOpEncoderInputs),
                        .output_o(aluOp)
                        );
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// -- RegFile
wire [4:0] rs1 = instruction_i[19:15];
wire [4:0] rs2 = instruction_i[24:20];
wire [4:0] rd  = instruction_i[11:7];
reg regFile_we_reg;
wire [31:0] rs1_data;
wire [31:0] rs2_data;
reg [31:0] rd_data;

regFile registerFile(
  .addr_rs1_i(rs1), 
  .addr_rs2_i(rs2), 
  .addr_rd_i(rd), 
  .rs1_o(rs1_data), 
  .rs2_o(rs2_data), 
  .rd_i(rd_data), 
  .write_enable_i(regFile_we_reg), 
  .reset_i(reset_i), 
  .clk(clk)
  );
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// -- Alu
wire [31:0] aluOut;
wire [31:0] ALU_A;
wire [31:0] ALU_B;
wire isALUEqual;

assign ALU_A = rs1_data;
assign ALU_B = (store_instructions | load_instructions | i_type_instruction) ? immediateValue : rs2_data;

alu ALU(
  .A_i(ALU_A), 
  .B_i(ALU_B), 
  .op_i(aluOp), 
  .output_o(aluOut), 
  .isEqual_o(isALUEqual)
);
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// -- Program Counter Register
reg counter = 1'b0;
reg [31:0] pc_reg = 32'b0;
reg [31:0] pc_next = 32'b0;

assign inst_rom_addr_o = pc_reg;

always @(posedge clk) begin
  pc_reg <= pc_next;
  if (counter == 1'b0) begin
    counter <= 1'b1;    
  end
  else if (counter == 1'b1) begin
    counter <= 1'b0;
  end
end
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// less_than_signed: Less than operator (signed)
// Inputs: x = left operand, y = right operand
// Return: (int)x < (int)y
//-----------------------------------------------------------------
function [0:0] less_than_signed;
    input  [31:0] x;
    input  [31:0] y;
    reg [31:0] v;
begin
    v = (x - y);
    if (x[31] != y[31])
        less_than_signed = x[31];
    else
        less_than_signed = v[31];
end
endfunction
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// greater_than_signed: Greater than operator (signed)
// Inputs: x = left operand, y = right operand
// Return: (int)x > (int)y
//-----------------------------------------------------------------
function [0:0] greater_than_signed;
    input  [31:0] x;
    input  [31:0] y;
    reg [31:0] v;
begin
    v = (y - x);
    if (x[31] != y[31])
        greater_than_signed = y[31];
    else
        greater_than_signed = v[31];
end
endfunction
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// -- Control Logic
always @(*) begin
  data_ram_addr_o = aluOut[clogb2(RAM_DEPTH-1)-1:0];
  data_ram_o = rs2_data;
  rd_data = aluOut;
  regFile_we_reg = 1'b0;
  data_ram_we_reg_o = 1'b0;
  pc_next = pc_reg;

  if (counter == 1) begin
    if (alu_instructions) begin
      regFile_we_reg = 1'b1;
      rd_data = aluOut;
      pc_next = pc_reg + 1;
    end
    else if (load_instructions) begin
      regFile_we_reg = 1'b1;
      rd_data = data_ram_i;
      data_ram_addr_o = aluOut[clogb2(RAM_DEPTH-1)-1:0];
      pc_next = pc_reg + 1;
    end
    else if (store_instructions) begin
      data_ram_addr_o = aluOut[clogb2(RAM_DEPTH-1)-1:0];
      data_ram_o = rs2_data;
      data_ram_we_reg_o = 1'b1;
      pc_next = pc_reg + 1;
    end
    else if (`JAL) begin    
      regFile_we_reg = 1'b1;
      rd_data = pc_reg + 1;
      pc_next = pc_reg + immediateValue;
    end
    else if (`JALR) begin    
      regFile_we_reg = 1'b1;
      rd_data = pc_reg + 1;
      pc_next = rs1_data + immediateValue;
    end
    else if (`LUI) begin
      regFile_we_reg = 1'b1;
      rd_data = immediateValue;
      pc_next = pc_reg + 1;
    end
    else if (`AUIPC) begin
      regFile_we_reg = 1'b1;
      rd_data = pc_reg + immediateValue;
      pc_next = pc_reg + 1;
    end
    else if (`BEQ) begin
      pc_next = (rs1_data == rs2_data) ? (pc_reg + immediateValue) : (pc_reg + 1);
    end
    else if (`BNE) begin
      pc_next = (rs1_data != rs2_data) ? (pc_reg + immediateValue) : (pc_reg + 1);
    end
    else if (`BLT) begin
      pc_next = (less_than_signed(rs1_data, rs2_data)) ? (pc_reg + immediateValue) : (pc_reg + 1);
    end
    else if (`BGE) begin
      pc_next = (greater_than_signed(rs1_data, rs2_data) | (rs1_data == rs2_data)) ? (pc_reg + immediateValue) : (pc_reg + 1);
    end
    else if (`BLTU) begin
      pc_next = (rs1_data < rs2_data) ? (pc_reg + immediateValue) : (pc_reg + 1);
    end
    else if (`BGEU) begin
      pc_next = (rs1_data >= rs2_data) ? (pc_reg + immediateValue) : (pc_reg + 1);
    end
  end
end
//-----------------------------------------------------------------

endmodule
