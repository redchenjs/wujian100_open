//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//--------------------------------------------------------
`timescale 1ns/1ns

`ifndef CLK_FREQ
`define CLK_FREQ       50000000
`endif
`ifndef MEM_DELAY
`define MEM_DELAY 0
`endif
`ifndef SIZE_IN_BYTES
`define SIZE_IN_BYTES 1024
`endif

module ahb_rsa2048_tb;
   //------------------------------------------------
   localparam SIZE_IN_BYTES=`SIZE_IN_BYTES // memory size
            , DELAY        =`MEM_DELAY; // access delay if any for AMBA3/4
   //------------------------------------------------
   reg         HRESETn= 1'b0;
   reg         HCLK   = 1'b0;
   wire        T_HBUSREQ;
   wire        T_HGRANT = T_HBUSREQ; // no arbiter
   wire [31:0] T_HADDR     ;
   wire [3:0]  T_HPROT     ;
   wire        T_HLOCK     ;
   wire [1:0]  T_HTRANS    ;
   wire        T_HWRITE    ;
   wire [2:0]  T_HSIZE     ;
   wire [2:0]  T_HBURST    ;
   wire [31:0] T_HWDATA    ;
   wire        T_HREADY    ;
   wire [31:0] T_HRDATA    ;
   wire [1:0]  T_HRESP     ;
   wire        T_HSEL      = T_HTRANS[1];
   wire        M_HBUSREQ;
   wire        M_HGRANT = M_HBUSREQ; // no arbiter
   wire [31:0] M_HADDR     ;
   wire [3:0]  M_HPROT     ;
   wire        M_HLOCK     ;
   wire [1:0]  M_HTRANS    ;
   wire        M_HWRITE    ;
   wire [2:0]  M_HSIZE     ;
   wire [2:0]  M_HBURST    ;
   wire [31:0] M_HWDATA    ;
   wire        M_HREADY    ;
   wire [31:0] M_HRDATA    ;
   wire [1:0]  M_HRESP     ;
   wire [31:0] S_HADDR     ;
   wire [3:0]  S_HPROT     ;
   wire [1:0]  S_HTRANS    ;
   wire        S_HWRITE    ;
   wire [2:0]  S_HSIZE     ;
   wire [2:0]  S_HBURST    ;
   wire [31:0] S_HWDATA    ;
   wire        S_HREADY    ;
   wire [31:0] S_HRDATA    [0:2];
   wire [1:0]  S_HRESP     [0:2];
   wire        S_HREADYout [0:2];
   wire        S_HSEL      [0:2];
   //------------------------------------------------
   bfm_ahb #(
        .START_ADDR     (32'h78000000)
      , .DEPTH_IN_BYTES (32'd256)
    )u_bfm_ahb (
        .HRESETn    (HRESETn    )
      , .HCLK       (HCLK       )
      , .HBUSREQ    (T_HBUSREQ  )
      , .HGRANT     (T_HGRANT   )
      , .HADDR      (T_HADDR    )
      , .HPROT      (T_HPROT    )
      , .HLOCK      (T_HLOCK    )
      , .HTRANS     (T_HTRANS   )
      , .HWRITE     (T_HWRITE   )
      , .HSIZE      (T_HSIZE    )
      , .HBURST     (T_HBURST   )
      , .HWDATA     (T_HWDATA   )
      , .HRDATA     (T_HRDATA   )
      , .HRESP      (T_HRESP    )
      , .HREADY     (T_HREADY   )
      , .IRQ        (1'b0       )
   );
   //----------------------------------------------------
   ahb_rsa2048 u_ahb_rsa2048 (
       .HRESETn     (HRESETn    )
     , .HCLK        (HCLK       )
     , .sHSEL       (T_HSEL     )
     , .sHADDR      (T_HADDR    )
     , .sHTRANS     (T_HTRANS   )
     , .sHWRITE     (T_HWRITE   )
     , .sHSIZE      (T_HSIZE    )
     , .sHBURST     (T_HBURST   )
     , .sHWDATA     (T_HWDATA   )
     , .sHRDATA     (T_HRDATA   )
     , .sHRESP      (T_HRESP    )
     , .sHREADYin   (1          )
     , .sHREADYout  (T_HREADY   )
   );
   
   //-----------------------------------------------------
   localparam CLK_FREQ=`CLK_FREQ;
   localparam CLK_PERIOD_HALF=1000000000/(CLK_FREQ*2);
   //-----------------------------------------------------
   always #CLK_PERIOD_HALF HCLK <= ~HCLK;
   //-----------------------------------------------------
   real stamp_x, stamp_y, delta;
   initial begin
       HRESETn <= 1'b0;
       repeat (5) @ (posedge HCLK);
       `ifdef RIGOR
        @ (posedge HCLK);
        @ (posedge HCLK); stamp_x = $time;
        @ (posedge HCLK); stamp_y = $time; delta = stamp_y - stamp_x;
        @ (negedge HCLK); $display("%m HCLK %f nsec %f Mhz", delta, 1000.0/delta);
       `endif
       repeat (5) @ (posedge HCLK);
       HRESETn <= 1'b1;
   end
   //------------------------------------------------
   `ifdef VCD
   initial begin
       $dumpfile("wave.vcd");
       $dumpvars(0);
   end
   `endif
endmodule
//--------------------------------------------------------
// Revision history:
//
// 2013.01.31.: Started by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
