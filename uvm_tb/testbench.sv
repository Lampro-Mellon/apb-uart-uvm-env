module tbench_top;

  bit PCLK=0;
  bit PRESETn;

  always #5 PCLK = ~PCLK;
  
  initial begin
    PRESETn 	  = 1;
    #10
    PRESETn 	  = 0;
    #10 PRESETn = 1;
  end

  apb_if  vifapb  (PCLK,PRESETn);
  uart_if vifuart (PCLK,PRESETn);

  apb_uart_top  DUT (
                 	  .PCLK(vifapb.PCLK),
                 	  .PRESETn(vifapb.PRESETn),
	             	    .PSELx(vifapb.PSELx),
	             	    .PENABLE(vifapb.PENABLE),
	             	    .PWRITE(vifapb.PWRITE),
	             	    .Tx(vifuart.Tx),
	             	    .RX(vifuart.RX),
	             	    .PREADY(vifapb.PREADY),
	             	    .PSLVERR(vifapb.PSLVERR),
	             	    .PWDATA(vifapb.PWDATA),
	             	    .PADDR(vifapb.PADDR),
	             	    .PRDATA(vifapb.PRDATA)
                	  );
  initial 
  begin 
    uvm_config_db # (virtual apb_if)::set(uvm_root::get(),"*","vifapb",vifapb);
    uvm_config_db # (virtual uart_if)::set(uvm_root::get(),"*","vifuart",vifuart);
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
   
  initial
    run_test(); // built in func...you can give test name as argument

endmodule
