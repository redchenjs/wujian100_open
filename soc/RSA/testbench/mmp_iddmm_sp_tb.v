/*
*   Name        :IDDMM algorithm pipelined,TOP testbench 
*   Description :only for simulation and verifiy.define _VIEW_WAVEFORM_ to view waveform
*   Orirgin     :20200721
*                20200812
*   Author      :helrori2011@gmail.com
*   License     :
*/
`timescale  1ns / 1ps
// `define _VIEW_WAVEFORM_

`define _RSA2048
module mmp_iddmm_sp_tb;
//---------------------------------------------------------------------------------------------------

parameter PERIOD  = 10 ;
`ifdef _RSA256
    parameter K       = 128;
    parameter N       = 2  ;
    reg [K-1  :0]wr_m1_= 128'hBCB223FEDC24A059D838091DD2253531;//m1=(-1*(mod_inv(m,2**K)))%2**K 
    reg [K*N-1:0]big_m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
    reg [K*N-1:0]big_x = 256'hf913b410fe0d6b547a64ce68e9b7430214e56ec57e37d50dc22be4fe5e5f8d2f;
    reg [K*N-1:0]big_y = 256'h0de6501bd55b07ce9c83bbcbba280e5700e53c152304f6a1ab183a7b2e16e308;
`endif
`ifdef _RSA1024
    parameter K       = 128;
    parameter N       = 8  ;
    //reg [K-1  :0]wr_m1_= 128'hBCB223FEDC24A059D838091DD2253531;//m1=(-1*(mod_inv(m,2**K)))%2**K 
    reg [K*N-1:0]big_m = 256'he603bcf9fa9b405cd851ac0a3d33f9120c8957e79825c2a5bdae35000c5e6b1d302162200dd35659c2ae138eff1e6bb394a745f0f871b8af861371106fa0db087c74ac64df7c8b41f3363f7a791d833d680290523fc74d0b99260744681bfe8cc70b677d15d1546a34f2f4d361a43fed28555239471420e41a82e74d576982cf;
    reg [K*N-1:0]big_x = 256'h22ff5b47eb95c38b0a888e57377998711376cda83d693af54f7944012c2825774530af1b597b9b905653095ebc3ca3ef2e451934cebd839662a2e58d41d8c4462966e56d5af09f615530eab1fa857d09f9b80e649d0c0c94559884f2d76fdae70dcea6640f39912aacf016ea938c68b005372d1b3477dbeef0ae4530081b8724;
    reg [K*N-1:0]big_y = 256'h7481eb9b0d819f15632afd73befe15ece799cf7cd1893cc89c606226c4d1d42d26db5a67ddd5ec1966e0f835c3bfc091b94ddcbbe85d53e2e7fe81e94f7e0c31addb904c7af1630904bbb71b80f62e45977cacbf9e8c868e04f3471ec1733a2ad99dfbe5d6d4ad8573d09a79e76b7779234bfce84ff12324488e39d285345bed;
`endif
`ifdef _RSA2048
    parameter K       = 128;
    parameter N       = 16 ;
    reg [K-1  :0]wr_m1_= 'h328289a3442afa98c0d743199fd3cc59;//m1=(-1*(mod_inv(m,2**K)))%2**K 
    reg [K*N-1:0]big_m = 2048'hD27BF9F01E2A901DB957879F45F697330D21A21095DA4FA7D3AAB75454A8E9F0F4EA531ECE34F0C3BA9E02EB27D8F0DBE78EEDE4AC84061BEEF162D00B55C0DD772D28F23E994899AA19B9BEA7B12A8027A32A92190A3630E249544675488121565A23548FCD36F5382EEB993DB9CE3F526F20AB355E82D963D59541BC1161E211A03E3B372560840C57E12BD2F40EAC5FFCEC01B3F07C378C0A60B74BEF7B572764C88A4F98B61FA8CCD905AFAE779E6193378304D8EB17695CE71A173AC3DE11271753C48DB58546E5AF9917C1CEBBA5BB1AF3FCE3DF9516C0C95C9BC14BB65D1C53078C06C81AC0F3ED0D8634260E47BF780CF4F4996084DF732935194417;
    reg [K*N-1:0]big_x = 2048'hABA5E025B607AA14F7F1B8CC88D6EC01C2D17C536508E7FA10114C9437D9616C9E1C689A4FC54744FA7DFE66D6C2FCF86E332BFD6195C13FE9E331148013987A947D9556A27A326A36C84FB38BFEFA0A0FFA2E121600A4B6AA4F9AD2F43FB1D5D3EB5EABA13D3B382FED0677DF30A089869E4E93943E913D0DC099AA320B8D8325B2FC5A5718B19254775917ED48A34E86324ADBC8549228B5C7BEEEFA86D27A44CEB204BE6F315B138A52EC714888C8A699F6000D1CD5AB9BF261373A5F14DA1F568BE70A0C97C2C3EFF0F73F7EBD47B521184DC3CA932C91022BF86DD029D21C660C7C6440D3A3AE799097642F0507DFAECAC11C2BD6941CBC66CEDEEAB744;
    reg [K*N-1:0]big_y = 2048'hD091BE9D9A4E98A172BD721C4BC50AC3F47DAA31522DB869EB6F98197E63535636C8A6F0BA2FD4C154C762738FBC7B38BDD441C5B9A43B347C5B65CFDEF4DCD355E5E6F538EFBB1CC161693FA2171B639A2967BEA0E3F5E429D991FE1F4DE802D2A1D600702E7D517B82BFFE393E090A41F57E966A394D34297842552E15550B387E0E485D81C8CCCAAD488B2C07A1E83193CE757FE00F3252E4BD670668B1728D73830F7AE7D1A4C02E7AFD913B3F011782422F6DE4ED0EF913A3A261176A7D922E65428AE7AAA2497BB75BFC52084EF9F74190D0D24D581EB0B3DAC6B5E44596881200B2CE5D0FB2831D65F036D8E30D5F42BECAB3A956D277E3510DF8CBA9;
`endif
`ifdef _RSA4096
    parameter K       = 128;
    parameter N       = 32 ;
    reg [K-1  :0]wr_m1_= 'hecd18b11b6a41b9bb3ef4fcae3ba221f;//m1=(-1*(mod_inv(m,2**K)))%2**K 
    reg [K*N-1:0]big_m = 4096'hff5f4906fd176bc241535c78955d02f4d0acf376d736ae280077887200c758b7781b4432fa8baca2a81ad6fb0817051a00fccf8e15c63048681bcf8342b56433abd550affa489b289cd4f0482adce321c8cf4374ce15267692dfc8b0da108f4bb0e922d4a28402ef785c2516f6296486f8505ac3df05c0f953acce65e2dc5f1e59965ded73fa18ffb482ad1a2e5433d4df8211de12a3e7a71a1a084fed671fb11eeaf76f640c4fd549ea307b6622f798f027786e79232206de1507281d84c719209d408bc85f9ed2e1b82ecf72ff805a45221dc712c45a8dbc375e9b64227ec6b659a75fc5b5e051e776bcd9f4f6d82ebaff89a48c8494d6ed072372b846156af229994baab390ec57c00130255acc2cdf975783df4678153f0ca51b854425b1568b5b8b53239f50dd39fc53c3d41827a0687c435f6de5e98843def3fb7b0f7e701cdfb51517d6628392bd9291c16282556f5581766dd6a0a426a35312237399f93ad69502592c0f6d1864ba0b75600ee04cb406bcb833bc98527a0ac1249c6a918456b06f24611770c1708426b4d9041f7fe83be68fbc7018e461951d234ebf00227b4301911e24055c745203c888276f4db0c05f66514ae4e6b4bf4c8914e36c4a94bf57bf807dd40c7572d1a99c27d9f58af0877bb217c081d750d5edbe3c45eafc3ea6786560fa819873452cc8bffc7ab998ab70496b77fdadffb7ef2621;
    reg [K*N-1:0]big_x = 4096'h7ffffffef380fcff68e38a9fcc30b4c64e94dbc4f2b03a88ae0650f51f46fe1f4f10ba102d77eb77c1547e0c40e6d7aeb05539c308ea01dafb6da33649210fab2cdd38a580091aaec64d74192431c00cce4f4c752498e88aaa5ccc010b2317db8e01cf660e1dc9ba01154024448965f8209721d391f8422ef2e1817ac4240be53bfc0f05b7336e172e271c9e9fcd38057746bbe8f5bb1907ab681ae012395e78e531f5291340108b4f8b182614a29fa0c7a44032229fe3fb3af01a5577cf335f318c1ecc70b613e7532ab85dc087c618020e949640cb14a3dbf634fa0b48f0098c9e9ee4861a5e6193f2a9241e28d1f4d3c9a8f11c460943dbd7b7b06f18fe75454e20593388dcaa8b98aabe293987d22e2725251d6ebf2729cde05db076ed775b7f369d1f9e1109812960b8b76e333bcca8aaa98931c2937cadb68a4ffc6c54eff9a6bcb77da76dc02fcb83167105319dd5a25f19d6ef0b214927120635e665afe46f681259247978d4a6853bb3cac03bc554d07003496f6b8b624bfec45f4cfb24acded0aeb074e8f70df1813ebb26bd5fe26be2a627684d793a8a052e3a9476a1d9697dd9e27beb4db7ad01eb8b0a3b5c7717d716ebd30727cc7786a17f09b04d6b94a56d9f70ac514e026f42834486e6a0852ce00808c7222cc02f90802ab22509fe316612d10d60359087ab7a23be6348b73f6704e6fde2ed070c500db0;
    reg [K*N-1:0]big_y = 4096'h9ffff4f73caff09ff67fc82fe8f5988fe76cff5b4241f1f3f3f4ccb35f29fff573f617bc077c80165ec5270c0b863fc231ae96dd5d933e9a98abdaf3d6e852e98149945ab1a9a90e38e07c3017c1273b18598d87b59a289de9d7c5bc5c6f64cccdbcbec42c289c8b1b799f8454cba6b89e5976a84c19217d64ddde5af42e37ab465928d068deaa3a0270b8d062dbe0b737667c3afd065871532081e72bc1f79e1d7ebd1fb933ec3555a8e986f949f72ca11bc2fbe4c704b20838c68b707d9f3db1d8ae45b44b6bd36a58bfbf7d565347a6c6e20130c84f1bad77f6251e81dfb6ffa9a508d64db7d2fe48b5e4ebe68e7c8d62cdf5ab1c2ca8c2d2e835a1423acbef65956c980dfb62b3a405b9efbc93283d5071c2129b831481c537cc5be8f1d2723f1168f797bde736c1f73054d7d0dc97538fba25bb3e38703934d8fc46ad22eb23ea409184c3dba8241efc92ce5a6728f4385da637bc23ef7acb506d0543804ae7d660926a82406f9d3206376d5454466ecde2246a125c99aebdf16743d55cfb1c4ab0fdb8387320d541a94e3c5aa6038466eaa18682a163d571db3214de448b3d4d7a632bc60f0a524a041cd6e72a75dbc9f6bb63743df3c3c0d4649a28bd0bbeee569182303a66b830a2273b8df05c712adadf2bcb75244a66826265da778e0c3b45a20d6c962fd203e708ff62dd29b9edd90f2afd2bfe92014968e4396a;
`endif
//---------------------------------------------------------------------------------------------------
integer seed=1;
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   task_req                             = 0 ;
reg   wr_ena                               = 0 ;
reg   [$clog2(N)-1:0]  wr_addr             = 0 ;
wire  [K-1:0]  wr_x;
wire  [K-1:0]  wr_y;
wire  [K-1:0]  wr_m;
reg   [K-1:0]  wr_m1                       = 0 ;//m1=(-1*(mod_inv(m,2**K)))%2**K 
reg            start_wr_ram                = 0 ;
wire           res_val;
wire  [K-1:0]  res;
wire           task_end;
//---------------------------------------------------------------------------------------------------
reg [K*N-1:0]big_a = 'd0;//always 0
//---------------------------------------------------------------------------------------------------
initial
begin
    forever #(PERIOD/2)  clk=~clk;
end
initial
begin
    #(PERIOD*2) rst_n  =  1;
end
//---------------------------------------------------------------------------------------------------
parameter MULT_METHOD  = "COMMON";//"TRADITION" ;// | COMMON ? | TRADITION 10| VEDIC8    8|
parameter ADD1_METHOD  = "COMMON";//"3-2_PIPE1" ;// | COMMON ? | 3-2_PIPE1 1 | 3-2_PIPE2 2|
parameter ADD2_METHOD  = "COMMON";//"3-2_DELAY2";// | COMMON   | 3-2_DELAY2  |            |
//---------------------------------------------------------------------------------------------------
parameter MULT_LATENCY = MULT_METHOD == "COMMON"      ?0 :
                         MULT_METHOD == "TRADITION"   ?10:
                         MULT_METHOD == "VEDIC8"      ?8 :'dx;
parameter ADD1_LATENCY = ADD1_METHOD == "COMMON"      ?0 :
                         ADD1_METHOD == "3-2_PIPE1"   ?1 : 
                         ADD1_METHOD == "3-2_PIPE2"   ?2 :'dx;
initial begin
    if (ADD2_METHOD == "3-2_DELAY2") begin
        if (MULT_LATENCY*3+ADD1_LATENCY>=63) begin
            $display("\nCaution: pipeline failed(%0d)\n",MULT_LATENCY*3+ADD1_LATENCY);
            $stop;
        end
    end else if(ADD2_METHOD == "COMMON")begin
        if (MULT_LATENCY*3+ADD1_LATENCY>=31) begin
            $display("\nCaution: pipeline failed(%0d)\n",MULT_LATENCY*3+ADD1_LATENCY);
            $stop;
        end
    end
end
//---------------------------------------------------------------------------------------------------

mmp_iddmm_sp #(
    .MULT_METHOD  ( MULT_METHOD  ),
    .ADD1_METHOD  ( ADD1_METHOD  ),
    .ADD2_METHOD  ( ADD2_METHOD  ),
    .MULT_LATENCY ( MULT_LATENCY ),        
    .ADD1_LATENCY ( ADD1_LATENCY ),
    .K            ( K ),
    .N            ( N ) 
)mmp_iddmm_sp_0 (
    .clk                     ( clk                        ),
    .rst_n                   ( rst_n                      ),

    .wr_ena                  ( wr_ena                     ),
    .wr_addr                 ( wr_addr    [$clog2(N)-1:0] ),
    .wr_x                    ( wr_x       [K-1:0]         ),
    .wr_y                    ( wr_y       [K-1:0]         ),
    .wr_m                    ( wr_m       [K-1:0]         ),
    .wr_m1                   ( wr_m1      [K-1:0]         ),

    .task_req                ( task_req                   ),
    .task_end                ( task_end                   ),
    .task_grant              ( res_val                    ),
    .task_res                ( res        [K-1:0]         )
);
integer i,j,tick=0,fpx,fpy,fpm,fpa;
reg [K*N-1:0]result_iddmm = 'd0;
reg [K*N-1:0]result_r2mm  = 'd0;
assign wr_x = big_x[wr_addr*K +: K] ;
assign wr_y = big_y[wr_addr*K +: K] ;
assign wr_m = big_m[wr_addr*K +: K] ;

reg [3:0]st=0;
always@(posedge clk)begin
    if (res_val) begin
        result_iddmm <= {res,result_iddmm[K*N-1:K]};
    end
end
always@(posedge clk)begin
    case (st)
        0:begin
            if (start_wr_ram) begin
                st      <=  st+1;
                wr_ena  <=  1;
                wr_addr <=  'd0;
                wr_m1   <=  wr_m1_;
            end
        end 
        1:begin
            if (wr_addr==N-1) begin
                wr_ena  <=  0;
                st      <=  2;
            end else begin
                wr_addr<=wr_addr+1'd1;
            end
        end 
        2:begin
            st  <=  0;
        end 
        default:; 
    endcase
end

task random2bigxy;
    begin
        for (j = 0;j<128 ;j=j+1 ) begin
            big_x[j*32 +: 32]=$random(seed);
            big_y[j*32 +: 32]=$random(seed);
        end
        if (big_x>=big_m) begin
            big_x=big_x-big_m;
        end
        if (big_y>=big_m) begin
            big_y=big_y-big_m;
        end
    end
endtask
task big2file;
    begin
        fpx = $fopen("../../src/x.mem","w");
        fpy = $fopen("../../src/y.mem","w");
        fpm = $fopen("../../src/m.mem","w");
        fpa = $fopen("../../src/a0.mem","w");
        for (i = 0;i<N;i=i+1 ) begin
            $fwrite(fpx,"%x\n",big_x[i*K +: K]);
            $fwrite(fpy,"%x\n",big_y[i*K +: K]);
            $fwrite(fpm,"%x\n",big_m[i*K +: K]);
            $fwrite(fpa,"%x\n",big_a[i*K +: K]);
        end
        $fclose(fpx);
        $fclose(fpy);
        $fclose(fpm);
        $fclose(fpa);
    end
endtask
reg [K-1:0] membf_x [0:N-1];
reg [K-1:0] membf_y [0:N-1];
reg [K-1:0] membf_m [0:N-1];
reg [K-1:0] membf_a [0:N-1];
task file2big;
    begin
        $readmemh("../../src/x.mem",membf_x);
        $readmemh("../../src/y.mem",membf_y);
        $readmemh("../../src/m.mem",membf_m);
        $readmemh("../../src/a0.mem",membf_a);
        for (i = N-1;i>=0 ;i=i-1 ) begin
            big_x[(i*K+K-1)-:K]=membf_x[i];
            big_y[(i*K+K-1)-:K]=membf_y[i];
            big_m[(i*K+K-1)-:K]=membf_m[i];
            big_a[(i*K+K-1)-:K]=membf_a[i];
        end

    end
endtask
task ram2big;
    begin
        for (i = N-1;i>=0 ;i=i-1 ) begin
            big_x[(i*K+K-1)-:K]=mmp_iddmm_sp_0.simple_ram_x.mem[i];
            big_y[(i*K+K-1)-:K]=mmp_iddmm_sp_0.simple_ram_y.mem[i];
            big_m[(i*K+K-1)-:K]=mmp_iddmm_sp_0.simple_ram_m.mem[i];
            big_a[(i*K+K-1)-:K]=mmp_iddmm_sp_0.simple_ram_a.mem[i];
        end
    end
endtask

task display_big_value;
    begin
        $display("[BIG value]:");
        $display("X:\n0x%x",big_x);
        $display("Y:\n0x%x",big_y);
        // $display("M:\n0x%x",big_m);
        // $display("A:\n0x%x",big_a);
    end
endtask 

task big2ram;
    begin
        @(posedge clk)
        #0 start_wr_ram=1;
        wait(st==2)begin
            @(posedge clk)
            #0 start_wr_ram=0;
        end
    end
endtask 

task make_task;
    begin
        @(posedge clk)
        #0 task_req=1;
        wait(task_end)begin
            @(posedge clk)
            #0 task_req=0;
        end
        @(posedge clk)
        $display("[mmp_iddmm_sp_tb.v]result_iddmm: \n0x%x",result_iddmm);
    end
endtask 
task run_iddmm;
    begin
        big2ram;
        make_task;
    end
endtask 
//---------------------------------------------------------------------------------------------------
// R2MM
reg  r2mm_req=0;
wire [K*N-1:0]r2mm_res;
wire r2mm_val;
mm_r2mm_2n #(
    .K ( K*N )
)mm_r2mm_2n (
    .clk                     ( clk              ),
    .rst_n                   ( rst_n            ),
    .x                       ( big_x            ),
    .y                       ( big_y            ),
    .m                       ( big_m            ),
    .req                     ( r2mm_req         ),
    .res                     ( r2mm_res         ),
    .val                     ( r2mm_val         )
); 
task run_r2mm;
    begin
        @(posedge clk);
        #0 r2mm_req=1;
        @(posedge clk);
        #0 r2mm_req=0;
        wait(r2mm_val);
        @(posedge clk);
        result_r2mm=r2mm_res;
        $display("[mmp_iddmm_sp_tb.v]result_r2mm:\n0x%x\n",result_r2mm);
    end
endtask 
// R2MM END
//---------------------------------------------------------------------------------------------------
task match_test;
    begin
        tick=tick+1;
        $display("---------------------------------------------%d",tick);
        //random2bigxy;
        display_big_value;
        run_iddmm;
        run_r2mm;
        if (result_r2mm==result_iddmm) begin
            $display("[mmp_iddmm_sp_tb.v]match_test:Match r2mm==iddmm");
        end else begin
            $display("[mmp_iddmm_sp_tb.v]match_test:ERROR");
            $stop;
        end
        $display("---------------------------------------------");
    end
endtask 
initial
begin
    $display("---------------------------------------------");
    `ifdef _VIEW_WAVEFORM_
    $dumpfile("wave.vcd");      
    $dumpvars(0,mmp_iddmm_sp_tb);  
    #(100)
    run_iddmm;
    `else
    while(1)begin
        match_test;
    end
    `endif
    $display("---------------------------------------------");
    #(1000)
    $finish;
end

endmodule