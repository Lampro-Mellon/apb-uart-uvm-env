//`include "Defines.sv"
//`include "apb_slave.sv"
//`include "apb_uart.sv"
module apb_uart_top (
	 input logic PCLK,
	 input logic PRESETn,
	 input logic PSELx,
	 input logic PENABLE,
	 input logic PWRITE,
	 input logic [`DATA_WIDTH-1 : 0]	PWDATA,
	 input logic [`ADDR_WIDTH-1 : 0]	PADDR,
	 input logic 						RX,

 	 output logic [`DATA_WIDTH-1 : 0]	PRDATA,
	 output logic 						PREADY,
	 output logic 						PSLVERR,
	 output	logic						Tx

);

logic		TX_detect_apb;
logic		RX_detect_apb;
logic		config_read_detect_apb;
logic 		config_write_detect_apb;
logic 		error_uart;
logic 		ready_uart;
logic [`ADDR_WIDTH-1 : 0] config_address_apb;
logic [`DATA_WIDTH-1 : 0] write_data_apb;
logic [`DATA_WIDTH-1 : 0] read_data_uart;

apb_slave	apb_slave_instance (.* ,
								. read_data(read_data_uart), 
								. error(error_uart), 
								. ready(ready_uart),
								. TX_detect(TX_detect_apb),
								. RX_detect(RX_detect_apb),
								. config_read_detect(config_read_detect_apb),
								. config_write_detect(config_write_detect_apb),
								. config_address(config_address_apb),
								. write_data(write_data_apb)

);

apb_uart	apb_uart_instance  (.* ,
 								.read_data(read_data_uart), 
								.error(error_uart),
								.ready(ready_uart),
								.TX_detect(TX_detect_apb),
								.RX_detect(RX_detect_apb),	
								.config_read_detect(config_read_detect_apb),
								.config_write_detect(config_write_detect_apb),
								.config_address(config_address_apb),
								.write_data_in(write_data_apb)
  );		
endmodule
