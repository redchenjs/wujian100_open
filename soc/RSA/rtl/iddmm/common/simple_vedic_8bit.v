/*
*   Name        :8bit vedic multiplier
*   Description :
*   Orirgin     :20200805
*   Author      :helrori
*   Modify      :
*/
module simple_vedic_8bit
(
    input   wire    [7:0]   a   ,
    input   wire    [7:0]   b   ,
    output  wire    [15:0]  s 
);
wire [7:0]res0;
wire [7:0]res1;
wire [7:0]res2;
wire [7:0]res3;

wire [8:0]res0_adder;
wire [8:0]res1_adder;
simple_vedic_4bit simple_vedic_4bit_0 (.a( a  [3:0] ),.b( b  [3:0] ),.s( res0 ));
simple_vedic_4bit simple_vedic_4bit_1 (.a( a  [7:4] ),.b( b  [3:0] ),.s( res1 ));
simple_vedic_4bit simple_vedic_4bit_2 (.a( a  [3:0] ),.b( b  [7:4] ),.s( res2 ));
simple_vedic_4bit simple_vedic_4bit_3 (.a( a  [7:4] ),.b( b  [7:4] ),.s( res3 ));

assign s[3:0]       = res0[3:0];
assign res0_adder   = res1+res2;
assign res1_adder   = res0_adder[7:0]+res0[7:4];
assign s[7:4]       = res1_adder[3:0];
assign s[15:8]      = res3+{3'd0,res1_adder[8]|res0_adder[8],res1_adder[7:4]};
endmodule

// module simple_vedic_8bit
// (
//     input   wire    [7:0]   a   ,
//     input   wire    [7:0]   b   ,
//     output  wire    [15:0]  s 
// );
// wire [7:0]res0;
// wire [7:0]res1;
// wire [7:0]res2;
// wire [7:0]res3;

// wire [8:0]res0_adder;
// wire [8:0]res1_adder;
// simple_vedic_4bit simple_vedic_4bit_0 (.a( a  [3:0] ),.b( b  [3:0] ),.s( res0 ));
// simple_vedic_4bit simple_vedic_4bit_1 (.a( a  [7:4] ),.b( b  [3:0] ),.s( res1 ));
// simple_vedic_4bit simple_vedic_4bit_2 (.a( a  [3:0] ),.b( b  [7:4] ),.s( res2 ));
// simple_vedic_4bit simple_vedic_4bit_3 (.a( a  [7:4] ),.b( b  [7:4] ),.s( res3 ));

// assign s[3:0]       = res0[3:0];
// assign res0_adder   = res1+res2;
// assign res1_adder   = res0_adder[7:0]+res0[7:4];
// assign s[7:4]       = res1_adder[3:0];
// assign s[15:8]      = res3+{3'd0,res1_adder[8]|res0_adder[8],res1_adder[7:4]};
// endmodule