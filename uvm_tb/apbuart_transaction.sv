
`include "uvm_macros.svh"
import uvm_pkg::*;

class apbuart_transaction extends uvm_sequence_item;
    // Input Signals of DUT for APB UART's transaction
	rand logic            	PWRITE;
    rand logic			  	RX;
	rand logic [31 : 0]   	PWDATA;
	rand logic [31 : 0]	  	PADDR;
    rand logic [47 : 0]   	rec_temp;
	rand logic [1  : 0]	  	fpn_flag;
	
    // Output Signals of DUT for APB UART's transaction
	logic				PREADY;
	logic 				PSLVERR;
	logic				Tx;
    logic [31: 0]		PRDATA;
    
    // Constructor Define Method
    function  new (string name = "apbuart_transaction");
        super.new(name);
    endfunction
    
    // Registering our transaction with the UVM Object Utils
    // these signals are going to exchange with between DUT and testbench 

    `uvm_object_utils_begin (apbuart_transaction)
        `uvm_field_int (PWRITE,UVM_ALL_ON)
        `uvm_field_int (RX,UVM_ALL_ON)
        `uvm_field_int (PWDATA,UVM_ALL_ON)
        `uvm_field_int (PADDR,UVM_ALL_ON)
        `uvm_field_int (PREADY,UVM_ALL_ON)
        `uvm_field_int (PSLVERR,UVM_ALL_ON)
        `uvm_field_int (Tx,UVM_ALL_ON)
        `uvm_field_int (PRDATA,UVM_ALL_ON)
        `uvm_field_int (rec_temp,UVM_ALL_ON)
        `uvm_field_int (fpn_flag,UVM_ALL_ON)
    `uvm_object_utils_end
	
  constraint ADDRESS {PADDR <= 32'h5;}

endclass
