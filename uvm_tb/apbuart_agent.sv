class apbuart_agent extends uvm_agent;
  
	`uvm_component_utils(apbuart_agent)

  	// ------------------------------------------------------------
  	//  component instances to make driver , sequencer and monitor 
  	// ------------------------------------------------------------
  	apbuart_driver    driver;
  	apbuart_sequencer sequencer;
  	apbuart_monitor   monitor;
  	// ---------------------------------------
  	//  Calling the constructor
  	// ---------------------------------------
  	function new (string name, uvm_component parent);
  		super.new(name, parent);
  	endfunction : new

  	// ---------------------------------------------------------------------
  	//  build_phase to create the instance of monitor , driver and sequencer
  	// ---------------------------------------------------------------------
  	function void build_phase(uvm_phase phase);
  	  	super.build_phase(phase);
  	  	monitor = apbuart_monitor::type_id::create("monitor", this);
  	  	//creating driver and sequencer only for ACTIVE agent
  	  	if(get_is_active() == UVM_ACTIVE) 
  	  		begin
  	  	  		driver    = apbuart_driver::type_id::create("driver", this);
  	  	  		sequencer = apbuart_sequencer::type_id::create("sequencer", this);
  	  	  	end
  	endfunction : build_phase
	
  	// ------------------------------------------------------------------  
  	//  connect_phase - connecting the driver and sequencer port
  	// ------------------------------------------------------------------
  	function void connect_phase(uvm_phase phase);
  		if(get_is_active() == UVM_ACTIVE) 
  	    	driver.seq_item_port.connect(sequencer.seq_item_export);
  	endfunction : connect_phase
endclass