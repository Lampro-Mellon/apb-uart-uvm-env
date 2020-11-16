class apbuart_env extends uvm_env;
  
	`uvm_component_utils(apbuart_env)

    // ---------------------------------------
    //  agent and scoreboard instance
    // ---------------------------------------
    apbuart_agent       apbuart_agnt;
    uart_agent          uart_agnt;
    apbuart_scoreboard  apbuart_scb;
    vsequencer          v_sqr;
    

    // --------------------------------------- 
    //  Calling the constructor
    // ---------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // --------------------------------------------------------------
    //  build_phase - create the components of scorebaord and agent
    // --------------------------------------------------------------
    function void build_phase(uvm_phase phase);
      	super.build_phase(phase);
        apbuart_agnt  = apbuart_agent::type_id::create("apbuart_agnt", this);
        uart_agnt  = apbuart_agent::type_id::create("uart_agnt", this); 
      	apbuart_scb   = apbuart_scoreboard::type_id::create("apbuart_scb", this);
        v_sqr  = vsequencer::type_id::create("v_sqr",this);
    endfunction : build_phase

    // ------------------------------------------------------------
    //  connect_phase - connecting monitor and scoreboard port
    // ------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
	apbuart_agnt.monitor.item_collected_port.connect(apbuart_scb.item_collected_export_monapb);
       	uart_agnt.driver.item_collected_port.connect(apbuart_scb.item_collected_export_drvuart);
        apbuart_agnt.driver.item_collected_port.connect(apbuart_scb.item_collected_export_drvapb);
	uart_agnt.monitor.item_collected_export.connect(apbuart_scb.item_collected_export_monuart)
         
        uvm_config_db#(apbuart_sequencer)::set(this,"*","apb_sqr",apbuart_agnt.sequencer);
        uvm_config_db#(uart_sequencer)::set(this,"*","uart_sqr",uart_agnt.sequencer); 
    endfunction : connect_phase

endclass : apbuart_env
