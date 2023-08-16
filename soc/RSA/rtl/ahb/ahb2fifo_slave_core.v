//----------------------------------------------------------------
//  Copyright (c) 2010-2012 by Ando Ki.
//  All right reserved.
//----------------------------------------------------------------
// AHB Slave to synchronous FIFO
//----------------------------------------------------------------
// VERSION: 2012.02.17.
//----------------------------------------------------------------
// Macros and parameters:
//----------------------------------------------------------------
// Note:
//----------------------------------------------------------------
// Signal naming convention:
//    * forward: address and control information goes out
//    * bakward: data information comes in
//    * fwr_ : forward and fifo-write
//    * brd_ : backward and fifo-read
//----------------------------------------------------------------
`timescale 1ns/1ns

module ahb2fifo_slave_core#(
        parameter FIFO_AW=5
    ,   parameter ADDR_BASE = 32'h78000000
    ,   parameter K = 128
    ,   parameter N = 16
)(
   //----------------------------------------------------
   // AHB slave port
     input    wire              HRESETn
   , input    wire              HCLK
   , input    wire              HSEL
   , input    wire [31  :0]     HADDR
   , input    wire [1   :0]     HTRANS
   , input    wire              HWRITE
   , input    wire [2   :0]     HSIZE
   , input    wire [2   :0]     HBURST
   , input    wire [31  :0]     HWDATA  
   , output   reg  [31  :0]     HRDATA
   , output   reg  [1   :0]     HRESP
   , input    wire              HREADYin
   , output   reg               HREADYout
   //----------------------------------------------------
   // FIFO forward: address related
   , output  wire               fwr_clk  
   , input   wire               fwr_rdy  
   , output  reg                fwr_vld  
   , output  reg  [31   :0]     fwr_dat  
   , input   wire               fwr_full
   , input   wire [FIFO_AW:0]   fwr_cnt // how many rooms available
   //----------------------------------------------------
   // FIFO backward: data related
   , output  wire               brd_clk  
   , output  reg                brd_rdy  
   , input   wire               brd_vld  
   , input   wire [31   :0]     brd_dat  
   , input   wire               brd_empty
   , input   wire [FIFO_AW:0]   brd_cnt // how many items available
   //----------------------------------------------------
   // FIFO backward: data related
   , output  wire               rsa_start
   , input   wire               rsa_finish          
);
    //----------------------------------------------------
    assign fwr_clk   = HCLK;
    assign brd_clk   = HCLK;
    assign rsa_start = (REG_STATE[0] != 0) & (fwr_cnt==(K*N/32));
    //----------------------------------------------------
    reg [31:0]  T_ADDR;
    reg         T_WRITE;
    reg [ 1:0]  T_TRANS;
    reg [ 2:0]  T_BURST;
    reg [ 2:0]  T_SIZE;
    reg [ 4:0]  T_LENG;
    //----------------------------------------------------
    reg [31:0]  REG_STATE [0:1];
    //----------------------------------------------------
    reg [3:0] state;
    localparam      STH_IDLE    = 'h0,
                    STH_WREG    = 'h1,
                    STH_RREG    = 'h2,
                    STH_WAIT    = 'h3,
                    STH_ADDR    = 'h4,
                    STH_READ0   = 'h5,
                    STH_READ1   = 'h6,
                    STH_READ2   = 'h7,
                    STH_WRITE0  = 'h8,
                    STH_WRITE1  = 'h9;

   always @ (posedge HCLK or negedge HRESETn) begin
        if(HRESETn==0)begin
           REG_STATE[1] <=  0;
        end
        else if(rsa_finish)begin
           REG_STATE[1] <=  1;
        end
   end


   always @ (posedge HCLK or negedge HRESETn) begin
       if (HRESETn==0) begin
           HRDATA       <=  32'h0;
           HREADYout    <=  1'b1;
           HRESP        <=  2'b00; //`HRESP_OKAY;
           fwr_vld      <=  1'b0;
           fwr_dat      <=  32'h0;
           brd_rdy      <=  1'b0;
           T_ADDR       <=  32'h0;
           T_WRITE      <=  1'b0;
           T_TRANS      <=  2'h0;
           T_BURST      <=  3'h0;
           T_SIZE       <=  3'h0;
           state        <=  STH_IDLE;
           REG_STATE[0] <=  0;
       end else begin // if (HRESETn==0) begin
           case (state)
            STH_IDLE: begin
                fwr_vld   <= 1'b0; // see STH_WRITE1 (should be here)
                if (HSEL && HREADYin) begin
                   case (HTRANS)
                   2'b00, 2'b01: begin //`HTRANS_IDLE,`HTRANS_BUSY
                          HREADYout <= 1'b1;
                          state     <= STH_IDLE;
                    end
                   2'b10, 2'b11: begin //`HTRANS_NONSEQ,`HTRANS_SEQ
                          T_ADDR    <= HADDR;
                          T_WRITE   <= HWRITE;
                          T_TRANS   <= HTRANS;
                          T_BURST   <= HBURST;
                          T_SIZE    <= HSIZE;
                          if((HADDR == (ADDR_BASE + 32'd0)) & HWRITE)begin
                            HREADYout   <=  1'b1;
                            state       <=  STH_WREG;
                          end
                          else if((HADDR == (ADDR_BASE + 32'd4)) & (!HWRITE))begin
                            HREADYout   <=  1'b0;
                            state       <=  STH_RREG;
                          end
                          else if (HADDR == (ADDR_BASE + 32'd16))begin
                            HREADYout   <=  1'b0;
                            state       <=  STH_ADDR;
                          end
                          else begin
                            HREADYout   <=  1'b1;
                            state       <=  STH_IDLE;
                          end
                    end
                   endcase
                end 
                else begin// if (HSEL && HREADYin)
                    HREADYout <= 1'b1;
                end
            end // STH_IDLE
            STH_WREG: begin
                HREADYout       <=  1'b0;
                REG_STATE[0]    <=  HWDATA;
                state           <=  STH_IDLE;
            end
            STH_RREG: begin
                HREADYout       <=  1'b1;
                HRDATA          <=  REG_STATE[1];
                state           <=  STH_IDLE;
            end
            STH_ADDR: begin
                if (fwr_rdy) begin
                   if (T_WRITE) begin
                      state     <= STH_WRITE0;
                   end 
                   else begin
                        if(REG_STATE[1])begin
                            HREADYout <= 1'b0;
                            state     <= STH_READ0;
                        end
                        else begin
                            HREADYout <= 1'b1;
                            state     <= STH_IDLE;
                        end
                   end
                end
            end // STH_ADDR
            STH_READ0: begin
                if (fwr_rdy) begin
                    fwr_vld <= 1'b0;
                    state   <= STH_READ1;
                end
            end // STH_READ0
            STH_READ1: begin
                if (brd_vld) begin
                    brd_rdy <= 1'b1;
                    state   <= STH_READ2;
                end
            end // STH_READ1
            STH_READ2: begin
                HRDATA      <= brd_dat;
                HREADYout   <= 1'b1;
                brd_rdy     <= 1'b0;
                state       <= STH_IDLE;
            end // STH_READ1
            STH_WRITE0: begin
                HREADYout   <= 1'b1;
                fwr_vld     <= 1'b0;
                state       <= STH_WRITE1;
            end // STH_WRITE0
            STH_WRITE1: begin
                fwr_dat  <= HWDATA;
                fwr_vld  <= 1'b1;
                if (HSEL && HREADYin) begin
                    case (HTRANS)
                    2'b00, 2'b01: begin //`HTRANS_IDLE,`HTRANS_BUSY
                            HREADYout <= 1'b1;
                            state     <= STH_IDLE;
                    end
                    2'b10, 2'b11: begin //`HTRANS_NONSEQ,`HTRANS_SEQ
                            T_ADDR    <= HADDR;
                            T_WRITE   <= HWRITE;
                            T_TRANS   <= HTRANS;
                            T_BURST   <= HBURST;
                            T_SIZE    <= HSIZE;
                            HREADYout <= 1'b0;
                            state     <= STH_ADDR;
                    end
                    endcase
                end 
                else begin// if (HSEL && HREADYin)
                    HREADYout <= 1'b1;
                    state     <= STH_IDLE;
                end
            end // STH_WRITE1
            default: begin
                state <= STH_IDLE;
            end
           endcase // state
       end // if (HRESETn==0)
   end // always

   //----------------------------------------------------
   function [4:0] burst_leng;
        input [2:0] burst;
        begin
            case (burst)
            3'b010, 3'b011:  burst_leng = 5'h04;  // increment & wrap 4
            3'b100, 3'b101:  burst_leng = 5'h08;  // increment & wrap8
            3'b110, 3'b111:  burst_leng = 5'h10;  // increment & wrap16
            default: burst_leng = 5'h01;  // all other
            endcase
        end
   endfunction

endmodule
//----------------------------------------------------------------
// Revision History
//
// 2012.02.17.: timescale & include
// 2010.01.07.: Starting based on ahb2ahb_asm_slave_core.v
//              by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
