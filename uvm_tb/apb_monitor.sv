`define MONAPB_IF vifapb.MONITOR.monitor_cb

class apb_monitor extends uvm_monitor;
  
	`uvm_component_utils(apb_monitor)
  
  	// ---------------------------------------
  	//  Virtual Interface
  	// ---------------------------------------
  	virtual apb_if 				vifapb;

  	// ---------------------------------------
  	// analysis port, to `uvm_analysis_imp_decl( _mon ) send the transaction
  	// to scoreboard
  	// ---------------------------------------
  	uvm_analysis_port #(apb_transaction) item_collected_port_mon;
  
  	// ------------------------------------------------------------------------
  	// The following property holds the transaction information currently
  	// begin captured by monitor run phase and make it one transaction.
  	// ------------------------------------------------------------------------
  	apb_transaction trans_collected; 

  	// ---------------------------------------
  	//  new - constructor
  	// ---------------------------------------
  	function new (string name, uvm_component parent);
  	  	super.new(name, parent);
  	  	trans_collected = new();
      	item_collected_port_mon = new("item_collected_port_mon", this);
  	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
endclass

// -----------------------------------------------
//  build_phase - getting the interface handle
// -----------------------------------------------
function void apb_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase); 
  	if(!uvm_config_db#(virtual apb_if)::get(this, "", "vifapb", vifapb))
    	`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vifapb"})
endfunction: build_phase
	
// ------------------------------------------------------------------------------------
// run_phase - convert the signal level activity to transaction level.
// i.e, sample the values on interface signal ans assigns to transaction class fields
// ------------------------------------------------------------------------------------
task apb_monitor::run_phase(uvm_phase phase);
	logic count = 0;
	forever 
 	begin
   		wait(`MONAPB_IF.PSELx && `MONAPB_IF.PENABLE);
  		wait(`MONAPB_IF.PREADY || `MONAPB_IF.PSLVERR);
  		if(`MONAPB_IF.PSLVERR) 
  		begin
  			trans_collected.PSLVERR = `MONAPB_IF.PSLVERR;
  			wait(`MONAPB_IF.PREADY);
  		end
  		else
  			trans_collected.PSLVERR = `MONAPB_IF.PSLVERR;
			  
		trans_collected.PWRITE 		= `MONAPB_IF.PWRITE;
		trans_collected.PWDATA 		= `MONAPB_IF.PWDATA;
		trans_collected.PADDR 		= `MONAPB_IF.PADDR;		  
		trans_collected.PRDATA 		= `MONAPB_IF.PRDATA;
		trans_collected.PREADY 		= `MONAPB_IF.PREADY;
		`uvm_info(get_type_name(), {"APB Monitor :: Transaction Collected:\n", trans_collected.sprint()}, UVM_HIGH)	  
		wait(!`MONAPB_IF.PREADY); 
  		item_collected_port_mon.write(trans_collected); // It sends the transaction non-blocking and it sends to all connected export 
 	end
endtask : run_phase
