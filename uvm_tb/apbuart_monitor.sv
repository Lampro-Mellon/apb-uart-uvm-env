`define MON_IF vif.MONITOR.monitor_cb

class apbuart_monitor extends uvm_monitor;
  
	`uvm_component_utils(apbuart_monitor)
  
  	// ---------------------------------------
  	//  Virtual Interface
  	// ---------------------------------------
  	virtual apbuart_if vif;
  
  	// ---------------------------------------
  	// analysis port, to `uvm_analysis_imp_decl( _mon ) send the transaction
  	// to scoreboard
  	// ---------------------------------------
  	uvm_analysis_port #(apbuart_transaction) item_collected_port_mon;
  
  	// ------------------------------------------------------------------------
  	// The following property holds the transaction information currently
  	// begin captured by monitor run phase and make it one transaction.
  	// ------------------------------------------------------------------------
  	apbuart_transaction trans_collected; 

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
  	  	if(!uvm_config_db#(virtual apbuart_if)::get(this, "", "vif", vif))
  	    	`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
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
          repeat(2)@(posedge vif.MONITOR.PCLK);
       		wait(`MON_IF.PENABLE);
       		if(`MON_IF.PWRITE == 1 && (`MON_IF.PADDR == 0 || `MON_IF.PADDR == 1 || `MON_IF.PADDR == 2 || `MON_IF.PADDR == 3)) 
        	begin
            		trans_collected.PWRITE 		= `MON_IF.PWRITE;
        		trans_collected.PADDR 		= `MON_IF.PADDR;
        		trans_collected.PWDATA		= `MON_IF.PWDATA;
            	@(posedge vif.MONITOR.PCLK);
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
   	/*		else if(`MON_IF.PADDR == 4) 
        	begin
          		trans_collected.PWDATA  	= `MON_IF.PWDATA;
			trans_collected.PWRITE  	= `MON_IF.PWRITE;  
          		trans_collected.PADDR 		= `MON_IF.PADDR;
          		if(count == 1'b0)
          		begin
          			wait(!`MON_IF.Tx);
          		    	@(posedge vif.MONITOR.PCLK);
          		    	count 				=  1'b1;
          		  end  
          		else 
          		  begin
          		    repeat(5208)@(posedge vif.MONITOR.PCLK);
          		  end
          		trans_collected.Tx          = `MON_IF.Tx;
          		trans_collected.PREADY      = `MON_IF.PREADY;
              
              		wait(!`MON_IF.PREADY);
              	wait(!`MON_IF.PREADY);
      		end  
	*/
      		else if(`MON_IF.PWRITE == 0 && `MON_IF.PADDR == 5) 
      			begin
      		    	trans_collected.PADDR 		=  vif.PADDR;
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
      		item_collected_port.write(trans_collected); // It sends the transaction non-blocking and it sends to all connected export 
     	end
  	endtask : run_phase
endclass
