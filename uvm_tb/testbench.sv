module tbench_top;

  bit PCLK=0;
  bit PRESETn;

  always #5 PCLK = ~PCLK;
  
  initial begin
    PRESETn 	= 0;
    #10 PRESETn = 1;
  end

  apbuart_if vif (PCLK,PRESETn);

  apb_uart_top  DUT (
                 	.PCLK(vif.PCLK),
                 	.PRESETn(vif.PRESETn),
	             	.PSELx(vif.PSELx),
	             	.PENABLE(vif.PENABLE),
	             	.PWRITE(vif.PWRITE),
	             	.Tx(vif.Tx),
	             	.RX(vif.RX),
	             	.PREADY(vif.PREADY),
	             	.PSLVERR(vif.PSLVERR),
	             	.PWDATA(vif.PWDATA),
	             	.PADDR(vif.PADDR),
	             	.PRDATA(vif.PRDATA)
                	);
  initial 
  begin 
    uvm_config_db # (virtual apbuart_if)::set(uvm_root::get(),"*","vif",vif);
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
   
  initial
    run_test(); // built in func...you can give test name as argument

endmodule
