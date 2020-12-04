module tbench_top;

  bit PCLK;
  bit PRESETn;

  clk_rst_interface vifclk(PRESETn, PCLK);
  apb_if            vifapb  (PCLK,PRESETn);
  uart_if           vifuart (PCLK,PRESETn);

  apb_uart_top  DUT (
                 	  .PCLK(PCLK),
                 	  .PRESETn(PRESETn),
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
	
  apbuart_property assertions (
                              	.PCLK(PCLK),
                 	        	.PRESETn(PRESETn),
	             	            .PSELx(vifapb.PSELx),
	             	            .PENABLE(vifapb.PENABLE),
	             	            .PWRITE(vifapb.PWRITE),
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
    uvm_config_db # (virtual clk_rst_interface)::set(uvm_root::get(),"*","vifclk",vifclk);
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end

  initial
    run_test(); // built in func...you can give test name as argument
endmodule