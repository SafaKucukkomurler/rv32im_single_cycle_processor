module ROM(
    input clk,
    input [31:0] address_i,    
    output [31:0] data_o
);
    reg [31:0] memory [12:0];

    assign data_o = memory[address_i];

    always @(posedge clk) begin
        memory[0] <= 32'h00000013; // nop (addi x0 x0 0)
        memory[1] <= 32'h00100093; // addi x1 x0 1
        //memory[2] = 32'h00208113; // addi x2 x1 2 
        memory[2] <= 32'h00100313; // addi x6 x0 1
        memory[3] <= 32'h0060A023; // sw x6 0(x1)        
        memory[4] <= 32'h00300313; //addi x6 x0 3
        //memory[3] = 32'h00400613; // addi x12 x0 4
        //memory[4] = 32'h0060A023; // sw x6 0(x1)        
        //memory[4] = 32'h00100313; // addi x6 x0 1
        memory[5] <= 32'h0000A303; // lw x6 0(x1)        
        memory[6] <= 32'h00130313; // addi x6 x6 1       
        //memory[7] = 32'hFF930313; // addi x6 x6 -7
        //memory[7] = 32'hFF960613; // addi x12 x12 -7
        memory[7] <= 32'h0060A023; // sw x6 0(x1)        
        memory[8] <= 32'hFEC34FE3; // blt x6 x12 -2     
        //memory[8] = 32'hFEC36FE3; // bltu x6 x12 -2
        //memory[7] = 32'h00230313; // addi x6 x6 2
        //memory[8] = 32'hFEC35FE3; // bge x6 x12 -2
        //memory[8] = 32'hFEC37FE3; // bgeu x6 x12 -2
        memory[9] <= 32'h03700413; // addi x8 x0 55
        memory[10] <= 32'h00800433; // add x8 x0 x8      
        memory[11] <= 32'h00140413; // addi x8 x8 1      
        memory[12] <= 32'h00000013; // nop (add x0 x0 0)
    end
endmodule
