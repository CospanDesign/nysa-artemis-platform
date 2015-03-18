module artemis_clkgen (
  input   clk_100mhz,
  input   rst,

  output  locked,

  output  clk,
  output  ddr3_clk
);

//Local Parameters

//Registers/Wires
wire        clk_100mhz_buf;
wire        clk_fbout;
wire        clk_fbout_buf;
wire        clk_100mhz_out;

//Submodules
ibufg clk_100mhz_buf (
  .i                    (clk_100mhz           ),
  .o                    (clk_100mhz_buf       )
);

bufg  clkfb_buf (
  .i                    (clkfbout             ),
  .o                    (clkfbout_buf         )
);

bufg  clk100mhz_buf (
  .i                    (clk_100mhz_out       ),
  .o                    (clk                  )
);



pll_base #(
  .bandwidth            ("OPTIMIZED"          ),
  .clk_feedback         ("CLKFBOUT"           ),
  .compensation         ("SYSTEM_SYNCHRONOUS" ),
  .divclk_divide        (1                    ),
  .clkfbout_mult        (10                   ),
  .clkfbout_phase       (0.00                 ),
  .clkout0_divide       (10                   ),
  .clkout0_phase        (0.00                 ),
  .clkout0_duty_cycle   (0.50                 ),
  .clkout1_divide       (3                    ),
  .clkout1_phase        (0.00                 ),
  .clkout1_duty_cycle   (0.50                 ),
  .clkin_period         (10.0                 ),
  .ref_jitter           (0.010                )

) artemis_clkgen_pll(

  .clkfbout             (clk_fbout            ),
  .clkout0              (clk_100mhz_out       ),
  .clkout1              (ddr3_clk             ),
  .clkout2              (                     ),
  .clkout3              (                     ),
  .clkout4              (                     ),
  .clkout5              (                     ),

  .locked               (locked               ),
  .rst                  (rst                  ),

  .clkfbin              (clk_fbout_buf        ),
  .clkin                (clk_100mhz_buf       )
);

//Assynchronous Logic
//Synchronous Logic

endmodule
