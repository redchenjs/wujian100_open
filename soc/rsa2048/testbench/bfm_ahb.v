//--------------------------------------------------------
// Copyright (c) 2013 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
// bfm_ahb.v
//--------------------------------------------------------
// VERSION = 2013.01.31.
//--------------------------------------------------------
// Macros and parameters
//     START_ADDR:       starting address to test
//     DEPTH_IN_BYTES:   num of bytes to test
//     END_ADDR:
//--------------------------------------------------------
`timescale 1ns/1ns

module bfm_ahb #(parameter START_ADDR=0
                         , DEPTH_IN_BYTES=32'h100
                         , END_ADDR=START_ADDR+DEPTH_IN_BYTES-1)
(
       input   wire        HRESETn
     , input   wire        HCLK
     , output  reg         HBUSREQ
     , input   wire        HGRANT
     , output  reg  [31:0] HADDR
     , output  reg  [3:0]  HPROT
     , output  reg         HLOCK
     , output  reg  [1:0]  HTRANS
     , output  reg         HWRITE
     , output  reg  [2:0]  HSIZE
     , output  reg  [2:0]  HBURST
     , output  reg  [31:0] HWDATA
     , input   wire [31:0] HRDATA
     , input   wire [1:0]  HRESP
     , input   wire        HREADY
     , input   wire        IRQ
);
    localparam full_size = 3'd4;
    localparam half_size = 3'd2;
    localparam byte_size = 3'd1;



    reg [31:0]data_got;
   //-----------------------------------------------------
   initial begin
        HBUSREQ = 0;
        HADDR   = 0;
        HPROT   = 0;
        HLOCK   = 0;
        HTRANS  = 0;
        HWRITE  = 0;
        HSIZE   = 0;
        HBURST  = 0;
        HWDATA  = 0;
        while  (HRESETn===1'bx) @ (posedge HCLK);
        while  (HRESETn===1'b1) @ (posedge HCLK);
        while  (HRESETn===1'b0) @ (posedge HCLK);       
        //write x
        rsa2048_Wtest(START_ADDR, END_ADDR, full_size);
        //wait for RSA2048 done
        data_got = 0;
        while(data_got == 0) begin
            ahb_read(START_ADDR + 4, full_size, data_got);
        end
        //read the result of (x^y mod m)
        rsa2048_Rtest(START_ADDR, END_ADDR, full_size);
        $finish(2);
   end

   //-----------------------------------------------------
   reg [31:0] data_burst[0:1023];
//    reg  [2047:0]   me_x = 2048'hABA5E025B607AA14F7F1B8CC88D6EC01C2D17C536508E7FA10114C9437D9616C9E1C689A4FC54744FA7DFE66D6C2FCF86E332BFD6195C13FE9E331148013987A947D9556A27A326A36C84FB38BFEFA0A0FFA2E121600A4B6AA4F9AD2F43FB1D5D3EB5EABA13D3B382FED0677DF30A089869E4E93943E913D0DC099AA320B8D8325B2FC5A5718B19254775917ED48A34E86324ADBC8549228B5C7BEEEFA86D27A44CEB204BE6F315B138A52EC714888C8A699F6000D1CD5AB9BF261373A5F14DA1F568BE70A0C97C2C3EFF0F73F7EBD47B521184DC3CA932C91022BF86DD029D21C660C7C6440D3A3AE799097642F0507DFAECAC11C2BD6941CBC66CEDEEAB744;
   reg  [2047:0]   me_x = 2048'd4383469006797802965900166396837597864367624855394082032209483702583300419438092976937961586140431423411590751040731516236398647423909090222492350986021111521063795972675638257881567069810319963159498543253395094090773193102711958604530272276517864565444139733944929225690945892841259072817147610572367526103873257620908807345079772017986871550742601352234687948107591938358658283638524388308868650507668402736086456298457776255381674353703558219659887562261764334209573964861812668120829861352034167252914887254749340347163862616148571581465231900374525669170143009397718879587641824557877536198051647542715605299480;
   //-----------------------------------------------------
   task rsa2048_Wtest;
        input [31:0] base_addr;  // start address
        input [31:0] end_addr; // end address
        input [2:0]  size;   // data size: 1, 2, 4
	//------------------
        integer i, error;
        reg [31:0] data, gen, got;
        begin
            ahb_write(0+base_addr, full_size, 16'hffff_ffff);
            for (i=base_addr; i<=(end_addr-size+1); i=i+size) begin
                data = me_x[31:0];
                ahb_write(16+base_addr, size, data);
                me_x = me_x >> 32;
            end
            // ahb_read(16+base_addr, size, data_got);
            // ahb_read(16+base_addr, size, data_got);
            // ahb_read(16+base_addr, size, data_got);
        end
   endtask

   // Test scenario comes here.
   task rsa2048_Rtest;
        input [31:0] start;  // start address
        input [31:0] finish; // end address
        input [2:0]  size;   // data size: 1, 2, 4
	//------------------
        integer i;
        reg [31:0] got;
        reg [2047 : 0] data_received;
        reg [31:0] reposit[START_ADDR:END_ADDR];
        begin
            for (i=start; i<=(finish-size+1); i=i+size) begin
                ahb_read(start+16, size, got);
                data_received = {got, data_received[2047:32]};
            end
            $display("received data: %x ", data_received);
        end
   endtask


   // Test scenario comes here.
   task memory_test;
        input [31:0] start;  // start address
        input [31:0] finish; // end address
        input [2:0]  size;   // data size: 1, 2, 4
	//------------------
        integer i, error;
        reg [31:0] data, gen, got;
        reg [31:0] reposit[START_ADDR:END_ADDR];
        begin
            $display("%m: read-after-write test with %d-byte access", size);
            error = 0;
            gen = $random(7);
            for (i=start; i<(finish-size+1); i=i+size) begin
                gen = $random&~32'b0;
                data = align(i, gen, size);
                ahb_write(i, size, data);
                ahb_read(i, size, got);
                got = align(i, got, size);
                if (got!==data) begin
                   $display("[%10d] %m A:%x D:%x, but %x expected", $time, i, got, data);
                   error = error+1;
                end
            end
            if (error==0)
                   $display("[%10d] %m OK: from %x to %x", $time, start, finish);
            //-------------------------------------------------------------
            $display("%m read-all-after-write-all with %d-byte access", size);
            error = 0;
            gen = $random(1);
            for (i=start; i<(finish-size+1); i=i+size) begin
                gen = {$random} & ~32'b0;
                data = align(i, gen, size);
                reposit[i] = data;
                ahb_write(i, size, data);
            end
            for (i=start; i<(finish-size+1); i=i+size) begin
                data = reposit[i];
                ahb_read(i, size, got);
                got = align(i, got, size);
                if (got!==data) begin
                   $display("[%10d] %m A:%x D:%x, but %x expected", $time, i, got, data);
                   error = error+1;
                end
            end
            if (error==0)
                   $display("[%10d] %m OK: from %x to %x", $time, start, finish);
        end
   endtask

   //-----------------------------------------------------
   task memory_test_burst;
        input [31:0] start; // start address
        input [31:0] finish;   // end address
        input [7:0]  leng;  // burst length
        integer i, j, k, r, error;
        reg [31:0] data, gen, got;
        reg [31:0] reposit[0:1023];
        integer seed;
        begin
          $display("%m: read-all-after-write-all burst test with %d-beat access", leng);
          error = 0;
          seed  = 111;
          gen = $random(seed);
          k = 0;
          if (finish>(start+leng*4)) begin
             for (i=start; i<(finish-(leng*4)+1); i=i+leng*4) begin
                 for (j=0; j<leng; j=j+1) begin
                     data_burst[j] = $random;
                     reposit[j+k*leng] = data_burst[j];
                 end
                 @ (posedge HCLK);
                 ahb_write_burst(i, leng);
                 k = k+1;
             end
             gen = $random(seed);
             k = 0;
             for (i=start; i<(finish-(leng*4)+1); i=i+leng*4) begin
                 @ (posedge HCLK);
                 ahb_read_burst(i, leng);
                 for (j=0; j<leng; j=j+1) begin
                     if (data_burst[j] != reposit[j+k*leng]) begin
                        error = error+1;
                        $display("%m A=%hh D=%hh, but %hh expected",
                                i+j*leng, data_burst[j], reposit[j+k*leng]);
                     end
                 end
                 k = k+1;
                 r = $random&8'h0F;
                 repeat (r) @ (posedge HCLK);
             end
             if (error==0)
                 $display("%m %d-length burst read-after-write OK: from %hh to %hh",
                           leng, start, finish);
          end else begin
              $display("%m %d-length burst read-after-write from %hh to %hh ???",
                           leng, start, finish);
          end
       end
    endtask

   //-----------------------------------------------------
   // As AMBA AHB bus uses non-justified data bus scheme,
   // data should be aligned according to the address.
   function [31:0] align;
            input [ 1:0] addr;
            input [31:0] data;
            input [ 2:0] size; // num of bytes
         begin
            `ifdef BIG_ENDIAN
            case (size)
            1: case (addr[1:0])
               0: align = data&32'hFF00_0000;
               1: align = data&32'h00FF_0000;
               2: align = data&32'h0000_FF00;
               3: align = data&32'h0000_00FF;
               endcase
            2: case (addr[1])
               0: align = data&32'hFFFF_0000;
               1: align = data&32'h0000_FFFF;
               endcase
            4: align = data&32'hFFFF_FFFF;
            default: $display($time,,"%m ERROR %d-byte not supported for size", size);
            endcase
            `else
            case (size)
            1: case (addr[1:0])
               0: align = data&32'h0000_00FF;
               1: align = data&32'h0000_FF00;
               2: align = data&32'h00FF_0000;
               3: align = data&32'hFF00_0000;
               endcase
            2: case (addr[1])
               0: align = data&32'h0000_FFFF;
               1: align = data&32'hFFFF_0000;
               endcase
            4: align = data&32'hFFFF_FFFF;
            default: $display($time,,"%m ERROR %d-byte not supported for size", size);
            endcase
            `endif
         end
   endfunction
   //-----------------------------------------------------
   `include "bfm_ahb_tasks.v"
   //-----------------------------------------------------
endmodule
//--------------------------------------------------------
// Revision history
//
// 2013.01.31: Started by Ando Ki (adki@dynalith.com)
//--------------------------------------------------------
