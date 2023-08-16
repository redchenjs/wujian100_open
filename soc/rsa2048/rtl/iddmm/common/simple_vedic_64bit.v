/*
*   Name        :64bit vedic multiplier
*   Description :
*   Orirgin     :20200810
*   Author      :helrori
*   Modify      :
*/
module simple_vedic_64bit#(
    parameter W=64
)
(
    input   wire               clk ,
    input   wire    [W-1:0]    a   ,
    input   wire    [W-1:0]    b   ,
    output  wire    [2*W-1:0]  s 
);
wire [W-1:0]res0;
wire [W-1:0]res1;
wire [W-1:0]res2;
wire [W-1:0]res3;

wire [W  :0]res0_adder;
wire [W  :0]res1_adder;
wire [W-1:0]res2_adder;
simple_vedic_32bit simple_vedic_32bit_0 (.clk(clk),.a( a  [W/2-1:0] ),.b( b  [W/2-1:0] ),.s( res0 ));
simple_vedic_32bit simple_vedic_32bit_1 (.clk(clk),.a( a  [W-1:W/2] ),.b( b  [W/2-1:0] ),.s( res1 ));
simple_vedic_32bit simple_vedic_32bit_2 (.clk(clk),.a( a  [W/2-1:0] ),.b( b  [W-1:W/2] ),.s( res2 ));
simple_vedic_32bit simple_vedic_32bit_3 (.clk(clk),.a( a  [W-1:W/2] ),.b( b  [W-1:W/2] ),.s( res3 ));
reg [(W+W+W+1)-1  :0]stage0;
reg [(W+W/2+1+W)-1:0]stage1;
assign res0_adder   = res1+res2;
assign res1_adder   = stage0[W-1:W/2]+stage0[W+W-1:W];
assign res2_adder   = stage1[(W+W/2+1+W)-1:W+W/2+1]+{stage1[W+W/2],stage1[W+W/2-1:W]};
assign s            = {res2_adder,stage1[W-1:0]};
always@(posedge clk)begin
    stage0<={res3,res0_adder,res0};
    stage1<={stage0[((W+W+W+1)-1)-:W],res1_adder[W]|stage0[2*W],res1_adder[W-1:0],stage0[W/2-1:0]};
end

endmodule