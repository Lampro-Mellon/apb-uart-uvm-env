class apbuart_env extends uvm_env;
  
	`uvm_component_utils(apbuart_env)

    // ---------------------------------------
    //  agent and scoreboard instance
    // ---------------------------------------
    apbuart_agent       apbuart_agnt;
    apbuart_scoreboard  apbuart_scb;

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
      	apbuart_scb   = apbuart_scoreboard::type_id::create("apbuart_scb", this);
    endfunction : build_phase

    // ------------------------------------------------------------
    //  connect_phase - connecting monitor and scoreboard port
    // ------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
    	apbuart_agnt.monitor.item_collected_port.connect(apbuart_scb.item_collected_export);
	apbuart_agnt.driver.item_collected_port_drv.connect(apbuart_scb.item_collected_export_drv);
    endfunction : connect_phase

endclass : apbuart_env
