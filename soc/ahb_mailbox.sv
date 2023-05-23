/*
 * ahb_mailbox.sv
 *
 *  Created on: 2023-05-15 21:28
 *      Author: Jack Chen <redchenjs@live.com>
 */

import ahb_enum::*;

module ahb_mailbox #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input logic hclk,
    input logic hresetn,

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

    output logic mailbox_intr
);

typedef struct packed {
    logic         intr;
    logic         resp; // 0: normal, 1: ack
    logic         full; // 0: empty, 1: full
    logic [28:23] rsvd;
    logic  [22:8] size;
    logic   [7:0] id;
} mbox_ctrl_t;

mbox_ctrl_t mbox_ctrl_0;

logic                  ram_hsel;
logic            [1:0] ram_hresp;
logic                  ram_hready;
logic [DATA_WIDTH-1:0] ram_hrdata;

logic [DATA_WIDTH-1:0] reg_hrdata;

logic                  reg_hsel_r;
logic [ADDR_WIDTH-1:0] reg_haddr_r;

wire rd_en = !haddr[15] & hsel & !hwrite;

wire [1:0] reg_hresp  = AHB_RESP_OKAY;
wire       reg_hready = 'b1;

assign hresp  = ram_hsel ? ram_hresp  : reg_hresp;
assign hready = ram_hsel ? ram_hready : reg_hready;
assign hrdata = ram_hsel ? ram_hrdata : reg_hrdata;

assign mailbox_intr = mbox_ctrl_0.intr;

sms_bank_64k_top #(
  .WIDTH(32),
  .DEPTH(8192)
) mbox_32k_top (
  .big_endian_b (1'b1),
  .mem_haddr(haddr),
  .mem_hclk(hclk),
  .mem_hprot(hprot),
  .mem_hrdata(ram_hrdata),
  .mem_hready(1'b1),
  .mem_hready_resp(ram_hready),
  .mem_hresp(ram_hresp),
  .mem_hrst_b(hresetn),
  .mem_hsel(hsel),
  .mem_hsize(hsize),
  .mem_htrans(htrans),
  .mem_hwdata(hwdata),
  .mem_hwrite(hwrite & haddr[15]),
  .region_rd_deny_flag(1'b0),
  .region_wr_deny_flag(1'b0),
  .sms_idle0()
);

always_ff @(posedge hclk or negedge hresetn)
begin
    if (!hresetn) begin
        ram_hsel <= 'b0;

        reg_hsel_r  <= 'b0;
        reg_haddr_r <= 'b0;

        reg_hrdata <= 'b0;

        mbox_ctrl_0 <= 'b0;
    end else begin
        ram_hsel <= haddr[15] & hsel;

        reg_hsel_r  <= !haddr[15] & hsel & hwrite;
        reg_haddr_r <=  haddr;

        if (reg_hsel_r) begin
            case (reg_haddr_r[7:0])
                8'h00: begin
                    mbox_ctrl_0 <= hwdata;
                end
            endcase
        end

        if (rd_en) begin
            case (haddr[7:0])
                8'h00: begin
                    reg_hrdata <= mbox_ctrl_0;
                end
                default: begin
                    reg_hrdata <= 'b0;
                end
            endcase
        end
    end
end

endmodule
