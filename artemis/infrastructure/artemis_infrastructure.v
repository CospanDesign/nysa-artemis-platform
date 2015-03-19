/*
Distributed under the MIT license.
Copyright (c) 2015 Dave McCoy (dave.mccoy@cospandesign.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/*
  All the Artemis specific features that need to be in an FPGA design
  but are not specifically a slave, memory or host interface

  Inside the Artemis core contains
    -the clock PLL to generate both
      the system clock (100MHz and the DDR3 clock)
    -the DDR3 Core
      this needs to be connected to the DDR3 Signals
*/


module artemis_infrastructure (
  input                 clk_100mhz,
  output                clk,
  input                 rst,
  output                calibration_done,
  output                ddr3_rst,

  output                ddr3_clk_out,
  input                 ddr3_clk_in,

  inout         [7:0]   ddr3_dram_dq,
  output        [13:0]  ddr3_dram_a,
  output        [2:0]   ddr3_dram_ba,
  output                ddr3_dram_ras_n,
  output                ddr3_dram_cas_n,
  output                ddr3_dram_we_n,
  output                ddr3_dram_odt,
  output                ddr3_dram_reset_n,
  output                ddr3_dram_cke,
  output                ddr3_dram_dm,
  inout                 ddr3_dram_rzq,
  inout                 ddr3_dram_zio,
  inout                 ddr3_dram_dqs,
  inout                 ddr3_dram_dqs_n,
  output                ddr3_dram_ck,
  output                ddr3_dram_ck_n,


  input                 p0_cmd_clk,
  input                 p0_cmd_en,
  input         [2:0]   p0_cmd_instr,
  input         [5:0]   p0_cmd_bl,
  input         [29:0]  p0_cmd_byte_addr,
  output                p0_cmd_empty,
  output                p0_cmd_full,
  input                 p0_wr_clk,
  input                 p0_wr_en,
  input         [3:0]   p0_wr_mask,
  input         [31:0]  p0_wr_data,
  output                p0_wr_full,
  output                p0_wr_empty,
  output        [6:0]   p0_wr_count,
  output                p0_wr_underrun,
  output                p0_wr_error,
  input                 p0_rd_clk,
  input                 p0_rd_en,
  output        [31:0]  p0_rd_data,
  output                p0_rd_full,
  output                p0_rd_empty,
  output        [6:0]   p0_rd_count,
  output                p0_rd_overflow,
  output                p0_rd_error,

  input                 p1_cmd_clk,
  input                 p1_cmd_en,
  input         [2:0]   p1_cmd_instr,
  input         [5:0]   p1_cmd_bl,
  input         [29:0]  p1_cmd_byte_addr,
  output                p1_cmd_empty,
  output                p1_cmd_full,
  input                 p1_wr_clk,
  input                 p1_wr_en,
  input         [3:0]   p1_wr_mask,
  input         [31:0]  p1_wr_data,
  output                p1_wr_full,
  output                p1_wr_empty,
  output        [6:0]   p1_wr_count,
  output                p1_wr_underrun,
  output                p1_wr_error,
  input                 p1_rd_clk,
  input                 p1_rd_en,
  output        [31:0]  p1_rd_data,
  output                p1_rd_full,
  output                p1_rd_empty,
  output        [6:0]   p1_rd_count,
  output                p1_rd_overflow,
  output                p1_rd_error,

  input                 p2_cmd_clk,
  input                 p2_cmd_en,
  input         [2:0]   p2_cmd_instr,
  input         [5:0]   p2_cmd_bl,
  input         [29:0]  p2_cmd_byte_addr,
  output                p2_cmd_empty,
  output                p2_cmd_full,
  input                 p2_wr_clk,
  input                 p2_wr_en,
  input         [3:0]   p2_wr_mask,
  input         [31:0]  p2_wr_data,
  output                p2_wr_full,
  output                p2_wr_empty,
  output        [6:0]   p2_wr_count,
  output                p2_wr_underrun,
  output                p2_wr_error,
  input                 p2_rd_clk,
  input                 p2_rd_en,
  output        [31:0]  p2_rd_data,
  output                p2_rd_full,
  output                p2_rd_empty,
  output        [6:0]   p2_rd_count,
  output                p2_rd_overflow,
  output                p2_rd_error,

  input                 p3_cmd_clk,
  input                 p3_cmd_en,
  input         [2:0]   p3_cmd_instr,
  input         [5:0]   p3_cmd_bl,
  input         [29:0]  p3_cmd_byte_addr,
  output                p3_cmd_empty,
  output                p3_cmd_full,
  input                 p3_wr_clk,
  input                 p3_wr_en,
  input         [3:0]   p3_wr_mask,
  input         [31:0]  p3_wr_data,
  output                p3_wr_full,
  output                p3_wr_empty,
  output        [6:0]   p3_wr_count,
  output                p3_wr_underrun,
  output                p3_wr_error,
  input                 p3_rd_clk,
  input                 p3_rd_en,
  output        [31:0]  p3_rd_data,
  output                p3_rd_full,
  output                p3_rd_empty,
  output        [6:0]   p3_rd_count,
  output                p3_rd_overflow,
  output                p3_rd_error
);

//Local Parameters

//Registers/Wires

//Submodules
artemis_clkgen clkgen(
  .clk_100mhz         (clk_100mhz           ),
  .rst                (board_rst            ),

  .locked             (locked               ),

  .clk                (clk                  ),
  .ddr3_clk           (ddr3_clk_out         )
);

artemis_ddr3 artemis_ddr3_cntrl(
  .clk_333mhz         (ddr3_clk_in           ),
  .board_rst          (board_rst             ),

  .calibration_done   (calibration_done      ),

  .usr_clk            (usr_clk               ),
  .rst                (rst                   ),

  .ddr3_dram_dq       (ddr3_dram_dq          ),
  .ddr3_dram_a        (ddr3_dram_a           ),
  .ddr3_dram_ba       (ddr3_dram_ba          ),
  .ddr3_dram_ras_n    (ddr3_dram_ras_n       ),
  .ddr3_dram_cas_n    (ddr3_dram_cas_n       ),
  .ddr3_dram_we_n     (ddr3_dram_we_n        ),
  .ddr3_dram_odt      (ddr3_dram_odt         ),
  .ddr3_dram_reset_n  (ddr3_dram_reset_n     ),
  .ddr3_dram_cke      (ddr3_dram_cke         ),
  .ddr3_dram_dm       (ddr3_dram_dm          ),
  .ddr3_rzq           (ddr3_dram_rzq         ),
  .ddr3_zio           (ddr3_dram_zio         ),
  .ddr3_dram_dqs      (ddr3_dram_dqs         ),
  .ddr3_dram_dqs_n    (ddr3_dram_dqs_n       ),
  .ddr3_dram_ck       (ddr3_dram_ck          ),
  .ddr3_dram_ck_n     (ddr3_dram_ck_n        ),

  .p0_cmd_clk         (p0_cmd_clk            ),
  .p0_cmd_en          (p0_cmd_en             ),
  .p0_cmd_instr       (p0_cmd_instr          ),
  .p0_cmd_bl          (p0_cmd_bl             ),
  .p0_cmd_byte_addr   (p0_cmd_byte_addr      ),
  .p0_cmd_empty       (p0_cmd_empty          ),
  .p0_cmd_full        (p0_cmd_full           ),
  .p0_wr_clk          (p0_wr_clk             ),
  .p0_wr_en           (p0_wr_en              ),
  .p0_wr_mask         (p0_wr_mask            ),
  .p0_wr_data         (p0_wr_data            ),
  .p0_wr_full         (p0_wr_full            ),
  .p0_wr_empty        (p0_wr_empty           ),
  .p0_wr_count        (p0_wr_count           ),
  .p0_wr_underrun     (p0_wr_underrun        ),
  .p0_wr_error        (p0_wr_error           ),
  .p0_rd_clk          (p0_rd_clk             ),
  .p0_rd_en           (p0_rd_en              ),
  .p0_rd_data         (p0_rd_data            ),
  .p0_rd_full         (p0_rd_full            ),
  .p0_rd_empty        (p0_rd_empty           ),
  .p0_rd_count        (p0_rd_count           ),
  .p0_rd_overflow     (p0_rd_overflow        ),
  .p0_rd_error        (p0_rd_error           ),

  .p1_cmd_clk         (p1_cmd_clk            ),
  .p1_cmd_en          (p1_cmd_en             ),
  .p1_cmd_instr       (p1_cmd_instr          ),
  .p1_cmd_bl          (p1_cmd_bl             ),
  .p1_cmd_byte_addr   (p1_cmd_byte_addr      ),
  .p1_cmd_empty       (p1_cmd_empty          ),
  .p1_cmd_full        (p1_cmd_full           ),
  .p1_wr_clk          (p1_wr_clk             ),
  .p1_wr_en           (p1_wr_en              ),
  .p1_wr_mask         (p1_wr_mask            ),
  .p1_wr_data         (p1_wr_data            ),
  .p1_wr_full         (p1_wr_full            ),
  .p1_wr_empty        (p1_wr_empty           ),
  .p1_wr_count        (p1_wr_count           ),
  .p1_wr_underrun     (p1_wr_underrun        ),
  .p1_wr_error        (p1_wr_error           ),
  .p1_rd_clk          (p1_rd_clk             ),
  .p1_rd_en           (p1_rd_en              ),
  .p1_rd_data         (p1_rd_data            ),
  .p1_rd_full         (p1_rd_full            ),
  .p1_rd_empty        (p1_rd_empty           ),
  .p1_rd_count        (p1_rd_count           ),
  .p1_rd_overflow     (p1_rd_overflow        ),
  .p1_rd_error        (p1_rd_error           ),

  .p2_cmd_clk         (p2_cmd_clk            ),
  .p2_cmd_en          (p2_cmd_en             ),
  .p2_cmd_instr       (p2_cmd_instr          ),
  .p2_cmd_bl          (p2_cmd_bl             ),
  .p2_cmd_byte_addr   (p2_cmd_byte_addr      ),
  .p2_cmd_empty       (p2_cmd_empty          ),
  .p2_cmd_full        (p2_cmd_full           ),
  .p2_wr_clk          (p2_wr_clk             ),
  .p2_wr_en           (p2_wr_en              ),
  .p2_wr_mask         (p2_wr_mask            ),
  .p2_wr_data         (p2_wr_data            ),
  .p2_wr_full         (p2_wr_full            ),
  .p2_wr_empty        (p2_wr_empty           ),
  .p2_wr_count        (p2_wr_count           ),
  .p2_wr_underrun     (p2_wr_underrun        ),
  .p2_wr_error        (p2_wr_error           ),
  .p2_rd_clk          (p2_rd_clk             ),
  .p2_rd_en           (p2_rd_en              ),
  .p2_rd_data         (p2_rd_data            ),
  .p2_rd_full         (p2_rd_full            ),
  .p2_rd_empty        (p2_rd_empty           ),
  .p2_rd_count        (p2_rd_count           ),
  .p2_rd_overflow     (p2_rd_overflow        ),
  .p2_rd_error        (p2_rd_error           ),

  //Port 3
  .p3_cmd_clk         (p3_cmd_clk            ),
  .p3_cmd_en          (p3_cmd_en             ),
  .p3_cmd_instr       (p3_cmd_instr          ),
  .p3_cmd_bl          (p3_cmd_bl             ),
  .p3_cmd_byte_addr   (p3_cmd_byte_addr      ),
  .p3_cmd_empty       (p3_cmd_empty          ),
  .p3_cmd_full        (p3_cmd_full           ),
  .p3_wr_clk          (p3_wr_clk             ),
  .p3_wr_en           (p3_wr_en              ),
  .p3_wr_mask         (p3_wr_mask            ),
  .p3_wr_data         (p3_wr_data            ),
  .p3_wr_full         (p3_wr_full            ),
  .p3_wr_empty        (p3_wr_empty           ),
  .p3_wr_count        (p3_wr_count           ),
  .p3_wr_underrun     (p3_wr_underrun        ),
  .p3_wr_error        (p3_wr_error           ),
  .p3_rd_clk          (p3_rd_clk             ),
  .p3_rd_en           (p3_rd_en              ),
  .p3_rd_data         (p3_rd_data            ),
  .p3_rd_full         (p3_rd_full            ),
  .p3_rd_empty        (p3_rd_empty           ),
  .p3_rd_count        (p3_rd_count           ),
  .p3_rd_overflow     (p3_rd_overflow        ),
  .p3_rd_error        (p3_rd_error           )
);

//Asynchronous Logic

//Synchronous Logic


endmodule
