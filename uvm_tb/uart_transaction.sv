`include "uvm_macros.svh"
import uvm_pkg::*;

class uart_transaction extends uvm_sequence_item;
    // Input Signals of DUT for APB UART's transaction
    rand 	logic 	[31 : 0]   	payload; 												// 32-bit data that need to be sent on DUT RX pin serially in UART_DRIVER
    rand 	logic 	[31 : 0]    transmitter_reg; 									// 32-data monitored from DUT TX pin...sent to scoreboard from UART_MONITOR
	rand 	logic 				bad_parity;
	rand 	logic 				sb_corr;
	rand 	bit 				start_bit;
	rand 	bit 	[1:0] 		stop_bits;
  
	logic 	[35:0] 				payld_func;
	
    // Constructor Define Method
    function  new (string name = "uart_transaction");
        super.new(name);
    endfunction
    
    // Registering our transaction with the UVM Object Utils
    // these signals are going to exchange with between DUT and testbench 
    `uvm_object_utils_begin (uart_transaction)
        `uvm_field_int (start_bit,UVM_ALL_ON)
		`uvm_field_int (stop_bits,UVM_ALL_ON)
		`uvm_field_int (payload,UVM_ALL_ON)
        `uvm_field_int (bad_parity,UVM_ALL_ON)
		`uvm_field_int (sb_corr,UVM_ALL_ON)
        `uvm_field_int (transmitter_reg,UVM_ALL_ON)
    `uvm_object_utils_end
	
	constraint default_start_bit { start_bit == 1'b0;}
	constraint default_stop_bits { stop_bits == 2'b11;}
  
	function bit [6:0] calc_parity 	(
										logic [31:0] payload,			
											 logic [3:0] frame_len, 
											 logic bad_parity,
											 logic ev_odd
										);
		payld_func={{4{1'b0}},payload[31:0]}; 
		case(frame_len)
			5:	
			begin
				for(int i=0;i<7;i++)
					calc_parity[i] = ev_odd?(^( payld_func[i*(5) +: 5] )) : (~^( payld_func[i*(5) +: 5] ));
			end
			
			6:	
			begin
				for(int i=0;i<6;i++)
					calc_parity[i] = ev_odd?(^( payld_func[i*(6) +: 6] )) : (~^( payld_func[i*(6) +: 6] ));		
			end	
			
			7:	
			begin
				for(int i=0;i<5;i++)
					calc_parity[i] = ev_odd?(^( payld_func[i*(7) +: 7] )) : (~^( payld_func[i*(7) +: 7] ));		
			end
			
			8:
			begin
			  for(int i=0;i<4;i++) 
					calc_parity[i] = ev_odd?(^( payld_func[i*(8) +: 8] )) : (~^( payld_func[i*(8) +: 8] ));		
			end
			
			9:   // frame_length could be used of 9-bit long iff for no parity bit.
			begin
			  for(int i=0;i<4;i++) 
					calc_parity[i] = ev_odd?(^( payld_func[i*(9) +: 9] )) : (~^( payld_func[i*(9) +: 9] ));		
			end
			
			default: 	`uvm_error(get_type_name(),$sformatf("------ :: Incorrect frame length selected :: ------"))
		endcase
		calc_parity= bad_parity?(~calc_parity) : calc_parity;
	endfunction

endclass



