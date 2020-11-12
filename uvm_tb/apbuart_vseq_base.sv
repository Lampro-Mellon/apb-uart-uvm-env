class vseq_base extends uvm_sequence;
    `uvm_object_utils(vseq_base)
    `uvm_declare_p_sequencer(vsequencer)
    function new(string name="vseq_base");
        super.new(name);
    endfunction
    apbuart_sequencer    apb_sqr;
    uart_sequencer       uart_sqr;
    virtual task body();
        apb_sqr = p_sequencer.apb_sqr;
        uart_sqr = p_sequencer.uart_sqr;
    endtask
endclass


class apbuart_config_seq extends vseq_base;
    `uvm_object_utils(apbuart_config_seq)
    function new(string name="apbuart_config");
        super.new(name);
    endfunction
    virtual task body();
        config_apbuart apbuart_seq;
        super.body();
        `uvm_info("apbuart_config_seq", "Executing sequence", UVM_HIGH)
        `uvm_do_on(apbuart_seq,  apb_sqr)
        `uvm_info("apbuart_config_seq", "Sequence complete", UVM_HIGH)
    endtask
endclass
class vseq_base extends uvm_sequence;
    `uvm_object_utils(vseq_base)
    `uvm_declare_p_sequencer(vsequencer)
    function new(string name="vseq_base");
        super.new(name);
    endfunction
    apbuart_sequencer    apb_sqr;
    uart_sequencer       uart_sqr;
    virtual task body();
        apb_sqr = p_sequencer.apb_sqr;
        uart_sqr = p_sequencer.uart_sqr;
    endtask
endclass


class apbuart_config_seq extends vseq_base;
    `uvm_object_utils(apbuart_config_seq)
    function new(string name="apbuart_config");
        super.new(name);
    endfunction
    virtual task body();
        config_apbuart apbuart_seq;
        super.body();
        `uvm_info("apbuart_config_seq", "Executing sequence", UVM_HIGH)
        `uvm_do_on(apbuart_seq,  apb_sqr)
        `uvm_info("apbuart_config_seq", "Sequence complete", UVM_HIGH)
    endtask
endclass

class apbuart_singlebeat_seq extends vseq_base;
    `uvm_object_utils(apbuart_singlebeat_seq)
    function new(string name="apbuart_singlebeat_seq");
        super.new(name);
    endfunction
    virtual task body();
        config_apbuart apbuart_seq;
        transmit_single_beat apbuart_seq1;
        super.body();
        `uvm_info("apbuart_singlebeat_seq", "Executing sequence", UVM_HIGH)
        `uvm_do_on(apbuart_seq,  apb_sqr)
        `uvm_do_on(apbuart_seq1,  apb_sqr)
        `uvm_info("apbuart_singlebeat_seq", "Sequence complete", UVM_HIGH)
    endtask
endclass


class apbuart_recReg_seq extends vseq_base;
    `uvm_object_utils(apbuart_recReg_seq)
    function new(string name="apbuart_recReg_seq");
        super.new(name);
    endfunction
    virtual task body();
        config_apbuart apbuart_seq;
        rec_reg_test   apbuart_seq1;
        super.body();
        `uvm_info("apbuart_recReg_seq", "Executing sequence", UVM_HIGH)
        `uvm_do_on(apbuart_seq,  apb_sqr)
        `uvm_do_on(apbuart_seq1, apb_sqr)
        `uvm_info("apbuart_recReg_seq", "Sequence complete", UVM_HIGH)
    endtask
endclass


class apbuart_frameError_seq extends vseq_base;
    `uvm_object_utils(apbuart_frameError_seq)
    function new(string name="apbuart_frameError_seq");
        super.new(name);
    endfunction
    virtual task body();
        config_apbuart    apbuart_seq;
        fe_test_apbuart   apbuart_seq1;
        fe_test_uart      apbuart_seq2; 
        super.body();
        `uvm_info("apbuart_frameError_seq", "Executing sequence", UVM_HIGH)
        `uvm_do_on(apbuart_seq,  apb_sqr)
        fork 
        `uvm_do_on(apbuart_seq1, apb_sqr)
        `uvm_do_on(apbuart_seq2, uart_sqr) 
        join 
        `uvm_info ("apbuart_frameError_seq", "Sequence complete", UVM_HIGH)
    endtask
endclass



class apbuart_parityError_seq extends vseq_base;
    `uvm_object_utils(apbuart_parityError_seq)
    function new(string name="apbuart_parityError_seq");
        super.new(name);
    endfunction
    virtual task body();
        config_apbuart    apbuart_seq;
        pe_test_apbuart   apbuart_seq1;
        pe_test_uart      apbuart_seq2; 
        super.body();
        `uvm_info("apbuart_parityError_seq", "Executing sequence", UVM_HIGH)
        `uvm_do_on(apbuart_seq,  apb_sqr)
        fork 
        `uvm_do_on(apbuart_seq1, apb_sqr)
        `uvm_do_on(apbuart_seq2, uart_sqr) 
        join 
        `uvm_info ("apbuart_parityError_seq", "Sequence complete", UVM_HIGH)
    endtask
endclass 

class apbuart_NoError_seq extends vseq_base;
    `uvm_object_utils(apbuart_NoError_seq)
    function new(string name="apbuart_NoError_seq");
        super.new(name);
    endfunction
    virtual task body();
        config_apbuart           apbuart_seq;
        err_free_test_apbuart   apbuart_seq1;
        err_free_test_uart      apbuart_seq2; 
        super.body();
        `uvm_info("apbuart_NoError_seq", "Executing sequence", UVM_HIGH)
        `uvm_do_on(apbuart_seq,  apb_sqr)
        fork 
        `uvm_do_on(apbuart_seq1, apb_sqr)
        `uvm_do_on(apbuart_seq2, uart_sqr) 
        join 
        `uvm_info ("apbuart_NoError_seq", "Sequence complete", UVM_HIGH)
    endtask
endclass 
class apbuart_singlebeat_seq extends vseq_base;
    `uvm_object_utils(apbuart_singlebeat_seq)
    function new(string name="apbuart_singlebeat_seq");
        super.new(name);
    endfunction
    virtual task body();
        config_apbuart apbuart_seq;
        transmit_single_beat apbuart_seq1;
        super.body();
        `uvm_info("apbuart_singlebeat_seq", "Executing sequence", UVM_HIGH)
        `uvm_do_on(apbuart_seq,  apb_sqr)
        `uvm_do_on(apbuart_seq1,  apb_sqr)
        `uvm_info("apbuart_singlebeat_seq", "Sequence complete", UVM_HIGH)
    endtask
endclass


class apbuart_recReg_seq extends vseq_base;
    `uvm_object_utils(apbuart_recReg_seq)
    function new(string name="apbuart_recReg_seq");
        super.new(name);
    endfunction
    virtual task body();
        config_apbuart apbuart_seq;
        rec_reg_test   apbuart_seq1;
        super.body();
        `uvm_info("apbuart_recReg_seq", "Executing sequence", UVM_HIGH)
        `uvm_do_on(apbuart_seq,  apb_sqr)
        `uvm_do_on(apbuart_seq1, apb_sqr)
        `uvm_info("apbuart_recReg_seq", "Sequence complete", UVM_HIGH)
    endtask
endclass


class apbuart_frameError_seq extends vseq_base;
    `uvm_object_utils(apbuart_frameError_seq)
    function new(string name="apbuart_frameError_seq");
        super.new(name);
    endfunction
    virtual task body();
        config_apbuart    apbuart_seq;
        fe_test_apbuart   apbuart_seq1;
        fe_test_uart      apbuart_seq2; 
        super.body();
        `uvm_info("apbuart_frameError_seq", "Executing sequence", UVM_HIGH)
        `uvm_do_on(apbuart_seq,  apb_sqr)
        fork 
        `uvm_do_on(apbuart_seq1, apb_sqr)
        `uvm_do_on(apbuart_seq2, uart_sqr) 
        join 
        `uvm_info ("apbuart_frameError_seq", "Sequence complete", UVM_HIGH)
    endtask
endclass



class apbuart_parityError_seq extends vseq_base;
    `uvm_object_utils(apbuart_parityError_seq)
    function new(string name="apbuart_parityError_seq");
        super.new(name);
    endfunction
    virtual task body();
        config_apbuart    apbuart_seq;
        pe_test_apbuart   apbuart_seq1;
        pe_test_uart      apbuart_seq2; 
        super.body();
        `uvm_info("apbuart_parityError_seq", "Executing sequence", UVM_HIGH)
        `uvm_do_on(apbuart_seq,  apb_sqr)
        fork 
        `uvm_do_on(apbuart_seq1, apb_sqr)
        `uvm_do_on(apbuart_seq2, uart_sqr) 
        join 
        `uvm_info ("apbuart_parityError_seq", "Sequence complete", UVM_HIGH)
    endtask
endclass 

class apbuart_NoError_seq extends vseq_base;
    `uvm_object_utils(apbuart_NoError_seq)
    function new(string name="apbuart_NoError_seq");
        super.new(name);
    endfunction
    virtual task body();
        config_apbuart           apbuart_seq;
        err_free_test_apbuart   apbuart_seq1;
        err_free_test_uart      apbuart_seq2; 
        super.body();
        `uvm_info("apbuart_NoError_seq", "Executing sequence", UVM_HIGH)
        `uvm_do_on(apbuart_seq,  apb_sqr)
        fork 
        `uvm_do_on(apbuart_seq1, apb_sqr)
        `uvm_do_on(apbuart_seq2, uart_sqr) 
        join 
        `uvm_info ("apbuart_NoError_seq", "Sequence complete", UVM_HIGH)
    endtask
endclass 