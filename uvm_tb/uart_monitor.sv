`define MON_IF vif.MONITOR.monitor_cb

class uart_monitor extends uvm_monitor;
  
	`uvm_component_utils(uart_monitor)
  
  	// ---------------------------------------
  	//  Virtual Interface
  	// ---------------------------------------
  	virtual uart_if vif;
  
  	// ---------------------------------------
  	// analysis port, to send the transaction
  	// to scoreboard
  	// ---------------------------------------
  	uvm_analysis_port #(uart_transaction) item_collected_port;
  
  	// ------------------------------------------------------------------------
  	// The following property holds the transaction information currently
  	// begin captured by monitor run phase and make it one transaction.
  	// ------------------------------------------------------------------------
  	uart_transaction trans_collected; 

  	// ---------------------------------------
  	//  new - constructor
  	// ---------------------------------------
  	function new (string name, uvm_component parent);
  	  	super.new(name, parent);
  	  	trans_collected = new();
  	  	item_collected_port = new("item_collected_port", this);
  	endfunction : new

  	// -----------------------------------------------
  	//  build_phase - getting the interface handle
  	// -----------------------------------------------
  	function void build_phase(uvm_phase phase);
  		super.build_phase(phase);
  	  	if(!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif))
  	    	`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  	endfunction: build_phase
	
	logic [6:0] count;
  
  	//------------------------------------------------------------------------------------
  	// run_phase - convert the signal level activity to transaction level.
  	// i.e, sample the values on interface signal ans assigns to transaction class fields
  	//------------------------------------------------------------------------------------
  	virtual task run_phase(uvm_phase phase);
    	count = 0;
    	forever 
     	begin
          repeat(2)@(posedge vif.MONITOR.PCLK);
		repeat(48) begin ///////////////////// check if it is to be 48 or 47 
			if(count == 1'b0) begin
          			wait(!`MON_IF.Tx);
          		    	@(posedge vif.MONITOR.PCLK);
				trans_collected.transmitter_reg[count]          = `MON_IF.Tx;
          		    	count=count+1;
          		end  
          		else begin
          		    	repeat(5208)@(posedge vif.MONITOR.PCLK);
				trans_collected.transmitter_reg[count]          = `MON_IF.Tx;
				count=count+1;				  
			end
		end
      	item_collected_port.write(trans_collected); // It sends the transaction non-blocking and it sends to all connected export 
     	end
  	endtask : run_phase
endclass
