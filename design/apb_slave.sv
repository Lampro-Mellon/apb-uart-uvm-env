
module apb_slave(
 	 /*Input Signals from APB Master*/
	 input logic PCLK,
	 input logic PRESETn,
	 input logic PSELx,
	 input logic PENABLE,
	 input logic PWRITE,
	 input logic [`DATA_WIDTH-1 : 0]	PWDATA,
	 input logic [`ADDR_WIDTH-1 : 0]	PADDR,
	 /*Input Signals from UART*/
	 input logic [`DATA_WIDTH-1 : 0]	read_data,
	 input logic 						error,
	 input logic 						ready,
 	 /*Output Signals to APB Master*/
	 output logic [`DATA_WIDTH-1 : 0]	PRDATA,
	 output logic 						PREADY,
	 output logic 						PSLVERR,
 	/*Output Signals to UART*/
	 output logic TX_detect,
	 output logic RX_detect,
	 output logic config_write_detect,
	 output logic config_read_detect,
	 output logic [`ADDR_WIDTH-1 : 0] config_address,
	 output logic [`DATA_WIDTH-1 : 0] write_data
);
	logic config_temp;

	assign  config_temp 		= (PADDR == `baud_config) || (PADDR == `frame_config) || (PADDR == `parity_config) || (PADDR == `stop_bits_config);
	assign 	TX_detect 			= PSELx && PENABLE && PWRITE 	 && (PADDR == `trans_data);
	assign 	RX_detect 			= PSELx && PENABLE && (~PWRITE)  && (PADDR == `recv_data);
	assign 	config_write_detect = PSELx && PENABLE && PWRITE && config_temp;
	assign 	config_read_detect  = PSELx && PENABLE && (~PWRITE) && config_temp;
	assign	config_address		= PADDR;
	assign  write_data			= PWDATA;
	assign	PRDATA				= read_data;//(PSELx && PENABLE)?read_data:'bz;
	assign 	PREADY				= ready;//(PSELx && PENABLE)?ready:1'bz;
	assign	PSLVERR				= error;//(PSELx && PENABLE)?error:1'bz;
endmodule
