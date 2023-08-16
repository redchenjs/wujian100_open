/*
*   Name        :Radix-2 Montgomery multiplication algorithm
*   Description :two units in series
*   Orirgin     :20200706
*   Author      :
*/

module mm_r2mm_2n
#(
    parameter K = 2048 //K%2==0 AND K<8191
)
(
    input   wire            clk     ,
    input   wire            rst_n   ,

    input   wire [K-1  :0]  x       ,
    input   wire [K-1  :0]  y       ,
    input   wire [K-1  :0]  m       ,

    input   wire            req     ,
    output  reg  [K-1  :0]  res     ,
    output  reg             val     
);
wire [K+1-1 :0]s_mid_w;
wire [K+1-1 :0]s_sid_w;
reg  [K+1-1 :0]s_sid_r={(K+1){1'd0}};
reg  [12    :0]sel    ='d0;
reg  [1     :0]buf0   ='d0;
wire           req_pp = buf0 == 2'b01;

mm_r2mm #(.K ( K ))mm_r2mm_0
(
    .xi                      ( x[sel]        ),
    .y                       ( y   [K-1  :0] ),
    .m                       ( m   [K-1  :0] ),
    .si                      ( s_sid_r       ),
    .so                      ( s_mid_w       )
);
mm_r2mm #(.K ( K ))mm_r2mm_1
(
    .xi                      ( x[sel+1]      ),
    .y                       ( y   [K-1  :0] ),
    .m                       ( m   [K-1  :0] ),
    .si                      ( s_mid_w       ),
    .so                      ( s_sid_w       )
);
always@(posedge clk or negedge rst_n)begin if(!rst_n) buf0 <= 'd0;else buf0 <= {buf0[0],req};end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        sel     <= 'd0;
        val     <= 'd0;
        s_sid_r <= {(K+1){1'd0}};
        res     <= {(K  ){1'd0}};
    end else begin
        if (req_pp && sel=='d0) begin
            sel     <= sel + 'd2;
            s_sid_r <= s_sid_w;
        end else if(sel>0)begin
            if(sel==K-2)begin
                res     <= (s_sid_w >= m)? s_sid_w-m : s_sid_w; //caution!
                val     <= 1'd1;
                sel     <=  'd0;
            end else begin
                sel     <= sel + 'd2;
                s_sid_r <= s_sid_w;
            end
        end else begin
            val     <= 1'd0;
            s_sid_r <= {(K+1){1'd0}};
        end
    end
end
endmodule