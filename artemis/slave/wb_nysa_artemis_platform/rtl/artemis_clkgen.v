module artemis_clkgen (
 (* KEEP = "TRUE" *) input   clk,
  input   rst,

  output  locked,
(* KEEP = "TRUE" *)  output  ddr3_clk
);

//Local Parameters

//Registers/Wires
wire        clk_100mhz_buf;
wire        clk_fbout;
wire        clk_fbout_buf;
wire        clk_100mhz_out;
//wire        ddr3_clk_pre;
//wire        ddr3_clk_int;

//Submodules
BUFG  clkfb_buf (
  .I                    (clk_fbout            ),
  .O                    (clk_fbout_buf        )
);

/*
BUFG ddr3_clk_obuf     (
  .I                    (ddr3_clk_pre         ),
  .O                    (ddr3_clk_int         )
);

ODDR2 #(
	.DDR_ALIGNMENT        ("NONE"),	//Sets output alignment to NON
	.INIT                 (1'b0),			//Sets the inital state to 0
	.SRTYPE               ("SYNC")			//Specified "SYNC" or "ASYNC" reset
)	pad_buf (

	.Q                    (ddr3_clk),
	.C0                   (ddr3_clk_int),
	.C1                   (~ddr3_clk_int),
	.CE                   (1'b1),
	.D0                   (1'b1),
	.D1                   (1'b0),
	.R                    (1'b0),
	.S                    (1'b0)
);
*/

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
  .CLKOUT0              (ddr3_clk             ),
//  .CLKOUT0              (ddr3_clk_pre         ),
  .CLKOUT1              (                     ),
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
