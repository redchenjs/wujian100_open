/*
*   Name        :IDDMM algorithm,mmp top support
*   Description :4096bit 32 groups IDDMM algorithm
*                Device related XILINX feature at src/common/simple_ram.v,force LUT RAMs
*   Orirgin     :20200622
*               :20200721 - mm->mmp
*               :20200804 - add 3-2_DELAY2 method
*   Author      :helrori2011@gmail.com||lihehe muyexinya@163.com
*                
*   Timing      :Write ram first,then make task_req,maximum time cost:2176+32+32*2=2272
*                minimum time cost:2176+1+32=2209 when use 3-2_DELAY2
*   License     :
*/
// `define _VIEW_UJ_;
module mmp_iddmm_sp#(
        parameter MULT_METHOD  = "TRADITION"    // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                                // "TRADITION" :MULT_LATENCY=9                
                                                // "VEDIC8-8"  :VEDIC MULT, MULT_LATENCY=8 
    ,   parameter ADD1_METHOD  = "3-2_PIPE1"    // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                                // "3-2_PIPE2" :classic pipeline adder,stage 2,ADD1_LATENCY=2
                                                // "3-2_PIPE1" :classic pipeline adder,stage 1,ADD1_LATENCY=1
                                                // 
    ,   parameter ADD2_METHOD  = "3-2_DELAY2"   // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                                // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                                // 
    ,   parameter MULT_LATENCY = 0                                   
    ,   parameter ADD1_LATENCY = 0       

    ,   parameter K = 128                       // K bits in every group
    ,   parameter N = 16                        // Number of groups
    ,   parameter ADDR_W = $clog2(N)
)(
    input       wire                    clk         ,
    input       wire                    rst_n       ,
    
    input       wire [1  :0]            wr_ena      ,
    input       wire [ADDR_W-1:0]       wr_addr     ,
    input       wire [K-1:0]            wr_x        ,//low words first
    input       wire [K-1:0]            wr_y        ,//low words first
    input       wire [K-1:0]            wr_m        ,//low words first
    input       wire [K-1:0]            wr_m1       ,

    input       wire                    task_req    ,
    output      wire                    task_end    ,
    output      wire                    task_grant  ,
    output      wire [K-1:0]            task_res         
);
localparam L1      = MULT_LATENCY;// xj*yi latency
localparam L2      = ADD1_LATENCY;// First adder latency
localparam L3      = MULT_LATENCY;// m1*s  latency
localparam L4      = MULT_LATENCY;// mj*q  latency
localparam D5      = (ADD2_METHOD=="3-2_DELAY2")?1:0;//End adder method
wire ctl_carry_clr  ;
wire ctl_carry_ena  ;
wire ctl_carry_sel  ;
wire ctl_c_pre_clr  ;
wire ctl_c_pre_ena  ;
wire ctl_q_ena      ;
wire carry          ;
wire [K-1:0]xj      ;
wire [K-1:0]yi      ;
wire [K-1:0]mj      ;
reg  [K-1:0]m1      ;
wire [K-1:0]aj      ;
wire [K-1:0]uj      ;
wire comp_req       ;
wire comp_end       ;
wire [K-1:0]comp_res ;
wire comp_val     ;

assign task_end   = comp_end;
assign task_grant = comp_val;
assign task_res   = comp_res;
wire an;
wire [5-1 :0]   addr_compa,
                addr_compm,
                addr_rdy,
                addr_rdm,
                addr_rda,
                clra_addr,
                wr_a_addr;
wire [6-1:0]    addr_rdx;
wire            clra_mem;  
wire            clra_wren;
wire            wr_a_ena;

wire            wr_n;
//----------------------------------------------------------------------------------------------------------
always@(posedge clk)begin if (wr_ena) begin m1<=wr_m1; end else begin m1<=m1;end end
//----------------------------------------------------------------------------------------------------------
mmp_iddmm_ctrl #(
        .L1 ( L1 )
    ,   .L2 ( L2 )
    ,   .L3 ( L3 )
    ,   .L4 ( L4 )
    ,   .D5 ( D5 )
    ,   .K  ( K  )
    ,   .N  ( N  )
)mmp_iddmm_ctrl_0 (
    .clk                     ( clk              ),
    .rst_n                   ( rst_n            ),
    .task_req                ( task_req         ),
    // TO PE
    .ctl_carry_clr           ( ctl_carry_clr    ),
    .ctl_carry_ena           ( ctl_carry_ena    ),
    .ctl_carry_sel           ( ctl_carry_sel    ),
    .ctl_c_pre_clr           ( ctl_c_pre_clr    ),
    .ctl_c_pre_ena           ( ctl_c_pre_ena    ),
    .ctl_q_ena               ( ctl_q_ena        ),
    .carry                   ( carry            ),
    // TO SUB 
    .comp_req                ( comp_req         ),
    .comp_end                ( comp_end         ),
    // REF
    .ref_an                  ( an               ),
    .ref_addr_rdx            ( addr_rdx         ),
    .ref_addr_rdy            ( addr_rdy         ),
    .ref_addr_rdm            ( addr_rdm         ),
    .ref_addr_rda            ( addr_rda         ),
    .ref_wr_n                ( wr_n             ),
    .ref_wr_a_addr           ( wr_a_addr        ),
    .ref_wr_a_ena            ( wr_a_ena         )
);
mmp_iddmm_pe #(
        .L1                  ( L1 )
    ,   .L2                  ( L2 )
    ,   .L3                  ( L3 )
    ,   .L4                  ( L4 )
    ,   .D5                  ( D5 )
    ,   .MULT_METHOD         (MULT_METHOD)
    ,   .ADD1_METHOD         (ADD1_METHOD)
    ,   .ADD2_METHOD         (ADD2_METHOD)
    ,   .K                   ( K )
    ,   .N                   ( N )
)mmp_iddmm_pe_0 (
    .clk                     ( clk                  ),
    .rst_n                   ( rst_n                ),
    // PE
    .xj                      ( xj                   ),
    .yi                      ( yi     [K-1  :0]     ),
    .mj                      ( (wr_n)?  0   :mj     ),// caution
    .m1                      ( m1     [K-1  :0]     ),
    .aj                      ( (wr_n)?  0   :aj     ),// caution
    .ctl_carry_clr           ( ctl_carry_clr        ),// (j==0 && i==0);
    .ctl_carry_ena           ( ctl_carry_ena        ),// (j==N);        
    .ctl_carry_sel           ( ctl_carry_sel        ),        
    .ctl_c_pre_clr           ( ctl_c_pre_clr        ),// (j==0 && j00); 
    .ctl_c_pre_ena           ( ctl_c_pre_ena        ),// (jref);will be used if D5==1
    .ctl_q_ena               ( ctl_q_ena            ),// (j==0 && j00); 
    .carry                   ( carry                ),
    .uj                      ( uj     [K-1  :0]     )
);
mm_iddmm_sub #(
    .K ( K ),
    .N ( N )
)mm_iddmm_sub_0 (
    .clk                     ( clk                       ),
    .rst_n                   ( rst_n                     ),
    // SUB
    .task_req                ( comp_req                  ),
    .task_end                ( comp_end                  ),
    .res                     ( comp_res                  ),
    .res_val                 ( comp_val                  ),
    // TO MEMORY
    .clra_mem                ( clra_mem                  ),
    .clra_wren               ( clra_wren                 ),
    .clra_addr               ( clra_addr                 ),
    .aj                      ( aj        [K-1       :0]  ),
    .an                      ( {{127{1'd0}},an}          ),
    .mj                      ( mj        [K-1       :0]  ),
    .addr_a                  ( addr_compa[5-1       :0]  ),
    .addr_m                  ( addr_compm[5-1       :0]  )
);
//----------------------------------------------------------------------------------------------------------
simple_ram#(
    .width                   ( K                ),
    .widthad                 ( ADDR_W+1         ),//0-63,0-32 will be used
    .filename                ( "x.mem"))//caution:>>>>> addr32 must be 0 <<<<<
simple_ram_x(
    .clk                     ( clk              ),
    .wraddress               ( {1'd0,wr_addr}   ),//0-31
    .wren                    ( wr_ena[0]        ),
    .data                    ( wr_x             ),
    .rdaddress               ( addr_rdx         ),//0-32 will be read out
    .q                       ( xj               )
);
simple_ram#(
    .width                   ( K                ),
    .widthad                 ( ADDR_W           ),
    .filename                ( "y.mem"))
simple_ram_y(
    .clk                     ( clk              ),
    .wraddress               ( wr_addr          ),
    .wren                    ( wr_ena[1]        ),
    .data                    ( wr_y             ),
    .rdaddress               ( addr_rdy         ),
    .q                       ( yi               )
);
simple_ram#(
    .width                   ( K                ),
    .widthad                 ( ADDR_W           ),
    .filename                ( "m.mem"))
simple_ram_m(
    .clk                     ( clk              ),
    .wraddress               ( wr_addr          ),
    .wren                    ( wr_ena&0         ),
    .data                    ( wr_m             ),
    .rdaddress               ( (comp_req)?addr_compm:addr_rdm),
    .q                       ( mj               )
);
simple_ram#(
    .width                   ( K                ),
    .widthad                 ( ADDR_W           ),
    .filename                ("a0.mem"))
simple_ram_a(//a(0)~a(n-1)
    .clk                     ( clk                                ),
    .wraddress               ( (clra_mem)?clra_addr   :wr_a_addr  ),
    .wren                    ( (clra_mem)?clra_wren   :wr_a_ena   ),
    .data                    ( (clra_mem)?{K{1'd0}}   :uj         ),
    .rdaddress               ( (comp_req)?addr_compa  :addr_rda   ),
    .q                       ( aj                                 )
);
`ifdef _VIEW_UJ_
always@(posedge clk)begin
    if (wr_a_ena) begin
        $display("%d:%x",wr_a_addr,uj);
    end
end
`endif
endmodule