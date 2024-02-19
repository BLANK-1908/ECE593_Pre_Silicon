`include "package.sv"
typedef enum {RESET,STIMULUS} pkt_type_t;

class packet;
  rand bit [17:0] instr_pkt1;
  rand bit [17:0] instr_pkt2;
  rand bit [17:0] instr_pkt3;
  pkt_type_t kind;
  bit [7:0] reset_cycle;
  
  
  function void copy(packet to_cp);
    if(to_cp==null) begin
$display("[Error] NULL handle passed to copy method");
end
    else begin
      this.instr_pkt1 = to_cp.instr_pkt1;
      this.instr_pkt2 = to_cp.instr_pkt2;
      this.instr_pkt3 = to_cp.instr_pkt3;
      this.kind = to_cp.kind;
      this.reset_cycle = to_cp.reset_cycle;
    end
  endfunction
    
  function void con_pkt( bit [17:0] instr_pkt1_a,  bit [17:0] instr_pkt2_a2,  bit [17:0] instr_pkt3_a3);
    this.instr_pkt1=instr_pkt1_a;
    this.instr_pkt2=instr_pkt2_a2;
    this.instr_pkt3=instr_pkt3_a3;
  endfunction
endclass

class check_packet;
  bit [7:0] reg_out;
  bit [3:0] op_temp;
  bit [10:0] addr;
  bit [3:0] reg_a;
  bit [3:0] reg_b;
  bit [3:0] reg_c;
  

  
  function void cal_out(bit [17:0] instr_exp);
   op_temp = instr_exp[17:14];
    reg_a = instr_exp[13:11];// a is always destination
    reg_b = instr_exp[7:5];
    reg_c = instr_exp[2:0];
    addr = instr_exp [10:0];
    
    case(op_temp)
      add_op: reg_c = reg_a + reg_b;
      and_op: reg_c = reg_a & reg_b;
      sub_op: reg_c = reg_a - reg_b;
      mul_op: reg_c = reg_a * reg_b;
      slr_op: reg_c = reg_a << reg_b;
      sll_op: reg_c = reg_a >> reg_b;
      sp_func1_op: reg_c = (reg_a*reg_b)-reg_a;
      sp_func2_op: reg_c = (reg_a*reg_b*4)-reg_a;   
      sp_func3_op: reg_c = (reg_a*reg_b)+reg_a;
      sp_func2_op: reg_c = (reg_a*3);   
    endcase
   
  endfunction
        
  function void con_pkt(bit [7:0] reg_out_arg);          
          this.reg_out=reg_out_arg;
        endfunction
        
  function bit cmp(check_packet out_pkt_arg);
          if (out_pkt_arg.reg_out != this.reg_out) 
            return 0;
          else
            return 1;
        endfunction
endclass



class out_packet;
  check_packet c1,c2,c3; 
  bit [7:0] mem_out_ch;
  logic [7:0] mem_arr [0:2047];  
  bit [7:0] local_data;
  bit [7:0] data_out;
  bit [10:0] addr1; 
  bit [10:0] addr2; 
  bit [10:0] addr3; 
  bit [3:0] op_temp1; 
  bit [3:0] op_temp2; 
  bit [3:0] op_temp3; 
  
  function new(packet g_p);
    c1 =new();
    c2 =new();
    c3 =new();
    addr1 = g_p.instr_pkt1 [10:0];
    addr2 = g_p.instr_pkt2 [10:0];
	addr3 = g_p.instr_pkt3 [10:0];
    op_temp1 = g_p.instr_pkt1[17:14];
    op_temp2 = g_p.instr_pkt2[17:14];
    op_temp3 = g_p.instr_pkt3[17:14];
  endfunction
  
  function void cal_run(packet cal_pkt);
    if(op_temp1 == load_op || op_temp1 == store_op) begin
      case(op_temp1)
          load_op: mem_arr[addr1] = local_data;
          store_op: data_out = mem_arr[addr1];
      endcase
    end
    else begin
    this.c1.cal_out(cal_pkt.instr_pkt1);
    end
    
    if(op_temp2 == load_op || op_temp2 == store_op) begin
      case(op_temp2)
          load_op: mem_arr[addr2] = local_data;
          store_op: data_out = mem_arr[addr2];
      endcase
    end
    else begin
      this.c2.cal_out(cal_pkt.instr_pkt2);
    end
    
    if(op_temp3 == load_op || op_temp3 == store_op) begin
      case(op_temp3)
          load_op: mem_arr[addr3] = local_data;
          store_op: data_out = mem_arr[addr3];
      endcase
    end
    else begin
      this.c3.cal_out(cal_pkt.instr_pkt3);
    end
  endfunction
  
  function bit cmp_run(out_packet to_cp);
    if ((this.c1.cmp(to_cp.c1)==1) && (this.c2.cmp(to_cp.c2)==1) && (this.c3.cmp(to_cp.c3)==1) && (to_cp.mem_out_ch == this.mem_out_ch)) 
      return 1;
    else
      return 1;
  endfunction
  
  function void con_pkt_run(bit [7:0] mem_out_arg, bit [7:0] reg_out1_arg, bit [7:0] reg_out2_arg, bit [7:0] reg_out3_arg);
    this.mem_out_ch=mem_out_arg;
    this.c1.con_pkt(reg_out1_arg);
    this.c2.con_pkt(reg_out2_arg);
    this.c3.con_pkt(reg_out3_arg);
  endfunction
    endclass
    

