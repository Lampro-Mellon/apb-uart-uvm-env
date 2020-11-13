class apbuart_data_compare_test extends apbuart_base_test;
    `uvm_component_utils (apbuart_data_compare_test)

    //uart_env env_sq;
   	apbuart_config_seq 	    apbuart_sq1; // all configuration for write and read configuration
    apbuart_singlebeat_seq 	apbuart_sq2;

    function new (string name, uvm_component parent= null);
      	super.new(name, parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
      	super.build_phase(phase);
      	apbuart_sq1 = apbuart_config_seq::type_id::create("apbuart_sq1",this);
      	apbuart_sq2 = apbuart_singlebeat_seq::type_id::create("apbuart_sq2",this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection (.obj(this));
        apbuart_sq1.start(env_sq.v_sqr);
      	apbuart_sq2.start(env_sq.v_sqr);
        phase.drop_objection(.obj(this));
      	phase.phase_done.set_drain_time(this, 75000 * 34);
    endtask
endclass
