class uart_agent extends uvm_agent;
  
	`uvm_component_utils(uart_agent)
  	// ------------------------------------------------------------
  	//  component instances to make driver , sequencer and monitor 
  	// ------------------------------------------------------------
  	uart_driver    driver;
  	uart_sequencer sequencer;
	uart_monitor   monitor;
	uart_config    cfg;  
  	// ---------------------------------------
  	//  Calling the constructor
  	// ---------------------------------------
  	function new (string name, uvm_component parent);
  		super.new(name, parent);
  	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass

// ---------------------------------------------------------------------
//  build_phase to create the instance of monitor , driver and sequencer
// ---------------------------------------------------------------------
function void uart_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(uart_config)::get(this, "", "cfg", cfg))
		`uvm_fatal("NO_CFG",{"Configuration must be set for: ",get_full_name(),".cfg"});
  	monitor = uart_monitor::type_id::create("monitor", this);
  	//creating driver and sequencer only for ACTIVE agent
  	if(cfg.is_active == UVM_ACTIVE) 
  		begin
  	  		driver    = uart_driver::type_id::create("driver", this);
  	  		sequencer = uart_sequencer::type_id::create("sequencer", this);
  	  	end
endfunction : build_phase
	
// ------------------------------------------------------------------  
//  connect_phase - connecting the driver and sequencer port
// ------------------------------------------------------------------
function void uart_agent::connect_phase(uvm_phase phase);
	if(cfg.is_active == UVM_ACTIVE) 
    	driver.seq_item_port.connect(sequencer.seq_item_export);
endfunction : connect_phase