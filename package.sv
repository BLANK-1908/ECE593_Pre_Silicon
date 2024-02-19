
typedef enum logic[3:0] {   				no_op  = 4'b0000,
							add_op = 4'b0001, 
							and_op = 4'b0010,
							sub_op = 4'b0011,
							mul_op = 4'b0100,
							load_op = 4'b0101,
							store_op = 4'b0110,
							slr_op = 4'b0111,
							sll_op = 4'b1000,
							sp_func1_op = 4'b1001,
							sp_func2_op = 4'b1010,
							sp_func3_op = 4'b1011,
							sp_func4_op = 4'b1100 } operation_t;
