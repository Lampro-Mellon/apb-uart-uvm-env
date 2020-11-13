`include "uvm_macros.svh"
import uvm_pkg::*;

class uart_transaction extends uvm_sequence_item;
    // Input Signals of DUT for APB UART's transaction
    rand logic			  	RX;
    rand logic [47 : 0]   	rec_temp;
	rand logic [1  : 0]	  	fpn_flag;
    rand logic [47 : 0]     transmitter_reg;
	
    // Output Signals of DUT for APB UART's transaction
	logic				Tx;
    
    // Constructor Define Method
    function  new (string name = "uart_transaction");
        super.new(name);
    endfunction
    
    // Registering our transaction with the UVM Object Utils
    // these signals are going to exchange with between DUT and testbench 

    `uvm_object_utils_begin (uart_transaction)
        `uvm_field_int (RX,UVM_ALL_ON)
        `uvm_field_int (Tx,UVM_ALL_ON)
        `uvm_field_int (rec_temp,UVM_ALL_ON)
        `uvm_field_int (fpn_flag,UVM_ALL_ON)
        `uvm_field_int (transmitter_reg,UVM_ALL_ON)
    `uvm_object_utils_end
	
  // no constraint required

endclass
