/*
*   Name        :256bit 1 or 2 stage pipelined adder
*   Description :256bit 1 or 2 stage pipelined adder，为了对接3-2压缩的输出，本模块含有final_fa_cout信号,不用可以置零
*   Orirgin     :20200731
*   Author      :helrori2011@gmail.com
*   Timing      :
*/
module simple_p12adder256_3_2
#(
    parameter STAGE = 1 //1 OR 2
)
(
    input   wire            clk,

    input   wire [255:0]    ain ,
    input   wire [255:0]    bin ,
    input   wire            final_fa_cout_i,

    output  wire [257:0]    full_sum 
);


generate
    if (STAGE==2) begin:stage2

        reg  [127:0]a_h,b_h,s_l,s2_l,s2_h;
        reg  c_l,ffc;
        reg  [1:0]h2;
        wire [1:0]h2_;
        wire c_h;
        wire [127:0]s2_h_;
        assign {c_h,s2_h_} = c_l+a_h+b_h;
        assign h2_ = ffc+c_h;
        always@(posedge clk)begin
            {c_l,s_l}       <=  ain[127:0]+bin[127:0];
            {ffc,a_h,b_h}   <= {final_fa_cout_i,ain[255:128],bin[255:128]};
            s2_h            <=  s2_h_;
            s2_l            <=  s_l;
            h2              <=  h2_;
        end
        assign full_sum={h2,s2_h,s2_l};

    end else if(STAGE==1)begin:stage1

        reg  [127:0]a_h,b_h,s_l;
        reg  c_l,ffc;
        wire [1:0]h2_;
        wire c_h;
        wire [127:0]s2_h_;
        assign {c_h,s2_h_} = c_l+a_h+b_h;
        assign h2_ = ffc+c_h;
        always@(posedge clk)begin
            {c_l,s_l}       <=   ain[127:0]+bin[127:0];
            {ffc,a_h,b_h}   <= {final_fa_cout_i,ain[255:128],bin[255:128]};
        end
        assign full_sum={h2_,s2_h_,s_l};
        
    end
endgenerate
endmodule