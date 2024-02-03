module alu 
(
 input [7:0] A,
 input [7:0] B,
 input [3:0] opcode,
 input clk,
 input reset_n,
 input start,
 output done,
 output [15:0] result
);

 // Start condtions
 logic start_arith;
 logic start_mult;
 logic start_special_func;
 logic start_shift;
 logic start_dbg;

 // Output flags and results
 logic [15:0] result_arith, result_shift, result_mult, result_spec, result_dbg;
 logic done_arith, done_shift, done_mult, done_spec, done_dbg;

   
   // Module Instantiations 
 single_cycle_arith arith_operations (.A(A), .B(B), .opcode(opcode), .clk(clk), .reset_n(reset_n), .start(start_arith), .done(done_arith), .result(result_arith));
  
 single_cycle_shift shift_operations (.A(A), .opcode(opcode), .clk(clk), .reset_n(reset_n), .start(start_shift), .done(done_shift), .result(result_shift));

 three_cycle_mult mult_operation (.A(A), .B(B), .opcode(opcode), .clk(clk), .reset_n(reset_n), .start(start_mult), .done(done_mult), .result(result_mult));

 special_func func (.A(A), .B(B), .opcode(opcode), .clk(clk), .reset_n(reset_n), .start(start_special_func), .done(done_spec), .result(result_spec));

/* debug_func show (.A(A), .B(B), .opcode(opcode), .clk(clk), .reset_n(reset_n), .start(start_dbg), .done(done_dbg), .result(result_dbg));*/

 assign start_arith = start & (~opcode[3] & ~opcode[2]); // Opcodes: 0000 to 0011
 assign start_mult = start & (opcode == 4'b0100); // Multiplication Opcode 0100
 assign start_special_func = start & ((opcode >= 4'b1001) && (opcode <= 4'b1100)); // Special Function Opcodes: 4'b1001 to 4'b1100  
 assign start_shift = start & ((opcode == 4'b0111) ? 1'b1 : (opcode == 4'b1000) ? 1'b1 : 1'b0); // Shift Operation Opcodes: 4'b0111 and 4'b1000
 assign start_dbg = start & ((opcode == 4'b0111) ? 1'b1 : 1'b0); // Debug function: 4'b1110

 assign done = done_arith | done_shift | done_mult | done_spec | done_dbg;
 
 assign result = (~opcode[3] & ~opcode[2]) ? result_arith : 
     ((opcode == 4'b0111) || (opcode == 4'b1000)) ? result_shift : 
     (opcode == 4'b0100) ? result_mult : 
     (opcode == 4'b0111) ? result_spec : result_dbg;

endmodule : alu

module single_cycle_arith
(
 input logic [7:0] A,
 input logic [7:0] B,
 input logic [3:0] opcode,
 input logic clk,
 input logic reset_n,
 input logic start,
 output logic done,
 output logic [15:0] result
);

  always @(posedge clk)
    if (!reset_n)
      result <= 0;
    else
      if(start)
       case(opcode)
   4'b0001 : result <= A + B;
   4'b0010 : result <= A & B;
   4'b0011 : result <= A - B;
       endcase
     else
        result <= 0;

   always @(posedge clk)
     if (!reset_n)
       done <= 0;
     else
       done = ((start) && (opcode >= 4'b0001) && (opcode <= 4'b0011));

endmodule : single_cycle_arith
      

module single_cycle_shift
(
 input logic [7:0] A,
 input logic [3:0] opcode,
 input logic clk,
 input logic reset_n,
 input logic start,
 output logic done,
 output logic [15:0] result
);

  always @(posedge clk)
    if (!reset_n)
      begin
       result <= 0;
      end
    else begin
      if(start) begin
       case(opcode)
   4'b0111 : result <= A<<1;
   4'b1000 : result <= A>>1;
       endcase // case (opcode)
      end
     else
        result <= 0;
    end

   always @(posedge clk)
     if (!reset_n)
       done <= 0;
     else
  done = ((start) && ((opcode >= 4'b0111 ) || (opcode <= 4'b1000)));
  
endmodule : single_cycle_shift


module three_cycle_mult
(
 input logic [7:0] A,
 input logic [7:0] B,
 input logic [3:0] opcode,
 input logic clk,
 input logic reset_n,
 input logic start,
 output logic done,
 output logic [15:0] result
);

 logic [7:0] a_int, b_int;
 logic [15:0] mult_ff_1, mult_ff_2;
 logic done_ff_1, done_ff_2, done_ff_3;

 always @(posedge clk)
  if (!reset_n) begin
   done <= 0;
   done_ff_3 <= 0;
   done_ff_2 <= 0;
   done_ff_1 <= 0;
   a_int <= 0;
   b_int <= 0;
   mult_ff_1 <= 0;
   mult_ff_2 <= 0;
   result<= 0;
  end 
  else begin 
   if(start)
     begin
    a_int <= A;
    b_int <= B;
    mult_ff_1 <= a_int * b_int;
    mult_ff_2 <= mult_ff_1;
    result <= mult_ff_2;
    done_ff_3 <= start & !done;
    done_ff_2 <= done_ff_3 & !done;
    done_ff_1 <= done_ff_2 & !done;
    done <= done_ff_1 & !done;
   end 
   else 
    begin
    result <= 0;
    done <= 0;
   end
 end
endmodule : three_cycle_mult


module special_func
(
 input logic [7:0] A,
 input logic [7:0] B,
 input logic [3:0] opcode,
 input logic clk,
 input logic reset_n,
 input logic start,
 output logic done,
 output logic [15:0] result
);
  
 logic [7:0] a_int, b_int;
 logic [15:0] mult_ff_1, mult_ff_2;
 logic done_ff_1, done_ff_2, done_ff_3;
  
 always @(posedge clk)
  if (!reset_n) begin
   done <= 0;
   done_ff_3 <= 0;
   done_ff_2 <= 0;
   done_ff_1 <= 0;
   a_int <= 0;
   b_int <= 0;
   mult_ff_1 <= 0;
   mult_ff_2 <= 0;
   result<= 0;
  end   
  else begin 
   if(start) begin
    if (opcode == 4'b1001) begin
     a_int <= A;
     b_int <= B * A;

     mult_ff_1 <= b_int - a_int; // (A*B)-A
     mult_ff_2 <= mult_ff_1;
     result <= mult_ff_2; 

     done_ff_3 <= start & !done;
     done_ff_2 <= done_ff_3 & !done;
     done_ff_1 <= done_ff_2 & !done;
     done <= done_ff_1 & !done;
    end 
    else if (opcode == 4'b1010) begin
     a_int <= A*B;
     b_int <= A;
     mult_ff_1 <= a_int * 4; // (A * B * 4) - A
     mult_ff_2 <= mult_ff_1 - b_int;
     result <= mult_ff_2;

     done_ff_3 <= start & !done;
     done_ff_2 <= done_ff_3 & !done;
     done_ff_1 <= done_ff_2 & !done;
     done <= done_ff_1 & !done;
    end
    else if (opcode == 4'b1011) begin
     a_int <= A*B;
     b_int <= A;
     mult_ff_1 <= a_int + b_int; // (A * B) + A
     mult_ff_2 <= mult_ff_1 ;
     result <= mult_ff_2;

     done_ff_3 <= start & !done;
     done_ff_2 <= done_ff_3 & !done;
     done_ff_1 <= done_ff_2 & !done;
     done <= done_ff_1 & !done;
    end 
    else if (opcode == 4'b1100) begin
     a_int <= A;
     b_int <= B;

     mult_ff_1 <= a_int * 3; // A*3
     mult_ff_2 <= mult_ff_1;
     result <= mult_ff_2;

     done_ff_3 <= start & !done;
     done_ff_2 <= done_ff_3 & !done;
     done_ff_1 <= done_ff_2 & !done;
     done <= done_ff_1 & !done;
    end    
   end
   else begin
    a_int <= 0;
    b_int <= 0;
    result <= 0;
    done <= 0;
    done_ff_3 <= 0;
    done_ff_2 <= 0;
    done_ff_1 <= 0;
    mult_ff_1 <= 0;
    mult_ff_2 <= 0;
   end
  end  

endmodule : special_func
