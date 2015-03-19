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
IBUFG clk_100mhz_ibuf (
  .I                    (clk_100mhz           ),
  .O                    (clk                  )
);

BUFG  clkfb_buf (
  .I                    (clk_fbout            ),
  .O                    (clk_fbout_buf        )
);

BUFG ddr3_clk_obuf     (
  .I                    (ddr3_clk_pre         ),
  .O                    (ddr3_clk             )
);


PLL_BASE #(
  .BANDWIDTH            ("OPTIMIZED"          ),
  .CLK_FEEDBACK         ("CLKFBOUT"           ),
  .COMPENSATION         ("SYSTEM_SYNCHRONOUS" ),
  .DIVCLK_DIVIDE        (1                    ),
  .CLKFBOUT_MULT        (10                   ),
  .CLKFBOUT_PHASE       (0.00                 ),
  .CLKOUT0_DIVIDE       (3                    ),
  .CLKOUT0_PHASE        (0.00                 ),
  .CLKOUT0_DUTY_CYCLE   (0.50                 ),
  .CLKIN_PERIOD         (10.0                 ),
  .REF_JITTER           (0.010                )

) artemis_clkgen_pll(

  .CLKFBOUT             (clk_fbout            ),
//  .CLKOUT0              (ddr3_clk             ),
  .CLKOUT0              (ddr3_clk_pre         ),
  .CLKOUT2              (                     ),
  .CLKOUT3              (                     ),
  .CLKOUT4              (                     ),
  .CLKOUT5              (                     ),

  .LOCKED               (locked               ),
  .RST                  (rst                  ),

  .CLKFBIN              (clk_fbout_buf        ),
  .CLKIN                (clk                  )
);

//Assynchronous Logic
//Synchronous Logic

endmodule
