interface apbuart_if (input PCLK, input PRESETn);

  //Signals Declaration 
    logic           PSELx;
    logic           PENABLE;
    logic           PWRITE;
    logic           Tx;
    logic           RX;
    logic           PREADY;
    logic           PSLVERR;
    logic [32-1:0]  PWDATA;
    logic [32-1:0]  PADDR;
    logic [32-1:0]  PRDATA;
	logic [47:0]	rec_temp;
    bit   [1:0] 	fpn_flag;

  //clocking blocks
  clocking driver_cb @(posedge PCLK);
    default input #1 output #1;	
	output 	PSELx;
	output 	PENABLE;
	output 	PWRITE;
	output 	PWDATA;
	output 	PADDR;
	output 	RX;
 	input  	PRDATA;
	input  	PREADY;
	input  	PSLVERR;
	input	Tx;
  endclocking
  
  clocking monitor_cb @(posedge PCLK);
    default input #1 output #1;
	input	PSELx;
	input	PENABLE;
	input	PWRITE;
	input	PWDATA;
	input	PADDR;
	input	RX;
 	input	PRDATA;
	input	PREADY;
	input	PSLVERR;
	input	Tx;  
  endclocking
  
  //modports
  modport DRIVER  (clocking driver_cb ,input PCLK,PRESETn);
  modport MONITOR (clocking monitor_cb,input PCLK,PRESETn);

endinterface
