
class uart_sequence extends uvm_sequence#(uart_transaction);
	// class registration with factory
	`uvm_object_utils(uart_sequence)

	// Constructor Define Method
	function new (string name = "uart_sequence");
	    super.new(name);
	endfunction

	// transaction declaration 
	uart_transaction uart_sq;
    
    // Virtual Task Body Function
    virtual task body();
    	uart_sq = uart_transaction::type_id::create("uart_sq"); 	// create the transaction item
    	wait_for_grant();												// Blocks until get next item calls by driver 
    	uart_sq.randomize();											// randomize the transaction
    	send_request(uart_sq);										// send the request to driver
    	wait_for_item_done(); 											// this will blocks the execution until it get response from driver
    endtask
endclass

class fe_test_uart extends uvm_sequence#(uart_transaction);
	`uvm_object_utils(fe_test_uart)
	uart_transaction uart_sq;
  
	function new(string name = "fe_test_uart");
		super.new(name);
  endfunction: new
  
  //Test pattern
	virtual task body();
    	uart_sq = uart_transaction::type_id::create("uart_sq");
		`uvm_do_with(uart_sq,{
									uart_sq.fpn_flag  == 2'h1;  
									uart_sq.rec_temp  == 48'h8AA8AA8AA8AA;		//framing Error
								}) 
  	endtask: body
endclass: fe_test_uart

class pe_test_uart extends uvm_sequence#(uart_transaction);
	`uvm_object_utils(pe_test_uart)
  uart_transaction uart_sq;
  
	function new(string name = "pe_test_uart");
    super.new(name);
  endfunction: new
  
  //Test pattern
  	virtual task body();
    	uart_sq = uart_transaction::type_id::create("uart_sq");
		`uvm_do_with(uart_sq,{
									uart_sq.fpn_flag  == 2'h2;  
									uart_sq.rec_temp  == 48'hEAAEAAEAAEAA;		//Parity Error  
								}) 
 	endtask: body
endclass: pe_test_uart


class err_free_test_uart extends uvm_sequence#(uart_transaction);
	`uvm_object_utils(err_free_test_uart)
  uart_transaction uart_sq;
  
	function new(string name = "err_free_test_uart");
    	super.new(name);
  endfunction: new
  
	//Test pattern
  	virtual task body();
  		uart_sq = uart_transaction::type_id::create("uart_sq");
			`uvm_do_with(uart_sq,{
									uart_sq.fpn_flag  == 2'h3;  
									uart_sq.rec_temp  == 48'hCAACAACAACAA;		// Non-erroneous Data  
								}) 
  	endtask
endclass: err_free_test_uart
