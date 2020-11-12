class uart_sequencer extends uvm_sequencer#(uart_transaction);

	`uvm_component_utils(uart_sequencer) 
  	//---------------------------------------
  	//constructor
  	//---------------------------------------
  	function new(string name, uvm_component parent);
    	super.new(name,parent);
  	endfunction

endclass