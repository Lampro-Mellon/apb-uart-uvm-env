class apbuart_config_test extends apbuart_base_test;
	`uvm_component_utils (apbuart_config_test)

	//uart_env env_sq;
	config_apbuart 	apbuart_sq; // all configuration for write and read configuration

	function new (string name, uvm_component parent= null);
	  	super.new(name, parent);
	endfunction

	virtual function void build_phase (uvm_phase phase);
	  	super.build_phase(phase);
	  	apbuart_sq  = config_apbuart::type_id::create("apbuart_sq",this);
	endfunction

	task run_phase(uvm_phase phase);
	    phase.raise_objection(.obj(this));
	    apbuart_sq.start(env_sq.apbuart_agnt.sequencer);
	    phase.drop_objection(.obj(this));
	  	phase.phase_done.set_drain_time(this, 20);
	endtask
  
endclass
