//=========================================================================== //
// Copyright (c) 2022, Stephen Henry
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//=========================================================================== //

`include "common_defs.vh"
`include "macros.vh"

//
//
//
//                          +----+
//                          |    |
//                          |    |
//                     10b  |    |   32b
//               -----/-----|    |===/=====
//                          |    |
//                          |    |
//                          |    |
//                          +----+

module conv10bto32b (
// -------------------------------------------------------------------------- //
// Input
  input                                             i_vld
, input [9:0]                                       i_dat

// -------------------------------------------------------------------------- //
// Ouput
, output logic                                      o_vld
, output logic [31:0]                               o_dat

// -------------------------------------------------------------------------- //
// Clk/Reset
, input                                             rst
, input                                             clk
);

// ========================================================================== //
//                                                                            //
//  Wires                                                                     //
//                                                                            //
// ========================================================================== //

`ifdef HAS_ENABLE
logic                                   upt_en;
`endif
logic [31:0]                            out;

// ========================================================================== //
//                                                                            //
//  Flops                                                                     //
//                                                                            //
// ========================================================================== //

`ifdef HAS_ENABLE
  `P_DFFE(clk, 41, align, upt_en);
  `P_DFFRE(clk, 6, cnt, upt_en, 'b0);
`else
  `P_DFF(clk, 41, align);
  `P_DFFR(clk, 6, cnt, 'b0);
`endif

// ========================================================================== //
//                                                                            //
//  Logic                                                                     //
//                                                                            //
// ========================================================================== //

// Algorithm:
//
//   Init:
//
//     cnt_r <- 0;
//     align_r <- 0;
//     o_vld <- 0;
//     o_dat <- 0;
//
//   On Clock:
//
//     if (cnt_r >= 32) {
//       o_vld <- 'b1;
//       o_dat <- align_r >> cnt_r [3:0];
//       cnt_r <- cnt_r - 32;
//     } else {
//       o_vld <- 'b0;
//     }
//     if (i_vld) {
//       align_r <- {align_r, i_dat};
//       cnt_r <- cnt_r + 10;
//     }

`ifdef HAS_ENABLE
assign upt_en = (i_vld | o_vld);
`endif

assign cnt_w =
    //
    (o_vld ? {1'b0, cnt_r [4:0]} : cnt_r) +
    //
    (i_vld ? 'd10 : '0);

assign align_w = i_vld ? {align_r [30:10], i_dat} : align_r;

assign out = (align_r >> cnt_r [3:0]);

// ========================================================================== //
//                                                                            //
//  Outputs                                                                   //
//                                                                            //
// ========================================================================== //

assign o_vld = cnt_r [5];
assign o_dat = dat;

endmodule // conv10bto32b

`include "unmacros.vh"
