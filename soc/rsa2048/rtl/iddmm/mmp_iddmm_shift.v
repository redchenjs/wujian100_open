/*
*   Name        :IDDMM algorithm shift
*   Description :
*   Orirgin     :20200717
*   Author      :helrori
*   Timing      :
*/
module mmp_iddmm_shift
#(
    parameter LATENCY = 4   ,
    parameter WD      = 256
)
(
    input   wire             clk           ,
    input   wire             rst_n         ,

    input   wire  [WD-1:0]   a_in          ,
    output  wire  [WD-1:0]   b_out         
);
//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------
generate
    if (LATENCY==0) begin
        assign b_out=a_in;
    end else if(LATENCY==1)begin
        reg [WD-1:0]lc;
        always@(posedge clk or negedge rst_n)begin
            if (!rst_n) begin
                lc <= 'd0;
            end else begin
                lc <= a_in;
            end
        end
        assign b_out=lc;
    end else begin
        reg [WD-1:0]lc[0:LATENCY-1];
        integer j;
        always@(posedge clk or negedge rst_n)begin
            if (!rst_n) begin
                for ( j = 0;j< LATENCY;j=j+1 ) begin
                    lc[j] <= 'd0;
                end
            end else begin
                for ( j = 0;j< LATENCY-1;j=j+1 ) begin
                    lc[0]   <= a_in;
                    lc[j+1] <= lc[j];
                end
            end
        end
        assign b_out=lc[LATENCY-1];        
    end
endgenerate



endmodule



