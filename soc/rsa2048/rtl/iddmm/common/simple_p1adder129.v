/*
*   Name        :1 stage,129bits classic pipelined adder
*   Description :
*   Orirgin     :20200813
*   Author      :helrori2011@gmail.com
*   Timing      :
*/
module simple_p1adder129
(
    input   wire            clk,
    input   wire [128:0]    ain ,
    input   wire [128:0]    bin ,
    output  wire [129:0]    full_sum 
);
    reg  [63:0]s_l;
    reg  [64:0]a_h,b_h;
    reg  c_l;
    wire [65:0]s_h;
    assign s_h = c_l+a_h+b_h;
    always@(posedge clk)begin
        {c_l,s_l}   <=  ain[63 : 0]+bin[63 : 0];
        {a_h,b_h}   <= {ain[128:64],bin[128:64]};
    end
    assign full_sum={s_h,s_l};
        
endmodule