module alu (
    input [3:0] op_i,
    input [31:0] A_i, 
    input [31:0] B_i,
    output [31:0] output_o,
    output isEqual_o 
);
    reg signed [63:0] result;

    wire signed [31:0] A_signed = A_i;
    wire signed [31:0] B_signed = B_i;

    assign isEqual = A_i == B_i;

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

    always @(*) begin
        case (op_i)
            0:  result = A_signed +   B_signed; // add
            1:  result = A_signed -   B_signed; // sub
            2:  result = A_signed &   B_signed; // and
            3:  result = A_signed |   B_signed; // or
            4:  result = A_signed ^   B_signed; // xor
            5:  result = A_signed <<  B_signed[4:0]; // shift left logical
            6:  result = A_signed >>  B_signed[4:0]; // shift right logical
            7:  result = A_signed >>> B_signed[4:0]; // shift right arithmetic
            8:  result = A_signed *   B_signed; // mul
            9:  result = A_signed *   B_signed; // mulh
            10: result = A_signed /   B_signed; // div
            11: result = A_signed %   B_signed; // rem
            12: result = (less_than_signed(A_i, B_i) ? 1'b1 : 1'b0); // set less than (slt)
            13: result = (A_i < B_i ? 1'b1 : 1'b0); // set less than (sltu)
            14: result = A_i * B_i; //mulhu 
            15: result = {{32{A_i[31]}}, A_i} * B_i; //mulhsu, A_i manuel signed extended because B_i is unsigned
        endcase
    end

    assign output_o = (op_i == 9 || op_i == 14 || op_i == 15) ? result[63:32] : result[31:0];
    
endmodule