/*
 * rst.sv
 *
 *  Created on: 2023-05-15 20:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

module rst_top #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
) (
    input logic pclk,
    input logic presetn,

    input logic                  psel,
    input logic [ADDR_WIDTH-1:0] paddr,
    input logic                  pwrite,
    input logic                  penable,

    input  logic [DATA_WIDTH-1:0] pwdata,
    output logic [DATA_WIDTH-1:0] prdata,

    output logic sys_rst_n
);

typedef struct packed {
    logic [7:0] rsvd_3;
    logic [7:0] rsvd_2;
    logic [7:0] rsvd_1;
    logic [7:1] rsvd_0;
    logic       rst_n;
} rst_ctrl_0_t;

rst_ctrl_0_t rst_ctrl_0;

wire wr_en = psel &  penable &  pwrite;
wire rd_en = psel & !penable & !pwrite;

assign sys_rst_n = rst_ctrl_0.rst_n;

always_ff @(posedge pclk or negedge presetn)
begin
    if (!presetn) begin
        prdata <= 'b0;

        rst_ctrl_0 <= 'b0;
    end else begin
        if (wr_en) begin
            case (paddr)
                8'h00: begin
                    rst_ctrl_0 <= pwdata;
                end
            endcase
        end

        if (rd_en) begin
            case (paddr)
                8'h00: begin
                    prdata <= rst_ctrl_0;
                end
                default: begin
                    prdata <= 'b0;
                end
            endcase
        end
    end
end

endmodule