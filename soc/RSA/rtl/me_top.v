module me_top#(
    parameter K = 2048 //K%2==0 AND K<8191
)(
    input                   clk         ,
    input                   rst_n       ,

    input                   me_start    ,
    input       [K-1:0]     me_x        ,
    input       [K-1:0]     me_y        ,

    output      [K-1:0]     me_result   ,
    output                  me_valid    
);

wire    [K-1 : 0]       me_m         =   2048'hD27BF9F01E2A901DB957879F45F697330D21A21095DA4FA7D3AAB75454A8E9F0F4EA531ECE34F0C3BA9E02EB27D8F0DBE78EEDE4AC84061BEEF162D00B55C0DD772D28F23E994899AA19B9BEA7B12A8027A32A92190A3630E249544675488121565A23548FCD36F5382EEB993DB9CE3F526F20AB355E82D963D59541BC1161E211A03E3B372560840C57E12BD2F40EAC5FFCEC01B3F07C378C0A60B74BEF7B572764C88A4F98B61FA8CCD905AFAE779E6193378304D8EB17695CE71A173AC3DE11271753C48DB58546E5AF9917C1CEBBA5BB1AF3FCE3DF9516C0C95C9BC14BB65D1C53078C06C81AC0F3ED0D8634260E47BF780CF4F4996084DF732935194417;

wire    [K-1 : 0]       rou         =   2048'd4673544351928906046203075781234456340860342427899196109974867069526363176777061117077189764289655613554239663579860143609079969876638900167688504271598230385649191879021485056598880699114051861514654414884961445423529436019107325719994071840960517766786340070835303993299369955627885675392660430969044157724532756435959844957311792426868004933539296138443662043047401086365317568544931104789513349939071584303589265261126296127327257961555994661331209512214851352130313122890811637860959708241364460376994123694567495098924339095036693780940653864027629679264735358148812140150901416091997858508190468762454584277101;//2^(2*K) mod m
wire    [K-1 : 0]       mm_rou_1    =   2048'd5745827026436342522467946299197905857390481383327337347038188538970711392389601499825139024386282422049084069017505469779316527473425111900980069474194036860960244895375103837289976760106488485919734325353053503765803953878918058759863230663336519472743859233005196310620750026401202675616964315932382663267943872689927715978115910097180268726384517818574952770948042475641775285154528800294799682180492651872126944669494814934964191166952453321030515153424222620735286554128623407152302510307959708556458823336919897558273082090315314853422244873819729683359430850911143373961158818084935325175670062385266598263785;//1*2^(K) mod m
//result:
//16a5831ec2bccf96f3dd402cfa8eb055fef8d90b1be065063a3a7d54b4b4401002db743257c5c4a19b6cbe12c20790a189ec1a2974d4dba9a6ff5292f09a4de8a5c125768c671e6ad9eded25be7adcdd0eec2bef085af63512003869d9fc2f976404db8a55b435111a76c802aa74e372c38af53bf484299f14499f54f9c408104de8214a9d05711fded05643b36e2d6bed9d534fa6640d9e6f50b7a54a49de5546dab86f113e9fa0d46919174ac833268bbb3dbf71f2b4971497093e7299e20f919836f876c5cabec8035c83b59488fcc8984848b8501ca07a55850ec8c87347084324500f4e411eb072536ba69903531021a3957bfb7be5f80feab34add3e16
localparam  IDLE        = 0,
            stage_0     = 1,
            stage_1_0   = 2,
            stage_1_1   = 3,
            stage_2     = 4;

reg         [4   : 0]   current_stage;   
reg                     mm_req;
wire                    mm_val;
wire        [K-1 : 0]   mm_res;

reg         [K-1 : 0]   mm_x;
reg         [K-1 : 0]   mm_y;

reg         [K-1 : 0]   loop_counter;
reg         [K-1 : 0]   result2;
reg         [K-1 : 0]   yy;
reg                     skip_flag;
reg         [K-1 : 0]   result;
reg                     result_valid;


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



always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        mm_req          <=  0;
        current_stage   <=  IDLE;
        mm_x            <=  0;
        mm_y            <=  0;
        loop_counter    <=  0;
        result2         <=  0;
        yy              <=  0;
        skip_flag       <=  0;
        result          <=  0;
        result_valid    <=  0;
    end
    else begin
        case (current_stage)
            IDLE:begin
                result_valid    <=  0;
                result          <=  0;
                if(me_start)begin
                    mm_req          <=  1;
                    yy              <=  me_y;
                    mm_x            <=  me_x;
                    mm_y            <=  rou;
                    current_stage   <=  stage_0;
                end
            end
            stage_0:begin
                mm_req          <=  0;
                if(mm_val)begin
                    result2         <=  mm_res;
                    mm_req          <=  1;
                    mm_x            <=  mm_rou_1;
                    mm_y            <=  mm_rou_1;
                    current_stage   <=  stage_1_1;
                end
            end
            stage_1_0:begin
                mm_req          <=  0;
                if(mm_val | skip_flag)begin
                    if(loop_counter == K)begin
                        mm_req          <=  1;
                        mm_x            <=  mm_res;
                        mm_y            <=  1;
                        current_stage   <=  stage_2;
                    end
                    else begin
                        skip_flag       <=  0;
                        mm_req          <=  1;
                        mm_x            <=  mm_res;
                        mm_y            <=  mm_res;
                        current_stage   <=  stage_1_1;
                    end
                end
            end
            stage_1_1:begin
                mm_req          <=  0;
                if(mm_val)begin
                    if(yy[K-1])begin
                        mm_req          <=  1;
                        mm_x            <=  mm_res;
                        mm_y            <=  result2;
                    end
                    else begin
                        skip_flag       <=  1;
                    end
                    current_stage   <=  stage_1_0;
                    yy              <=  yy << 1;
                    loop_counter    <=  loop_counter + 1;
                end
            end
            stage_2:begin
                mm_req          <=  0;
                if(mm_val)begin
                    result          <=  mm_res;
                    result_valid    <=  1;
                    current_stage   <=  IDLE;
                end
            end
            default:begin
                current_stage   <=  IDLE;
            end
        endcase
    end
end

mm_r2mm_2n#(
    .K ( K )
)mm_r2mm_2n(
    .clk                     ( clk              ),
    .rst_n                   ( rst_n            ),
    .x                       ( mm_x             ),
    .y                       ( mm_y             ),
    .m                       ( me_m             ),
    .req                     ( mm_req           ),
    .res                     ( mm_res           ),
    .val                     ( mm_val           )
); 

assign me_result    = result;
assign me_valid     = result_valid;






























endmodule