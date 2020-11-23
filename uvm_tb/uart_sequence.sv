class recReg_test_uart extends uvm_sequence#(uart_transaction);
	`uvm_object_utils(recReg_test_uart)
	uart_transaction uart_sq;

	function new(string name = "recReg_test_uart");
		super.new(name);
  	endfunction: new

  	extern virtual task body();
endclass: recReg_test_uart

class fe_test_uart extends uvm_sequence#(uart_transaction);
	`uvm_object_utils(fe_test_uart)
	uart_transaction uart_sq;

	function new(string name = "fe_test_uart");
		super.new(name);
  	endfunction: new
	  
	extern virtual task body();
endclass: fe_test_uart

class pe_test_uart extends uvm_sequence#(uart_transaction);
	`uvm_object_utils(pe_test_uart)
  	uart_transaction uart_sq;

	function new(string name = "pe_test_uart");
    	super.new(name);
  	endfunction: new
	
	extern virtual task body();
endclass: pe_test_uart

class err_free_test_uart extends uvm_sequence#(uart_transaction);
	`uvm_object_utils(err_free_test_uart)
  	uart_transaction uart_sq;
  
	function new(string name = "err_free_test_uart");
    	super.new(name);
 	endfunction: new
  
	extern virtual task body();
endclass: err_free_test_uart

task recReg_test_uart::body();
	uart_sq = uart_transaction::type_id::create("uart_sq");
	`uvm_do(uart_sq);
endtask: body

task fe_test_uart::body();
    uart_sq = uart_transaction::type_id::create("uart_sq");
	`uvm_do_with(uart_sq,{
							uart_sq.bad_parity  == 1'b0;
							uart_sq.sb_corr 	== 1'b1;  
							uart_sq.payload  	== 32'hAA8AA8AA;		//framing Error
						 }) 
endtask: body

task pe_test_uart::body();
    uart_sq = uart_transaction::type_id::create("uart_sq");
	`uvm_do_with(uart_sq,{
							uart_sq.bad_parity  == 1'b1;
							uart_sq.sb_corr 	== 1'b0;  
							uart_sq.payload  	== 32'hAA8AA8AA;		//Parity Error  
						 }) 
endtask: body

task err_free_test_uart::body();
  	uart_sq = uart_transaction::type_id::create("uart_sq");
	`uvm_do_with(uart_sq,{
							uart_sq.bad_parity  == 1'b0;
							uart_sq.sb_corr 	== 1'b0;  
							uart_sq.payload  	== 32'hAA8AA8AA;		// Non-erroneous Data  
						 }) 
endtask
