module RAM #(parameter RAM_DEPTH = 512)
(
    input [clogb2(RAM_DEPTH-1)-1:0] address_i,
    input [31:0] data_i,
    input we_i,
    input clk,
    input reset_i,    
    output [31:0] data_o
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
    
    reg [31:0] memory [RAM_DEPTH-1:0];

    integer i;

    initial begin
        for(i = 0; i < RAM_DEPTH; i = i + 1) begin
            memory[i] <= 0;
        end
    end

    assign data_o = memory[address_i];

    always @(posedge clk) begin
        if (reset_i) begin
            for (i = 0; i < RAM_DEPTH ; i = i + 1) begin
                memory[i] <= 0;
            end
        end
        else if (we_i)
            memory[address_i] <= data_i;
    end

endmodule