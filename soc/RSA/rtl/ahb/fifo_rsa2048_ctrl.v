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

localparam iddmm = 1;

generate 
if (iddmm==1) begin:iddmm1

    localparam K = 128;
    localparam N = 16;

    localparam  IDLE    = 0,
                Rd_me_x = 1,
                Wait    = 2,
                Wr_me_s = 3;

    reg     [2      :   0]  current_state;
    reg     [FAW - 1:   0]  cnt_rd;
    reg     [FAW - 1:   0]  cnt_n;

    reg     [K-1:0]     me_x                =   0       ;       
    reg                 me_x_valid          =   0       ; 
    wire    [K-1:0]     me_result                       ;
    reg     [K-1:0]     me_result_out[N-1:0]            ;
    wire                me_valid                        ;

    wire                me_start                        ;
    assign              me_start            = rd_start  ;

    always @(posedge clk or posedge rst)begin
        if(rst)begin
            current_state   <= IDLE;
            rd_rdy          <= 0;
            cnt_rd          <= 0;
            cnt_n           <= 0;
            wr_vld          <= 0;
        end
        else begin
            case(current_state)
                IDLE:begin
                    wr_vld          <= 0;
                    rd_rdy          <= 0;
                    cnt_rd          <= 0;
                    cnt_n           <= 0;
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
                        me_x_valid      <=  1;
                        cnt_rd          <=  0;
                        cnt_n           <=  cnt_n + 1;
                    end
                    else begin
                        me_x_valid      <=  0;
                    end
                    if((cnt_n == N-1) & (cnt_rd == (K/FDW) - 1))begin
                        cnt_n           <=  0;
                        cnt_rd          <=  0;
                        me_x_valid      <=  1;
                        current_state   <=  Wait;
                    end
                end
                Wait:begin
                    me_x_valid      <=  0;
                    if(me_valid)begin
                        me_result_out[cnt_n]    <= me_result;
                        cnt_n                   <= cnt_n + 1;
                    end
                    if(cnt_n == N-1) begin
                        cnt_n                   <= 0;
                        current_state           <= Wr_me_s;
                    end
                end
                Wr_me_s:begin
                    if(wr_rdy)begin
                        wr_vld                  <= 1;
                        wr_dout                 <= me_result_out[cnt_n][FDW-1:0];
                        me_result_out[cnt_n]    <= me_result_out[cnt_n] >> FDW;
                        cnt_rd                  <= cnt_rd + 1;
                    end
                    if(cnt_rd == (K/FDW) - 1)begin
                        cnt_n           <=  cnt_n + 1;
                        cnt_rd          <=  0;
                        wr_vld          <=  1;
                    end
                    if((cnt_n == N-1) & (cnt_rd == (K/FDW) - 1)) begin
                        cnt_n           <=  0;
                        cnt_rd          <=  0;
                        wr_vld          <=  1;
                        current_state   <= IDLE;
                    end
                end
            endcase
        end
    end


    me_iddmm_top #(
        .K              ( K )
    ,   .N              ( N )
    )u_me_iddmm_top(
        .clk            (clk        )
    ,   .rst_n          (!rst       )

    ,   .me_start       (me_start   )

    ,   .me_x           (me_x       )
    ,   .me_x_valid     (me_x_valid )

    ,   .me_result      (me_result  )
    ,   .me_valid       (me_valid   )
    );

end
else begin:r2mm
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
end
endgenerate









endmodule

