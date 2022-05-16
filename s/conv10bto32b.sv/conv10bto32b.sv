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

logic                                   upt_en;

// ========================================================================== //
//                                                                            //
//  Flops                                                                     //
//                                                                            //
// ========================================================================== //

`P_DFFE(clk, 41, align, upt_en);
`P_DFFRE(clk, 6, cnt, upt_en, 'b0);

// ========================================================================== //
//                                                                            //
//  Logic                                                                     //
//                                                                            //
// ========================================================================== //

assign upt_en = (i_vld | o_vld);

assign cnt_w =
    // Subtract 32.
    (o_vld ? (cnt_r & 6'b01_1111) : cnt_r) +  // (1)
    // Add 10
    (i_vld ? 'd10 : '0);                      // (2)

assign align_initial = o_vld ? { 'b0, align_r [40:32] } : align_r;
assign align_w = i_vld ? {align_initial [30:10], i_dat} : align_initial;

// ========================================================================== //
//                                                                            //
//  Outputs                                                                   //
//                                                                            //
// ========================================================================== //

assign o_vld = cnt_r [5];
assign o_dat = align_r [31:0];

endmodule // conv10bto32b

`include "unmacros.vh"
