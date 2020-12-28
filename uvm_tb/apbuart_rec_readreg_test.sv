class apbuart_rec_readreg_test extends apbuart_base_test;
    `uvm_component_utils(apbuart_rec_readreg_test)
    
    apbuart_config_seq          apbuart_confg_sq;
    apbuart_NoError_seq         apbuart_no_err_sq;
    apbuart_parityError_seq     apbuart_part_err_sq;
    apbuart_frameError_seq 	    apbuart_frm_err_sq;
    apbuart_recdrv_seq 	        apbuart_drv_random_sq;
    apbuart_recreadreg_seq      apbuart_read_rcv_reg_sq; 
    apbuart_singlebeat_seq      apbuart_transmission_sq;
    function new (string name, uvm_component parent= null);
      	super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);

endclass

function void apbuart_rec_readreg_test::build_phase (uvm_phase phase);
	super.build_phase(phase);
    apbuart_confg_sq        = apbuart_config_seq::type_id::create("apbuart_confg_sq",this);
    apbuart_no_err_sq       = apbuart_NoError_seq::type_id::create("apbuart_no_err_sq",this);
    apbuart_part_err_sq     = apbuart_parityError_seq::type_id::create("apbuart_part_err_sq",this);
    apbuart_frm_err_sq      = apbuart_frameError_seq::type_id::create("apbuart_frm_err_sq",this);
    apbuart_transmission_sq = apbuart_singlebeat_seq::type_id::create("apbuart_transmission_sq",this);
    apbuart_drv_random_sq   = apbuart_recdrv_seq::type_id::create("apbuart_drv_random_sq",this);
    apbuart_read_rcv_reg_sq = apbuart_recreadreg_seq::type_id::create("apbuart_read_rcv_reg_sq",this);
endfunction

task apbuart_rec_readreg_test::run_phase(uvm_phase phase);
    repeat(cfg.loop_time)
    begin
        set_config_params(9600,7,3,1,1); // Baud Rate , Frame Len , Parity , Stop Bit , Randomize Flag (1 for random , 0 for directed)
        cfg.print();
        phase.raise_objection (.obj(this));
        apbuart_confg_sq.start(env_sq.v_sqr);
        apbuart_no_err_sq.start(env_sq.v_sqr);
        apbuart_read_rcv_reg_sq.start(env_sq.v_sqr);
        apbuart_part_err_sq.start(env_sq.v_sqr);    
        apbuart_read_rcv_reg_sq.start(env_sq.v_sqr);
        //apbuart_frm_err_sq.start(env_sq.v_sqr);
        //apbuart_read_rcv_reg_sq.start(env_sq.v_sqr);
        apbuart_drv_random_sq.start(env_sq.v_sqr);
        apbuart_read_rcv_reg_sq.start(env_sq.v_sqr);
        phase.drop_objection(.obj(this));
    end        
    phase.phase_done.set_drain_time(this, 20);
endtask
