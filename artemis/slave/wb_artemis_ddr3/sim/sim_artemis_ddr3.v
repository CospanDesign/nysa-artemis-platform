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


module sim_artemis_ddr3 (
  input               ddr3_in_clk,
  input               rst,

  output              calibration_done,

  output              usr_clk,
  output              usr_rst,

  inout       [7:0]   mcb3_dram_dq,
  output      [13:0]  mcb3_dram_a,
  output      [2:0]   mcb3_dram_ba,
  output              mcb3_dram_ras_n,
  output              mcb3_dram_cas_n,
  output              mcb3_dram_we_n,
  output              mcb3_dram_odt,
  output              mcb3_dram_reset_n,
  output              mcb3_dram_cke,
  output              mcb3_dram_dm,
  inout               mcb3_rzq,
  inout               mcb3_zio,
  inout               mcb3_dram_dqs,
  inout               mcb3_dram_dqs_n,
  output              mcb3_dram_ck,
  output              mcb3_dram_ck_n,

  input               p0_cmd_clk,
  input               p0_cmd_en,
  input       [2:0]   p0_cmd_instr,
  input       [5:0]   p0_cmd_bl,
  input       [29:0]  p0_cmd_byte_addr,
  output              p0_cmd_empty,
  output              p0_cmd_full,
  input               p0_wr_clk,
  input               p0_wr_en,
  input       [3:0]   p0_wr_mask,
  input       [31:0]  p0_wr_data,
  output              p0_wr_full,
  output              p0_wr_empty,
  output      [6:0]   p0_wr_count,
  output              p0_wr_underrun,
  output              p0_wr_error,
  input               p0_rd_clk,
  input               p0_rd_en,
  output      [31:0]  p0_rd_data,
  output              p0_rd_full,
  output              p0_rd_empty,
  output      [6:0]   p0_rd_count,
  output              p0_rd_overflow,
  output              p0_rd_error,

  input               p1_cmd_clk,
  input               p1_cmd_en,
  input       [2:0]   p1_cmd_instr,
  input       [5:0]   p1_cmd_bl,
  input       [29:0]  p1_cmd_byte_addr,
  output              p1_cmd_empty,
  output              p1_cmd_full,
  input               p1_wr_clk,
  input               p1_wr_en,
  input       [3:0]   p1_wr_mask,
  input       [31:0]  p1_wr_data,
  output              p1_wr_full,
  output              p1_wr_empty,
  output      [6:0]   p1_wr_count,
  output              p1_wr_underrun,
  output              p1_wr_error,
  input               p1_rd_clk,
  input               p1_rd_en,
  output      [31:0]  p1_rd_data,
  output              p1_rd_full,
  output              p1_rd_empty,
  output      [6:0]   p1_rd_count,
  output              p1_rd_overflow,
  output              p1_rd_error,

  input               p2_cmd_clk,
  input               p2_cmd_en,
  input       [2:0]   p2_cmd_instr,
  input       [5:0]   p2_cmd_bl,
  input       [29:0]  p2_cmd_byte_addr,
  output              p2_cmd_empty,
  output              p2_cmd_full,
  input               p2_wr_clk,
  input               p2_wr_en,
  input       [3:0]   p2_wr_mask,
  input       [31:0]  p2_wr_data,
  output              p2_wr_full,
  output              p2_wr_empty,
  output      [6:0]   p2_wr_count,
  output              p2_wr_underrun,
  output              p2_wr_error,
  input               p2_rd_clk,
  input               p2_rd_en,
  output      [31:0]  p2_rd_data,
  output              p2_rd_full,
  output              p2_rd_empty,
  output      [6:0]   p2_rd_count,
  output              p2_rd_overflow,
  output              p2_rd_error,

  input               p3_cmd_clk,
  input               p3_cmd_en,
  input       [2:0]   p3_cmd_instr,
  input       [5:0]   p3_cmd_bl,
  input       [29:0]  p3_cmd_byte_addr,
  output              p3_cmd_empty,
  output              p3_cmd_full,
  input               p3_wr_clk,
  input               p3_wr_en,
  input       [3:0]   p3_wr_mask,
  input       [31:0]  p3_wr_data,
  output              p3_wr_full,
  output              p3_wr_empty,
  output  reg [6:0]   p3_wr_count,
  output  reg         p3_wr_underrun,
  output  reg         p3_wr_error,
  input               p3_rd_clk,
  input               p3_rd_en,
  output  reg [31:0]  p3_rd_data,
  output              p3_rd_full,
  output              p3_rd_empty,
  output  reg [6:0]   p3_rd_count,
  output  reg         p3_rd_overflow,
  output  reg         p3_rd_error

);

//Local Parameters
localparam            CMD_WRITE     = 3'b000;
localparam            CMD_READ      = 3'b001;
localparam            CMD_WRITE_PC  = 3'b010;
localparam            CMD_READ_PC   = 3'b011;
localparam            CMD_REFRESH   = 3'b100;


//Registers/Wires
reg           [23:0]  write_data_count;
reg           [23:0]  cmd_count;
reg           [23:0]  read_data_count;

reg           [23:0]  write_timeout;
reg           [23:0]  cmd_timeout;
reg           [23:0]  read_timeout;
reg           [23:0]  read_data_size;

reg                   p3_cmd_error;

//Submodules

//Asynchronous Logic
assign  p0_cmd_empty   = 1;
assign  p0_cmd_full    = 0;
assign  p0_wr_empty    = 1;
assign  p0_wr_full     = 0;
assign  p0_wr_count    = 0;
assign  p0_wr_underrun = 0;
assign  p0_wr_error    = 0;
assign  p0_rd_data     = 0;
assign  p0_rd_full     = 0;
assign  p0_rd_empty    = 1;
assign  p0_rd_count    = 0;
assign  p0_rd_overflow = 0;
assign  p0_rd_error    = 0;

assign  p1_cmd_empty   = 1;
assign  p1_cmd_full    = 0;
assign  p1_wr_empty    = 1;
assign  p1_wr_full     = 0;
assign  p1_wr_count    = 0;
assign  p1_wr_underrun = 0;
assign  p1_wr_error    = 0;
assign  p1_rd_data     = 0;
assign  p1_rd_full     = 0;
assign  p1_rd_empty    = 1;
assign  p1_rd_count    = 0;
assign  p1_rd_overflow = 0;
assign  p1_rd_error    = 0;

assign  p2_cmd_empty   = 1;
assign  p2_cmd_full    = 0;
assign  p2_wr_empty    = 1;
assign  p2_wr_full     = 0;
assign  p2_wr_count    = 0;
assign  p2_wr_underrun = 0;
assign  p2_wr_error    = 0;
assign  p2_rd_data     = 0;
assign  p2_rd_full     = 0;
assign  p2_rd_empty    = 1;
assign  p2_rd_count    = 0;
assign  p2_rd_overflow = 0;
assign  p2_rd_error    = 0;


assign p3_wr_full   = (write_data_count == 63);
assign p3_wr_empty  = (write_data_count == 0);

assign p3_cmd_full  = (cmd_count == 4);
assign p3_cmd_empty = (cmd_count == 0);

assign p3_rd_full   = (read_data_count == 63);
assign p3_rd_empty  = (read_data_count == 0);


//Synchronous Logic
parameter CFIFO_READ_DELAY = 20;
parameter WFIFO_READ_DELAY = 20;
parameter RFIFO_WRITE_DELAY = 10;

always @ (posedge p3_cmd_clk) begin
  if (rst) begin
    p3_wr_count         <=  0;
    p3_wr_underrun      <=  0;
    p3_wr_error         <=  0;

    p3_rd_data          <=  0;
    p3_rd_count         <=  0;
    p3_rd_overflow      <=  0;
    p3_rd_error         <=  0;

    p3_cmd_error        <=  0;

    cmd_count           <=  0;
    read_data_count     <=  0;
    write_data_count    <=  0;

    read_timeout        <=  RFIFO_WRITE_DELAY;
    write_timeout       <=  WFIFO_READ_DELAY;
    cmd_timeout         <=  CFIFO_READ_DELAY;
    read_data_size      <=  0;

  end
  else begin
    //Command Stuff
    if (p3_cmd_en && !p3_cmd_full) begin

      if ((p3_cmd_instr == CMD_WRITE) || (p3_cmd_instr == CMD_WRITE_PC)) begin
        if (write_data_count  <  p3_cmd_bl) begin
          p3_wr_underrun  <=  1;
        end
      end
      else if ((p3_cmd_instr == CMD_READ) || (p3_cmd_instr == CMD_READ_PC)) begin
        read_data_size    <=  p3_cmd_bl;
      end
      cmd_count       <=  cmd_count + 1;
      if (cmd_timeout == CFIFO_READ_DELAY) begin
        cmd_timeout   <=  0;
      end
    end
    else if (p2_cmd_en && p2_cmd_full) begin
      p3_cmd_error        <=  1;
    end

    if (cmd_count > 0) begin
      if (cmd_timeout < CFIFO_READ_DELAY) begin
        cmd_timeout       <=  cmd_timeout + 1;
      end
      else begin
        cmd_timeout       <=  0;
        cmd_count         <=  cmd_count - 1;
      end
    end








    //Write Stuff
    if ((write_data_count > 0) && (write_data_count < 64)) begin
      if (write_timeout < WFIFO_READ_DELAY) begin
          write_timeout <= write_timeout + 1;
      end
      else begin
          write_timeout <=  0;
          write_data_count <= write_data_count - 1;
      end
    end
    if (p3_wr_en && !p3_wr_full) begin
      write_data_count  <=  write_data_count + 1;
      if (write_timeout == WFIFO_READ_DELAY) begin
        write_timeout   <=  0;
      end
    end







    //Read Stuff
    if (read_data_size > 0) begin
      if (read_timeout < RFIFO_WRITE_DELAY) begin
        read_timeout  <=  read_timeout + 1;
      end
      else begin
        read_timeout  <=  0;
        read_data_size <= read_data_size - 1;
        read_data_count <= read_data_count + 1;
      end
    end

    if (read_data_count > 0) begin
      if (p3_rd_en && !p3_rd_empty) begin
        if (read_data_count > 0) begin
          read_data_count <= read_data_count - 1;
          p3_rd_data     <= p3_rd_data + 1;
        end
      end
    end

    //Error Condition
    if (p3_rd_en && p3_rd_empty) begin
      p3_rd_error     <=  1;
    end
  end
end
endmodule
