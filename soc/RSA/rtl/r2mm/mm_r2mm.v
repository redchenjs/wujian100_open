/*
*   Name        :Radix-2 Montgomery multiplication algorithm,single unit
*   Description :
*   Orirgin     :20200706
*   Author      :
*/
module mm_r2mm
#(
    parameter K = 64
)
(
    input   wire            xi  ,
    input   wire [K-1  :0]  y   ,
    input   wire [K-1  :0]  m   ,

    input   wire [K+1-1:0]  si  ,
    output  wire [K+1-1:0]  so  
);
wire [K+2-1:0]a;
wire [K-1  :0]ximuly;
wire [K+2-1:0]buf0;
assign        ximuly =  xi  ==1'd1 ? y            : {(K){1'd0}} ;
assign        a      =  si + {1'd0,ximuly};
assign        buf0   =  a[0]==1'd1 ? ({2'd0,m}+a) : a           ;
assign        so     =  buf0>>1;
endmodule