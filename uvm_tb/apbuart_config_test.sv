class apbuart_config_test extends apbuart_base_test;
	`uvm_component_utils (apbuart_config_test)

	//uart_env env_sq;
	apbuart_config_seq  apbuart_sq; // all configuration for write and read configuration

	function new (string name, uvm_component parent= null);
	  	super.new(name, parent);
	endfunction

	virtual function void build_phase (uvm_phase phase);
	  	super.build_phase(phase);
	  	apbuart_sq  = apbuart_config_seq::type_id::create("apbuart_sq",this);
	endfunction

	task run_phase(uvm_phase phase);
	    phase.raise_objection(.obj(this));
		`uvm_info("test1 run", "Starting Configuration test", UVM_MEDIUM)
		apbuart_sq.start(env_sq.v_sqr);
		`uvm_info("test1 run", "Ending Configuration test",   UVM_MEDIUM)
	    phase.drop_objection(.obj(this));
	    phase.phase_done.set_drain_time(this, 20);
	endtask
  
endclass
