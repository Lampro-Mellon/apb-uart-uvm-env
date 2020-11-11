
class apbuart_sequence extends uvm_sequence#(apbuart_transaction);
	// class registration with factory
	`uvm_object_utils(apbuart_sequence)

	// Constructor Define Method
	function new (string name = "apbuart_sequence");
	    super.new(name);
	endfunction

	// transaction declaration 
	apbuart_transaction apbuart_sq;
    
    // Virtual Task Body Function
    virtual task body();
    	apbuart_sq = apbuart_transaction::type_id::create("apbuart_sq"); 	// create the transaction item
    	wait_for_grant();												// Blocks until get next item calls by driver 
    	apbuart_sq.randomize();											// randomize the transaction
    	send_request(apbuart_sq);										// send the request to driver
    	wait_for_item_done(); 											// this will blocks the execution until it get response from driver
    endtask
endclass

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

class fe_test extends uvm_sequence#(apbuart_transaction);
	`uvm_object_utils(fe_test)
	apbuart_transaction apbuart_sq;
  
	function new(string name = "fe_test");
		super.new(name);
  	endfunction: new
  
  //Test pattern
	virtual task body();
    	apbuart_sq = apbuart_transaction::type_id::create("apbuart_sq");
		`uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE 	 == 1'b0;
                              		apbuart_sq.PADDR  	 == 32'd5;
									apbuart_sq.fpn_flag  == 2'h1;  
									apbuart_sq.rec_temp  == 48'h8AA8AA8AA8AA;		//framing Error  
								}) 
  	endtask: body
endclass: fe_test

class pe_test extends uvm_sequence#(apbuart_transaction);
	`uvm_object_utils(pe_test)
  	apbuart_transaction apbuart_sq;
  
	function new(string name = "pe_test");
    	super.new(name);
  	endfunction: new
  
  //Test pattern
  	virtual task body();
    	apbuart_sq = apbuart_transaction::type_id::create("apbuart_sq");
		`uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE 	 == 1'b0;
                              		apbuart_sq.PADDR  	 == 32'd5;
									apbuart_sq.fpn_flag  == 2'h2;  
									apbuart_sq.rec_temp  == 48'hEAAEAAEAAEAA;		//Parity Error  
								}) 
 	endtask: body
endclass: pe_test


class err_free_test extends uvm_sequence#(apbuart_transaction);
	`uvm_object_utils(err_free_test)
  	apbuart_transaction apbuart_sq;
  
	function new(string name = "err_free_test");
    	super.new(name);
  	endfunction: new
  
	//Test pattern
  	virtual task body();
    	apbuart_sq = apbuart_transaction::type_id::create("apbuart_sq");
		`uvm_do_with(apbuart_sq,{
		  							apbuart_sq.PWRITE 	 == 1'b0;
                              		apbuart_sq.PADDR  	 == 32'd5;
									apbuart_sq.fpn_flag  == 2'h3;  
									apbuart_sq.rec_temp  == 48'hCAACAACAACAA;		// Non-erroneous Data  
								}) 
  	endtask
endclass: err_free_test
