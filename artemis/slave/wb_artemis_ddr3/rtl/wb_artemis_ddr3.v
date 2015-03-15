//wb_artemis_ddr3.v
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
  SDB_DEVICE_ID:0x00000000

  Set the version of the Core XX.XXX.XXX Example: 01.000.000
  SDB_CORE_VERSION:00.000.001

  Set the Device Name: 19 UNICODE characters
  SDB_NAME:wb_artemis_ddr3

  Set the class of the device (16 bits) Set as 0
  SDB_ABI_CLASS:0

  Set the ABI Major Version: (8-bits)
  SDB_ABI_VERSION_MAJOR:0x06

  Set the ABI Minor Version (8-bits)
  SDB_ABI_VERSION_MINOR:0x03

  Set the Module URL (63 Unicode Characters)
  SDB_MODULE_URL:http://www.example.com

  Set the date of module YYYY/MM/DD
  SDB_DATE:2015/03/11

  Device is executable (True/False)
  SDB_EXECUTABLE:True

  Device is readable (True/False)
  SDB_READABLE:True

  Device is writeable (True/False)
  SDB_WRITEABLE:True

  Device Size: Number of Registers
  SDB_SIZE:0x8000000
*/

`timescale 1 ns/1 ps

module wb_artemis_ddr3 (
  input                 clk,
  input                 rst,

  //Add signals to control your device here
  input                 clk_100mhz,
  output  wire          calibration_done,

  output                usr_clk,
  output                usr_rst,

  inout         [7:0]   mcb3_dram_dq,
  output        [13:0]  mcb3_dram_a,
  output        [2:0]   mcb3_dram_ba,
  output                mcb3_dram_ras_n,
  output                mcb3_dram_cas_n,
  output                mcb3_dram_we_n,
  output                mcb3_dram_odt,
  output                mcb3_dram_reset_n,
  output                mcb3_dram_cke,
  output                mcb3_dram_dm,
  inout                 mcb3_rzq,
  inout                 mcb3_zio,
  inout                 mcb3_dram_dqs,
  inout                 mcb3_dram_dqs_n,
  output                mcb3_dram_ck,
  output                mcb3_dram_ck_n,

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

  //Wishbone Bus Signals
  input                 i_wbs_we,
  input                 i_wbs_cyc,
  input         [3:0]   i_wbs_sel,
  input         [31:0]  i_wbs_dat,
  input                 i_wbs_stb,
  output  reg           o_wbs_ack,
  output  reg   [31:0]  o_wbs_dat,
  input         [31:0]  i_wbs_adr,

  //This interrupt can be controlled from this module or a submodule
  output  reg         o_wbs_int
  //output              o_wbs_int
);

//Local Parameters
//Registers/Wires

reg           write_en;
reg           read_en;

reg           if_write_strobe;
wire  [1:0]   if_write_ready;
reg   [1:0]   if_write_activate;
wire  [23:0]  if_write_fifo_size;
wire          if_starved;

reg           of_read_strobe;
wire          of_read_ready;
reg           of_read_activate;
wire  [23:0]  of_read_size;
wire  [31:0]  of_read_data;


wire          cmd_en;
wire   [2:0]  cmd_instr;
wire   [5:0]  cmd_bl;
wire   [27:0] cmd_word_addr;
wire          cmd_empty;
wire          cmd_full;

wire          wr_en;
wire   [3:0]  wr_mask;
wire   [31:0] wr_data;
wire          wr_full;
wire          wr_empty;
wire   [6:0]  wr_count;
wire          wr_underrun;
wire          wr_error;

wire          rd_en;
wire   [31:0] rd_data;
wire          rd_full;
wire          rd_empty;
wire   [6:0]  rd_count;
wire          rd_overflow;
wire          rd_error;


reg   [23:0]  write_count;
reg   [23:0]  read_count;



//Submodules
sim_artemis_ddr3 adu(
  .clk_100mhz         (clk_100mhz            ),
  .rst                (rst                   ),
                      
  .calibration_done   (calibration_done      ),
                      
  .usr_clk            (usr_clk               ),
  .usr_rst            (usr_rst               ),
                      
  .mcb3_dram_dq       (mcb3_dram_dq          ),
  .mcb3_dram_a        (mcb3_dram_a           ),
  .mcb3_dram_ba       (mcb3_dram_ba          ),
  .mcb3_dram_ras_n    (mcb3_dram_ras_n       ),
  .mcb3_dram_cas_n    (mcb3_dram_cas_n       ),
  .mcb3_dram_we_n     (mcb3_dram_we_n        ),
  .mcb3_dram_odt      (mcb3_dram_odt         ),
  .mcb3_dram_reset_n  (mcb3_dram_reset_n     ),
  .mcb3_dram_cke      (mcb3_dram_cke         ),
  .mcb3_dram_dm       (mcb3_dram_dm          ),
  .mcb3_rzq           (mcb3_rzq              ),
  .mcb3_zio           (mcb3_zio              ),
  .mcb3_dram_dqs      (mcb3_dram_dqs         ),
  .mcb3_dram_dqs_n    (mcb3_dram_dqs_n       ),
  .mcb3_dram_ck       (mcb3_dram_ck          ),
  .mcb3_dram_ck_n     (mcb3_dram_ck_n        ),
                      
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
                      
  //P.ort 3           
  .p3_cmd_clk         (clk                   ),
  .p3_cmd_en          (cmd_en                ),
  .p3_cmd_instr       (cmd_instr             ),
  .p3_cmd_bl          (cmd_bl                ),
  .p3_cmd_byte_addr   ({cmd_word_addr, 2'b00}),
  .p3_cmd_empty       (cmd_empty             ),
  .p3_cmd_full        (cmd_full              ),
                      
  .p3_wr_clk          (clk                   ),
  .p3_wr_en           (wr_en                 ),
  .p3_wr_mask         (wr_mask               ),
  .p3_wr_data         (wr_data               ),
  .p3_wr_full         (wr_full               ),
  .p3_wr_empty        (wr_empty              ),
  .p3_wr_count        (wr_count              ),
  .p3_wr_underrun     (wr_underrun           ),
  .p3_wr_error        (wr_error              ),
                      
  .p3_rd_clk          (clk                   ),
  .p3_rd_en           (rd_en                 ),
  .p3_rd_data         (rd_data               ),
  .p3_rd_full         (rd_full               ),
  .p3_rd_empty        (rd_empty              ),
  .p3_rd_count        (rd_count              ),
  .p3_rd_overflow     (rd_overflow           ),
  .p3_rd_error        (rd_error              )

);

ddr3_controller dc(

  .clk                (clk                   ),
  .rst                (rst                   ),
                                             
  .calibration_done   (calibration_done      ),
  .address            (i_wbs_adr[27:0]       ),
  .write_en           (write_en              ),
  .read_en            (read_en               ),
                                             
  .if_write_strobe    (if_write_strobe       ),
  .if_write_data      (i_wbs_dat             ),
  .if_write_ready     (if_write_ready        ),
  .if_write_activate  (if_write_activate     ),
  .if_write_fifo_size (if_write_fifo_size    ),
  .if_starved         (if_starved            ),
                                             
  .of_read_strobe     (of_read_strobe        ),
  .of_read_ready      (of_read_ready         ),
  .of_read_activate   (of_read_activate      ),
  .of_read_size       (of_read_size          ),
  .of_read_data       (of_read_data          ),
                                             
                                             
  .cmd_en             (cmd_en                ),
  .cmd_instr          (cmd_instr             ),
  .cmd_bl             (cmd_bl                ),
  .cmd_word_addr      (cmd_word_addr         ),
  .cmd_empty          (cmd_empty             ),
  .cmd_full           (cmd_full              ),
                                             
  .wr_en              (wr_en                 ),
  .wr_mask            (wr_mask               ),
  .wr_data            (wr_data               ),
  .wr_full            (wr_full               ),
  .wr_empty           (wr_empty              ),
  .wr_count           (wr_count              ),
  .wr_underrun        (wr_underrun           ),
  .wr_error           (wr_error              ),
                                             
  .rd_en              (rd_en                 ),
  .rd_data            (rd_data               ),
  .rd_full            (rd_full               ),
  .rd_empty           (rd_empty              ),
  .rd_count           (rd_count              ),
  .rd_overflow        (rd_overflow           ),
  .rd_error           (rd_error              )

);


//Asynchronous Logic

//Synchronous Logic
always @ (posedge clk) begin
  if (rst) begin
    o_wbs_dat                 <= 32'h0;
    o_wbs_ack                 <= 0;
    o_wbs_int                 <= 0;


    write_en                  <= 0;
    read_en                   <= 0;

    if_write_strobe           <= 0;
    if_write_activate         <= 0;

    of_read_strobe            <= 0;
    of_read_activate          <= 0;

    write_count               <= 0;
    read_count                <= 0;

  end
  else begin
    //Deasserts Strobes
    if_write_strobe           <= 0;
    of_read_strobe            <= 0;

    //Get a Ping Pong FIFO Writer
    if ((if_write_ready > 0) && (if_write_activate == 0)) begin
      write_count             <=  0;
      if (if_write_ready[0]) begin
        if_write_activate[0]  <=  1;
      end
      else begin
        if_write_activate[1]  <=  1;
      end
    end

    //Get the Ping Pong FIFO Reader
    if (of_read_ready && !of_read_activate) begin
      read_count              <=  0;
      of_read_activate        <=  1;
    end

    //when the master acks our ack, then put our ack down
    if (o_wbs_ack && ~i_wbs_stb)begin
      o_wbs_ack <= 0;
    end

    //A transaction has starting
    if (i_wbs_cyc) begin
      if (i_wbs_we) begin
        write_en            <=  1;
      end
      else begin
        read_en             <=  1;
      end
    end
    else begin
      write_en              <=  0;
      read_en               <=  0;
      //A transaction has ended
      //Close any FIFO that is open
      if_write_activate     <=  0;
      of_read_activate      <=  0;
    end
    if ((if_write_activate > 0) && (write_count > 0)&& (if_write_ready > 0)) begin
      //Other side is idle, give it something to do
      if_write_activate <= 0;
    end


    //Strobe
    else if (i_wbs_stb && i_wbs_cyc) begin
      //master is requesting somethign
      if (!o_wbs_ack) begin
        if (write_en) begin
          //write request
          if (if_write_activate > 0) begin
            if (write_count < if_write_fifo_size) begin
              if_write_strobe <=  1;
              o_wbs_ack       <=  1;
              write_count     <=  write_count + 1;
            end
            else begin
              if_write_activate <=  0;
            end
          end
        end
        else begin
          //read request
          if (of_read_activate) begin
            if (read_count < of_read_size) begin
              o_wbs_dat         <=  of_read_data;
              o_wbs_ack         <=  1;
              of_read_strobe    <=  1;
            end
            else begin
              of_read_activate  <=  0;
            end
          end
        end
      end
    end
  end
end

endmodule
