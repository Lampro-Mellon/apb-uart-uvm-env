`define DRIV_IF vif.DRIVER.driver_cb

class apbuart_driver extends uvm_driver #(apbuart_transaction);
	logic [5:0]		bcount = 0;
  
	virtual apbuart_if	vif;
  	`uvm_component_utils(apbuart_driver)
    
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
  
  	uvm_analysis_port #(apbuart_transaction) item_collected_port_drv;
  
  	// ------------------------------------------------------------------------
  	// The following property holds the transaction information currently
  	// begin captured by monitor run phase and make it one transaction.
  	// ------------------------------------------------------------------------
  	apbuart_transaction trans_collected_drv; 

  	//--------------------------------------- 
  	// build phase
  	//---------------------------------------
  	function void build_phase(uvm_phase phase);
  		super.build_phase(phase);
  	   	if(!uvm_config_db#(virtual apbuart_if)::get(this, "", "vif", vif))
  	    	`uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
      	trans_collected_drv = new();
      	item_collected_port_drv = new("item_collected_port_drv", this);
  	endfunction: build_phase

  	//---------------------------------------  
  	// run phase
  	//---------------------------------------  
  	virtual task run_phase(uvm_phase phase);
  		apbuart_transaction req;
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
	
  	virtual task drive(apbuart_transaction req);
  		`DRIV_IF.PSELx		<= 0;
		`DRIV_IF.PENABLE	<= 0;  
		`DRIV_IF.PWRITE		<= 0;
  	  	`DRIV_IF.RX			<= 1;
  	  	`DRIV_IF.PWDATA		<= 0;
  	  	`DRIV_IF.PADDR		<= 0;
  	  	repeat(2)@(posedge vif.DRIVER.PCLK);
  	  	if(req.PADDR == 0 || req.PADDR == 1 || req.PADDR == 2 || req.PADDR == 3 || req.PADDR == 4) 
  	  	begin
			`DRIV_IF.PSELx		<= 1;
			@(posedge vif.DRIVER.PCLK);
			`DRIV_IF.PENABLE	<= 1;
  	  	    `DRIV_IF.PWRITE		<= req.PWRITE;
  	  	    `DRIV_IF.PWDATA		<= req.PWDATA;
  	  	    `DRIV_IF.PADDR		<= req.PADDR;
			 wait(`DRIV_IF.PREADY);		
			`DRIV_IF.PSELx		<= 0;
			`DRIV_IF.PENABLE	<= 0;
          	 trans_collected_drv.PADDR <= req.PADDR;
  	  	end
  	  	else if(req.PADDR == 5)
  	  	begin
			`DRIV_IF.PSELx		<= 1;
			@(posedge vif.DRIVER.PCLK);
			`DRIV_IF.PENABLE	<= 1;
  	  	    `DRIV_IF.PWRITE		<= req.PWRITE;
  	  	    `DRIV_IF.PWDATA		<= req.PWDATA;
  	  	    `DRIV_IF.PADDR		<= req.PADDR;
          	 trans_collected_drv.PADDR   <= req.PADDR;
          	 trans_collected_drv.rec_temp <= req.rec_temp;
          	 trans_collected_drv.fpn_flag <= req.fpn_flag;
  	  	    @(posedge vif.PCLK); 
  	  	  	repeat(48) 
			begin
              repeat(326*16)@(posedge vif.DRIVER.PCLK); // 16*6
  	  	  			`DRIV_IF.RX 	<= req.rec_temp[bcount];
  	  	  		bcount++;
  	  	  	end
  	  	end
      	item_collected_port_drv.write(trans_collected_drv); // It sends the transaction non-blocking and it
  	endtask
endclass
