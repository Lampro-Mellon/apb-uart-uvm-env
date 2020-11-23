class vsequencer extends uvm_sequencer;
   `uvm_component_utils(vsequencer)

    apb_sequencer   apb_sqr;
    uart_sequencer  uart_sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
endclass

function void vsequencer::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    if (!uvm_config_db#(apb_sequencer)::get(this, "", "apb_sqr", apb_sqr))
        `uvm_fatal("VSQR/CFG/NOAHB", "No ahb_sqr specified for this instance");
    if (!uvm_config_db#(uart_sequencer)::get(this, "", "uart_sqr", uart_sqr))
        `uvm_fatal("VSQR/CFG/NOETH", "No eth_sqr specified for this instance");
endfunction
