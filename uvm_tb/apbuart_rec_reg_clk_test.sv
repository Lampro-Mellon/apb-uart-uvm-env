class apbuart_rec_reg_clk_test extends apbuart_base_test;
    `uvm_component_utils(apbuart_rec_reg_clk_test)
    
    apbuart_recReg_seq 	    apbuart_sq;
    clk_rst_default_seq 	apbuart_clk_sq;
    
    function new (string name, uvm_component parent= null);
      	super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);

endclass

function void apbuart_rec_reg_clk_test::build_phase (uvm_phase phase);
	super.build_phase(phase);
    apbuart_sq  = apbuart_recReg_seq::type_id::create("apbuart_sq2",this);
    apbuart_clk_sq  = clk_rst_default_seq::type_id::create("apbuart_clk_sq",this);
endfunction

task apbuart_rec_reg_clk_test::run_phase(uvm_phase phase);
    repeat(cfg.loop_time)
    begin
        set_config_params(9600,8,3,1,0); // Baud Rate , Frame Len , Parity , Stop Bit , Randomize Flag (1 for random , 0 for directed)
        cfg.print();
        phase.raise_objection (.obj(this));
        fork
            apbuart_clk_sq.start(env_sq.clk_agnt.sequencer);
            apbuart_sq.start(env_sq.v_sqr);
        join    
        phase.drop_objection(.obj(this));
        if (!apbuart_clk_sq.randomize()) 
			`uvm_error("RNDFAIL", " Clock Period and Reset Cycles Randomization")	
    end
    phase.phase_done.set_drain_time(this, 20);
endtask
