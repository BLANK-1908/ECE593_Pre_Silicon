interface mcp(input clk);
  logic [27:0] instr1;
  logic [27:0] instr2;
  logic [27:0] instr3;
  logic [7:0] mem_out;
  logic [7:0] reg_out;
  logic rst;
  logic start1; 
  logic start2; 
  logic start3;
  logic done;
  
  
  clocking cb@(posedge clk);
  output instr1;
  output instr2;
  output instr3;
  input mem_out;
  input reg_out;
  output rst;
  output start1; 
  output start2; 
  output start3;
  input done;
  endclocking
  
  clocking mcb@(posedge clk);
  input instr1;
  input instr2;
  input instr3;
  input mem_out;
  input reg_out;
  input rst;
  input start1; 
  input start2; 
  input start3;
  input done;
  endclocking
  
  modport tb_modport (clocking cb);
  modport tb_mon (clocking mcb);
    endinterface
  

module top;
  
  logic clk;
  
  initial clk = 0;
  always #5 clk =! clk;
  
  mcp mcp_inst(clk);
  
  core dut_inst(.clk(clk),
.done(mcp_inst.done), 
.rst_n(mcp_inst.rst), 
                           .start1(mcp_inst.start1),
                           .start2(mcp_inst.start2),
                           .start3(mcp_inst.start3),
                           .inst1(mcp_inst.instr1),
                           .inst2(mcp_inst.instr2),
                           .inst3(mcp_inst.instr3));

testbench  tb_inst(.vif(mcp_inst));
  
  initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0,top.dut_inst); 
end
endmodule	
