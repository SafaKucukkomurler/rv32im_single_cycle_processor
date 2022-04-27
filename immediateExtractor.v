module immediateExtractor(
    input [31:0] instruction_i,
    input [2:0] selection_i,
    output reg [31:0] value_o
);
    wire [11:0] imm_11_0  = instruction_i[31:20];
    wire [19:0] imm_31_12 = instruction_i[31:12];
    wire [4:0] imm_4_0    = instruction_i[11:7];
    wire [6:0] imm_11_5   = instruction_i[31:25];
    wire imm_11_B         = instruction_i[7];
    wire [3:0] imm_4_1    = instruction_i[11:8];
    wire [5:0] imm_10_5   = instruction_i[30:25];
    wire imm_12           = instruction_i[31];
    wire [7:0] imm_19_12  = instruction_i[19:12];
    wire imm_11_J         = instruction_i[20];
    wire [9:0] imm_10_1   = instruction_i[30:21];
    wire imm_20           = instruction_i[31];

    // Extend bits and get immediate values of types.    
    wire [31:0] imm_I  = { {20{imm_11_0[11]}}, imm_11_0 };
    wire [31:0] imm_U  = { imm_31_12, 12'h000 };
    wire [31:0] imm_B  = { {20{imm_12}}, imm_11_B, imm_10_5, imm_4_1, 1'b0 };
    wire [31:0] imm_S  = { {20{imm_11_5[6]}}, imm_11_5, imm_4_0 };
    wire [31:0] imm_UJ = { {12{imm_20}}, imm_19_12, imm_11_J, imm_10_1, 1'b0 };

    always @(*) begin
        case (selection_i)
            1: value_o = imm_I;
            2: value_o = imm_U;
            3: value_o = imm_S;
            4: value_o = imm_B;
            5: value_o = imm_UJ;
            default : value_o = 0;
        endcase
    end
endmodule