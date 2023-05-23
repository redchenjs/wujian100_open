/*
 * ahb_iopmp.sv
 *
 *  Created on: 2023-05-21 15:56
 *      Author: Jack Chen <redchenjs@live.com>
 */

import ahb_enum::*;

module ahb_iopmp #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input logic hclk,
    input logic hresetn,

    // Config port
    input logic                  hsel,
    input logic [ADDR_WIDTH-1:0] haddr,
    input logic            [3:0] hprot,
    input logic            [2:0] hsize,
    input logic            [1:0] htrans,
    input logic            [2:0] hburst,
    input logic                  hwrite,
    input logic [DATA_WIDTH-1:0] hwdata,

    output logic            [1:0] hresp,
    output logic                  hready,
    output logic [DATA_WIDTH-1:0] hrdata,

    // Slave port 0
    input logic [ADDR_WIDTH-1:0] s0_haddr,
    input logic            [3:0] s0_hprot,
    input logic            [2:0] s0_hsize,
    input logic            [1:0] s0_htrans,
    input logic            [2:0] s0_hburst,
    input logic                  s0_hwrite,
    input logic [DATA_WIDTH-1:0] s0_hwdata,

    output logic            [1:0] s0_hresp,
    output logic                  s0_hgrant,
    output logic                  s0_hready,
    output logic [DATA_WIDTH-1:0] s0_hrdata,

    // Slave port 1
    input logic [ADDR_WIDTH-1:0] s1_haddr,
    input logic            [3:0] s1_hprot,
    input logic            [2:0] s1_hsize,
    input logic            [1:0] s1_htrans,
    input logic            [2:0] s1_hburst,
    input logic                  s1_hwrite,
    input logic [DATA_WIDTH-1:0] s1_hwdata,

    output logic            [1:0] s1_hresp,
    output logic                  s1_hgrant,
    output logic                  s1_hready,
    output logic [DATA_WIDTH-1:0] s1_hrdata,

    // Master port 0
    output logic                  m0_hsel,
    output logic [ADDR_WIDTH-1:0] m0_haddr,
    output logic            [3:0] m0_hprot,
    output logic            [2:0] m0_hsize,
    output logic            [1:0] m0_htrans,
    output logic            [2:0] m0_hburst,
    output logic                  m0_hwrite,
    output logic [DATA_WIDTH-1:0] m0_hwdata,

    input logic            [1:0] m0_hresp,
    input logic                  m0_hgrant,
    input logic                  m0_hready,
    input logic [DATA_WIDTH-1:0] m0_hrdata,

    // Master port 1
    output logic                  m1_hsel,
    output logic [ADDR_WIDTH-1:0] m1_haddr,
    output logic            [3:0] m1_hprot,
    output logic            [2:0] m1_hsize,
    output logic            [1:0] m1_htrans,
    output logic            [2:0] m1_hburst,
    output logic                  m1_hwrite,
    output logic [DATA_WIDTH-1:0] m1_hwdata,

    input logic            [1:0] m1_hresp,
    input logic                  m1_hgrant,
    input logic                  m1_hready,
    input logic [DATA_WIDTH-1:0] m1_hrdata
);

typedef struct packed {
    logic [31:16] rsvd;
    logic  [15:8] hit;
    logic   [7:0] en;
} pmp_ctrl_t;

typedef struct packed {
    logic [31:0] mask;
    logic [31:0] base;
} pmp_conf_t;

pmp_ctrl_t pmp_ctrl_0;
pmp_ctrl_t pmp_ctrl_1;

pmp_conf_t pmp_conf_0_0;
pmp_conf_t pmp_conf_0_1;
pmp_conf_t pmp_conf_0_2;
pmp_conf_t pmp_conf_0_3;
pmp_conf_t pmp_conf_0_4;
pmp_conf_t pmp_conf_0_5;
pmp_conf_t pmp_conf_0_6;
pmp_conf_t pmp_conf_0_7;

pmp_conf_t pmp_conf_1_0;
pmp_conf_t pmp_conf_1_1;
pmp_conf_t pmp_conf_1_2;
pmp_conf_t pmp_conf_1_3;
pmp_conf_t pmp_conf_1_4;
pmp_conf_t pmp_conf_1_5;
pmp_conf_t pmp_conf_1_6;
pmp_conf_t pmp_conf_1_7;

logic [7:0] pmp_addr_0_hit;
logic [7:0] pmp_addr_1_hit;

logic                  hsel_r;
logic [ADDR_WIDTH-1:0] haddr_r;

wire rd_en = hsel & !hwrite;

assign hresp  = AHB_RESP_OKAY;
assign hready = 'b1;

assign m0_haddr  = s0_haddr;
assign m0_hprot  = s0_hprot;
assign m0_hsize  = s0_hsize;
assign m0_htrans = |pmp_addr_0_hit ? s0_htrans : AHB_TRANS_IDLE;
assign m0_hburst = s0_hburst;
assign m0_hwrite = s0_hwrite;
assign m0_hwdata = s0_hwdata;

assign m1_haddr  = s1_haddr;
assign m1_hprot  = s1_hprot;
assign m1_hsize  = s1_hsize;
assign m1_htrans = |pmp_addr_1_hit ? s1_htrans : AHB_TRANS_IDLE;
assign m1_hburst = s1_hburst;
assign m1_hwrite = s1_hwrite;
assign m1_hwdata = s1_hwdata;

assign s0_hresp  = m0_hresp;
assign s0_hgrant = m0_hgrant;
assign s0_hready = m0_hready;
assign s0_hrdata = m0_hrdata;

assign s1_hresp  = m1_hresp;
assign s1_hgrant = m1_hgrant;
assign s1_hready = m1_hready;
assign s1_hrdata = m1_hrdata;

assign pmp_addr_0_hit[0] = pmp_ctrl_0.en[0] & ((s0_haddr & pmp_conf_0_0.mask) == pmp_conf_0_0.base);
assign pmp_addr_0_hit[1] = pmp_ctrl_0.en[1] & ((s0_haddr & pmp_conf_0_1.mask) == pmp_conf_0_1.base);
assign pmp_addr_0_hit[2] = pmp_ctrl_0.en[2] & ((s0_haddr & pmp_conf_0_2.mask) == pmp_conf_0_2.base);
assign pmp_addr_0_hit[3] = pmp_ctrl_0.en[3] & ((s0_haddr & pmp_conf_0_3.mask) == pmp_conf_0_3.base);
assign pmp_addr_0_hit[4] = pmp_ctrl_0.en[4] & ((s0_haddr & pmp_conf_0_4.mask) == pmp_conf_0_4.base);
assign pmp_addr_0_hit[5] = pmp_ctrl_0.en[5] & ((s0_haddr & pmp_conf_0_5.mask) == pmp_conf_0_5.base);
assign pmp_addr_0_hit[6] = pmp_ctrl_0.en[6] & ((s0_haddr & pmp_conf_0_6.mask) == pmp_conf_0_6.base);
assign pmp_addr_0_hit[7] = pmp_ctrl_0.en[7] & ((s0_haddr & pmp_conf_0_7.mask) == pmp_conf_0_7.base);

assign pmp_addr_1_hit[0] = pmp_ctrl_1.en[0] & ((s1_haddr & pmp_conf_1_0.mask) == pmp_conf_1_0.base);
assign pmp_addr_1_hit[1] = pmp_ctrl_1.en[1] & ((s1_haddr & pmp_conf_1_1.mask) == pmp_conf_1_1.base);
assign pmp_addr_1_hit[2] = pmp_ctrl_1.en[2] & ((s1_haddr & pmp_conf_1_2.mask) == pmp_conf_1_2.base);
assign pmp_addr_1_hit[3] = pmp_ctrl_1.en[3] & ((s1_haddr & pmp_conf_1_3.mask) == pmp_conf_1_3.base);
assign pmp_addr_1_hit[4] = pmp_ctrl_1.en[4] & ((s1_haddr & pmp_conf_1_4.mask) == pmp_conf_1_4.base);
assign pmp_addr_1_hit[5] = pmp_ctrl_1.en[5] & ((s1_haddr & pmp_conf_1_5.mask) == pmp_conf_1_5.base);
assign pmp_addr_1_hit[6] = pmp_ctrl_1.en[6] & ((s1_haddr & pmp_conf_1_6.mask) == pmp_conf_1_6.base);
assign pmp_addr_1_hit[7] = pmp_ctrl_1.en[7] & ((s1_haddr & pmp_conf_1_7.mask) == pmp_conf_1_7.base);

always_ff @(posedge hclk or negedge hresetn)
begin
    if (!hresetn) begin
        hrdata <= 'b0;

        hsel_r  <= 'b0;
        haddr_r <= 'b0;

        pmp_ctrl_0 <= 'b0;
        pmp_ctrl_1 <= 'b0;

        pmp_conf_0_0 <= 'b0;
        pmp_conf_0_1 <= 'b0;
        pmp_conf_0_2 <= 'b0;
        pmp_conf_0_3 <= 'b0;
        pmp_conf_0_4 <= 'b0;
        pmp_conf_0_5 <= 'b0;
        pmp_conf_0_6 <= 'b0;
        pmp_conf_0_7 <= 'b0;

        pmp_conf_1_0 <= 'b0;
        pmp_conf_1_1 <= 'b0;
        pmp_conf_1_2 <= 'b0;
        pmp_conf_1_3 <= 'b0;
        pmp_conf_1_4 <= 'b0;
        pmp_conf_1_5 <= 'b0;
        pmp_conf_1_6 <= 'b0;
        pmp_conf_1_7 <= 'b0;
    end else begin
        hsel_r  <= hsel & hwrite;
        haddr_r <= haddr;

        pmp_ctrl_0.hit <= |pmp_addr_0_hit ? pmp_addr_0_hit : pmp_ctrl_0.hit;
        pmp_ctrl_1.hit <= |pmp_addr_1_hit ? pmp_addr_1_hit : pmp_ctrl_1.hit;

        if (hsel_r) begin
            case (haddr_r[7:0])
                8'h00: begin
                    pmp_ctrl_0.en <= hwdata;
                end
                8'h04: begin
                    pmp_ctrl_1.en <= hwdata;
                end
                8'h10: begin
                    pmp_conf_0_0.base <= hwdata;
                end
                8'h14: begin
                    pmp_conf_0_0.mask <= hwdata;
                end
                8'h18: begin
                    pmp_conf_0_1.base <= hwdata;
                end
                8'h1C: begin
                    pmp_conf_0_1.mask <= hwdata;
                end
                8'h20: begin
                    pmp_conf_0_2.base <= hwdata;
                end
                8'h24: begin
                    pmp_conf_0_2.mask <= hwdata;
                end
                8'h28: begin
                    pmp_conf_0_3.base <= hwdata;
                end
                8'h2C: begin
                    pmp_conf_0_3.mask <= hwdata;
                end
                8'h30: begin
                    pmp_conf_0_4.base <= hwdata;
                end
                8'h34: begin
                    pmp_conf_0_4.mask <= hwdata;
                end
                8'h38: begin
                    pmp_conf_0_5.base <= hwdata;
                end
                8'h3C: begin
                    pmp_conf_0_5.mask <= hwdata;
                end
                8'h40: begin
                    pmp_conf_0_6.base <= hwdata;
                end
                8'h44: begin
                    pmp_conf_0_6.mask <= hwdata;
                end
                8'h48: begin
                    pmp_conf_0_7.base <= hwdata;
                end
                8'h4C: begin
                    pmp_conf_0_7.mask <= hwdata;
                end
                8'h50: begin
                    pmp_conf_1_0.base <= hwdata;
                end
                8'h54: begin
                    pmp_conf_1_0.mask <= hwdata;
                end
                8'h58: begin
                    pmp_conf_1_1.base <= hwdata;
                end
                8'h5C: begin
                    pmp_conf_1_1.mask <= hwdata;
                end
                8'h60: begin
                    pmp_conf_1_2.base <= hwdata;
                end
                8'h64: begin
                    pmp_conf_1_2.mask <= hwdata;
                end
                8'h68: begin
                    pmp_conf_1_3.base <= hwdata;
                end
                8'h6C: begin
                    pmp_conf_1_3.mask <= hwdata;
                end
                8'h70: begin
                    pmp_conf_1_4.base <= hwdata;
                end
                8'h74: begin
                    pmp_conf_1_4.mask <= hwdata;
                end
                8'h78: begin
                    pmp_conf_1_5.base <= hwdata;
                end
                8'h7C: begin
                    pmp_conf_1_5.mask <= hwdata;
                end
                8'h80: begin
                    pmp_conf_1_6.base <= hwdata;
                end
                8'h84: begin
                    pmp_conf_1_6.mask <= hwdata;
                end
                8'h88: begin
                    pmp_conf_1_7.base <= hwdata;
                end
                8'h8C: begin
                    pmp_conf_1_7.mask <= hwdata;
                end
            endcase
        end

        if (rd_en) begin
            case (haddr[7:0])
                8'h00: begin
                    hrdata <= pmp_ctrl_0;
                end
                8'h04: begin
                    hrdata <= pmp_ctrl_1;
                end
                8'h10: begin
                    hrdata <= pmp_conf_0_0.base;
                end
                8'h14: begin
                    hrdata <= pmp_conf_0_0.mask;
                end
                8'h18: begin
                    hrdata <= pmp_conf_0_1.base;
                end
                8'h1C: begin
                    hrdata <= pmp_conf_0_1.mask;
                end
                8'h20: begin
                    hrdata <= pmp_conf_0_2.base;
                end
                8'h24: begin
                    hrdata <= pmp_conf_0_2.mask;
                end
                8'h28: begin
                    hrdata <= pmp_conf_0_3.base;
                end
                8'h2C: begin
                    hrdata <= pmp_conf_0_3.mask;
                end
                8'h30: begin
                    hrdata <= pmp_conf_0_4.base;
                end
                8'h34: begin
                    hrdata <= pmp_conf_0_4.mask;
                end
                8'h38: begin
                    hrdata <= pmp_conf_0_5.base;
                end
                8'h3C: begin
                    hrdata <= pmp_conf_0_5.mask;
                end
                8'h40: begin
                    hrdata <= pmp_conf_0_6.base;
                end
                8'h44: begin
                    hrdata <= pmp_conf_0_6.mask;
                end
                8'h48: begin
                    hrdata <= pmp_conf_0_7.base;
                end
                8'h4C: begin
                    hrdata <= pmp_conf_0_7.mask;
                end
                8'h50: begin
                    hrdata <= pmp_conf_1_0.base;
                end
                8'h54: begin
                    hrdata <= pmp_conf_1_0.mask;
                end
                8'h58: begin
                    hrdata <= pmp_conf_1_1.base;
                end
                8'h5C: begin
                    hrdata <= pmp_conf_1_1.mask;
                end
                8'h60: begin
                    hrdata <= pmp_conf_1_2.base;
                end
                8'h64: begin
                    hrdata <= pmp_conf_1_2.mask;
                end
                8'h68: begin
                    hrdata <= pmp_conf_1_3.base;
                end
                8'h6C: begin
                    hrdata <= pmp_conf_1_3.mask;
                end
                8'h70: begin
                    hrdata <= pmp_conf_1_4.base;
                end
                8'h74: begin
                    hrdata <= pmp_conf_1_4.mask;
                end
                8'h78: begin
                    hrdata <= pmp_conf_1_5.base;
                end
                8'h7C: begin
                    hrdata <= pmp_conf_1_5.mask;
                end
                8'h80: begin
                    hrdata <= pmp_conf_1_6.base;
                end
                8'h84: begin
                    hrdata <= pmp_conf_1_6.mask;
                end
                8'h88: begin
                    hrdata <= pmp_conf_1_7.base;
                end
                8'h8C: begin
                    hrdata <= pmp_conf_1_7.mask;
                end
                default: begin
                    hrdata <= 'b0;
                end
            endcase
        end
    end
end

endmodule
