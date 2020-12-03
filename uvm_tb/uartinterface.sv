interface uart_if (input PCLK , input PRESETn);

  //Signals Declaration 
    logic           Tx;
    logic           RX;

  //clocking blocks
  clocking driver_cb @(posedge PCLK);
    default input #1 output #1;	
	output 	RX;
  endclocking
  
  clocking monitor_cb @(posedge PCLK);
    default input #1 output #1;
	input	Tx;  
  endclocking
  
  //modports
  modport DRIVER  (clocking driver_cb , input PCLK,PRESETn);
  modport MONITOR (clocking monitor_cb , input PCLK,PRESETn);

endinterface
