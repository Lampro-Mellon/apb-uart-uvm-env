class vseq_base extends uvm_sequence;

    `uvm_object_utils(vseq_base)
    `uvm_declare_p_sequencer(vsequencer)

    apb_sequencer        apb_sqr;
    uart_sequencer       uart_sqr;

    function new(string name="vseq_base");
        super.new(name);
    endfunction

    extern virtual task body();
endclass

class apbuart_config_seq extends vseq_base;
    `uvm_object_utils(apbuart_config_seq)

    function new(string name="apbuart_config");
        super.new(name);
    endfunction
    
    extern virtual task body();
endclass

class apbuart_singlebeat_seq extends vseq_base;
    `uvm_object_utils(apbuart_singlebeat_seq)

    function new(string name="apbuart_singlebeat_seq");
        super.new(name);
    endfunction

    extern virtual task body();
endclass

class apbuart_recdrv_seq extends vseq_base;
    `uvm_object_utils(apbuart_recdrv_seq)

    function new(string name="apbuart_recdrv_seq");
        super.new(name);
    endfunction

    extern virtual task body();
endclass

class apbuart_recreadreg_seq extends vseq_base;
    `uvm_object_utils(apbuart_recreadreg_seq)

    function new(string name="apbuart_recreadreg_seq");
        super.new(name);
    endfunction

    extern virtual task body();
endclass

class apbuart_frameError_seq extends vseq_base;
    `uvm_object_utils(apbuart_frameError_seq)

    function new(string name="apbuart_frameError_seq");
        super.new(name);
    endfunction

    extern virtual task body();
endclass

class apbuart_parityError_seq extends vseq_base;
    `uvm_object_utils(apbuart_parityError_seq)

    function new(string name="apbuart_parityError_seq");
        super.new(name);
    endfunction

    extern virtual task body();
endclass 

class apbuart_NoError_seq extends vseq_base;
    `uvm_object_utils(apbuart_NoError_seq)

    function new(string name="apbuart_NoError_seq");
        super.new(name);
    endfunction

    extern virtual task body();
endclass

task vseq_base::body();
    apb_sqr = p_sequencer.apb_sqr;
    uart_sqr = p_sequencer.uart_sqr;
endtask

task apbuart_config_seq::body();
    config_apbuart          apbuart_seq;
    super.body();
    `uvm_info("apbuart_config_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(apbuart_seq,  apb_sqr)
    `uvm_info("apbuart_config_seq", "Sequence complete", UVM_HIGH)
endtask

task apbuart_singlebeat_seq::body();
    transmit_single_beat    apbuart_seq;
    super.body();
    `uvm_info("apbuart_singlebeat_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(apbuart_seq,  apb_sqr)
    `uvm_info("apbuart_singlebeat_seq", "Sequence complete", UVM_HIGH)
endtask

task apbuart_recdrv_seq::body();
    recdrv_test_uart      apbuart_seq;
    super.body();
    `uvm_info("apbuart_recdrv_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(apbuart_seq, uart_sqr)
    `uvm_info("apbuart_recdrv_seq", "Sequence complete", UVM_HIGH)
endtask

task apbuart_recreadreg_seq::body();
    rec_reg_test        apbuart_seq;
    super.body();
    `uvm_info("apbuart_recdrv_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(apbuart_seq, apb_sqr)
    `uvm_info("apbuart_recdrv_seq", "Sequence complete", UVM_HIGH)
endtask

task apbuart_frameError_seq::body();
    fe_test_uart      apbuart_seq; 
    super.body();
    `uvm_info("apbuart_frameError_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(apbuart_seq,  uart_sqr) 
    `uvm_info ("apbuart_frameError_seq", "Sequence complete", UVM_HIGH)
endtask

task apbuart_parityError_seq::body();
    pe_test_uart      apbuart_seq; 
    super.body();
    `uvm_info("apbuart_parityError_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(apbuart_seq, uart_sqr) 
    `uvm_info ("apbuart_parityError_seq", "Sequence complete", UVM_HIGH)
endtask

task apbuart_NoError_seq::body();
    err_free_test_uart      apbuart_seq; 
    super.body();
    `uvm_info("apbuart_NoError_seq", "Executing sequence", UVM_HIGH)
    `uvm_do_on(apbuart_seq, uart_sqr) 
    `uvm_info ("apbuart_NoError_seq", "Sequence complete", UVM_HIGH)
endtask