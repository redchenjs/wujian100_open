/*
*   Name        :IDDMM algorithm pipelined,FPGA TOP 
*   Description :mmp_iddmm_top.v only for FPGA implementation
*   Tool        :Vivado 2017.4
*   Test part   :xc7k325tffg900-3 @ 304MHz.Verilog xilinx device relate at:
*                1. /src/mmp_iddmm_top.v/clk_300mhz_ibufgds_inst 
*                2. /src/common/simple_ram.v/(* ram_style = "distributed" *)
*   Orirgin     :20200722
*                20200812
*   Author      :helrori2011@gmail.com || lihehe muyexinya@163.com
*/
module mmp_iddmm_top
(
    input  wire      clk_300mhz_p   ,
    input  wire      clk_300mhz_n   ,
    input  wire      reset          ,
    output wire [7:0]led
);
wire        clk;
wire        rst_n      =   ~reset;
wire        res_val;
wire        task_end;
reg         task_req   =   0;
reg  [3  :0]st         =   0;
reg  [31 :0]cnt        =   0;
wire [127:0]res;
assign      led        =   res[7:0];

IBUFGDS clk_300mhz_ibufgds_inst
(
    .I      ( clk_300mhz_p  ),
    .IB     ( clk_300mhz_n  ),
    .O      ( clk           )
);
always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        st      <='d0;
        task_req<='d0;
        cnt     <='d0;
    end else begin
        case (st)
            0:begin
                if (cnt==50_000_000-1) begin
                    cnt     <= 'd0;
                    st      <= 'd1;
                    task_req<= 'd1;
                end else begin
                    cnt     <=  cnt + 1'd1;
                end
            end
            1:begin
                if (task_end) begin
                    task_req<= 'd0;
                    st      <= 'd2;
                end
            end 
            2:begin
                    st  <=  'd0;
            end 
            default:st  <=  'd0;
        endcase
    end
end
mmp_iddmm_sp #(
    .MULT_METHOD             ("TRADITION"  ),// | COMMON-? | TRADITION 10| VEDIC8 8   |
    .ADD1_METHOD             ("3-2_PIPE2"  ),// | COMMON-? | 3-2_PIPE1 1 | 3-2_PIPE2 2|
    .ADD2_METHOD             ("3-2_DELAY2" ),// | COMMON   | 3-2_DELAY2  |            |
    .MULT_LATENCY            (10           ),                            
    .ADD1_LATENCY            (2            ) 
)
mmp_iddmm_sp_0 (
    .clk                     ( clk         ),
    .rst_n                   ( rst_n       ),

    .wr_ena                  ( 1'd0        ),
    .wr_addr                 ( 'd0         ),
    .wr_x                    ( 'd0         ),
    .wr_y                    ( 'd0         ),
    .wr_m                    ( 'd0         ),
    .wr_m1                   ( 'd0         ),

    .task_req                ( task_req    ),
    .task_end                ( task_end    ),
    .task_grant              ( res_val     ),
    .task_res                ( res         )
);


endmodule