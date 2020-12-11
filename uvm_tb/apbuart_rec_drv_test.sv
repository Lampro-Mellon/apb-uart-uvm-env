class apbuart_rec_drv_test extends apbuart_base_test;
    `uvm_component_utils(apbuart_rec_drv_test)
    
    apbuart_config_seq      apbuart_confg_sq;
    apbuart_recdrv_seq 	    apbuart_drv_sq;
    clk_rst_default_seq 	clk_seq;
    
    function new (string name, uvm_component parent= null);
      	super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);

endclass

function void apbuart_rec_drv_test::build_phase (uvm_phase phase);
	super.build_phase(phase);
    apbuart_confg_sq  = apbuart_config_seq::type_id::create("apbuart_confg_sq",this);
    apbuart_drv_sq    = apbuart_recdrv_seq::type_id::create("apbuart_drv_sq",this);
endfunction

task apbuart_rec_drv_test::run_phase(uvm_phase phase);
    repeat(1)
    begin
        set_config_params(9600,8,3,1,0); // Baud Rate , Frame Len , Parity , Stop Bit , Randomize Flag (1 for random , 0 for directed)
        cfg.print();
        phase.raise_objection (.obj(this));
        apbuart_confg_sq.start(env_sq.v_sqr);
        apbuart_drv_sq.start(env_sq.v_sqr);
        phase.drop_objection(.obj(this));
    end
    phase.phase_done.set_drain_time(this, 20);
endtask
