class imon;
  packet pkt;
  out_packet opkt;
  virtual mcp.tb_mon vif;
  mailbox#(out_packet) mbx;
  
  bit [31:0] no_of_pkts_rcvd;
  
  function new(input mailbox#(packet) mbx_arg, input virtual mcp.tb_mon vif_arg);
    this.mbx=mbx_arg;
    this.vif = vif_arg;
  endfunction
  
  task run();
    $display("[iMon] run started at time=%0t ",$time); 
    forever begin
      @(posedge vif.mcb.start1);
      no_of_pkts_rcvd++;
      $display("[iMon] Started collecting packet %0d at time=%0t ",no_of_pkts_rcvd,$time); 
      opkt.cal_out(vif.mcb.instr1);
      mbx.put(opkt);
      end
    $display("[iMon] run ended at time=%0t ",$time);
  endtask
  
endclass
