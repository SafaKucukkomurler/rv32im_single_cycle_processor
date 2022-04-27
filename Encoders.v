module Encoder_4 (
    input [3:0] input_i,
    output reg [1:0] output_o
  );
  initial begin
    output_o = 0;
  end

  always @(input_i) begin
    casex (input_i)
      4'b1xxx : output_o = 3;
      4'b01xx : output_o = 2;
      4'b001x : output_o = 1;
      4'b0001 : output_o = 0;
      4'b0000 : output_o = 0;
      default: output_o = 0;
    endcase
  end
endmodule

module Encoder_8 (
    input [7:0] input_i,
    output reg [2:0] output_o
  );
  initial begin
    output_o = 0;
  end
  
  always @(input_i) begin
    casex (input_i)
      8'b1xxxxxxx : output_o = 7;
      8'b01xxxxxx : output_o = 6;
      8'b001xxxxx : output_o = 5;
      8'b0001xxxx : output_o = 4;
      8'b00001xxx : output_o = 3;
      8'b000001xx : output_o = 2;
      8'b0000001x : output_o = 1;
      8'b00000001 : output_o = 0;
      8'b00000000 : output_o = 0;
      default: output_o = 0;
    endcase
  end
  
endmodule

module Encoder_16 (
    input [15:0] input_i,
    output reg [3:0] output_o
  );
  initial begin
    output_o = 0;
  end
  
  always @(input_i) begin
    casex (input_i)
      16'b1xxxxxxxxxxxxxxx : output_o = 15;
      16'b01xxxxxxxxxxxxxx : output_o = 14;
      16'b001xxxxxxxxxxxxx : output_o = 13;
      16'b0001xxxxxxxxxxxx : output_o = 12;
      16'b00001xxxxxxxxxxx : output_o = 11;
      16'b000001xxxxxxxxxx : output_o = 10;
      16'b0000001xxxxxxxxx : output_o = 9;
      16'b00000001xxxxxxxx : output_o = 8;
      16'b000000001xxxxxxx : output_o = 7;
      16'b0000000001xxxxxx : output_o = 6;
      16'b00000000001xxxxx : output_o = 5;
      16'b000000000001xxxx : output_o = 4;
      16'b0000000000001xxx : output_o = 3;
      16'b00000000000001xx : output_o = 2;
      16'b000000000000001x : output_o = 1;
      16'b0000000000000001 : output_o = 0;
      16'b0000000000000000 : output_o = 0;
      default: output_o = 0;
    endcase
  end
  
endmodule