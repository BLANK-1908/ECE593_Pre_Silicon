//`include "packet.sv"
import filepackage::*;
class driver;
  packet pkt;
  virtual mcp.tb_modport vif;
  mailbox#(packet) mbx;
  
  bit [31:0] no_of_pkts_rcvd;
  
  function new(input mailbox#(packet) mbx_arg, input virtual mcp.tb_modport vif_arg);
    this.mbx=mbx_arg;
    this.vif = vif_arg;
  endfunction
  
  task driver(packet pkt);
    case (pkt.kind)
      RESET : drive_reset(pkt);
      STIMULUS : drive_stimulus(pkt);
      default : $display("[Driver] Unknown packet received");
    endcase
  endtask
  
  task drive_reset(packet pkt);
    $display("[Driver] Driving Reset transaction into DUT at time=%0t",$time);
    vif.cb.rst <= 1'b0;
    repeat(pkt.reset_cycle) @(vif.cb);
    vif.cb.rst <= 1'b1;
    $display("[Driver] Driving Reset transaction completed at time=%0t",$time); 
  endtask
  
  task drive_stimulus(packet pkt);
    wait(vif.cb.done == 1'b1);
    $display("|| checking for done time =%0t ||",$time);
     vif.cb.start1<=0;
    vif.cb.start2<=0;
    vif.cb.start3<=0;
   	vif.cb.instr1<=18'b0;
    vif.cb.instr2<=18'b0;
	vif.cb.instr3<=18'b0;
	@(vif.cb);
    @(vif.cb);
    $display("[Driver] Driving of packet %0d || instr_pkt1 = %0b || instr_pkt2=%0b || instr_pkt3=%0b || started at time=%0t ||",no_of_pkts_rcvd,pkt.instr_pkt1, pkt.instr_pkt2, pkt.instr_pkt3, $time);
    vif.cb.start1<=1;
    vif.cb.start2<=1;
    vif.cb.start3<=1;
   	vif.cb.instr1<=pkt.instr_pkt1;
    vif.cb.instr2<=pkt.instr_pkt2;
	vif.cb.instr3<=pkt.instr_pkt3;
    $display("[Driver] Driving of packet %0d ended at time=%0t \n",no_of_pkts_rcvd,$time);
  endtask
  
    task run();
    $display("[Driver] run started at time=%0t",$time); 
    while(1) begin
      mbx.get(pkt);
      no_of_pkts_rcvd++;
      $display("[Driver] Received  %0s packet %0d from generator at time=%0t",pkt.kind.name(),no_of_pkts_rcvd,$time); 
      driver(pkt);
      $display("[Driver] Done with %0s packet %0d from generator at time=%0t",pkt.kind.name(),no_of_pkts_rcvd,$time); 
    end
  endtask
  
  
endclass        
