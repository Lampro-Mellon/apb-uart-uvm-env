module testbench #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 32
)
(
	`ifdef VIP_APB
		`ifdef VIP_CLK
		output logic 				t_PCLK,
    	output logic 				t_PRESETn,
		`else
		input logic 				t_PCLK,
    	input logic 				t_PRESETn,
		`endif
	output logic 					t_PSELx,
    output logic 					t_PENABLE,
    output logic 					t_PWRITE,
    output logic [DATA_WIDTH-1 : 0] t_PWDATA,
    output logic [ADDR_WIDTH-1 : 0] t_PADDR,
    `else
	input  logic 					t_PCLK,
    input  logic 					t_PRESETn,
    input  logic 					t_PSELx,
    input  logic 					t_PENABLE,
    input  logic 					t_PWRITE,
    input  logic [DATA_WIDTH-1 : 0] t_PWDATA,
    input  logic [ADDR_WIDTH-1 : 0] t_PADDR,
	`endif
	input  logic [DATA_WIDTH-1 : 0] t_PRDATA,
    input  logic            		t_PREADY,
    input  logic            		t_PSLVERR,
	output logic            		RX,
    input  logic            		Tx
);

  	bit pCLK;
  	bit pRESETn;

	`ifdef VIP_APB
  		assign t_PSELx  		=  	vifapb.PSELx;
  		assign t_PENABLE		=  	vifapb.PENABLE;
  		assign t_PWRITE 		=  	vifapb.PWRITE;
  		assign t_PWDATA 		=  	vifapb.PWDATA;
  		assign t_PADDR  		=  	vifapb.PADDR;
		`ifdef VIP_CLK
			assign t_PCLK 		= 	pCLK;
  			assign t_PRESETn 	= 	pRESETn;
			clk_rst_interface vifclk	(pRESETn, pCLK);
		`endif
	`else
		assign vifapb.PSELx  	=  	t_PSELx;
  		assign vifapb.PENABLE	=  	t_PENABLE;
  		assign vifapb.PWRITE 	=  	t_PWRITE;
  		assign vifapb.PWDATA 	=  	t_PWDATA;
  		assign vifapb.PADDR  	=  	t_PADDR;
	`endif
  	
	assign RX     			= vifuart.RX;
  	assign vifuart.Tx 		= Tx;
  	assign vifapb.PRDATA 	= t_PRDATA;
  	assign vifapb.PSLVERR 	= t_PSLVERR;
  	assign vifapb.PREADY 	= t_PREADY;
  
 	
  	apb_if  #(DATA_WIDTH,ADDR_WIDTH) vifapb  (t_PCLK,t_PRESETn); 
  	uart_if           				 vifuart (t_PCLK,t_PRESETn);

  	apbuart_property assertions (
                                .PCLK(t_PCLK),
                                .PRESETn(t_PRESETn),
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