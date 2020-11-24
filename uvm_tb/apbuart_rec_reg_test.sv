class apbuart_rec_reg_test extends apbuart_base_test;
    `uvm_component_utils(apbuart_rec_reg_test)
    
    apbuart_recReg_seq 	apbuart_sq;
    
    function new (string name, uvm_component parent= null);
      	super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);

endclass

function void apbuart_rec_reg_test::build_phase (uvm_phase phase);
	super.build_phase(phase);
    apbuart_sq = apbuart_recReg_seq::type_id::create("apbuart_sq2",this);
endfunction

task apbuart_rec_reg_test::run_phase(uvm_phase phase);
    repeat(cfg.loop_time)
    begin
        set_config_params(9600,8,3,1,1); // Baud Rate , Frame Len , Parity , Stop Bit , Randomize Flag (1 for random , 0 for directed)
        cfg.print();
        phase.raise_objection (.obj(this));
        apbuart_sq.start(env_sq.v_sqr);
        phase.drop_objection(.obj(this));
    end
    phase.phase_done.set_drain_time(this, 20);
endtask
