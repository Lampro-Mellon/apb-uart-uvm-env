interface apb_if #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 32
)
(input PCLK, input PRESETn);

  //Signals Declaration 
    logic                   PSELx;
    logic                   PENABLE;
    logic                   PWRITE;
    logic                   PREADY;
    logic                   PSLVERR;
    logic [DATA_WIDTH-1:0]  PWDATA;
    logic [ADDR_WIDTH-1:0]  PADDR;
    logic [DATA_WIDTH-1:0]  PRDATA;

  //clocking blocks
  clocking driver_cb @(posedge PCLK);
    default input #1 output #1;	
	output 	PSELx;
	output 	PENABLE;
	output 	PWRITE;
	output 	PWDATA;
	output 	PADDR;
 	input  	PRDATA;
	input  	PREADY;
	input  	PSLVERR;
  endclocking
  
  clocking monitor_cb @(posedge PCLK);
    default input #1 output #1;
	input	PSELx;
	input	PENABLE;
	input	PWRITE;
	input	PWDATA;
	input	PADDR;
 	input	PRDATA;
	input	PREADY;
	input	PSLVERR;
  endclocking
  
  //modports
  modport DRIVER  (clocking driver_cb , input PCLK,PRESETn);
  modport MONITOR (clocking monitor_cb , input PCLK,PRESETn);

endinterface
