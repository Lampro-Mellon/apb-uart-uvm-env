//`include "tick_generator.sv"
//`include "uart_rx_BB.sv"
//`include "uart_transmitter.sv"
module apb_uart
(
  input 	logic PCLK,
  input 	logic PRESETn,
  input 	logic [`DATA_WIDTH-1:0] write_data_in,
  input 	logic [`ADDR_WIDTH-1:0] config_address,
  input 	logic TX_detect,
  input		logic RX_detect,
  input		logic config_write_detect,
  input		logic config_read_detect,
  input		logic RX,

  output 	logic [((`DATA_WIDTH)-1):0] read_data,
  output 	logic ready,
  output 	logic error,
  output	logic Tx 
);

logic opt_done;
logic config_error;

//transmitter
logic TX_done;
logic TX_ERROR;
logic tx_tick_1;

// receiver
logic RX_done;
logic RX_ERROR;
logic RX_PERROR;
logic RX_tick_1; 

/*Output signals of configuration Registers*/
logic [((`BAUD_CONFIG_REG_SIZE)-1):0] BAUD_RATE;
logic [3:0] frame_length;
logic [1:0] parity_signal;
logic stop_bits;
//logic [((`DATA_WIDTH)-1):0]PRDATA_config;
//logic [((`DATA_WIDTH)-1):0] RX_PRDATA;
logic [((`DATA_WIDTH)-1):0] RX_DATA;



/*signals telling transaction type*/
logic baud_config_write_valid;
logic baud_config_read_valid;
logic frame_config_write_valid;
logic frame_config_read_valid;
logic parity_config_write_valid;
logic parity_config_read_valid;
logic SBITS_config_write_valid;
logic SBITS_config_read_valid;

/*Logic to determine transaction type from master*/
assign baud_config_write_valid 		=  config_write_detect && (config_address == `baud_config);
assign baud_config_read_valid 		=  config_read_detect  && (config_address == `baud_config);
assign frame_config_write_valid 	=  config_write_detect && (config_address == `frame_config);
assign frame_config_read_valid 		=  config_read_detect  && (config_address == `frame_config);
assign parity_config_write_valid 	=  config_write_detect && (config_address == `parity_config);
assign parity_config_read_valid 	=  config_read_detect  && (config_address == `parity_config);
assign SBITS_config_write_valid 	=  config_write_detect && (config_address == `stop_bits_config);
assign SBITS_config_read_valid 		=  config_read_detect  && (config_address == `stop_bits_config);

//-------------------------------Configuration Registers-----------------------------------//

/*baud rate configuration register: default BR = 9600 bps*/ 
reg [((`BAUD_CONFIG_REG_SIZE)-1):0] baud_config_reg;

/*Data frame length configuration register: default = 8 bits*/
reg [3:0] frame_length_reg;

/*Parity enable/type configuration register: default = disabled*/
reg [1:0] parity_enable_type_reg;

/*Stop bits configuration register: default = 1 bit*/
reg stop_bits_config_reg;

reg [31:0] receiver_reg;

//---------------------------------------------------------------------------------------//

assign BAUD_RATE		=	baud_config_reg;
assign frame_length 	=   frame_length_reg;
assign parity_signal	=	parity_enable_type_reg;
assign stop_bits		=	stop_bits_config_reg;
assign ready			=	opt_done || (TX_detect && TX_done );
//assign read_data		=	(RX_detect)?(RX_PRDATA):((config_read_detect)?(PRDATA_config):('bz));
always@(posedge PCLK)
	error			=   (RX_detect)? RX_PERROR:(config_error || TX_ERROR);
//--------------------writing and reading configuration registers----------------------//
always @ (posedge PCLK)  begin

	if (~PRESETn)begin
	baud_config_reg			<=	'd9600;
	frame_length_reg		<=	4'd8;
	parity_enable_type_reg	<=	2'd0;
	stop_bits_config_reg 	<= 	1'd0;
	config_error			<=	1'b0;
	opt_done				<=	1'b0;
	//PRDATA_config			<=	{`DATA_WIDTH{1'b0}};
	read_data				<=	{`DATA_WIDTH{1'b0}};
	end

/*Writing and Reading Baud Configuration Register*/
	else if (baud_config_write_valid) begin
	baud_config_reg	<=	write_data_in[(`BAUD_CONFIG_REG_SIZE-1):0];      
	opt_done		<=	1'b1;
	end

	else if (baud_config_read_valid)begin
		//PRDATA_config	<=	baud_config_reg;
		read_data		<=	baud_config_reg;
		opt_done		<=	1'b1;
	end

/*Writing and Reading Frame Configuration Register*/
else if (frame_config_write_valid)
begin
	frame_length_reg <=	write_data_in[3:0];       
	opt_done		 <=	1'b1;
end

else if (frame_config_read_valid)
begin
	//PRDATA_config	<=	frame_length_reg;
	read_data		<=	frame_length_reg;
	opt_done		<=	1'b1;
end

/*Writing and Reading Parity Configuration Register*/
else if (parity_config_write_valid)
begin
	parity_enable_type_reg 	<=	write_data_in[1:0];      
	opt_done		 		<=	1'b1;
end

else if (parity_config_read_valid)
begin
	//PRDATA_config	<=	parity_enable_type_reg;
	read_data		<=	parity_enable_type_reg;
	opt_done		<=	1'b1;
end

/*Writing and Reading Stop Bits Configuration Register*/
else if (SBITS_config_write_valid)
begin
	stop_bits_config_reg 	<=	write_data_in[0];         
	opt_done		 		<=	1'b1;
end

else if (SBITS_config_read_valid)
begin
	//PRDATA_config	<=	stop_bits_config_reg;
	read_data		<=	stop_bits_config_reg;
	opt_done		<=	1'b1;
end

/*Reading and Writing on Receiver Register*/
else if (RX_detect)
begin
//	RX_PRDATA	<=	receiver_reg;
	read_data	<=	receiver_reg;
	opt_done	<=	1'b1;
end
else if (RX_done)
begin
	receiver_reg 			<=	RX_DATA;
	RX_PERROR				<=	RX_ERROR;
end
else
begin
	baud_config_reg			<=	baud_config_reg;
	frame_length_reg		<=  frame_length_reg;
	parity_enable_type_reg	<=	parity_enable_type_reg;
	stop_bits_config_reg	<=	stop_bits_config_reg;
	opt_done				<=	1'b0;						
	//PRDATA_config			<=	'bz;         
	config_error 			<=	1'b0;
	read_data				<=	'bz;
end

end

/*Baud Rate Generator Module Instantiation*/
tick_generator BRG_instance (.clk(PCLK),
		   	 	 			 .resetn(PRESETn),
		         	 		 .baud_rate(BAUD_RATE),
		          	 		 .tx_tick(tx_tick_1),
							 .rx_tick(RX_tick_1)	       
							);

/*UART Transmitter Module Instantiation*/
uart_transmitter		 transmtr_instance 	(.tx_tick(tx_tick_1),
			    	 		 		.PRESETn (PRESETn),
			    			 		.write_data(write_data_in),
				     		 		.TX_detect(TX_detect),
							 		.frame_length(frame_length),
							 		.parity_signal(parity_signal),
							 		.stop_bits(stop_bits),		
			    	 		 		.TX_done (TX_done),
			     			 		.TX_ERROR (TX_ERROR),
			    	 		 		.Tx (Tx)
			       		   			);

/*UART receiver Module Instantiation*/
uart_rx_BB	receiver_instance	         (.rx_tick(RX_tick_1),
			    	 		 		  .PRESETn (PRESETn),
			    			 		  .RX(RX),
				     		 		  .RX_detect(1'b1),
							 		  .frame_length(frame_length),
							 		  .parity(parity_signal),
							 		  .stop_bit(stop_bits),		
			    	 		 		  .rx_done(RX_done),
			     			 		  .prx_error (RX_ERROR),
			    	 		 		  .rx_data_out(RX_DATA)
									);
endmodule
