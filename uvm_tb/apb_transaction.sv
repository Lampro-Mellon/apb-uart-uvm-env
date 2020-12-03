
`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_transaction extends uvm_sequence_item;
    // Input Signals of DUT for APB UART's transaction
	rand logic            	PWRITE;
	rand logic [31 : 0]   	PWDATA;
	rand logic [31 : 0]	  	PADDR;
	
    // Output Signals of DUT for APB UART's transaction
	logic				    PREADY;
	logic 				    PSLVERR;
    logic [31: 0]		    PRDATA;
    
    // Constructor Define Method
    function  new (string name = "apb_transaction");
        super.new(name);
    endfunction
    
    // Registering our transaction with the UVM Object Utils
    // these signals are going to exchange with between DUT and testbench 

    `uvm_object_utils_begin (apb_transaction)
        `uvm_field_int (PWRITE,UVM_ALL_ON)
        `uvm_field_int (PWDATA,UVM_ALL_ON)
        `uvm_field_int (PADDR,UVM_ALL_ON)
        `uvm_field_int (PREADY,UVM_ALL_ON)
        `uvm_field_int (PSLVERR,UVM_ALL_ON)
        `uvm_field_int (PRDATA,UVM_ALL_ON)
    `uvm_object_utils_end
	
endclass 