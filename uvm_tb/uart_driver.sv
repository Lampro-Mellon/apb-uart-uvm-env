`define DRIVUART_IF vifuart.DRIVER.driver_cb

class uart_driver extends uvm_driver #(uart_transaction);
	logic [5:0]		bcount = 0;
  
	virtual uart_if	vifuart;
  	`uvm_component_utils(uart_driver)
    
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
  	uvm_analysis_port #(uart_transaction) item_collected_port_drv;
	uart_transaction trans_collected; 

  	//--------------------------------------- 
  	// build phase
  	//---------------------------------------
  	function void build_phase(uvm_phase phase);
  		super.build_phase(phase);
  	   	if(!uvm_config_db#(virtual uart_if)::get(this, "", "vifuart", vifuart))
  	    	`uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vifuart"});
			trans_collected = new();
      		item_collected_port_drv = new("item_collected_port_drv", this);
  	endfunction: build_phase

  	//---------------------------------------  
  	// run phase
  	//---------------------------------------  
  	virtual task run_phase(uvm_phase phase);
  		uart_transaction req;
  	  	forever 
  	  	begin
  	    	@(posedge vifuart.PCLK iff (vifuart.PRESETn))
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
	  	trans_collected.rec_temp 	= req.rec_temp;
		trans_collected.fpn_flag 	= req.fpn_flag;  
		`DRIVUART_IF.RX				<= 1;
  	  	repeat(48) 
		begin
  	  		repeat(5208)@(posedge vifuart.DRIVER.PCLK);
  	  			`DRIVUART_IF.RX 	<= req.rec_temp[bcount];
  	  		bcount++;
  	  	end
		item_collected_port_drv.write(trans_collected); // It sends the transaction non-blocking and it
  	endtask
endclass
