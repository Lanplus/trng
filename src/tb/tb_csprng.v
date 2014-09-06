//======================================================================
//
// tb_csprng.v
// -----------
// Testbench for the csprng module in the trng.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2014, Secworks Sweden AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

//------------------------------------------------------------------
// Simulator directives.
//------------------------------------------------------------------
`timescale 1ns/100ps


//------------------------------------------------------------------
// Test module.
//------------------------------------------------------------------
module tb_csprng();

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter DEBUG     = 1;

  parameter CLK_HALF_PERIOD = 1;
  parameter CLK_PERIOD      = 2 * CLK_HALF_PERIOD;


  //----------------------------------------------------------------
  // Register and Wire declarations.
  //----------------------------------------------------------------
  reg [31 : 0] cycle_ctr;
  reg [31 : 0] error_ctr;
  reg [31 : 0] tc_ctr;

  reg            tb_clk;
  reg            tb_reset_n;
  reg            tb_debug_mode;
  reg [5 : 0]    tb_num_rounds;
  reg [63 : 0]   tb_num_blocks;
  reg            tb_seed;
  reg            tb_next;
  wire           tb_ready;
  wire           tb_error;
  reg            tb_seed_syn;
  reg [511 : 0]  tb_seed_data;
  wire           tb_seed_ack;
  wire           tb_rnd_syn;
  wire [511 : 0] tb_rnd_data;
  reg            tb_rnd_ack;


  //----------------------------------------------------------------
  // Device Under Test.
  //----------------------------------------------------------------
  trng_csprng dut(
                  .clk(tb_clk),
                  .reset_n(tb_reset_n),

                  .debug_mode(tb_debug_mode),
                  .num_rounds(tb_num_rounds),
                  .num_blocks(tb_num_blocks),
                  .seed(tb_seed),
                  .next(tb_next),
                  .ready(tb_ready),
                  .error(tb_error),

                  .seed_syn(tb_seed_syn),
                  .seed_data(tb_seed_data),
                  .seed_ack(tb_seed_ack),

                  .rnd_syn(tb_rnd_syn),
                  .rnd_data(tb_rnd_data),
                  .rnd_ack(tb_rnd_ack)
                 );


  //----------------------------------------------------------------
  // clk_gen
  //
  // Always running clock generator process.
  //----------------------------------------------------------------
  always
    begin : clk_gen
      #CLK_HALF_PERIOD;
      tb_clk = !tb_clk;
    end // clk_gen


  //----------------------------------------------------------------
  // sys_monitor()
  //
  // An always running process that creates a cycle counter and
  // conditionally displays information about the DUT.
  //----------------------------------------------------------------
  always
    begin : sys_monitor
      cycle_ctr = cycle_ctr + 1;
      #(CLK_PERIOD);
      if (DEBUG)
        begin
          dump_dut_state();
        end
    end


  //----------------------------------------------------------------
  // dump_dut_state()
  //
  // Dump the state of the dump when needed.
  //----------------------------------------------------------------
  task dump_dut_state();
    begin
      $display("State of DUT");
      $display("------------");
      $display("");
    end
  endtask // dump_dut_state


  //----------------------------------------------------------------
  // reset_dut()
  //
  // Toggle reset to put the DUT into a well known state.
  //----------------------------------------------------------------
  task reset_dut();
    begin
      $display("*** Toggle reset.");
      tb_reset_n = 0;

      #(2 * CLK_PERIOD);
      tb_reset_n = 1;
    end
  endtask // reset_dut


  //----------------------------------------------------------------
  // init_sim()
  //
  // Initialize all counters and testbed functionality as well
  // as setting the DUT inputs to defined values.
  //----------------------------------------------------------------
  task init_sim();
    begin
      cycle_ctr     = 0;
      error_ctr     = 0;
      tc_ctr        = 0;

      tb_clk        = 0;
      tb_reset_n    = 1;
      tb_debug_mode = 0;
      tb_num_rounds = 5'h00;
      tb_num_blocks = 64'h0000000000000000;
      tb_seed       = 0;
      tb_next       = 0;
      tb_seed_syn   = 0;
      tb_seed_data  = {16{32'h00000000}};
      tb_rnd_ack    = 0;
    end
  endtask // init_sim


  //----------------------------------------------------------------
  // csprng_test
  //
  // The main test functionality.
  //----------------------------------------------------------------
  initial
    begin : csprng_test

      $display("   -= Testbench for csprng started =-");
      $display("     ================================");
      $display("");

      init_sim();
      dump_dut_state();
      reset_dut();
      dump_dut_state();

      // Test code goes here.

      display_test_result();

      $display("");
      $display("*** CSPRNG simulation done. ***");
      $finish;
    end // csprng_test
endmodule // tb_csprng

//======================================================================
// EOF tb_csprng.v
//======================================================================