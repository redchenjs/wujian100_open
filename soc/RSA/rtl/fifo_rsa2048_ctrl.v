module fifo_rsa2048_ctrl#(
    parameter FDW = 32,
    parameter FAW = 8
)(
       input   wire           rst // asynchronous reset (active high)
     , input   wire           clr // synchronous reset (active high)
     , input   wire           clk
     , input   wire           rd_start
     , output  reg            rd_rdy
     , input   wire           rd_vld
     , input   wire [FDW-1:0] rd_din
     , input   wire           wr_rdy
     , output  reg            wr_vld
     , output  reg  [FDW-1:0] wr_dout
);
localparam K = 2048;

localparam  IDLE = 0,
            Rd_me_x = 1,
            Rd_me_y = 2,
            Wait = 3,
            Wr_me_s = 4;

reg     [2      :   0]  current_state;
reg     [FAW - 1:   0]  cnt_rd;
reg     [K - 1  :   0]  me_x;
reg     [K - 1  :   0]  me_y;
reg                     me_start;

wire                    me_valid;
wire    [K - 1  :   0]  me_result;
reg     [K - 1  :   0]  me_result_out;


me_top #(
    .K ( K ) //K%2==0 AND K<8191
)u_me_top(
      .clk         (clk         )
    , .rst_n       (!rst        )
    , .me_start    (me_start    )
    , .me_x        (me_x        )
    , .me_y        (me_y        )
    , .me_result   (me_result   )
    , .me_valid    (me_valid    )
);

always @(posedge clk or posedge rst)begin
    if(rst)begin
        current_state   <= IDLE;
        rd_rdy          <= 0;
        cnt_rd          <= 0;
        me_start        <= 0;
        wr_vld          <= 0;
    end
    else begin
        case(current_state)
            IDLE:begin
                wr_vld          <= 0;
                rd_rdy          <= 0;
                cnt_rd          <= 0;
                me_start        <= 0;
                if(rd_start)begin
                    current_state   <= Rd_me_x;
                    rd_rdy          <= 1;
                end
            end
            Rd_me_x:begin
                if(rd_vld)begin
                    cnt_rd          <=  cnt_rd + 1;
                    me_x            <=  {rd_din,me_x[K-1:FDW]};
                end
                if(cnt_rd == (K/FDW) - 1)begin
                    current_state   <= Rd_me_y;
                end
            end
            Rd_me_y:begin
                if(rd_vld)begin
                    cnt_rd          <=  cnt_rd - 1;
                    me_y            <=  {rd_din,me_y[K-1:FDW]};
                end
                if(cnt_rd == 0)begin
                    current_state   <= Wait;
                    me_start        <= 1;
                    rd_rdy          <= 0;
                end
            end
            Wait:begin
                me_start        <= 0;
                if(me_valid)begin
                    me_result_out   <= me_result;
                    current_state   <= Wr_me_s;
                end
            end
            Wr_me_s:begin
                if(wr_rdy)begin
                    wr_vld          <= 1;
                    wr_dout         <= me_result_out[FDW-1:0];
                    me_result_out   <= me_result_out >> FDW;
                    cnt_rd          <= cnt_rd + 1;
                end
                if(cnt_rd == (K/FDW) - 1)begin
                    current_state   <= IDLE;
                    wr_vld          <= 1;
                end
            end
        endcase
    end
end











endmodule