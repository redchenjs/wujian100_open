`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/13 22:03:08
// Design Name: 
// Module Name: me_iddmm_top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module me_iddmm_top_tb();

parameter K = 128;
parameter N = 16;

reg [K*N-1:0]big_x = 2048'hABA5E025B607AA14F7F1B8CC88D6EC01C2D17C536508E7FA10114C9437D9616C9E1C689A4FC54744FA7DFE66D6C2FCF86E332BFD6195C13FE9E331148013987A947D9556A27A326A36C84FB38BFEFA0A0FFA2E121600A4B6AA4F9AD2F43FB1D5D3EB5EABA13D3B382FED0677DF30A089869E4E93943E913D0DC099AA320B8D8325B2FC5A5718B19254775917ED48A34E86324ADBC8549228B5C7BEEEFA86D27A44CEB204BE6F315B138A52EC714888C8A699F6000D1CD5AB9BF261373A5F14DA1F568BE70A0C97C2C3EFF0F73F7EBD47B521184DC3CA932C91022BF86DD029D21C660C7C6440D3A3AE799097642F0507DFAECAC11C2BD6941CBC66CEDEEAB744;

reg [K*N-1:0]result =0;

parameter PERIOD  = 10 ;
reg     clk = 0;
reg     rst_n = 0;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end
initial
begin
    #(PERIOD*2) rst_n  =  1;
end

reg             me_start    =   0   ;
reg     [K-1:0] me_x        =   0   ;
reg             me_x_valid  =   0   ;
wire    [K-1:0] me_result           ;
wire            me_valid            ;


me_iddmm_top u_me_iddmm_top(
    .clk            (clk        )                  
  , .rst_n          (rst_n      )                  

  , .me_start       (me_start   )              

  , .me_x           (me_x       )          
  , .me_x_valid     (me_x_valid )              

  , .me_result      (me_result  )                  
  , .me_valid       (me_valid   )              
);

task rsa2048test; begin
    #(PERIOD*100)
    me_start = 1;
    #(PERIOD)
    me_start = 0;
    #(PERIOD*10)
    for (integer i = 0; i <= N; i = i + 1) begin
        @(posedge clk)
        me_x        =   big_x >> (K*i);
        me_x_valid  =   1;
    end
    me_x        =   0;
    me_x_valid  =   0;
    // while(1)begin
    //     wait(me_valid)begin
    //         result      = {result[(K*N-128-1):0],me_result};
    //     end
    //     $display("[mmp_iddmm_sp_tb.v]result_iddmm: \n0x%x\n",result);
    // end
end
endtask


initial begin
    rsa2048test;
end


endmodule
