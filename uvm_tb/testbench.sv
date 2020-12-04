module testbench (
    output logic 			PCLK,
    output logic 			PRESETn,
    output logic 			PSELx,
    output logic 			PENABLE,
    output logic 			PWRITE,
    output logic [32-1 : 0] PWDATA,
    output logic [32-1 : 0] PADDR,
    output logic            RX,
    input  logic [32-1 : 0] PRDATA,
    input  logic            PREADY,
    input  logic            PSLVERR,
    input  logic            Tx
);

  	bit pCLK;
  	bit pRESETn;

  	assign PCLK 	= 	pCLK;
  	assign PRESETn 	= 	pRESETn;

  	assign PSELx  	=  	vifapb.PSELx;
  	assign PENABLE	=  	vifapb.PENABLE;
  	assign PWRITE 	=  	vifapb.PWRITE;
  	assign PWDATA 	=  	vifapb.PWDATA;
  	assign PADDR  	=  	vifapb.PADDR;
  	assign RX     	=  	vifuart.RX;

  	assign vifuart.Tx 		= Tx;
  	assign vifapb.PRDATA 	= PRDATA;
  	assign vifapb.PSLVERR 	= PSLVERR;
  	assign vifapb.PREADY 	= PREADY;
  
 	clk_rst_interface vifclk	(pRESETn, pCLK);
  	apb_if            vifapb  	(PCLK,PRESETn);
  	uart_if           vifuart 	(PCLK,PRESETn);

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