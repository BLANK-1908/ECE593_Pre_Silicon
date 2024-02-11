interface mcp(input clk);
  logic [17:0] instr;
  logic rst;
  logic start;
  logic [7:0] mem_out;
  logic [7:0] reg_out;
  logic done;
  
  clocking cb@(posedge clk);
    output instr;
    output rst;
    output start;
    input mem_out;
    input reg_out;
    input done;
  endclocking
  
  clocking mcb@(posedge clk);
    input instr;
    input rst;
    input start;
    input mem_out;
    input reg_out;
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
  
  multi_cp_design dut_inst(.clk(clk), .mem_out(mcp_inst.mem_out), .reg_out(mcp_inst.reg_out), 
.done(mcp_inst.done), 
.rst(mcp_inst.rst), 
.start(mcp_inst.start), 
.instr(mcp_inst.instr));

testbench  tb_inst(.vif(mcp_inst));
  
  initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0,top.dut_inst); 
end
endmodule	
