`timescale 1ns/1ps

module tb_alu;

  // Inputs
  logic [7:0] A, B;
  logic [3:0] opcode;
  logic clk, reset_n, start;

  // Outputs
  logic done;
  logic [15:0] result;

  // Instantiate the alu module
  alu uut (
    .A(A),
    .B(B),
    .opcode(opcode),
    .clk(clk),
    .reset_n(reset_n),
    .start(start),
    .done(done),
    .result(result)
  );

  // Clock generation
  always #5 clk =~clk;

  // Testbench stimulus
  initial begin
    // Initialize inputs
    A = 8'b01010101; // You can still use $random here for random initialization
    B = 8'b00110011;
    opcode = 4'b0000;
    clk = 0;
    reset_n = 1;

    // Test Case 1: Arithmetic Operation (Addition)
    #10 opcode = 4'b0001; // Addition
    #10 start = 1;
    #10 start = 0;

    #10 opcode = 4'b0010; // And
    #10 start = 1;
    #10 start = 0;

    #10 opcode = 4'b011; // Sub
    #10 start = 1;
    #10 start = 0;


    // Test Case 2: Shift Operation
    #10 opcode = 4'b0111; // Shift Left
    #10 start = 1;
    #10 start = 0;

    // Test Case 3: Multiplication Operation
    #10 opcode = 4'b0100; // Multiplication
    #10 start = 1;
    #10 start = 0;

    // Test Case 4: Special Function (opcode 1001)
    #40 opcode = 4'b1001; // Special Function
    #10 start = 1;
    #20 start = 0;

    // Test Case 5: Special Function (opcode 1010)
    #10 opcode = 4'b1010; // Special Function
    #10 start = 1;
    #40 start = 0;

    // Test Case 6: Special Function (opcode 1011)
    #70 opcode = 4'b1011; // Special Function
    #10 start = 1;
    #40 start = 0;

    // Test Case 7: Special Function (opcode 1100)
    #10 opcode = 4'b1100; // Special Function
    #10 start = 1;
    #40 start = 0;

    // Additional Test Cases can be added based on your design

    // Stop simulation after 150 time units
    #150 $stop;
  end

  // Monitor output
  always_comb begin
    if (done === 1'b1)
      $display("Time=%0t A=0x%h B=0x%h opcode=%b result=0x%h done=%b", $time, A, B, opcode, result, done);
  end

endmodule
