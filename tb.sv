
program testbench(mcp vif);

//Section 4.1 : Include test cases
`include "test.sv"


//Section 4.2 : Define test class handles
base_test test;
packet pkt;
  out_packet opkt;
int t =0;
//Section 6: Verification Flow
initial begin
  pkt=new();
$display("[Program Block] Simulation Started at time=%0t",$time);
//Section 6.1 : Construct test object and pass required interface handles
 test = new(vif.tb_modport,vif.tb_mon,vif.tb_mon);
  
  $display("[Driver] Driving Reset transaction into DUT at time=%0t",$time);
  vif.rst <= 1'b1;
  #10;
  vif.rst <= 1'b0;
  $display("[Driver] Driving Reset transaction completed at time=%0t",$time); 
  
  repeat(30) begin
    t++;
       pkt.randomize();
    $display("[Generator] Sending packet %0d with value for instr1= %h,instr2= %h,instr3= %h, to driver",t,pkt.instr_pkt1,pkt.instr_pkt2,pkt.instr_pkt3);
    $display("[Driver] Received packet %0d from generator at time=%0t",t,$time);
    $display("[Driver] Driving packet %0d",t);
 
    vif.cb.start1<=1;
    vif.cb.start2<=1;
    vif.cb.start3<=1;
   	vif.cb.instr1<=pkt.instr_pkt1;
    vif.cb.instr2<=pkt.instr_pkt2;
    vif.cb.instr3<=pkt.instr_pkt3;
    $display("[Driver] Driving packet %0d",t);
  end
//Section 6.2 : Start the testcase.
//test.run();
$display("[Program Block] Simulation Finished");
end

endprogram
`include "top.sv"


