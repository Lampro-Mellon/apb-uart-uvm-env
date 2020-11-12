`define DRIV_IF vif.DRIVER.driver_cb

class uart_driver extends uvm_driver #(uart_transaction);
	logic [5:0]		bcount = 0;
  
	virtual uart_if	vif;
  	`uvm_component_utils(uart_driver)
    
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

  	//--------------------------------------- 
  	// build phase
  	//---------------------------------------
  	function void build_phase(uvm_phase phase);
  		super.build_phase(phase);
  	   	if(!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif))
  	    	`uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  	endfunction: build_phase

  	//---------------------------------------  
  	// run phase
  	//---------------------------------------  
  	virtual task run_phase(uvm_phase phase);
  		uart_transaction req;
  	  	forever 
  	  	begin
  	    	@(posedge vif.PCLK iff (vif.PRESETn))
  	    	seq_item_port.get_next_item(req);
  	    	drive(req);
  	    	seq_item_port.item_done();
  	  	end
  	endtask : run_phase
	
  	//---------------------------------------
  	// drive - transaction level to signal level
  	// drives the value's from seq_item to interface signals
  	//---------------------------------------
	
  	virtual task drive(uart_transaction req);
		vif.rec_temp	<= 0;
		vif.fpn_flag	<= 0;
		`DRIV_IF.RX	<= 1;
  	  	repeat(2)@(posedge vif.DRIVER.PCLK);
  	  	  	 vif.rec_temp 	<= req.rec_temp;
  	  	  	 vif.fpn_flag 		<= req.fpn_flag;
  	  	    @(posedge vif.PCLK); 
  	  	  	repeat(48) 
			begin
  	  	    	repeat(326*16)@(posedge vif.DRIVER.PCLK);
  	  	  			`DRIV_IF.RX 	<= req.rec_temp[bcount];
  	  	  		bcount++;
  	  	end
  	endtask
endclass
