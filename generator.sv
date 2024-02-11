class generator;
  bit [31:0] pkt_cnt;
  mailbox#(packet) mbx;
  packet ref_pkt;
  
  function new(input mailbox#(packet) mbx_arg,input bit [31:0] count_arg);
    mbx = mbx_arg;
    pkt_cnt = count_arg;
    ref_pkt = new;
  endfunction


task run ();
  bit [31:0] pkt_id;
  packet gen_pkt;
  
  gen_pkt = new;
  
  gen_pkt.kind = RESET;
  gen_pkt.reset_cycle=5;
  $display("[Generator] Sending %0s packet %0d to driver at time=%0t",gen_pkt.kind.name(),pkt_id,$time);
  
  mbx.put(gen_pkt);
  
  repeat(pkt_cnt) begin
    pkt_id++;
    assert(ref_pkt.randomize());
    gen_pkt=new;
    
    gen_pkt.kind=STIMULUS;
    gen_pkt.copy(ref_pkt);
    
    mbx.put(gen_pkt);
    $display("[Generator] Packet %0d Generated at time=%0t",pkt_id,$time); 
end

endtask
  
endclass
  
