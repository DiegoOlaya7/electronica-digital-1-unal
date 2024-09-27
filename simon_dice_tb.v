// filename: simon_dice_tb.v
`include "./simon_dice.v"
module simon_dice_tb;
// STIMULUS
reg sclk = 0;
reg rst = 0;
reg [3:0] button = 0;
wire [3:0] led;

localparam integer TICKS = 1;
always #(TICKS) sclk = !sclk;

initial begin
// Pasado 32 estímuslos finaliza la simulación
#(1000 * TICKS) $finish();  // [stop(), $finish()]
end

  // RESET STIMULUS
initial begin
#0 rst = 0;
#(1 * TICKS) button = 4'b0100;
#(1 * TICKS) button = 4'b0000;
end

// DEVICE/DESIGN UNDER TEST
simon_dice dut (.clk(sclk), .rst(reset), .button(button), .led(led));
// MONITOR
/*
initial
begin
	$monitor("Time: %t, b = %d, a = %d => c = %d, s = %d",
	$time, b, a, c, s);
end
*/

initial begin
$dumpvars(0, simon_dice_tb);
end

endmodule
