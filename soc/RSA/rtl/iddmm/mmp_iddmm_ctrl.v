/*
*   Name        :IDDMM algorithm,PE control module
*   Description :
*   Orirgin     :20200721
*                20200723-对 ref_wr_n,ctl_carry_clr,ctl_c_pre_clr加了一级寄存
*                            
*   Author      :helrori2011@gmail.com
*   Timing      :
*/
module mmp_iddmm_ctrl
#(
        parameter L1 = 0    // First mul128 latency
    ,   parameter L2 = 0    // First add latency
    ,   parameter L3 = 0    // m1*s latency
    ,   parameter L4 = 0    // mj*q latency
    ,   parameter D5 = 0    // 0:使用0延迟组合逻辑实现最后一级加法器。1:最后一级加法器两个周期出结果
    ,   parameter N  = 32   
    ,   parameter K  = 128   
    ,   parameter ADDR_W = $clog2(N)
)(
    input   wire                    clk           ,
    input   wire                    rst_n         ,

    input   wire                    task_req      ,

    // TO PE
    output  reg                     ctl_carry_clr ,// (j==0 && i==0);
    output  wire                    ctl_carry_ena ,// (j==N && c_pre_ena);
    output  wire                    ctl_carry_sel ,// (j==N);
    output  reg                     ctl_c_pre_clr ,// (j==0 && j00);
    output  wire                    ctl_c_pre_ena ,// (_jref);will be used if D5==1
    output  wire                    ctl_q_ena     ,// (j==0 && j00);
    input   wire                    carry         ,
    // TO SUB 
    output  reg                     comp_req      ,
    input   wire                    comp_end      ,
    // REF
    output  reg                     ref_an        ,
    output  wire  [6-1:0]           ref_addr_rdx  ,//xxx  [5-1:0]
    output  wire  [5-1:0]           ref_addr_rdy  ,
    output  wire  [5-1:0]           ref_addr_rdm  ,
    output  wire  [5-1:0]           ref_addr_rda  ,
    output  reg                     ref_wr_n      , 
    output  wire  [5-1:0]           ref_wr_a_addr ,
    output  wire                    ref_wr_a_ena  
);



generate
    if (D5==0) begin:d5_eq_0
        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
        reg   [5-1 :0]_i = 0 ;
        reg   [5   :0]_j = 0 ;
        wire  [5   :0]j_ ;
        reg   [5-1 :0] i = 0 ;
        reg   [5   :0] j = 0 ;
        reg   _j00       = 0 ;
        reg   j00        = 0 ;

        reg          task_en;
        reg   [2  :0]st;
        wire  [5  :0]bf0;
        //----------------------------------------------------------------------------------------------------------
        assign  ctl_carry_ena = ref_wr_n       ;// (j==N);        
        assign  ctl_carry_sel = ctl_carry_ena  ;// (j==N);  
        assign  ctl_q_ena     = ctl_c_pre_clr  ;// (j==0 && j00); 
        assign  ref_addr_rdx  = _j[6-1:0]      ;//xxx  _j[5-1:0]
        assign  ref_addr_rdy  = _i             ;
        assign  ref_addr_rdm  = _j[5-1:0]      ;
        assign  ref_addr_rda  = _j[5-1:0]      ;
        assign  bf0           = (j_ -  1'd1)   ;
        assign  ref_wr_a_addr = bf0[4:0]       ;
        assign  ref_wr_a_ena  = (j_ !=  'd0)   ;

        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
        mmp_iddmm_shift#(//将j的延时放在ctrl模块内(PE外面)可能会有问题
            .LATENCY ( L1+L2+L3+L4   ),
            .WD      (  6            )
        )shift_jnot0
        (
            .clk     ( clk           ),
            .rst_n   ( rst_n         ),
            .a_in    ( j             ),
            .b_out   ( j_            )
        );
        always@(posedge clk or negedge rst_n)begin
            if (!rst_n) begin
                task_en <= 1'd0;
            end else if (comp_end) begin
                task_en <= 1'd0;
            end else if (task_req) begin
                task_en <= 1'd1;
            end
        end
        always@(posedge clk or negedge rst_n)begin
            if (!rst_n) begin
                i   <= 'd0;
                j   <= 'd0;
                j00 <= 'd0;
                ref_wr_n        <= 'd0;// +20200723
                ctl_carry_clr   <= 'd0;// +20200723
                ctl_c_pre_clr   <= 'd0;// +20200723
            end else begin
                i   <= _i;
                j   <= _j;
                j00 <= _j00;
                ref_wr_n        <= (_j==N);     // +20200723
                ctl_carry_clr   <= (_j==0 && _i==0);// +20200723
                ctl_c_pre_clr   <= (_j==0 && _j00); // +20200723
            end
        end
        always@(posedge clk or negedge rst_n)begin
            if (!rst_n) begin
                st  <= 'd0;
                _j  <= 'd0;
                _i  <= 'd0;
                _j00<= 'd0;
                ref_an  <= 'd0;
                comp_req<=1'd0;
            end else if(task_en)begin
                case (st)
                    0:begin
                        _j00 <= 1'd1;
                        st   <= st  +   1'd1;
                    end 
                    1:begin
                        _j00 <= 1'd0;
                        st   <= st  +   1'd1;
                    end 
                    2:begin
                        if (_i==(N-1) && _j==N) begin
                            _j   <=  'd0;
                            _i   <=  'd0;
                            st   <= st  +   1'd1;
                        end else if (_j==N) begin
                            _j   <=  'd0;
                            _i   <= _i + 1'd1;
                            _j00 <= 1'd1;
                            st   <=  'd1;
                        end else begin
                            _j   <= _j + 1'd1;
                        end
                    end 
                    3:begin // save_carry2an
                        if (ref_wr_a_ena==1'd0) begin
                            ref_an  <= carry;
                            st      <= st  +   1'd1;
                            comp_req<= 1'd1;                    
                        end else begin
                            st  <=  st;
                        end
                    end
                    4:begin // make_finalsub
                        if (comp_end) begin
                            comp_req<=1'd0;
                            st      <= 'd0;
                        end            
                    end
                    default:st  <= 'd0;
                endcase
            end
        end
        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
    end else if(D5==1) begin:d5_eq_1
        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
        reg   [5-1 :0]_i = 0 ;
        reg   [5   :0]_j = 0 ;
        wire  [5   :0]j_     ;
        reg   [5-1 :0] i = 0 ;
        reg   [5   :0] j = 0 ;
        reg   _j00       = 0 ;
        reg   j00        = 0 ;

        reg          task_en = 0;
        reg   [2  :0]st      = 0;
        wire  [5  :0]bf0        ;
        reg  _jref           = 0;
        reg   jref           = 0;
        wire  jref_             ;
        wire  uj_fuzzy_val=(j_!='d0);
        // reg   uj_fuzzy_val_  = 0;
        //----------------------------------------------------------------------------------------------------------
        assign  ctl_q_ena     = ctl_c_pre_clr  ;
        assign  ref_addr_rdx  = _j[6-1:0]      ;
        assign  ref_addr_rdy  = _i             ;
        assign  ref_addr_rdm  = _j[5-1:0]      ;
        assign  ref_addr_rda  = _j[5-1:0]      ;
        assign  ctl_c_pre_ena = jref           ;
        assign  bf0           = (j_ -  1'd1)   ;
        assign  ref_wr_a_addr = bf0[4:0]       ;
        assign  ref_wr_a_ena  = (uj_fuzzy_val&&jref_);
        // always@(posedge clk)begin uj_fuzzy_val_ <= uj_fuzzy_val; end
        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
        mmp_iddmm_shift#(//将j的延时放在ctrl模块内(PE外面)可能会有问题
            .LATENCY ( L1+L2+L3+L4   ),
            .WD      (  6+1          )
        )shift_jnot0
        (
            .clk     ( clk           ),
            .rst_n   ( rst_n         ),
            .a_in    ( {jref ,j }    ),
            .b_out   ( {jref_,j_}    )
        );
        always@(posedge clk or negedge rst_n)begin
            if (!rst_n) begin
                task_en <= 1'd0;
            end else if (comp_end) begin
                task_en <= 1'd0;
            end else if (task_req) begin
                task_en <= 1'd1;
            end
        end
        reg    ctl_carry_ena_r,ctl_carry_sel_r;
        assign ctl_carry_ena=ctl_carry_ena_r;
        assign ctl_carry_sel=ctl_carry_sel_r;
        always@(posedge clk or negedge rst_n)begin
            if (!rst_n) begin
                i   <= 'd0;
                j   <= 'd0;
                j00 <= 'd0;
                jref<= 'd0;
                ref_wr_n        <= 'd0;
                ctl_carry_clr   <= 'd0;
                ctl_carry_ena_r <= 'd0;
                ctl_carry_sel_r <= 'd0;
                ctl_c_pre_clr   <= 'd0;
            end else begin
                i   <= _i;
                j   <= _j;
                j00 <= _j00;
                jref<= _jref;
                ref_wr_n        <= (_j==N);     
                ctl_carry_clr   <= (_j==0 && _i==0);
                ctl_carry_ena_r <= (_j==N && _jref);
                ctl_carry_sel_r <= (_j==N);
                ctl_c_pre_clr   <= (_j==0 && _j00); 
            end
        end
        always@(posedge clk or negedge rst_n)begin
            if (!rst_n) begin
                _jref <=  1'd0;
            end else if(_j00)begin
                _jref <=  1'd0;
            end else begin
                _jref <= ~_jref;
            end
        end
        always@(posedge clk or negedge rst_n)begin
            if (!rst_n) begin
                st  <= 'd0;
                _j  <= 'd0;
                _i  <= 'd0;
                _j00<= 'd0;
                ref_an  <= 'd0;
                comp_req<=1'd0;
            end else if(task_en)begin
                case (st)
                    0:begin
                        _j00 <= 1'd1;
                        st   <= st  +   1'd1;
                    end 
                    1:begin
                        _j00 <= 1'd0;
                        st   <= st  +   1'd1;
                    end 
                    2:begin
                        if (_jref) begin
                            if (_i==(N-1) && _j==N) begin
                                _j   <=  'd0;
                                _i   <=  'd0;
                                st   <= st  +   1'd1;
                            end else if (_j==N) begin
                                _j   <=  'd0;
                                _i   <= _i + 1'd1;
                                _j00 <= 1'd1;
                                st   <=  'd1;
                            end else begin
                                _j   <= _j + 1'd1;
                            end                            
                        end
                    end 
                    3:begin // save_carry2an
                        if (uj_fuzzy_val==1'd0) begin //wait pipeling to finish
                            ref_an  <= carry;
                            st      <= st  +   1'd1;
                            comp_req<= 1'd1;                    
                        end else begin
                            st  <=  st;
                        end
                    end
                    4:begin // make_finalsub
                        if (comp_end) begin
                            comp_req<=1'd0;
                            st      <= 'd0;
                        end            
                    end
                    default:st  <= 'd0;
                endcase
            end
        end

        //----------------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------------
    end
endgenerate


endmodule