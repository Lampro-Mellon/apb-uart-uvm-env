//Defined Baud Rates	
	`define		BR_4800					4800
	`define		BR_9600					9600
	`define		BR_14400				14400
	`define		BR_19200				19200
	`define		BR_38400				38400
	`define		BR_57600				57600	
	`define		BR_115200				115200	
	`define		BR_128000				128000

//------------------Addresses of Registers-------------------------------
	`define		baud_config				'h00	
	`define		frame_config			'h04
	`define		parity_config			'h08
	`define		stop_bits_config		'h0c
	`define		trans_data				'h10
	`define		recv_data				'h14
//----------------------------------------------------
	`define  	DATA_WIDTH				32
	`define     ADDR_WIDTH				32
	`define 	BAUD_CONFIG_REG_SIZE	17          
//-----------------------------------------------------	
