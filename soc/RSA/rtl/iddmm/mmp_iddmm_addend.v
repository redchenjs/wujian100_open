/*
*   Name        :IDDMM algorithm end adder,unsigned 257 = 129 + 256 + 256
*   Description :在COMMON模式中 加法器延迟(LATENCY)必须为0
*   Orirgin     :20200717
*   Author      :helrori2011@gmail.com
*   Timing      :
*/
module mmp_iddmm_addend
#(
    parameter LATENCY = 0   ,   //  do not modify!
    parameter METHOD  = "COMMON"//  COMMON      : use "+" LATENCY必须为0
                                //  3-2_DELAY2  :3-2压缩后使用2周期加法器 LATENCY无效
)
(
    input   wire             clk           ,
    input   wire             rst_n         ,

    input   wire  [128:0]    a_in          ,
    input   wire  [255:0]    b_in          ,
    input   wire  [255:0]    c_in          ,
    output  wire  [256:0]    d_out         
);
//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------
generate
    if (METHOD=="COMMON") begin// only for sim or common fpga:

        if (LATENCY==0) begin
            assign d_out=a_in+b_in+c_in;
        end else if(LATENCY==1)begin
            reg [256:0]lc;
            always@(posedge clk or negedge rst_n)begin
                if (!rst_n) begin
                    lc <= 'd0;
                end else begin
                    lc <= a_in+b_in+c_in;
                end
            end
            assign d_out=lc;
        end else begin
            reg [256:0]lc[0:LATENCY-1];
            integer j;
            always@(posedge clk or negedge rst_n)begin
                if (!rst_n) begin
                    for ( j = 0;j< LATENCY;j=j+1 ) begin
                        lc[j] <= 'd0;
                    end
                end else begin
                    for ( j = 0;j< LATENCY-1;j=j+1 ) begin
                        lc[0]   <= a_in+b_in+c_in;
                        lc[j+1] <= lc[j];
                    end
                end
            end
            assign d_out=lc[LATENCY-1];
        end
    end else if (METHOD=="3-2_DELAY2")begin// 3-2压缩，使用 + ，2个时钟出结果，输入数据需要保持2个时钟
        mmp_iddmm_addend_3_2 mmp_iddmm_addend_3_2
        (
            .clk   ( clk                ),
            .a_in  ( {127'd0,a_in}      ),//use low 129bits
            .b_in  ( b_in               ),//256
            .c_in  ( c_in               ),//256
            .d_out ( d_out              ) //257,根据加法运算全加器逻辑，3个256bit相加，结果为258bit，这里截掉了最高位。对于IDDMM特殊数据正确性未验证
        );
    end 
endgenerate

endmodule
/*
*   Name        :Full adder
*   Description :
*   Orirgin     :20200728
*   Author      :helrori
*   Timing      :
*/
module fa
(
    input   wire    a ,
    input   wire    b ,
    input   wire    ci,
    output  wire    s ,
    output  wire    co
);
assign  s =  a^b^ci;
assign  co= (a&b)|(ci&(a^b));
endmodule
/*
*   Name        :MLCLAA or "+" 3-2
*   Description :func d=a+b+c
*   Orirgin     :20200728
*   Author      :helrori
*   Timing      :
*/
module mmp_iddmm_addend_3_2
(
    input   wire             clk   ,
    input   wire  [255:0]    a_in  ,//use low 129bits
    input   wire  [255:0]    b_in  ,//256
    input   wire  [255:0]    c_in  ,//256
    output  wire  [256:0]    d_out  //257,根据加法运算全加器逻辑，3个256bit相加，结果为258bit，这里截掉了最高位。对于IDDMM特殊数据正确性未验证
);
generate
genvar i;
    //----------------------------------------input [255:0]a_in [255:0]b_in c_in
    for (i = 0;i<256 ;i=i+1 ) begin:loop
        wire sum,cout;
        fa fa
        (
            .a  ( a_in[i] ), 
            .b  ( b_in[i] ), 
            .ci ( c_in[i] ), 
            .s  ( sum     ),
            .co ( cout    )
        );
    end
    wire [255:0]fa_sum;
    wire [255:0]fa_cout;
    for (i = 0;i<256 ;i=i+1 ) begin:loop2
        assign  fa_sum [i]= loop[i].sum ;
        assign  fa_cout[i]= loop[i].cout;
    end
    wire final_fa_cout;
    wire final_adder_cout;
    wire [255:0]ain,bin,sum;
    
    assign ain           =  fa_sum;
    assign bin           = {fa_cout[254:0],1'd0};
    assign final_fa_cout =  fa_cout[255];
    //----------------------------------------output [255:0]ain [255:0]bin final_fa_cout

    // wire[1:0]h2 = final_fa_cout+final_adder_cout;
    // assign  {final_adder_cout,sum}  =   ain+bin; 
    // assign  d_out[256]              =   h2[0];
    // assign  d_out[255:0]            =   sum;

    wire _x;
    simple_p12adder256_3_2#(1) simple_p2adder256_3_2
    (
        .clk            ( clk           ),
        .ain            ( ain           ),//256
        .bin            ( bin           ),//256
        .final_fa_cout_i( final_fa_cout ),//1
        .full_sum       ({_x,d_out}     )//258
    );

endgenerate
endmodule

