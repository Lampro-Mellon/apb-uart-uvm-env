`define DRIVAPB_IF vifapb.DRIVER.driver_cb

class apb_driver extends uvm_driver #(apb_transaction);
	`uvm_component_utils(apb_driver)

	virtual apb_if				vifapb;
  	uart_config 				cfg; // Handle to  a cfg class
	apb_config 					apb_cfg; 

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual task drive(apb_transaction req);  

endclass

  	// --------------------------------------- 
  	// build phase
  	// ---------------------------------------
  	function void apb_driver::build_phase(uvm_phase phase);
  		super.build_phase(phase);  
		if(!uvm_config_db#(uart_config)::get(this, "", "cfg", cfg))
			`uvm_fatal("No cfg",{"Configuration must be set for: ",get_full_name(),".cfg"});
		if(!uvm_config_db#(apb_config)::get(this, "", "apb_cfg", apb_cfg))
			`uvm_fatal("No apb_cfg",{"Configuration must be set for: ",get_full_name(),".cfg"});
  	endfunction: build_phase

	// --------------------------------------- 
  	// Conenct phase
  	// ---------------------------------------
	function void apb_driver::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
	   	if(!uvm_config_db#(virtual apb_if)::get(this, "", "vifapb", vifapb))
  	    	`uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vifapb"}); 
    endfunction : connect_phase  

  	// ---------------------------------------  
  	//  run phase
  	// ---------------------------------------  
  	task apb_driver::run_phase(uvm_phase phase);
  		apb_transaction req;
  	  	forever 
  	  	begin
			@(posedge vifapb.PCLK iff (vifapb.PRESETn))
			`DRIVAPB_IF.PSELx		<= 0;
			`DRIVAPB_IF.PENABLE		<= 0;  
			`DRIVAPB_IF.PWRITE		<= 0;
  	  		`DRIVAPB_IF.PWDATA		<= 0;
  	  		`DRIVAPB_IF.PADDR		<= 0;  
  	    	seq_item_port.get_next_item(req);
  	    	drive(req);
 			`uvm_info("APB_DRIVER_TR", $sformatf("APB Finished Driving Transfer \n%s",req.sprint()), UVM_HIGH)
  	    	seq_item_port.item_done();
  	  	end
  	endtask : run_phase
	
  	//---------------------------------------------------------
  	// drive - transaction level to signal level
  	// drives the value's from seq_item to interface signals
  	//--------------------------------------------------------
	
  	task apb_driver::drive(apb_transaction req);
		`DRIVAPB_IF.PSELx			<= apb_cfg.psel_Index;
  	  	`DRIVAPB_IF.PWRITE			<= req.PWRITE;
		if(req.PADDR == cfg.baud_config_addr)
			`DRIVAPB_IF.PWDATA			<= cfg.bRate;
		else if (req.PADDR == cfg.frame_config_addr)
			`DRIVAPB_IF.PWDATA			<= cfg.frame_len;
		else if (req.PADDR == cfg.parity_config_addr)
			`DRIVAPB_IF.PWDATA			<= cfg.parity;
		else if (req.PADDR == cfg.stop_bits_config_addr)
			`DRIVAPB_IF.PWDATA			<= cfg.n_sb;	
		else
			`DRIVAPB_IF.PWDATA			<= req.PWDATA;
  	  	`DRIVAPB_IF.PADDR			<= req.PADDR;
		@(posedge vifapb.PCLK);
		`DRIVAPB_IF.PENABLE			<= 1;
		wait(`DRIVAPB_IF.PREADY);		
		`DRIVAPB_IF.PSELx			<= 0;
		`DRIVAPB_IF.PENABLE			<= 0;
		wait(!`DRIVAPB_IF.PREADY);
  	endtask
