/*
*   Name        :IDDMM algorithm,unsigned 256 = 256 + 128 + 1
*   Description :
*   Orirgin     :20200717
*   Author      :helrori
*   Timing      :
*/
module mmp_iddmm_addfirst
#(
    parameter LATENCY = 2   ,
    parameter METHOD  = "COMMON"//  COMMON      : use "+"  LATENCY任意
                                //  3-2_PIPE2   :3-2压缩后使用2 级经典流水线加法器 LATENCY=2
                                //  3-2_PIPE1   :3-2压缩后使用1 级经典流水线加法器 LATENCY=1
)
( 
    input   wire             clk           ,
    input   wire             rst_n         ,

    input   wire  [255:0]    a_in          ,
    input   wire  [127:0]    b_in          ,
    input   wire             c_in          ,
    output  wire  [255:0]    d_out         
);
//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------


generate
    if (METHOD  == "COMMON") begin:common// only for sim or common fpga:
        if (LATENCY==0) begin
            assign d_out=a_in+b_in+c_in;
        end else if(LATENCY==1)begin
            reg [255:0]lc;
            always@(posedge clk or negedge rst_n)begin
                if (!rst_n) begin
                    lc <= 'd0;
                end else begin
                    lc <= a_in+b_in+c_in;
                end
            end
            assign d_out=lc;
        end else begin
            reg [255:0]lc[0:LATENCY-1];
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
        
    end else if(METHOD  == "3-2_PIPE2") begin:pipe2
        mmp_iddmm_addfirst_3_2#(2) mmp_iddmm_addfirst_3_2
        (
            .clk   ( clk                ),
            .a_in  ( a_in               ),//256
            .b_in  ( {128'd0,b_in}      ),//256 use low 128
            .c_in  ( c_in               ),//1
            .d_out ( d_out              ) //256,根据3-2全加器逻辑，256+128+1，结果为258bit，IDDMM算法需要256位，这里截掉了高2位。注意256+128+1的结果在最小在257bit下可以完整表示
        );
    end else if(METHOD == "3-2_PIPE1")begin
        mmp_iddmm_addfirst_3_2#(1) mmp_iddmm_addfirst_3_2
        (
            .clk   ( clk                ),
            .a_in  ( a_in               ),//256
            .b_in  ( {128'd0,b_in}      ),//256 use low 128
            .c_in  ( c_in               ),//1
            .d_out ( d_out              ) //256,根据3-2全加器逻辑，256+128+1，结果为258bit，IDDMM算法需要256位，这里截掉了高2位。注意256+128+1的结果在最小在257bit下可以完整表示
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
module fa_
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
*   Name        : 3-2 pipelined adder
*   Description :func d=a+b+c
*   Orirgin     :20200731
*   Author      :helrori
*   Timing      :
*/
module mmp_iddmm_addfirst_3_2#(
    parameter   STAGE = 2
)
(
    input   wire             clk   ,
    input   wire  [255:0]    a_in  ,//256
    input   wire  [255:0]    b_in  ,//256 use low 128
    input   wire             c_in  ,//1
    output  wire  [255:0]    d_out  //256,根据3-2全加器逻辑，256+128+1，结果为258bit，IDDMM算法需要256位，这里截掉了高2位。注意256+128+1的结果在最小在257bit下可以完整表示
);
generate
genvar i;
    //----------------------------------------input [255:0]a_in [255:0]b_in c_in
    for (i = 0;i<256 ;i=i+1 ) begin:loop
        wire sum,cout;
        if (i==0) begin
            fa_ fa_
            (
                .a  ( a_in[0] ), 
                .b  ( b_in[0] ), 
                .ci ( c_in    ), 
                .s  ( sum     ),
                .co ( cout    )
            );            
        end else begin
            fa_ fa_
            (
                .a  ( a_in[i] ),
                .b  ( b_in[i] ),
                .ci ( 1'd0    ),
                .s  ( sum     ),
                .co ( cout    )
            ); 
        end

    end
    wire [255:0]fa_sum;
    wire [255:0]fa_cout;
    for (i = 0;i<256 ;i=i+1 ) begin:loop2
        assign  fa_sum [i]= loop[i].sum ;
        assign  fa_cout[i]= loop[i].cout;
    end
    
    wire final_fa_cout ;//根据3-2压缩加法原理，经过2输入加法器后，输出的最高两位应当是 final_fa_cout + <加法器cout>
    wire [255:0]ain,bin;
    assign ain=fa_sum;
    assign bin={fa_cout[254:0],1'd0};
    assign final_fa_cout = fa_cout[255];
    
    //----------------------------------------output [255:0]ain [255:0]bin final_fa_cout


    //-------------------------------------- input [255:0]ain [255:0]bin final_fa_cout
    wire _x,__x;
    simple_p12adder256_3_2#(STAGE) simple_p2adder256_3_2
    (
        .clk            ( clk           ),
        .ain            ( ain           ),//256
        .bin            ( bin           ),//256
        .final_fa_cout_i( final_fa_cout ),//1
        .full_sum       ({_x,__x,d_out} )//258
    );
    //-------------------------------------- output [257:0]full_sum


endgenerate
endmodule
