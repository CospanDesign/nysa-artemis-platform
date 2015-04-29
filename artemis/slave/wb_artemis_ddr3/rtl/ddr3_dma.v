

module ddr3_dma(

    //Write Side
    input                                 write_enable,
    input       [63:0]                    write_addr,
    input                                 write_addr_inc,
    input                                 write_addr_dec,
    output  reg                           write_finished,
    input       [23:0]                    write_count,
    input                                 write_flush,

    output      [1:0]                     write_ready,
    input       [1:0]                     write_activate,
    output      [23:0]                    write_size,
    input                                 write_strobe,
    input       [31:0]                    write_data,

    //Read Side
    input                                 read_enable,
    input       [63:0]                    read_addr,
    input                                 read_addr_inc,
    input                                 read_addr_dec,
    output                                read_busy,
    output                                read_error,
    input       [23:0]                    read_count,
    input                                 read_flush,

    output                                read_ready,
    input                                 read_activate,
    output      [23:0]                    read_size,
    output      [31:0]                    read_data,
    input                                 read_strobe,

    //Local Registers/Wires
    output                                cmd_en,       //Command is strobed into controller
    output        [2:0]                   cmd_instr,    //Instruction
    output        [5:0]                   cmd_bl,       //Burst Length
    output        [27:0]                  cmd_word_addr,//Word Address
    input                                 cmd_empty,    //Command FIFO empty
    input                                 cmd_full,     //Command FIFO full

    output                                wr_en,        //Write Data strobe
    output        [3:0]                   wr_mask,      //Write Strobe Mask (Not used, always set to 0)
    output        [31:0]                  wr_data,      //Data to write into memory
    input                                 wr_full,      //Write FIFO is full
    input                                 wr_empty,     //Write FIFO is empty
    input         [6:0]                   wr_count,     //Number of words in the write FIFO, this is slow to respond
    input                                 wr_underrun,  //There isn't enough data to fullfill the memory transaction
    input                                 wr_error,     //FIFO pointers are unsynchronized a reset is the only way to recover

    output                                rd_en,        //Enable a read from memory FIFO
    input         [31:0]                  rd_data,      //data read from FIFO
    input                                 rd_full,      //FIFO is full
    input                                 rd_empty,     //FIFO is empty
    input         [6:0]                   rd_count,     //Number of elements inside the FIFO (This is slow to respond, so don't use it as a clock to clock estimate of how much data is available
    input                                 rd_overflow,  //the FIFO is overflowed and data is lost
    input                                 rd_error      //FIFO pointers are out of sync and a reset is required
);

//Local Parameters

//Registers/Wires
reg [23:0]  local_write_size;
reg [23:0]  local_write_count;

reg         prev_edge_write_enable;
wire        posedge_write_enable;

//Sub Modules
//Submodules
ddr3_controller dc(

  .clk                (clk                   ),
  .rst                (rst                   ),

  .write_en           (write_enable          ),
  .write_address      (write_addr[27:0]      ),

  .read_en            (read_enable           ),
  .read_address       (read_addr[27:0]       ),

  .if_write_strobe    (write_strobe          ),
  .if_write_data      (write_data            ),
  .if_write_ready     (write_ready           ),
  .if_write_activate  (write_activate        ),
  .if_write_fifo_size (write_size            ),
  //.if_starved         (if_starved            ),

  .of_read_strobe     (read_strobe           ),
  .of_read_ready      (read_ready            ),
  .of_read_activate   (read_activate         ),
  .of_read_size       (read_size             ),
  .of_read_data       (read_data             ),

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



//Asynchroous Logic

assign      read_busy           = read_enable;
assign      read_error          = 0;
assign      posege_write_enable = (!prev_edge_write_enable & write_enable);

//Synchronous Logic
always @ (posedge clk) begin
  if (rst) begin
    local_write_size        <= 0;
    local_write_count       <= 0;
    write_finished          <= 0;
    prev_edge_write_enable  <= 0;
  end
  else begin
    if (!write_enable) begin
      //Reset Everything
      local_write_size      <= 0;
      local_write_count     <= 0;
      write_finished        <= 0;
    end
    else begin
      if (posedge_write_enable) begin
        local_write_size    <= write_count;
      end

      //Write Strobe
      if (write_strobe) begin
        local_write_count   <= local_write_count + 1;
      end

      //write finished
      if (local_write_count >= local_write_size) begin
        write_finished      <=  1;
      end
    end
    prev_edge_write_enable  <=  write_enable;
  end
end

endmodule
