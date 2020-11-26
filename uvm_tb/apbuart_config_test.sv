class apbuart_config_test extends apbuart_base_test;
	`uvm_component_utils (apbuart_config_test)

	apbuart_config_seq  apbuart_sq; // all configuration for write and read configuration
	clk_rst_default_seq clk_seq;
	function new (string name, uvm_component parent= null);
	  	super.new(name, parent);
	endfunction

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);

endclass

function void apbuart_config_test::build_phase (uvm_phase phase);
	super.build_phase(phase);
	apbuart_sq  = apbuart_config_seq::type_id::create("apbuart_sq",this);
	clk_seq     = clk_rst_default_seq::type_id::create("clk_seq",this);
endfunction

task apbuart_config_test::run_phase(uvm_phase phase);
	repeat(10)
	begin
		if (!clk_seq.randomize())
			`uvm_error("RNDFAIL", " Clock Sequence Randomization")
		set_config_params(9600,8,3,1,0); // Baud Rate , Frame Len , Parity , Stop Bit , Randomize Flag (1 for random , 0 for directed)
		cfg.print();
		phase.raise_objection(.obj(this));
		fork 
			clk_seq.start(env_sq.clk_agnt.sequencer);
			apbuart_sq.start(env_sq.v_sqr);
		join
		phase.drop_objection(.obj(this));
	end
    	phase.phase_done.set_drain_time(this, 20);
    
endtask