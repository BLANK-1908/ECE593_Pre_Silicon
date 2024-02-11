`include "package.sv"
typedef enum {IDLE,RESET,STIMULUS} pkt_type_t;

class packet;
  rand bit [17:0] instr_pkt; 
  pkt_type_t kind;
  bit [7:0] reset_cycle;
  
  function void copy(packet to_cp);
    if(to_cp==null) begin
$display("[Error] NULL handle passed to copy method");
$finish;
end
    else begin
      this.instr_pkt = to_cp.instr_pkt;
      this.kind = to_cp.kind;
      this.reset_cycle = to_cp.reset_cycle;
    end
  endfunction
    
  
endclass

class out_packet;
  bit [7:0] mem_out;
  bit [7:0] reg_out;
  bit [3:0] op_temp;
  bit [10:0] addr;
  bit [3:0] reg_a;
  bit [3:0] reg_b;
  logic [7:0] mem_arr [0:2047];
  bit [7:0] local_data;
  bit [7:0] data_out;
  
  function void cal_out(bit [0:17] instr_exp);
    op_temp = instr_exp[0:3];
    reg_a = instr_exp[4:7];
    reg_b = instr_exp[8:11];
    addr = instr_exp[4:14];
    local_data = instr_exp[0:7];
    
    if (op_temp == load_op || op_temp == store_op) begin
      case(op_temp)
        load_op: mem_arr[addr] = local_data;
        store_op: data_out = mem_arr[addr];
      endcase
    end
    else begin
    case(op_temp)
      add_op: reg_out = reg_a + reg_b;
      and_op: reg_out = reg_a & reg_b;
      exor_op: reg_out = reg_a ^ reg_b;
      mul_op: reg_out = reg_a * reg_b;
    endcase
      end
  endfunction
        
        function void con_pkt(bit [0:7] mem_out_arg, bit [7:0] reg_out_arg);
          this.mem_out=mem_out_arg;
          this.reg_out=reg_out_arg;
        endfunction
        
        function bit cmp(out_packet out_pkt_arg);
          if (out_pkt_arg.mem_out != this.mem_out && out_pkt_arg.reg_out != this.reg_out) 
            return 0;
          
          else
            return 1;
        endfunction
endclass
