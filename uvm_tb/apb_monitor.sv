`define MON_IF vifapb.MONITOR.monitor_cb

class apb_monitor extends uvm_monitor;
  
	`uvm_component_utils(apb_monitor)
  
  	// ---------------------------------------
  	//  Virtual Interface
  	// ---------------------------------------
  	virtual apb_if vifapb;
  
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

  	// -----------------------------------------------
  	//  build_phase - getting the interface handle
  	// -----------------------------------------------
  	function void build_phase(uvm_phase phase);
  		super.build_phase(phase);
  	  	if(!uvm_config_db#(virtual apb_if)::get(this, "", "vifapb", vifapb))
  	    	`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vifapb"});
  	endfunction: build_phase
	
  	logic count;
  
  	//------------------------------------------------------------------------------------
  	// run_phase - convert the signal level activity to transaction level.
  	// i.e, sample the values on interface signal ans assigns to transaction class fields
  	//------------------------------------------------------------------------------------
  	virtual task run_phase(uvm_phase phase);
    	count = 0;
    	forever 
     	begin
          repeat(2)@(posedge vifapb.MONITOR.PCLK);
       		wait(`MON_IF.PENABLE);
       		if(`MON_IF.PWRITE == 1 && (`MON_IF.PADDR == 0 || `MON_IF.PADDR == 1 || `MON_IF.PADDR == 2 || `MON_IF.PADDR == 3)) 
        	begin
            	trans_collected.PWRITE 		= `MON_IF.PWRITE;
        		trans_collected.PADDR 		= `MON_IF.PADDR;
        		trans_collected.PWDATA		= `MON_IF.PWDATA;
            	@(posedge vifapb.MONITOR.PCLK);
      		end
      		else if(`MON_IF.PWRITE == 0 && (`MON_IF.PADDR == 0 || `MON_IF.PADDR == 1 || `MON_IF.PADDR == 2 || `MON_IF.PADDR == 3)) 
        	begin
        		trans_collected.PWRITE		= `MON_IF.PWRITE;
        		trans_collected.PWDATA		=  0;
            	wait( `MON_IF.PREADY);
          		trans_collected.PADDR 		= `MON_IF.PADDR;
        		trans_collected.PRDATA 		= `MON_IF.PRDATA;
                wait(!`MON_IF.PREADY);
      		end
      		else if(`MON_IF.PWRITE == 0 && `MON_IF.PADDR == 5) 
      			begin
      		    	trans_collected.PADDR 		=  vifapb.PADDR;
      		    	wait(`MON_IF.PREADY || `MON_IF.PSLVERR);
      		    	if(`MON_IF.PSLVERR) 
      		      	begin
      		        	trans_collected.PSLVERR = `MON_IF.PSLVERR;
      		        	wait(`MON_IF.PREADY);
      		      	end
      		    	else
      		        	trans_collected.PSLVERR = `MON_IF.PSLVERR;

				trans_collected.PRDATA 		= `MON_IF.PRDATA;
				trans_collected.PREADY 		= `MON_IF.PREADY;	  
			wait(!`MON_IF.PREADY);
      		    end  
      		item_collected_port_mon.write(trans_collected); // It sends the transaction non-blocking and it sends to all connected export 
     	end
  	endtask : run_phase
endclass
