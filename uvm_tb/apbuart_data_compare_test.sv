class apbuart_data_compare_test extends apbuart_base_test;
    `uvm_component_utils (apbuart_data_compare_test)

    apbuart_singlebeat_seq 	apbuart_sq;

    function new (string name, uvm_component parent= null);
      	super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
	  extern virtual task run_phase(uvm_phase phase);

endclass

function void apbuart_data_compare_test::build_phase (uvm_phase phase);
    super.build_phase(phase);
    apbuart_sq = apbuart_singlebeat_seq::type_id::create("apbuart_sq",this);
endfunction

task apbuart_data_compare_test::run_phase(uvm_phase phase);
  repeat(cfg.loop_time)
  begin
    set_config_params(9600,8,3,1,1); // Baud Rate , Frame Len , Parity , Stop Bit , Randomize Flag (1 for random , 0 for directed)
    cfg.print();
    set_apbconfig_params(2,1);		 // Slave Bus Address , Randomize Flag (1 for random , 0 for directed)
		apb_cfg.print();
    phase.raise_objection (.obj(this));
  	apbuart_sq.start(env_sq.v_sqr);
    phase.drop_objection(.obj(this));
  end
  	phase.phase_done.set_drain_time(this, 75000*7);
endtask
