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

  //DDR3 Control Signals
  output                ddr3_cmd_clk,
  output                ddr3_cmd_en,
  output        [2:0]   ddr3_cmd_instr,
  output        [5:0]   ddr3_cmd_bl,
  output        [29:0]  ddr3_cmd_byte_addr,
  input                 ddr3_cmd_empty,
  input                 ddr3_cmd_full,

  output                ddr3_wr_clk,
  output                ddr3_wr_en,
  output        [3:0]   ddr3_wr_mask,
  output        [31:0]  ddr3_wr_data,
  input                 ddr3_wr_full,
  input                 ddr3_wr_empty,
  input         [6:0]   ddr3_wr_count,
  input                 ddr3_wr_underrun,
  input                 ddr3_wr_error,

  output                ddr3_rd_clk,
  output                ddr3_rd_en,
  input         [31:0]  ddr3_rd_data,
  input                 ddr3_rd_full,
  input                 ddr3_rd_empty,
  input         [6:0]   ddr3_rd_count,
  input                 ddr3_rd_overflow,
  input                 ddr3_rd_error,

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

wire  [27:0]  ddr3_cmd_word_addr;
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


reg   [23:0]  write_count;
reg   [23:0]  read_count;



//Submodules
ddr3_controller dc(

  .clk                (clk                   ),
  .rst                (rst                   ),

  .write_address      (i_wbs_adr[27:0]       ),
  .write_en           (write_en              ),
  .read_address       (i_wbs_adr[27:0]       ),
  .read_en            (read_en               ),

  .if_write_strobe    (if_write_strobe       ),
  .if_write_data      (i_wbs_dat             ),
  //.if_write_data      (32'h01234567          ),
  .if_write_ready     (if_write_ready        ),
  .if_write_activate  (if_write_activate     ),
  .if_write_fifo_size (if_write_fifo_size    ),
  .if_starved         (if_starved            ),

  .of_read_strobe     (of_read_strobe        ),
  .of_read_ready      (of_read_ready         ),
  .of_read_activate   (of_read_activate      ),
  .of_read_size       (of_read_size          ),
  .of_read_data       (of_read_data          ),


  .cmd_en             (ddr3_cmd_en           ),
  .cmd_instr          (ddr3_cmd_instr        ),
  .cmd_bl             (ddr3_cmd_bl           ),
  .cmd_word_addr      (ddr3_cmd_word_addr    ),
  .cmd_empty          (ddr3_cmd_empty        ),
  .cmd_full           (ddr3_cmd_full         ),

  .wr_en              (ddr3_wr_en            ),
  .wr_mask            (ddr3_wr_mask          ),
  .wr_data            (ddr3_wr_data          ),
  .wr_full            (ddr3_wr_full          ),
  .wr_empty           (ddr3_wr_empty         ),
  .wr_count           (ddr3_wr_count         ),
  .wr_underrun        (ddr3_wr_underrun      ),
  .wr_error           (ddr3_wr_error         ),

  .rd_en              (ddr3_rd_en            ),
  .rd_data            (ddr3_rd_data          ),
  .rd_full            (ddr3_rd_full          ),
  .rd_empty           (ddr3_rd_empty         ),
  .rd_count           (ddr3_rd_count         ),
  .rd_overflow        (ddr3_rd_overflow      ),
  .rd_error           (ddr3_rd_error         )

);


//Asynchronous Logic

assign  ddr3_cmd_clk               =  clk;
assign  ddr3_wr_clk                =  clk;
assign  ddr3_rd_clk                =  clk;
assign  ddr3_cmd_byte_addr         =  {ddr3_cmd_word_addr, 2'b0};

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
        write_en              <=  1;
      end
      else begin
        read_en               <=  1;
      end
    end
    else begin
      write_en                <=  0;
      read_en                 <=  0;
      //A transaction has ended
      //Close any FIFO that is open
      if_write_activate       <=  0;
      of_read_activate        <=  0;
    end
    if ((if_write_activate > 0) && (write_count > 0)&& (if_write_ready > 0)) begin
      //Other side is idle, give it something to do
      if_write_activate       <= 0;
    end
    //Strobe
    else if (i_wbs_stb && i_wbs_cyc && !o_wbs_ack) begin
      //master is requesting something
      if (write_en) begin
        //write request
        if (if_write_activate > 0) begin
          if (write_count < if_write_fifo_size) begin
            if_write_strobe   <=  1;
            o_wbs_ack         <=  1;
            write_count       <=  write_count + 24'h1;
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

endmodule
