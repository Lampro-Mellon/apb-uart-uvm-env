class apbuart_free_error_test extends apbuart_base_test;
    `uvm_component_utils (apbuart_free_error_test)

    apbuart_NoError_seq  apbuart_no_err_sq; // all configuration for write and read configuration

    function new (string name, uvm_component parent= null);
      	super.new(name, parent);
    endfunction
    
    extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);

endclass

function void apbuart_free_error_test::build_phase (uvm_phase phase);
  	super.build_phase(phase);
  	apbuart_no_err_sq = apbuart_NoError_seq::type_id::create("apbuart_no_err_sq",this);
endfunction

task apbuart_free_error_test::run_phase(uvm_phase phase);
    repeat(cfg.loop_time)
    begin
        set_config_params(9600,8,3,1,1); // Baud Rate , Frame Len , Parity , Stop Bit , Randomize Flag (1 for random , 0 for directed)
        cfg.print();
        phase.raise_objection (.obj(this));
        apbuart_no_err_sq.start(env_sq.v_sqr);
        phase.drop_objection(.obj(this)); 
    end
    phase.phase_done.set_drain_time(this, 20);
endtask
