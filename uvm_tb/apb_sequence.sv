class config_apbuart extends uvm_sequence #(apbuart_transaction);
	`uvm_object_utils (config_apbuart)
    apbuart_transaction apbuart_sq; 
    function new (string name = "config_apbuart");
        super.new (name);
    endfunction
     
    virtual task body();
       	apbuart_sq = apbuart_transaction::type_id::create("apbuart_sq");
	// Write data for Configuring the registers	   
      	`uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE == 1'b1;
                              		apbuart_sq.PADDR  == 32'd0;
                              		apbuart_sq.PWDATA == 32'd9600;
                              	})
      
    	`uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE == 1'b1;
                              		apbuart_sq.PADDR  == 32'd1;
                              		apbuart_sq.PWDATA == 32'd8;
                              	})
    
        `uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE == 1'b1;
                              		apbuart_sq.PADDR  == 32'd2;
                              		apbuart_sq.PWDATA == 32'd3;
                              	})
      
        `uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE == 1'b1;
                              		apbuart_sq.PADDR  == 32'd3;
                              		apbuart_sq.PWDATA == 32'd1;
                              	})
	// Read data to check the configured registers							  

		`uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE == 1'b0;
                              		apbuart_sq.PADDR  == 32'd0;
                              	})
      
    	`uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE == 1'b0;
                              		apbuart_sq.PADDR  == 32'd1;
                              	})
    
        `uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE == 1'b0;
                              		apbuart_sq.PADDR  == 32'd2;
                              	})
      
        `uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE == 1'b0;
                              		apbuart_sq.PADDR  == 32'd3;
                              	})
    endtask
endclass

class transmit_single_beat extends uvm_sequence #(apbuart_transaction);
	
	`uvm_object_utils (transmit_single_beat)
	apbuart_transaction apbuart_sq; 

    function new (string name = "transmit_single_beat");
        super.new (name);
    endfunction

    // Transmit bit by bit 
    virtual task body();
        apbuart_sq = apbuart_transaction::type_id::create("apbuart_sq");
		`uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE == 1'b1;
                              		apbuart_sq.PADDR  == 32'd4;
									apbuart_sq.PWDATA == 32'hFCBDABCD;  
                              	}) 
	endtask  
endclass

class rec_reg_test extends uvm_sequence#(apbuart_transaction);
	`uvm_object_utils(rec_reg_test)
  	apbuart_transaction	apbuart_sq;
  
  	function new(string name = "rec_reg_test");
  		super.new(name);
  	endfunction: new
  
  //Test pattern
	virtual task body();
		apbuart_sq = apbuart_transaction::type_id::create("apbuart_sq");
    	`uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE == 1'b0;
                              		apbuart_sq.PADDR  == 32'd5;
                              	}) 
  	endtask: body
endclass: rec_reg_test

class fe_test_apbuart extends uvm_sequence#(apbuart_transaction);
	`uvm_object_utils(fe_test_apbuart)
	apbuart_transaction apbuart_sq;
  
	function new(string name = "fe_test_apbuart");
		super.new(name);
  	endfunction: new
  
  //Test pattern
	virtual task body();
    	apbuart_sq = apbuart_transaction::type_id::create("apbuart_sq");
		`uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE 	 == 1'b0;
                              		apbuart_sq.PADDR  	 == 32'd5;    //framing Error  
								}) 
  	endtask: body
endclass: fe_test

class pe_test_apbuart extends uvm_sequence#(apbuart_transaction);
	`uvm_object_utils(pe_test_apbuart)
  	apbuart_transaction apbuart_sq;
  
	function new(string name = "pe_test_apbuart");
    	super.new(name);
  	endfunction: new
  
  //Test pattern
  	virtual task body();
    	apbuart_sq = apbuart_transaction::type_id::create("apbuart_sq");
		`uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE 	 == 1'b0;
                              		apbuart_sq.PADDR  	 == 32'd5;		//Parity Error  
								}) 
 	endtask: body
endclass: pe_test


class err_free_test_apbuart extends uvm_sequence#(apbuart_transaction);
	`uvm_object_utils(err_free_test_apbuart)
  	apbuart_transaction apbuart_sq;
  
	function new(string name = "err_free_test_apbuart");
    	super.new(name);
  	endfunction: new
  
	//Test pattern
  	virtual task body();
    	apbuart_sq = apbuart_transaction::type_id::create("apbuart_sq");
		`uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE 	 == 1'b0;
                              		apbuart_sq.PADDR  	 == 32'd5;	// Non-erroneous Data  
								}) 
  	endtask
endclass: err_free_test