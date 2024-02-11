class driver;
  packet pkt;
  virtual mcp_inst.tb_mod_port vif;
  mailbox#(packet) mbx;
  
  bit [31:0] no_of_pkts_rcvd;
  
  function new(input mailbox#(packet) mbx_arg, input virtual mcp_inst.tb_mod_port vif_arg);
    this.mbx=mbx_arg;
    this.vif = vif_arg;
  endfunction
  
  task run();
    $display("[Driver] run started at time=%0t",$time); 
    while(1) begin
      mbx.get(pkt);
      $display("[Driver] Received  %0s packet %0d from generator at time=%0t",pkt.kind.name(),no_of_pkts_recvd,$time); 
      drive(pkt);
      $display("[Driver] Done with %0s packet %0d from generator at time=%0t",pkt.kind.name(),no_of_pkts_recvd,$time); 
    end
  endtask
  
  task driver(packet pkt);
    case(pkt.kind)
      RESET : drive_reset(pkt);
      STIMULUS : drive_stimulus(pkt);
      default : $display("[Driver] Unknown packet received");
    endcase
  endtask
  
  task drive_reset(packet pkt);
    $display("[Driver] Driving Reset transaction into DUT at time=%0t",$time);
    vif.reset <= 1'b1;
    repeat(pkt.reset_cycle) @(vif.cb);
    vif.reset <= 1'b0;
    $display("[Driver] Driving Reset transaction completed at time=%0t",$time); 
  endtask
  
  task drive_stimulus(packet pkt);
    wait(vif.cb.done == 1'b1);
    @(vif.cb);
    $display("[Driver] Driving of packet %0d started at time=%0t",no_of_pkts_recvd,$time);
    vif.cb.start<=1;
   	vif.cb.instr_pkt<=pkt;
    $display("[Driver] Driving of packet %0d ended at time=%0t \n",no_of_pkts_recvd,$time);
    vif.cb.start<=0;
   	vif.cb.instr_pkt<='z;
  endtask
  
endclass    
