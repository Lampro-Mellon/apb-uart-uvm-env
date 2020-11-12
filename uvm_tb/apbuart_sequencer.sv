class apbuart_sequencer extends uvm_sequencer#(apbuart_transaction);

	`uvm_component_utils(apbuart_sequencer) 
  	//---------------------------------------
  	//constructor
  	//---------------------------------------
  	function new(string name, uvm_component parent);
    	super.new(name,parent);
  	endfunction

endclass