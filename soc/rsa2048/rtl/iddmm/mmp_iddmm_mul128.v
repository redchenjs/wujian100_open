/*
*   Name        :IDDMM algorithm,unsigned 256 = 128 * 128
*   Description :
*   Orirgin     :20200717
*   Author      :helrori
*   Timing      :
*/
// (* use_dsp = "no" *)
module mmp_iddmm_mul128
#(
    parameter LATENCY = 4 ,
    parameter METHOD  = "COMMON" // 一种乘法器实现方法对应一种LATENCY大小，默认COMMON时，LATENCY大小任意
)
(
    input   wire             clk           ,
    input   wire             rst_n         ,

    input   wire  [127:0]    a_in          ,
    input   wire  [127:0]    b_in          ,
    output  wire  [255:0]    c_out         
);
//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------

// only for sim or common fpga:
generate
    if (METHOD  == "COMMON") begin
        if (LATENCY==0) begin
            assign c_out=a_in*b_in;
        end else if(LATENCY==1)begin
            reg [255:0]lc;
            always@(posedge clk or negedge rst_n)begin
                if (!rst_n) begin
                    lc <= 'd0;
                end else begin
                    lc <= a_in*b_in;
                end
            end
            assign c_out=lc;
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
                        lc[0]   <= a_in*b_in;
                        lc[j+1] <= lc[j];
                    end
                end
            end
            assign c_out=lc[LATENCY-1];
        end
    end else if(METHOD=="TRADITION")begin// 传统分组乘法，单组乘法器使用 * 实现
        mult mult_inst(                  // LATENCY
            .clk(clk),
            .rst_n(rst_n),
            .x(a_in),
            .y(b_in),
            .ret(c_out[127:0]),
            .carry(c_out[255:128])
        );
    end else if (METHOD=="VEDIC8") begin
        simple_vedic_128bit  simple_vedic_128bit_0 (
            .clk    ( clk      ),
            .a      ( a_in     ),
            .b      ( b_in     ),
            .s      ( c_out    )
        );
    end
endgenerate
// only for sim or common fpga end




endmodule