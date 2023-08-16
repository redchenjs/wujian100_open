`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/13 12:45:13
// Design Name: 
// Module Name: me_iddmm_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//function:result = x^^y mod m

module me_iddmm_top#(
    parameter K       = 128
  , parameter N       = 16
  , parameter ADDR_W  = $clog2(N)
)(
    input                   clk         
  , input                   rst_n       

  , input                   me_start

  , input       [K-1:0]     me_x
  , input                   me_x_valid

  , output      [K-1:0]     me_result   
  , output                  me_valid
);
localparam data_test = 0;

wire    [K*N-1 : 0]     me_y          ;
wire    [K-1   : 0]     me_m1         ;
reg     [K-1  : 0]      rou [N-1:0]   ;
reg     [K-1  : 0]      result [N-1:0];

generate
if(data_test == 1)begin:virtual_value

  assign     me_y         =   2048'hD091BE9D9A4E98A172BD721C4BC50AC3F47DAA31522DB869EB6F98197E63535636C8A6F0BA2FD4C154C762738FBC7B38BDD441C5B9A43B347C5B65CFDEF4DCD355E5E6F538EFBB1CC161693FA2171B639A2967BEA0E3F5E429D991FE1F4DE802D2A1D600702E7D517B82BFFE393E090A41F57E966A394D34297842552E15550B387E0E485D81C8CCCAAD488B2C07A1E83193CE757FE00F3252E4BD670668B1728D73830F7AE7D1A4C02E7AFD913B3F011782422F6DE4ED0EF913A3A261176A7D922E65428AE7AAA2497BB75BFC52084EF9F74190D0D24D581EB0B3DAC6B5E44596881200B2CE5D0FB2831D65F036D8E30D5F42BECAB3A956D277E3510DF8CBA9;

  assign     me_m1        = 
  128'h328289a3442afa98c0d743199fd3cc59;//m1=(-1*(mod_inv(m,2**K)))%2**K 

  initial begin
    rou = '{
      128'h250587be7ffcea8af2224d0c24a784ac, 
      128'h66dceef15517d28730b926cd85bef8bc, 
      128'hf574132b8d2e5fb4824f7404146d0071, 
      128'hae5aa259b0f090e1c15a835e843ae277, 
      128'hc1037cd639d9b522a7242dd9fd3c718c, 
      128'h4ac9db510421922d1f9d742ec2ef1925, 
      128'h91d437eef9dc0bb97e6e43fbf0823a70, 
      128'h82f95eb83f667683ad516f6d270b376, 
      128'ha0076f9933a5ea462bfecf79fe219bb1, 
      128'h946c528a30ca276a1186eb398bd0f97f, 
      128'h3ee3de936e02eaf2bc6c51e025336625, 
      128'h16a803895f5b66ecf2051eec22c192b0, 
      128'h63f54e7b725cecd6d04725c6ab23a6db, 
      128'h703b44bfd2987c471401fe1d88734c12, 
      128'h762b921e88de82cc44acb36f9d41fb28, 
      128'hbad9430aa0c0b48e24a84569e941386d
    };//2^(2*K) mod m
  end

  initial begin
    result = '{
      128'h2d84060fe1d56fe246a87860ba0968cc, 
      128'hf2de5def6a25b0582c5548abab57160f, 
      128'hb15ace131cb0f3c4561fd14d8270f24, 
      128'h1871121b537bf9e4110e9d2ff4aa3f22, 
      128'h88d2d70dc166b76655e64641584ed57f, 
      128'hd85cd56de6f5c9cf1db6abb98ab77ede, 
      128'ha9a5dcab7032c90ac7d11466c24631c0, 
      128'had90df54caa17d269c2a6abe43ee9e1d, 
      128'hee5fc1c4c8da9f7bf3a81ed42d0bf153, 
      128'ha00313fe4c0f83c873f59f48b41084a8, 
      128'hd89b3775b06749e0573326fa50518861, 
      128'h9e6cc87cfb2714e896a318e5e8c53c21, 
      128'heed8e8ac3b724a7ab91a5066e83e3144, 
      128'h5a44e50c031c206ae93f36a3643eb449, 
      128'ha2e3acf873f937e53f0c12f279cbd9f1, 
      128'hb84087f30b0b669f7b208cd6cae6bbe9 
    };//1*2^(K) mod m
  end

  // wire    [K*N-1 : 0]     me_m        =   2048'hD27BF9F01E2A901DB957879F45F697330D21A21095DA4FA7D3AAB75454A8E9F0F4EA531ECE34F0C3BA9E02EB27D8F0DBE78EEDE4AC84061BEEF162D00B55C0DD772D28F23E994899AA19B9BEA7B12A8027A32A92190A3630E249544675488121565A23548FCD36F5382EEB993DB9CE3F526F20AB355E82D963D59541BC1161E211A03E3B372560840C57E12BD2F40EAC5FFCEC01B3F07C378C0A60B74BEF7B572764C88A4F98B61FA8CCD905AFAE779E6193378304D8EB17695CE71A173AC3DE11271753C48DB58546E5AF9917C1CEBBA5BB1AF3FCE3DF9516C0C95C9BC14BB65D1C53078C06C81AC0F3ED0D8634260E47BF780CF4F4996084DF732935194417;
  // 47BF780CF4F4996084DF732935194417//low
  // 5d1c53078c06c81ac0f3ed0d8634260e
  // A5BB1AF3FCE3DF9516C0C95C9BC14BB6
  // 11271753C48DB58546E5AF9917C1CEBB
  // 6193378304D8EB17695CE71A173AC3DE
  // 2764C88A4F98B61FA8CCD905AFAE779E
  // 5FFCEC01B3F07C378C0A60B74BEF7B57
  // 11A03E3B372560840C57E12BD2F40EAC
  // 526F20AB355E82D963D59541BC1161E2
  // 565A23548FCD36F5382EEB993DB9CE3F
  // 27A32A92190A3630E249544675488121
  // 772D28F23E994899AA19B9BEA7B12A80
  // E78EEDE4AC84061BEEF162D00B55C0DD
  // F4EA531ECE34F0C3BA9E02EB27D8F0DB
  // 0D21A21095DA4FA7D3AAB75454A8E9F0
  // D27BF9F01E2A901DB957879F45F69733//high
  //reg     [K*N-1 : 0]     rou             =   2048'd4673544351928906046203075781234456340860342427899196109974867069526363176777061117077189764289655613554239663579860143609079969876638900167688504271598230385649191879021485056598880699114051861514654414884961445423529436019107325719994071840960517766786340070835303993299369955627885675392660430969044157724532756435959844957311792426868004933539296138443662043047401086365317568544931104789513349939071584303589265261126296127327257961555994661331209512214851352130313122890811637860959708241364460376994123694567495098924339095036693780940653864027629679264735358148812140150901416091997858508190468762454584277101;//2^(2*K) mod m
  //wire    [K-1   : 0]     mm_rou_1        = 2048'd5745827026436342522467946299197905857390481383327337347038188538970711392389601499825139024386282422049084069017505469779316527473425111900980069474194036860960244895375103837289976760106488485919734325353053503765803953878918058759863230663336519472743859233005196310620750026401202675616964315932382663267943872689927715978115910097180268726384517818574952770948042475641775285154528800294799682180492651872126944669494814934964191166952453321030515153424222620735286554128623407152302510307959708556458823336919897558273082090315314853422244873819729683359430850911143373961158818084935325175670062385266598263785;//1*2^(K) mod m
  //result:16a5831ec2bccf96f3dd402cfa8eb055fef8d90b1be065063a3a7d54b4b4401002db743257c5c4a19b6cbe12c20790a189ec1a2974d4dba9a6ff5292f09a4de8a5c125768c671e6ad9eded25be7adcdd0eec2bef085af63512003869d9fc2f976404db8a55b435111a76c802aa74e372c38af53bf484299f14499f54f9c408104de8214a9d05711fded05643b36e2d6bed9d534fa6640d9e6f50b7a54a49de5546dab86f113e9fa0d46919174ac833268bbb3dbf71f2b4971497093e7299e20f919836f876c5cabec8035c83b59488fcc8984848b8501ca07a55850ec8c87347084324500f4e411eb072536ba69903531021a3957bfb7be5f80feab34add3e16
end
else begin:real_value
  assign   me_y        =   2048'h010001;

  assign   me_m1       =   128'ha83c91fe83adee77f2b721fabf7087cf;//m1=(-1*(mod_inv(m,2**K)))%2**K 

  initial begin
    rou = '{
      128'h3b3636ddb77b46770293953c94d38c7f, //high
      128'ha989cab7674f8bc029f672ed4bc1e407, 
      128'h8da0a9833396589a2be50f3c0257f7d8, 
      128'h525494873a726189c85e35da41c5fe05, 
      128'h371f55c4d3b471d84fc357113be8ac1b, 
      128'h2ddde970a2a0875b3605cdd55b1e7290, 
      128'h3e20225580b2cf51563ac90e479b9e53, 
      128'ha74c4c130e45d5d2779fe0190392362f, 
      128'h7efc07819a449874a894cc94a57836fe, 
      128'h60fc3316cf5a9fe92db2d3d41e07b99f, 
      128'hd86c994a5e3feb778afe4c626b467f0f, 
      128'h9ff0efa078a154c27b7e898852a701cf, 
      128'h52c2e6f009a7ba570f27f5c69a0462b8, 
      128'h7ebcf4fa614fde607e0701e3c7e7f553, 
      128'h4bd36ae80c5edd6b360f354fbd446411,
      128'hf94fd24132d8bd2b4475933c32178b17 //low
    };//2^(2*K) mod m
  end

  initial begin
    result = '{
      128'h23e4a90c916cc13dcbaba3b8eac8f4eb, 
      128'h351ff156c891609a21d3ec9e0ee90fa5, 
      128'hb3d00aa900ffad071d2cbcb00a17bc59, 
      128'h4db9bb6219370fb38357de100455e243, 
      128'h385e46fc5fa4898e4492f0279c62b6d3, 
      128'ha48b3d36eaef1c4ff94dd8340eb596b3, 
      128'hde5675b4e5db8b9ec132d6bfa79c8e93, 
      128'hc20a2ce9f12f466d5da4ca9d919800e, 
      128'h556dbd12c5e08152839c74d9241c9db4, 
      128'h98edfaa1efe3f889e059101c726eaff9, 
      128'had44b2891ad0ec15282fb4fb904b530, 
      128'h3fd5a81fd30d733e503c2dd4a8d99656, 
      128'h61182ca847bf437405b14e4452d787db, 
      128'h26c53da62a61445586712f0fd91a5f1f, 
      128'hac6d97c5974e969be9f206c9950864f5,
      128'h5726a0566919c9fdd1a7b79c5c0b1f2f
    };//1*2^(K) mod m
  end
end
endgenerate

reg   [4        : 0]    current_state ;  
localparam  IDLE        = 0,
            state_0_0   = 1,
            state_0_1   = 2,
            state_1_0   = 3,
            state_1_1   = 4,
            state_2_0   = 5,
            state_2_1   = 6,
            state_3     = 7,
            state_4     = 8;

reg   [$clog2(K*N)-1  : 0]    loop_counter            ; 
reg   [K-1            : 0]    result2       [N-1 : 0] ;
reg   [K*N-1          : 0]    yy                      ;
reg                           result_valid            ;
reg   [K-1            : 0]    result_out              ; 
reg   [ADDR_W         : 0]    wr_x_cnt                ;

wire  [1              : 0]    wr_ena                  ;
reg                           wr_ena_x                ;
reg                           wr_ena_y                ;
reg   [ADDR_W-1       : 0]    wr_addr                 ;
reg   [K-1            : 0]    wr_x                    ;
reg   [K-1            : 0]    wr_y                    ;

reg                           task_req                ;

wire                          task_end                ;
wire                          task_grant              ;
wire  [K-1            : 0]    task_res                ;


//algorithm achievement:
  // rou = fastExpMod(2,2*nbit,p)
  // result = mont_r2mm(rou,1,p,nbit)

  //step0
  // result2 = mont_r2mm(xx,rou,p,nbit) 

  //step1
  // for(i) in range(nbit-1,-1,-1):
  //     result = mont_r2mm(result,result,p,nbit)
  //     if((yy>>i)&1==1):
  //         result = mont_r2mm(result,result2,p,nbit)

  //step2
  // result = mont_r2mm(result,1,p,nbit)
reg  [ADDR_W-1       : 0]    wr_addr_d1              = 0;
always@(posedge clk)begin
  wr_addr_d1 <= wr_addr;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        current_state   <=  IDLE;
        task_req        <=  0;
        wr_addr         <=  0;
        wr_ena_x        <=  0;
        wr_ena_y        <=  0;
        yy              <=  me_y;
        loop_counter    <=  0;
        result_valid    <=  0;
        result_out      <=  0;
        wr_x            <=  0;  
        wr_y            <=  0;
        wr_x_cnt        <=  0;
    end
    else begin
        case (current_state)
            IDLE:begin
              task_req          <=  0;
              yy                <=  me_y;
              loop_counter      <=  0;
              result_valid      <=  0;
              result_out        <=  0;
              wr_x              <=  0;  
              wr_y              <=  0;
              wr_addr           <=  0;
              wr_x_cnt          <=  0;
              if(me_start)begin
                current_state   <=  state_0_0;
              end
            end
            //write xx & rou
            state_0_0:begin
              if(me_x_valid)begin
                wr_x_cnt          <=  wr_x_cnt + 1;
                wr_addr           <=  wr_addr + 1;
                wr_ena_x          <=  1;
                wr_x              <=  me_x;
                wr_ena_y          <=  1;
                wr_y              <=  rou[wr_addr];
              end 
              else begin
                wr_ena_x          <=  0;
                wr_ena_y          <=  0;
              end
              if(wr_x_cnt == N)begin
                wr_x_cnt          <=  0;
                task_req          <=  1;
                wr_addr           <=  0;
                current_state     <=  state_0_1;
              end
            end
            //store result2
            state_0_1:begin
              if(task_end)begin
                task_req          <=  0;
                wr_addr           <=  0;
                current_state     <=  state_1_0;
              end
              if(task_req & task_grant)begin
                wr_addr           <=  wr_addr + 1;
                result2[wr_addr]  <=  task_res;
              end
            end
            //result = mont_r2mm(result,result,p,nbit)
            state_1_0:begin
              if((wr_addr_d1 == N-1)&(wr_ena_x | wr_ena_y))begin
                task_req          <=  1;
                wr_addr           <=  0;
                wr_ena_x          <=  0;
                wr_ena_y          <=  0;
                current_state     <=  state_2_0;
              end
              else begin
                wr_addr           <=  wr_addr + 1;
                wr_ena_x          <=  1;
                wr_x              <=  result[wr_addr];
                wr_ena_y          <=  1;
                wr_y              <=  result[wr_addr];
              end
            end
            //result = mont_r2mm(result,result2,p,nbit)
            state_1_1:begin
              if((wr_addr_d1 == N-1)&(wr_ena_x | wr_ena_y))begin
                task_req          <=  1;
                wr_addr           <=  0;
                wr_ena_x          <=  0;
                wr_ena_y          <=  0;
                current_state     <=  state_2_1;
              end
              else begin
                wr_addr           <=  wr_addr + 1;
                wr_ena_x          <=  1;
                wr_x              <=  result[wr_addr];
                wr_ena_y          <=  1;
                wr_y              <=  result2[wr_addr];
              end
            end
            //store result and decide whether to skip state_1_1
            state_2_0:begin
              if(task_end)begin
                task_req          <=  0;
                wr_addr           <=  0;
                current_state     <=  yy[K*N-1] ? state_1_1 : ((loop_counter == (K*N-1)) ? state_3 : state_1_0);
                yy                <=  yy << 1;
                loop_counter      <=  loop_counter == (K*N-1) ? loop_counter : loop_counter + 1;
              end
              if(task_req & task_grant)begin
                wr_addr           <=  wr_addr + 1;
                result[wr_addr]   <=  task_res;
              end
            end
            //store result and decide whether to skip state_1_1
            state_2_1:begin
              if(task_end)begin
                task_req          <=  0;
                wr_addr           <=  0;
                current_state     <=  (loop_counter == (K*N-1)) ? state_3 : state_1_0;
              end
              if(task_req & task_grant)begin
                wr_addr           <=  wr_addr + 1;
                result[wr_addr]   <=  task_res;
              end
            end
            //result = mont_r2mm(result,1,p,nbit)
            state_3:begin
              if((wr_addr_d1 == N-1)&(wr_ena_x | wr_ena_y))begin
                task_req          <=  1;
                wr_addr           <=  0;
                wr_ena_x          <=  0;
                wr_ena_y          <=  0;
                current_state     <=  state_4;
              end
              else begin
                wr_addr           <=  wr_addr + 1;
                wr_ena_x          <=  1;
                wr_x              <=  result[wr_addr];
                wr_ena_y          <=  1;
                wr_y              <=  wr_addr==0 ? 1 : 0;
              end
            end
            //get final result
            state_4:begin
              if(task_end)begin
                task_req          <=  0;
                wr_addr           <=  0;
                current_state     <=  IDLE;
              end
              if(task_req & task_grant)begin
                wr_addr           <=  wr_addr + 1;
                result[wr_addr]   <=  task_res;
                result_out        <=  task_res;
                result_valid      <=  1;  
              end
              else begin
                result_valid      <=  0;
              end
            end
            //default state
            default:begin
                current_state     <=  IDLE;
            end
        endcase
    end
end


mmp_iddmm_sp #(
      . MULT_METHOD     ( "COMMON" )    // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                        // "TRADITION" :MULT_LATENCY=9                
                                        // "VEDIC8-8"  :VEDIC MULT, MULT_LATENCY=8 
    , . ADD1_METHOD     ( "COMMON" )    // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                        // "3-2_PIPE2" :classic pipeline adder,state 2,ADD1_LATENCY=2
                                        // "3-2_PIPE1" :classic pipeline adder,state 1,ADD1_LATENCY=1
                                        // 
    , . ADD2_METHOD     ( "COMMON")     // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                        // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                        // 
    , . MULT_LATENCY    ( 0           )                       
    , . ADD1_LATENCY    ( 0           )  

    , . K               ( K           ) // K bits in every group
    , . N               ( N           ) // Number of groups
)u_mmp_iddmm_sp(
      .clk              (clk          )
    , .rst_n            (rst_n        )

    , .wr_ena           (wr_ena       )
    , .wr_addr          (wr_addr_d1   )
    , .wr_x             (wr_x         ) //low words first
    , .wr_y             (wr_y         ) //low words first
    , .wr_m             (0) //low words first
    , .wr_m1            (me_m1        )

    , .task_req         (task_req     )
    , .task_end         (task_end     )
    , .task_grant       (task_grant   )
    , .task_res         (task_res     )    
);



assign wr_ena       = {wr_ena_y,wr_ena_x};
assign me_result    = result_out;
assign me_valid     = result_valid;



endmodule
