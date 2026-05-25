`default_nettype none
`timescale 1ns/1ps

/* This testbench instantiates the DUT and connects it to the cocotb test program */
module tb ();

  // ขาพินจำลองสัญญาณนาฬิกาและไฟสำหรับเตาหลอม
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;

  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // อัญเชิญหน้ากากครอบพอร์ตชิปตัวแม่ของเรา (tt_um_ai_gpu_core) มาต่อท่อไฟจำลอง
  tt_um_ai_gpu_core user_project (
`ifdef GL_TEST
      .VPWR(1'b1),
      .VGND(1'b0),
`endif
      .ui_in   (ui_in),    
      .uo_out  (uo_out),   
      .uio_in  (uio_in),   
      .uio_out (uio_out),  
      .uio_oe  (uio_oe),   
      .ena     (ena),
      .clk     (clk),
      .rst_n   (rst_n)
  );

endmodule
