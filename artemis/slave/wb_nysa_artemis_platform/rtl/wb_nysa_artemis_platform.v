//wb_nysa_artemis_platform.v
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
  Set the Vendor ID (Hexidecimal 64-bit Number)
  SDB_VENDOR_ID:0x800000000000C594

  Set the Device ID (Hexcidecimal 32-bit Number)
  SDB_DEVICE_ID:0x800000000000C594

  Set the version of the Core XX.XXX.XXX Example: 01.000.000
  SDB_CORE_VERSION:00.000.001

  Set the Device Name: 19 UNICODE characters
  SDB_NAME:wb_nysa_artemis_platform

  Set the class of the device (16 bits) Set as 0
  SDB_ABI_CLASS:0

  Set the ABI Major Version: (8-bits)
  SDB_ABI_VERSION_MAJOR:0x022

  Set the ABI Minor Version (8-bits)
  SDB_ABI_VERSION_MINOR:0x02

  Set the Module URL (63 Unicode Characters)
  SDB_MODULE_URL:http://www.example.com

  Set the date of module YYYY/MM/DD
  SDB_DATE:2015/05/23

  Device is executable (True/False)
  SDB_EXECUTABLE:True

  Device is readable (True/False)
  SDB_READABLE:True

  Device is writeable (True/False)
  SDB_WRITEABLE:True

  Device Size: Number of Registers
  SDB_SIZE:3
*/

`unconnected_drive pull0

module wb_nysa_artemis_platform #(
  parameter DDR3_W0_CH  = 0,
  parameter DDR3_R0_CH  = 0,
  parameter DDR3_W1_CH  = 0,
  parameter DDR3_R1_CH  = 0,
  parameter DDR3_RW0_CH = 0
)(
  output                clk,
  input                 rst,

  //Add signals to control your device here

  //Wishbone Bus Signals
  input                 i_wbs_we,
  input                 i_wbs_cyc,
  input       [3:0]     i_wbs_sel,
  input       [31:0]    i_wbs_dat,
  input                 i_wbs_stb,
  output  reg           o_wbs_ack,
  output  reg [31:0]    o_wbs_dat,
  input       [31:0]    i_wbs_adr,

  //This interrupt can be controlled from this module or a submodule
  output  reg           o_wbs_int,
  //output              o_wbs_int

  input                 clk_100mhz,
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


  //Write Channel 0
  input                 w0_write_enable,
  input         [63:0]  w0_write_addr,
  input                 w0_write_addr_inc,
  input                 w0_write_addr_dec,
  output                w0_write_finished,
  input         [31:0]  w0_write_count,
  input                 w0_write_flush,

  output        [1:0]   w0_write_ready,
  input         [1:0]   w0_write_activate,
  output        [23:0]  w0_write_size,
  input                 w0_write_strobe,
  input         [31:0]  w0_write_data,

  //Write Channel 1
  input                 w1_write_enable,
  input         [63:0]  w1_write_addr,
  input                 w1_write_addr_inc,
  input                 w1_write_addr_dec,
  output                w1_write_finished,
  input         [31:0]  w1_write_count,
  input                 w1_write_flush,

  output        [1:0]   w1_write_ready,
  input         [1:0]   w1_write_activate,
  output        [23:0]  w1_write_size,
  input                 w1_write_strobe,
  input         [31:0]  w1_write_data,

  //Read Channel 0
  input                 r0_read_enable,
  input         [63:0]  r0_read_addr,
  input                 r0_read_addr_inc,
  input                 r0_read_addr_dec,
  output                r0_read_busy,
  output                r0_read_error,
  input         [23:0]  r0_read_count,
  input                 r0_read_flush,

  output                r0_read_ready,
  input                 r0_read_activate,
  output        [23:0]  r0_read_size,
  output        [31:0]  r0_read_data,
  input                 r0_read_strobe,

  //Read Channel 1
  input                 r1_read_enable,
  input         [63:0]  r1_read_addr,
  input                 r1_read_addr_inc,
  input                 r1_read_addr_dec,
  output                r1_read_busy,
  output                r1_read_error,
  input         [23:0]  r1_read_count,
  input                 r1_read_flush,

  output                r1_read_ready,
  input                 r1_read_activate,
  output        [23:0]  r1_read_size,
  output        [31:0]  r1_read_data,
  input                 r1_read_strobe,

  //Read/Write Channel 0
  input                 rw0_read_enable,
  input         [63:0]  rw0_read_addr,
  input                 rw0_read_addr_inc,
  input                 rw0_read_addr_dec,
  output                rw0_read_busy,
  output                rw0_read_error,
  input         [23:0]  rw0_read_count,
  input                 rw0_read_flush,

  output                rw0_read_ready,
  input                 rw0_read_activate,
  output        [23:0]  rw0_read_size,
  output        [31:0]  rw0_read_data,
  input                 rw0_read_strobe,


  input                 rw0_write_enable,
  input         [63:0]  rw0_write_addr,
  input                 rw0_write_addr_inc,
  input                 rw0_write_addr_dec,
  output                rw0_write_finished,
  input         [31:0]  rw0_write_count,
  input                 rw0_write_flush,

  output        [1:0]   rw0_write_ready,
  input         [1:0]   rw0_write_activate,
  output        [23:0]  rw0_write_size,
  input                 rw0_write_strobe,
  input         [31:0]  rw0_write_data,


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
  output                p0_rd_error

);

//Local Parameters
localparam      CONTROL                 = 32'h00000000;
localparam      BIT_CALIBRATION_DONE    = 0;
localparam      BIT_DDR3_RST            = 1;
localparam      BIT_P0_ENABLE           = 2;
localparam      BIT_P1_ENABLE           = 3;
localparam      BIT_P2_ENABLE           = 4;
localparam      BIT_P3_ENABLE           = 5;
localparam      BIT_P4_ENABLE           = 6;
localparam      BIT_P5_ENABLE           = 7;

localparam      DDR3_STATUS0            = 32'h00000001;

localparam      BIT_P0_RD_FULL          = 0;
localparam      BIT_P0_RD_EMPTY         = 1;
localparam      BIT_P0_RD_OVERFLOW      = 2;
localparam      BIT_P0_RD_ERROR         = 3;
localparam      BIT_P0_WR_EMPTY         = 4;
localparam      BIT_P0_WR_FULL          = 5;
localparam      BIT_P0_WR_UNDERRUN      = 6;

localparam      BIT_P1_RD_FULL          = 0 + 8;
localparam      BIT_P1_RD_EMPTY         = 1 + 8;
localparam      BIT_P1_RD_OVERFLOW      = 2 + 8;
localparam      BIT_P1_RD_ERROR         = 3 + 8;
localparam      BIT_P1_WR_EMPTY         = 4 + 8;
localparam      BIT_P1_WR_FULL          = 5 + 8;
localparam      BIT_P1_WR_UNDERRUN      = 6 + 8;

localparam      BIT_P2_RD_FULL          = 0 + 16;
localparam      BIT_P2_RD_EMPTY         = 1 + 16;
localparam      BIT_P2_RD_OVERFLOW      = 2 + 16;
localparam      BIT_P2_RD_ERROR         = 3 + 16;
localparam      BIT_P2_WR_EMPTY         = 4 + 16;
localparam      BIT_P2_WR_FULL          = 5 + 16;
localparam      BIT_P2_WR_UNDERRUN      = 6 + 16;

localparam      BIT_P3_RD_FULL          = 0 + 24;
localparam      BIT_P3_RD_EMPTY         = 1 + 24;
localparam      BIT_P3_RD_OVERFLOW      = 2 + 24;
localparam      BIT_P3_RD_ERROR         = 3 + 24;
localparam      BIT_P3_WR_EMPTY         = 4 + 24;
localparam      BIT_P3_WR_FULL          = 5 + 24;
localparam      BIT_P3_WR_UNDERRUN      = 6 + 24;

localparam      DDR3_STATUS1            = 32'h00000002;

localparam      BIT_P4_RD_FULL          = 0;
localparam      BIT_P4_RD_EMPTY         = 1;
localparam      BIT_P4_RD_OVERFLOW      = 2;
localparam      BIT_P4_RD_ERROR         = 3;
localparam      BIT_P4_WR_EMPTY         = 4;
localparam      BIT_P4_WR_FULL          = 5;
localparam      BIT_P4_WR_UNDERRUN      = 6;


localparam      BIT_P5_RD_FULL          = 0 + 8;
localparam      BIT_P5_RD_EMPTY         = 1 + 8;
localparam      BIT_P5_RD_OVERFLOW      = 2 + 8;
localparam      BIT_P5_RD_ERROR         = 3 + 8;
localparam      BIT_P5_WR_EMPTY         = 4 + 8;
localparam      BIT_P5_WR_FULL          = 5 + 8;
localparam      BIT_P5_WR_UNDERRUN      = 6 + 8;

//Local Registers/Wires

wire                    pll_locked;

wire                    p1_cmd_clk;
wire                    p1_cmd_en;
wire            [2:0]   p1_cmd_instr;
wire            [5:0]   p1_cmd_bl;
wire            [29:0]  p1_cmd_byte_addr;
wire                    p1_cmd_empty;
wire                    p1_cmd_full;
wire                    p1_wr_clk;
wire                    p1_wr_en;
wire            [3:0]   p1_wr_mask;
wire            [31:0]  p1_wr_data;
wire                    p1_wr_full;
wire                    p1_wr_empty;
wire            [6:0]   p1_wr_count;
wire                    p1_wr_underrun;
wire                    p1_wr_error;
wire                    p1_rd_clk;
wire                    p1_rd_en;
wire            [31:0]  p1_rd_data;
wire                    p1_rd_full;
wire                    p1_rd_empty;
wire            [6:0]   p1_rd_count;
wire                    p1_rd_overflow;
wire                    p1_rd_error;

wire                    p2_cmd_clk;
wire                    p2_cmd_en;
wire            [2:0]   p2_cmd_instr;
wire            [5:0]   p2_cmd_bl;
wire            [29:0]  p2_cmd_byte_addr;
wire                    p2_cmd_empty;
wire                    p2_cmd_full;
wire                    p2_wr_clk;
wire                    p2_wr_en;
wire            [3:0]   p2_wr_mask;
wire            [31:0]  p2_wr_data;
wire                    p2_wr_full;
wire                    p2_wr_empty;
wire            [6:0]   p2_wr_count;
wire                    p2_wr_underrun;
wire                    p2_wr_error;

wire                    p3_cmd_clk;
wire                    p3_cmd_en;
wire            [2:0]   p3_cmd_instr;
wire            [5:0]   p3_cmd_bl;
wire            [29:0]  p3_cmd_byte_addr;
wire                    p3_cmd_empty;
wire                    p3_cmd_full;
wire                    p3_wr_clk;
wire                    p3_wr_en;
wire            [3:0]   p3_wr_mask;
wire            [31:0]  p3_wr_data;
wire                    p3_wr_full;
wire                    p3_wr_empty;
wire            [6:0]   p3_wr_count;
wire                    p3_wr_underrun;
wire                    p3_wr_error;

wire                    p4_cmd_clk;
wire                    p4_cmd_en;
wire            [2:0]   p4_cmd_instr;
wire            [5:0]   p4_cmd_bl;
wire            [29:0]  p4_cmd_byte_addr;
wire                    p4_cmd_empty;
wire                    p4_cmd_full;
wire                    p4_rd_clk;
wire                    p4_rd_en;
wire            [31:0]  p4_rd_data;
wire                    p4_rd_full;
wire                    p4_rd_empty;
wire            [6:0]   p4_rd_count;
wire                    p4_rd_overflow;
wire                    p4_rd_error;

wire                    p5_cmd_clk;
wire                    p5_cmd_en;
wire            [2:0]   p5_cmd_instr;
wire            [5:0]   p5_cmd_bl;
wire            [29:0]  p5_cmd_byte_addr;
wire                    p5_cmd_empty;
wire                    p5_cmd_full;
wire                    p5_rd_clk;
wire                    p5_rd_en;
wire            [31:0]  p5_rd_data;
wire                    p5_rd_full;
wire                    p5_rd_empty;
wire            [6:0]   p5_rd_count;
wire                    p5_rd_overflow;
wire                    p5_rd_error;
wire                    usr_clk;

reg                     ddr3_rst_in;
reg             [15:0]  ddr3_rst_in_count;

//Submodules
artemis_clkgen clkgen(
  .clk_100mhz         (clk_100mhz           ),
  .rst                (rst                  ),

  .locked             (pll_locked           ),

  .clk                (clk                  ),
  .ddr3_clk           (ddr3_clk_out         )
);

artemis_ddr3 artemis_ddr3_cntrl(
  .clk_333mhz         (ddr3_clk_in           ),
  //.board_rst          (rst  || !pll_locked   ),
  .board_rst          (ddr3_rst_in           ),

  .calibration_done   (calibration_done      ),

  .usr_clk            (usr_clk               ),
  .rst                (ddr3_rst              ),

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

  .p4_cmd_clk         (p4_cmd_clk            ),
  .p4_cmd_en          (p4_cmd_en             ),
  .p4_cmd_instr       (p4_cmd_instr          ),
  .p4_cmd_bl          (p4_cmd_bl             ),
  .p4_cmd_byte_addr   (p4_cmd_byte_addr      ),
  .p4_cmd_empty       (p4_cmd_empty          ),
  .p4_cmd_full        (p4_cmd_full           ),
  .p4_rd_clk          (p4_rd_clk             ),
  .p4_rd_en           (p4_rd_en              ),
  .p4_rd_data         (p4_rd_data            ),
  .p4_rd_full         (p4_rd_full            ),
  .p4_rd_empty        (p4_rd_empty           ),
  .p4_rd_count        (p4_rd_count           ),
  .p4_rd_overflow     (p4_rd_overflow        ),
  .p4_rd_error        (p4_rd_error           ),

  .p5_cmd_clk         (p5_cmd_clk            ),
  .p5_cmd_en          (p5_cmd_en             ),
  .p5_cmd_instr       (p5_cmd_instr          ),
  .p5_cmd_bl          (p5_cmd_bl             ),
  .p5_cmd_byte_addr   (p5_cmd_byte_addr      ),
  .p5_cmd_empty       (p5_cmd_empty          ),
  .p5_cmd_full        (p5_cmd_full           ),
  .p5_rd_clk          (p5_rd_clk             ),
  .p5_rd_en           (p5_rd_en              ),
  .p5_rd_data         (p5_rd_data            ),
  .p5_rd_full         (p5_rd_full            ),
  .p5_rd_empty        (p5_rd_empty           ),
  .p5_rd_count        (p5_rd_count           ),
  .p5_rd_overflow     (p5_rd_overflow        ),
  .p5_rd_error        (p5_rd_error           )
);

if (DDR3_W0_CH) begin
  assign  p2_cmd_clk  =   clk;
  assign  p2_wr_clk   =   clk;

  ddr3_dma w0(
      .clk                (clk                ),
      .rst                (rst                ),

      //Write Side
      .write_enable       (w0_write_enable    ),
      .write_addr         (w0_write_addr      ),
      .write_addr_inc     (w0_write_addr_inc  ),
      .write_addr_dec     (w0_write_addr_dec  ),
      .write_finished     (w0_write_finished  ),
      .write_count        (w0_write_count     ),
      .write_flush        (w0_write_flush     ),

      .write_ready        (w0_write_ready     ),
      .write_activate     (w0_write_activate  ),
      .write_size         (w0_write_size      ),
      .write_strobe       (w0_write_strobe    ),
      .write_data         (w0_write_data      ),

      //Read Side
      .read_enable        (1'b0               ),
      .read_addr          (64'b0              ),
      .read_addr_inc      (1'b0               ),
      .read_addr_dec      (1'b0               ),
      .read_count         (24'b0              ),
      .read_flush         (1'b0               ),

      .read_activate      (1'b0               ),
      .read_strobe        (1'b0               ),

      //Local Registers/Wires
      .cmd_en             (p2_cmd_en          ),
      .cmd_instr          (p2_cmd_instr       ),
      .cmd_bl             (p2_cmd_bl          ),
      .cmd_byte_addr      (p2_cmd_byte_addr   ),
      .cmd_empty          (p2_cmd_empty       ),
      .cmd_full           (p2_cmd_full        ),

      .wr_en              (p2_wr_en           ),
      .wr_mask            (p2_wr_mask         ),
      .wr_data            (p2_wr_data         ),
      .wr_full            (p2_wr_full         ),
      .wr_empty           (p2_wr_empty        ),
      .wr_count           (p2_wr_count        ),
      .wr_underrun        (p2_wr_underrun     ),
      .wr_error           (p2_wr_error        ),

      .rd_data            (32'b0              ),
      .rd_full            (1'b0               ),
      .rd_empty           (1'b1               ),
      .rd_count           (24'b0              ),
      .rd_overflow        (1'b0               ),
      .rd_error           (1'b0               )
  );
end
else begin

  assign  p2_cmd_clk         = 0;
  assign  p2_cmd_instr       = 0;
  assign  p2_cmd_en          = 0;
  assign  p2_cmd_bl          = 0;
  assign  p2_cmd_byte_addr   = 0;
  assign  p2_wr_clk          = 0;
  assign  p2_wr_en           = 0;
  assign  p2_wr_mask         = 0;
  assign  p2_wr_data         = 0;

  assign  w0_write_finished  = 0;
  assign  w0_write_ready     = 0;
  assign  w0_write_size      = 0;

end

if (DDR3_W1_CH) begin

  assign  p3_cmd_clk  =   clk;
  assign  p3_wr_clk   =   clk;

  ddr3_dma w1(
      .clk                (clk                ),
      .rst                (rst                ),

      //Write Side
      .write_enable       (w1_write_enable    ),
      .write_addr         (w1_write_addr      ),
      .write_addr_inc     (w1_write_addr_inc  ),
      .write_addr_dec     (w1_write_addr_dec  ),
      .write_finished     (w1_write_finished  ),
      .write_count        (w1_write_count     ),
      .write_flush        (w1_write_flush     ),

      .write_ready        (w1_write_ready     ),
      .write_activate     (w1_write_activate  ),
      .write_size         (w1_write_size      ),
      .write_strobe       (w1_write_strobe    ),
      .write_data         (w1_write_data      ),

      //Read Side
      .read_enable        (1'b0               ),
      .read_addr          (64'b0              ),
      .read_addr_inc      (1'b0               ),
      .read_addr_dec      (1'b0               ),
      .read_count         (24'b0              ),
      .read_flush         (1'b0               ),

      .read_activate      (1'b0               ),
      .read_strobe        (1'b0               ),

      //Local Registers/Wires
      .cmd_en             (p3_cmd_en          ),
      .cmd_instr          (p3_cmd_instr       ),
      .cmd_bl             (p3_cmd_bl          ),
      .cmd_byte_addr      (p3_cmd_byte_addr   ),
      .cmd_empty          (p3_cmd_empty       ),
      .cmd_full           (p3_cmd_full        ),

      .wr_en              (p3_wr_en           ),
      .wr_mask            (p3_wr_mask         ),
      .wr_data            (p3_wr_data         ),
      .wr_full            (p3_wr_full         ),
      .wr_empty           (p3_wr_empty        ),
      .wr_count           (p3_wr_count        ),
      .wr_underrun        (p3_wr_underrun     ),
      .wr_error           (p3_wr_error        ),

      .rd_data            (32'b0              ),
      .rd_full            (1'b0               ),
      .rd_empty           (1'b1               ),
      .rd_count           (24'b0              ),
      .rd_overflow        (1'b0               ),
      .rd_error           (1'b0               )
  );
end
else begin
  assign  p3_cmd_clk         = 0;
  assign  p3_cmd_instr       = 0;
  assign  p3_cmd_en          = 0;
  assign  p3_cmd_bl          = 0;
  assign  p3_cmd_byte_addr   = 0;
  assign  p3_wr_clk          = 0;
  assign  p3_wr_en           = 0;
  assign  p3_wr_mask         = 0;
  assign  p3_wr_data         = 0;

  assign  w1_write_finished  = 0;
  assign  w1_write_ready     = 0;
  assign  w1_write_size      = 0;
end

if (DDR3_R0_CH) begin
  assign  p4_cmd_clk  =   clk;
  assign  p4_rd_clk   =   clk;

  ddr3_dma r0(
      .clk                (clk                ),
      .rst                (rst                ),

      //Write Side
      .write_enable       (1'b0               ),
      .write_addr         (64'b0              ),
      .write_addr_inc     (1'b0               ),
      .write_addr_dec     (1'b0               ),
      .write_count        (24'b0              ),

      .write_activate     (1'b0               ),
      .write_strobe       (1'b0               ),
      .write_data         (32'b0              ),

      //Read Side
      .read_enable        (r0_read_enable     ),
      .read_addr          (r0_read_addr       ),
      .read_addr_inc      (r0_read_addr_inc   ),
      .read_addr_dec      (r0_read_addr_dec   ),
      .read_busy          (r0_read_busy       ),
      .read_error         (r0_read_error      ),
      .read_count         (r0_read_count      ),
      .read_flush         (r0_read_flush      ),

      .read_ready         (r0_read_ready      ),
      .read_activate      (r0_read_activate   ),
      .read_size          (r0_read_size       ),
      .read_data          (r0_read_data       ),
      .read_strobe        (r0_read_strobe     ),

      //Local Registers/Wires
      .cmd_en             (p4_cmd_en          ),
      .cmd_instr          (p4_cmd_instr       ),
      .cmd_bl             (p4_cmd_bl          ),
      .cmd_byte_addr      (p4_cmd_byte_addr   ),
      .cmd_empty          (p4_cmd_empty       ),
      .cmd_full           (p4_cmd_full        ),

      .wr_full            (1'b0               ),
      .wr_empty           (1'b1               ),
      .wr_count           (7'b0               ),
      .wr_underrun        (1'b0               ),
      .wr_error           (1'b0               ),

      .rd_en              (p4_rd_en           ),
      .rd_data            (p4_rd_data         ),
      .rd_full            (p4_rd_full         ),
      .rd_empty           (p4_rd_empty        ),
      .rd_count           (p4_rd_count        ),
      .rd_overflow        (p4_rd_overflow     ),
      .rd_error           (p4_rd_error        )
  );
end
else begin
  assign  p4_cmd_clk          =   0;
  assign  p4_cmd_en           =   0;
  assign  p4_cmd_instr        =   0;
  assign  p4_cmd_bl           =   0;
  assign  p4_cmd_byte_addr    =   0;

  assign  p4_rd_clk           =   0;
  assign  p4_rd_en            =   0;

  assign  r0_read_busy        =   0;
  assign  r0_read_error       =   0;
  assign  r0_read_ready       =   0;
  assign  r0_read_size        =   0;
  assign  r0_read_data        =   0;
end

if (DDR3_R1_CH) begin
  assign  p5_cmd_clk  =   clk;
  assign  p5_rd_clk   =   clk;

  ddr3_dma r1(
      .clk                (clk                ),
      .rst                (rst                ),

      //Write Side
      .write_enable       (1'b0               ),
      .write_addr         (64'b0              ),
      .write_addr_inc     (1'b0               ),
      .write_addr_dec     (1'b0               ),
      .write_count        (24'b0              ),

      .write_activate     (1'b0               ),
      .write_strobe       (1'b0               ),
      .write_data         (32'b0              ),

      //Read Side
      .read_enable        (r1_read_enable     ),
      .read_addr          (r1_read_addr       ),
      .read_addr_inc      (r1_read_addr_inc   ),
      .read_addr_dec      (r1_read_addr_dec   ),
      .read_busy          (r1_read_busy       ),
      .read_error         (r1_read_error      ),
      .read_count         (r1_read_count      ),
      .read_flush         (r1_read_flush      ),

      .read_ready         (r1_read_ready      ),
      .read_activate      (r1_read_activate   ),
      .read_size          (r1_read_size       ),
      .read_data          (r1_read_data       ),
      .read_strobe        (r1_read_strobe     ),

      .cmd_en             (p5_cmd_en          ),
      .cmd_instr          (p5_cmd_instr       ),
      .cmd_bl             (p5_cmd_bl          ),
      .cmd_byte_addr      (p5_cmd_byte_addr   ),
      .cmd_empty          (p5_cmd_empty       ),
      .cmd_full           (p5_cmd_full        ),

      .wr_full            (1'b0               ),
      .wr_empty           (1'b1               ),
      .wr_count           (7'b0               ),
      .wr_underrun        (1'b0               ),
      .wr_error           (1'b0               ),

      .rd_en              (p5_rd_en           ),
      .rd_data            (p5_rd_data         ),
      .rd_full            (p5_rd_full         ),
      .rd_empty           (p5_rd_empty        ),
      .rd_count           (p5_rd_count        ),
      .rd_overflow        (p5_rd_overflow     ),
      .rd_error           (p5_rd_error        )
  );
end
else begin
  assign  p5_cmd_clk          =   0;
  assign  p5_cmd_en           =   0;
  assign  p5_cmd_instr        =   0;
  assign  p5_cmd_bl           =   0;
  assign  p5_cmd_byte_addr    =   0;

  assign  p5_rd_clk           =   0;
  assign  p5_rd_en            =   0;

  assign  r1_read_busy        =   0;
  assign  r1_read_error       =   0;
  assign  r1_read_ready       =   0;
  assign  r1_read_size        =   0;
  assign  r1_read_data        =   0;
end

if (DDR3_RW0_CH) begin
  assign  p1_cmd_clk  =   clk;
  assign  p1_wr_clk   =   clk;
  assign  p1_rd_clk   =   clk;

  ddr3_dma rw0(
      .clk                (clk                ),
      .rst                (rst                ),

      //Write Side
      .write_enable       (rw0_write_enable   ),
      .write_addr         (rw0_write_addr     ),
      .write_addr_inc     (rw0_write_addr_inc ),
      .write_addr_dec     (rw0_write_addr_dec ),
      .write_finished     (rw0_write_finished ),
      .write_count        (rw0_write_count    ),
      .write_flush        (rw0_write_flush    ),

      .write_ready        (rw0_write_ready    ),
      .write_activate     (rw0_write_activate ),
      .write_size         (rw0_write_size     ),
      .write_strobe       (rw0_write_strobe   ),
      .write_data         (rw0_write_data     ),

      //Read Side
      .read_enable        (rw0_read_enable    ),
      .read_addr          (rw0_read_addr      ),
      .read_addr_inc      (rw0_read_addr_inc  ),
      .read_addr_dec      (rw0_read_addr_dec  ),
      .read_busy          (rw0_read_busy      ),
      .read_error         (rw0_read_error     ),
      .read_count         (rw0_read_count     ),
      .read_flush         (rw0_read_flush     ),

      .read_ready         (rw0_read_ready     ),
      .read_activate      (rw0_read_activate  ),
      .read_size          (rw0_read_size      ),
      .read_data          (rw0_read_data      ),
      .read_strobe        (rw0_read_strobe    ),

      //Memory Interfaces
      .cmd_en             (p1_cmd_en          ),
      .cmd_instr          (p1_cmd_instr       ),
      .cmd_bl             (p1_cmd_bl          ),
      .cmd_byte_addr      (p1_cmd_byte_addr   ),
      .cmd_empty          (p1_cmd_empty       ),
      .cmd_full           (p1_cmd_full        ),

      .wr_en              (p1_wr_en           ),
      .wr_mask            (p1_wr_mask         ),
      .wr_data            (p1_wr_data         ),
      .wr_full            (p1_wr_full         ),
      .wr_empty           (p1_wr_empty        ),
      .wr_count           (p1_wr_count        ),
      .wr_underrun        (p1_wr_underrun     ),
      .wr_error           (p1_wr_error        ),

      .rd_en              (p1_rd_en           ),
      .rd_data            (p1_rd_data         ),
      .rd_full            (p1_rd_full         ),
      .rd_empty           (p1_rd_empty        ),
      .rd_count           (p1_rd_count        ),
      .rd_overflow        (p1_rd_overflow     ),
      .rd_error           (p1_rd_error        )
  );
end
else begin

  assign  p1_cmd_clk          = 0;
  assign  p1_cmd_en           = 0;
  assign  p1_cmd_instr        = 0;
  assign  p1_cmd_bl           = 0;
  assign  p1_cmd_byte_addr    = 0;
  assign  p1_wr_data          = 0;
  assign  p1_wr_en            = 0;
  assign  p1_wr_clk           = 0;
  assign  p1_wr_mask          = 0;
  assign  p1_rd_clk           = 0;
  assign  p1_rd_en            = 0;
                              
  assign  rw0_read_busy       = 0;
  assign  rw0_read_error      = 0;
  assign  rw0_read_ready      = 0;
  assign  rw0_read_size       = 0;
  assign  rw0_read_data       = 0;

  assign  rw0_write_finished  = 0;
  assign  rw0_write_ready     = 0;
  assign  rw0_write_size      = 0;

end


//Synchronous Logic
always @ (posedge clk) begin
  if (rst) begin
    o_wbs_dat <= 32'h0;
    o_wbs_ack <= 0;
    o_wbs_int <= 0;
  end

  else begin
    //when the master acks our ack, then put our ack down
    if (o_wbs_ack && ~i_wbs_stb)begin
      o_wbs_ack <= 0;
    end

    if (i_wbs_stb && i_wbs_cyc) begin
      //master is requesting somethign
      if (!o_wbs_ack) begin
        if (i_wbs_we) begin
          //write request
          case (i_wbs_adr)
            CONTROL: begin
            end
            default: begin
            end
          endcase
        end
        else begin
          //read request
          case (i_wbs_adr)
            CONTROL: begin
                o_wbs_dat                       <= 32'h00;
                o_wbs_dat[BIT_CALIBRATION_DONE] <= calibration_done;
                o_wbs_dat[BIT_DDR3_RST]         <= ddr3_rst;
                o_wbs_dat[BIT_P0_ENABLE]        <= 1;
                o_wbs_dat[BIT_P1_ENABLE]        <= DDR3_RW0_CH;
                o_wbs_dat[BIT_P2_ENABLE]        <= DDR3_W0_CH;
                o_wbs_dat[BIT_P3_ENABLE]        <= DDR3_W1_CH;
                o_wbs_dat[BIT_P4_ENABLE]        <= DDR3_R0_CH;
                o_wbs_dat[BIT_P5_ENABLE]        <= DDR3_R1_CH;
            end
            DDR3_STATUS0: begin
                o_wbs_dat                       <= 0;
                o_wbs_dat[BIT_P0_RD_FULL]       <= p0_rd_full;
                o_wbs_dat[BIT_P0_RD_EMPTY]      <= p0_rd_empty;
                o_wbs_dat[BIT_P0_RD_OVERFLOW]   <= p0_rd_overflow;
                o_wbs_dat[BIT_P0_RD_ERROR]      <= p0_rd_error;
                o_wbs_dat[BIT_P0_WR_EMPTY]      <= p0_wr_empty;
                o_wbs_dat[BIT_P0_WR_FULL]       <= p0_wr_full;
                o_wbs_dat[BIT_P0_WR_UNDERRUN]   <= p0_wr_underrun;

                o_wbs_dat[BIT_P1_RD_FULL]       <= p1_rd_full;
                o_wbs_dat[BIT_P1_RD_EMPTY]      <= p1_rd_empty;
                o_wbs_dat[BIT_P1_RD_OVERFLOW]   <= p1_rd_overflow;
                o_wbs_dat[BIT_P1_RD_ERROR]      <= p1_rd_error;
                o_wbs_dat[BIT_P1_WR_EMPTY]      <= p1_wr_empty;
                o_wbs_dat[BIT_P1_WR_FULL]       <= p1_wr_full;
                o_wbs_dat[BIT_P1_WR_UNDERRUN]   <= p1_wr_underrun;

                o_wbs_dat[BIT_P2_RD_FULL]       <= 1'b0;
                o_wbs_dat[BIT_P2_RD_EMPTY]      <= 1'b0;
                o_wbs_dat[BIT_P2_RD_OVERFLOW]   <= 1'b0;
                o_wbs_dat[BIT_P2_RD_ERROR]      <= 1'b0;
                o_wbs_dat[BIT_P2_WR_EMPTY]      <= p2_wr_empty;
                o_wbs_dat[BIT_P2_WR_FULL]       <= p2_wr_full;
                o_wbs_dat[BIT_P2_WR_UNDERRUN]   <= p2_wr_underrun;

                o_wbs_dat[BIT_P3_RD_FULL]       <= 1'b0;
                o_wbs_dat[BIT_P3_RD_EMPTY]      <= 1'b0;
                o_wbs_dat[BIT_P3_RD_OVERFLOW]   <= 1'b0;
                o_wbs_dat[BIT_P3_RD_ERROR]      <= 1'b0;
                o_wbs_dat[BIT_P3_WR_EMPTY]      <= p3_wr_empty;
                o_wbs_dat[BIT_P3_WR_FULL]       <= p3_wr_full;
                o_wbs_dat[BIT_P3_WR_UNDERRUN]   <= p3_wr_underrun;
            end
            DDR3_STATUS1: begin
                o_wbs_dat                       <= 0;
                o_wbs_dat[BIT_P4_RD_FULL]       <= p4_rd_full;
                o_wbs_dat[BIT_P4_RD_EMPTY]      <= p4_rd_empty;
                o_wbs_dat[BIT_P4_RD_OVERFLOW]   <= p4_rd_overflow;
                o_wbs_dat[BIT_P4_RD_ERROR]      <= p4_rd_error;
                o_wbs_dat[BIT_P4_WR_EMPTY]      <= 1'b0;
                o_wbs_dat[BIT_P4_WR_FULL]       <= 1'b0;
                o_wbs_dat[BIT_P4_WR_UNDERRUN]   <= 1'b0; 

                o_wbs_dat[BIT_P5_RD_FULL]       <= p5_rd_full;
                o_wbs_dat[BIT_P5_RD_EMPTY]      <= p5_rd_empty;
                o_wbs_dat[BIT_P5_RD_OVERFLOW]   <= p5_rd_overflow;
                o_wbs_dat[BIT_P5_RD_ERROR]      <= p5_rd_error;
                o_wbs_dat[BIT_P5_WR_EMPTY]      <= 1'b0; 
                o_wbs_dat[BIT_P5_WR_FULL]       <= 1'b0; 
                o_wbs_dat[BIT_P5_WR_UNDERRUN]   <= 1'b0;
            end
            default: begin
            end
          endcase
        end
      o_wbs_ack <= 1;
    end
    end
  end
end

always @ (posedge clk) begin
    if (rst || !pll_locked) begin
        ddr3_rst_in_count       <=  0;
        ddr3_rst_in             <=  1;
    end
    else begin
        if (ddr3_rst_in_count < 16'hFFFF) begin
            ddr3_rst_in         <=  1;
            ddr3_rst_in_count   <=  ddr3_rst_in_count + 1;
        end
        else begin
            ddr3_rst_in     <=  0;
        end
    end
end

endmodule
