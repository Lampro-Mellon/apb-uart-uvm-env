class config_apbuart extends uvm_sequence #(apb_transaction);
	`uvm_object_utils (config_apbuart)

	apb_transaction apbuart_sq;
	uart_config 	cfg;

    function new (string name = "config_apbuart");
        super.new (name);
    endfunction

    extern virtual task body();

endclass

class transmit_single_beat extends uvm_sequence #(apb_transaction);
	
	`uvm_object_utils (transmit_single_beat)
	apb_transaction apbuart_sq; 
	uart_config 	cfg;

    function new (string name = "transmit_single_beat");
        super.new (name);
    endfunction

	extern virtual task body();
endclass

class rec_reg_test extends uvm_sequence#(apb_transaction);
	`uvm_object_utils(rec_reg_test)
  	apb_transaction	apbuart_sq;
	uart_config 	cfg;

  	function new(string name = "rec_reg_test");
  		super.new(name);
  	endfunction: new

	extern virtual task body();  
endclass: rec_reg_test

class fe_test_apbuart extends uvm_sequence#(apb_transaction);
	`uvm_object_utils(fe_test_apbuart)

	apb_transaction apbuart_sq;
	uart_config 	cfg;

	function new(string name = "fe_test_apbuart");
		super.new(name);
  	endfunction: new

	extern virtual task body();  
endclass: fe_test_apbuart

class pe_test_apbuart extends uvm_sequence#(apb_transaction);
	`uvm_object_utils(pe_test_apbuart)

  	apb_transaction apbuart_sq;
	uart_config 	cfg;
	
	function new(string name = "pe_test_apbuart");
    	super.new(name);
  	endfunction: new
	
	extern virtual task body();
endclass: pe_test_apbuart

class err_free_test_apbuart extends uvm_sequence#(apb_transaction);
	`uvm_object_utils(err_free_test_apbuart)
  	
	apb_transaction apbuart_sq;
	uart_config 	cfg;
	
	function new(string name = "err_free_test_apbuart");
    	super.new(name);
  	endfunction: new

	extern virtual task body();  
endclass: err_free_test_apbuart

task config_apbuart::body();
	apbuart_sq 	= apb_transaction::type_id::create("apbuart_sq");
	cfg 		= uart_config::type_id::create("cfg");
	
	// Write data for Configuring the registers	   
    `uvm_do_with(apbuart_sq,{
	  						 apbuart_sq.PWRITE == 1'b1;
                          	 apbuart_sq.PADDR  == cfg.baud_config_addr;
							})
	`uvm_do_with(apbuart_sq,{
	  						 apbuart_sq.PWRITE == 1'b0;
                          	 apbuart_sq.PADDR  == cfg.baud_config_addr;
                          	})
    `uvm_do_with(apbuart_sq,{
	  						 apbuart_sq.PWRITE == 1'b1;
                          	 apbuart_sq.PADDR  == cfg.frame_config_addr;
							})
    `uvm_do_with(apbuart_sq,{
	  						 apbuart_sq.PWRITE == 1'b0;
                          	 apbuart_sq.PADDR  == cfg.frame_config_addr;
                          	})								
    `uvm_do_with(apbuart_sq,{
	  						 apbuart_sq.PWRITE == 1'b1;
                          	 apbuart_sq.PADDR  == cfg.parity_config_addr;
							})
    `uvm_do_with(apbuart_sq,{
	  						 apbuart_sq.PWRITE == 1'b0;
                          	 apbuart_sq.PADDR  == cfg.parity_config_addr;
                          	})								  
    
    `uvm_do_with(apbuart_sq,{
	  						 apbuart_sq.PWRITE == 1'b1;
                          	 apbuart_sq.PADDR  == cfg.stop_bits_config_addr;
                          	})      
    `uvm_do_with(apbuart_sq,{
	  						 apbuart_sq.PWRITE == 1'b0;
                          	 apbuart_sq.PADDR  == cfg.stop_bits_config_addr;
                          	})
endtask

task transmit_single_beat::body();
    apbuart_sq 	= apb_transaction::type_id::create("apbuart_sq");
	cfg			= uart_config::type_id::create("cfg");
	
	`uvm_do_with(apbuart_sq,{
		  					 apbuart_sq.PWRITE == 1'b1;
                             apbuart_sq.PADDR  == cfg.trans_data_addr;
							 //apbuart_sq.PWDATA == 32'hFCBDABCD;  
                            }) 
endtask  

task rec_reg_test::body();
	apbuart_sq 	= apb_transaction::type_id::create("apbuart_sq");
	cfg 		= uart_config::type_id::create("cfg");

    `uvm_do_with(apbuart_sq,{
	  						 apbuart_sq.PWRITE == 1'b0;
                          	 apbuart_sq.PADDR  == cfg.receive_data_addr;
                          	}) 
	//`uvm_do(apbuart_sq) 

endtask: body

task fe_test_apbuart::body();
    apbuart_sq 	= apb_transaction::type_id::create("apbuart_sq");
	cfg 		= uart_config::type_id::create("cfg");

	`uvm_do_with(apbuart_sq,{
	  						 apbuart_sq.PWRITE 	 == 1'b0;
                          	 apbuart_sq.PADDR  	 == cfg.receive_data_addr;    //framing Error  
							}) 
endtask: body

task pe_test_apbuart::body();
    apbuart_sq 	= apb_transaction::type_id::create("apbuart_sq");
	cfg 		= uart_config::type_id::create("cfg");
	`uvm_do_with(apbuart_sq,{
	  						 apbuart_sq.PWRITE 	 == 1'b0;
                          	 apbuart_sq.PADDR  	 == cfg.receive_data_addr;		//Parity Error  
							}) 
endtask: body

task err_free_test_apbuart::body();
	apbuart_sq 	= apb_transaction::type_id::create("apbuart_sq");
	cfg 		= uart_config::type_id::create("cfg");

	`uvm_do_with(apbuart_sq,{
	  						 apbuart_sq.PWRITE 	 == 1'b0;
                          	 apbuart_sq.PADDR  	 == cfg.receive_data_addr;	// Non-erroneous Data  
							}) 
endtask