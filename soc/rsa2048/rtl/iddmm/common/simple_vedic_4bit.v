/*
*   Name        :4bit vedic multiplier
*   Description :
*   Orirgin     :20200805
*   Author      :helrori
*   Modify      :
*/
module simple_vedic_4bit
(
    input   wire    [3:0]   a   ,
    input   wire    [3:0]   b   ,
    output  wire    [7:0]   s 
);


function [3:0]vedic2x2; 
    input [1:0] a; 
    input [1:0] b; 
begin
    vedic2x2[0]=a[0]&b[0];
    vedic2x2[1]=(a[1]&b[0])^(a[0]&b[1]);
    vedic2x2[2]=((a[1]&b[0])&(a[0]&b[1]))^(a[1]&b[1]);
    vedic2x2[3]=((a[1]&b[0])&(a[0]&b[1]))&(a[1]&b[1]);
end    
endfunction

wire [3:0]res0;
wire [3:0]res1;
wire [3:0]res2;
wire [3:0]res3;
wire [4:0]res0_adder;
wire [4:0]res1_adder;
assign res0=vedic2x2(a[1:0],b[1:0]);
assign res1=vedic2x2(a[3:2],b[1:0]);
assign res2=vedic2x2(a[1:0],b[3:2]);
assign res3=vedic2x2(a[3:2],b[3:2]);

assign s[1:0]       = res0[1:0];
assign res0_adder   = res1+res2;
assign res1_adder   = res0_adder[3:0]+res0[3:2];
assign s[3:2]       = res1_adder[1:0];
assign s[7:4]       = res3+{1'd0,res1_adder[4]|res0_adder[4],res1_adder[3:2]};
endmodule