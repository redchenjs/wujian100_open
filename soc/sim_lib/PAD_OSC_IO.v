/*
Copyright (c) 2019 Alibaba Group Holding Limited

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/
module PAD_OSC_IO(
    EN    ,
    XOSC_OUT    ,
    XOSC_IN,
    CLK
);

input    EN;
input    XOSC_IN;
output   XOSC_OUT;
output   CLK;

// assign CLK = EN ? XOSC_IN : 1'b0;
// assign XOSC_OUT = EN ? XOSC_IN : 1'b0;

BUFGCE BUFGCE_inst (
    .O(CLK),        // 1-bit output: Clock output
    .CE(EN),        // 1-bit input: Clock enable input for I0
    .I(XOSC_IN)     // 1-bit input: Primary clock
);

OBUFT OBUFT_inst (
    .O(XOSC_OUT),   // Buffer output (connect directly to top-level port)
    .I(XOSC_IN),    // Buffer input
    .T(EN)          // 3-state enable input
);

endmodule
