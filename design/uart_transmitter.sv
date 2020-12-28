module uart_transmitter	
(
	input	logic	tx_tick,
	input	logic	PRESETn,
	input   logic  	[`DATA_WIDTH-1:0] write_data,
	input   logic   TX_detect,
	input	logic	[3:0]frame_length,
	input	logic	[1:0]parity_signal,
	input	logic	stop_bits,
	output 	logic   TX_done,
	output 	logic   TX_ERROR,
	output	logic	Tx
						
);

/*Register to hold data to be serially trasmitted*/
	logic [`DATA_WIDTH+4-1 : 0] TX_DATA_REG;

/*Start bit is logic 0 and stop bit is logic 1*/
	logic start_bit = 1'b0;
	logic stop_bit  = 1'b1;

/* register to hold parity bits*/
	logic [6:0]	parity_bit;            							

/* Declaring states*/
	localparam 	IDLE         		 = 3'd0,
		   		TX_START_BIT   		 = 3'd1,
		   		TX_DATA_BITS   		 = 3'd2,
		   		TX_PARITY_BIT  		 = 3'd3,	
		  		TX_FIRST_STOP_BIT    = 3'd4,
				TX_SECOND_STOP_BIT   = 3'd5,
				TX_DONE				 = 3'd6;
		
	logic [2:0] current_state,
				next_state;

/*Counters*/
	logic [2:0] Tx_bit_count = 3'd0;
	logic [5:0] index_count  = 6'd0;
	logic [2:0] parity_count = 3'b0;						  	

/*parity enable*/
	logic  parity_enable;
	assign parity_enable = parity_signal[1];


//----------------Calculating parity bits according to frame length-----------------//
//----------------Calculating parity bits according to frame length-----------------//
//----------------Calculating parity bits according to frame length-----------------//

	always @ (posedge tx_tick) begin
		if (frame_length == 4'd5) begin
			case (parity_signal)
				2'b10:begin
					for (int n=0; n<7; n++)			  					
					parity_bit[n] <= (~^(TX_DATA_REG[n*5 +: 5]));
				end
				2'b11:begin
					for (int n=0; n<7; n++)			  					
					parity_bit[n] <= ^TX_DATA_REG[n*5 +: 5];
				end
				default:
					parity_bit <= 7'bx;
			endcase
		end

		else if (frame_length == 4'd6) begin
			case (parity_signal)
				2'b10:begin
					for (int n=0; n<6; n++)			  					
					parity_bit[n] <= (~^(TX_DATA_REG[n*6 +: 6]));
				end
				2'b11:begin
					for (int n=0; n<6; n++)			  					
					parity_bit[n] <= ^TX_DATA_REG[n*6 +: 6];
				end
				default:
					parity_bit <= 7'bx;
			endcase
		end

		else if (frame_length == 4'd7) begin
			case (parity_signal)
				2'b10:begin
					for (int n=0; n<5; n++)			  					
					parity_bit[n] <= (~^(TX_DATA_REG[n*7 +: 7]));
				end
				2'b11:begin
					for (int n=0; n<5; n++)			  					
					parity_bit[n] <= ^TX_DATA_REG[n*7 +: 7];
				end
				default:
					parity_bit <= 7'bx;
			endcase
		end
	
		else if (frame_length == 4'd8) begin
			case (parity_signal)
				2'b10:begin
					for (int n=0; n<4; n++)			  					
					parity_bit[n] <= (~^(write_data[n*8 +: 8]));
				end
				2'b11:begin
					for (int n=0; n<4; n++)			  					
					parity_bit[n] <= ^write_data[n*8 +: 8];
				end
				default:
					parity_bit <= 7'bx;
			endcase
		end

		else begin
			parity_bit	<=	7'bx;
		end
	end




//----------------------------STATE Register-----------------------------//
//----------------------------STATE Register-----------------------------//
//----------------------------STATE Register-----------------------------//
	always @ (posedge tx_tick or negedge PRESETn or negedge TX_detect) begin 
		if (!PRESETn || !TX_detect)
			current_state <= IDLE;			 
		else 
			current_state <= next_state;
	end
//----------------------------NEXT STATE LOGIC----------------------------//
//----------------------------NEXT STATE LOGIC----------------------------//
//----------------------------NEXT STATE LOGIC----------------------------//
	always@(*)begin 
		case (current_state)
			IDLE:begin
				if (TX_detect)
					next_state 	= TX_START_BIT;
				else
					next_state	= IDLE;
			end
			TX_START_BIT:begin 
					next_state	= TX_DATA_BITS;
			end	

			TX_DATA_BITS:begin
				if (Tx_bit_count < (frame_length-1))   
					next_state  = TX_DATA_BITS;
				else if ((Tx_bit_count == (frame_length-1)) &&  parity_enable)
					next_state  = TX_PARITY_BIT;
				else
					next_state  = TX_FIRST_STOP_BIT;
			end

			TX_PARITY_BIT:
					next_state  =  TX_FIRST_STOP_BIT;
		
			TX_FIRST_STOP_BIT:begin
				if (stop_bits)
					next_state  = TX_SECOND_STOP_BIT;
				else if (~stop_bits && (index_count < 31))
					next_state  = TX_START_BIT;
				else 
					next_state 	= TX_DONE;
			end

			TX_SECOND_STOP_BIT:begin
				if (index_count < 31)
					next_state 	= TX_START_BIT;
				else 
					next_state   = TX_DONE;	
			end

			TX_DONE:begin
		 			next_state  = IDLE;	
			end
			default:			
					next_state 	= IDLE;
		endcase 
	end	

//--------------------------------For Counters----------------------------------------//
//--------------------------------For Counters----------------------------------------//
//--------------------------------For Counters----------------------------------------//
	always @ (posedge tx_tick) begin 
		case (current_state)
			IDLE:begin
				Tx_bit_count	<= 3'd0;
				parity_count	<= 2'd0;
				index_count		<= 6'd0;	
				TX_DATA_REG 	<=  {(`DATA_WIDTH+4){1'b0}};
			end

			TX_START_BIT:begin 
				Tx_bit_count	<= 3'd0;
				parity_count	<= parity_count;
				index_count		<= index_count;
				TX_DATA_REG 	<= {1'b0, 1'b0,1'b0,1'b0,write_data};
			end
					
			TX_DATA_BITS:begin
				Tx_bit_count 	<= Tx_bit_count + 1'b1;
				index_count	 	<= index_count  + 1'b1;
				parity_count	<= parity_count;
			end

			TX_PARITY_BIT:begin			
				Tx_bit_count	<= 3'd0;
				index_count		<= index_count;
				parity_count	<= parity_count + 1'b1;
			end
						
			TX_FIRST_STOP_BIT:begin
				Tx_bit_count	<= 3'd0;
				index_count		<= index_count;
				parity_count	<= parity_count;					
			end

			TX_SECOND_STOP_BIT:begin
				Tx_bit_count	<= 3'd0;
				index_count		<= index_count;
				parity_count	<= parity_count; 
			end

			TX_DONE:begin
				Tx_bit_count	<= 3'd0;
				index_count		<= 6'd0;
				parity_count	<= 2'd0;
			end
			default:begin
				Tx_bit_count	<= 3'd0;
				parity_count	<= 2'd0;
				index_count		<= 6'd0;
				TX_DATA_REG 	<= {`DATA_WIDTH{1'b0}};
			end		
		endcase 				
	end
//----------------------------OUTPUT COMBINATIONAL LOGIC--------------------------//
//----------------------------OUTPUT COMBINATIONAL LOGIC--------------------------//
//----------------------------OUTPUT COMBINATIONAL LOGIC--------------------------//
	always @(*)begin
		case (current_state)
			IDLE:begin
				Tx	  		= 1'b1;
				TX_done		= 1'b0;
				TX_ERROR	= 1'b0;
			end

			TX_START_BIT:begin
				Tx	 		= start_bit;
				TX_done		= 1'b0;
				TX_ERROR	= 1'b0;
			end

			TX_DATA_BITS:begin
				Tx 			= TX_DATA_REG[index_count];
				TX_done		= 1'b0;
				TX_ERROR	= 1'b0;
			end

			TX_PARITY_BIT:begin
				Tx 	 		= parity_bit[parity_count];               
				TX_done		= 1'b0;
				TX_ERROR	= 1'b0;
			end

			TX_FIRST_STOP_BIT:begin
				Tx			= stop_bit;
				TX_done		= 1'b0;
				TX_ERROR	= 1'b0;
			end
	
			TX_SECOND_STOP_BIT:begin
				Tx			= stop_bit;
		 		TX_done		= 1'b0;
		 		TX_ERROR	= 1'b0; 
			end
			TX_DONE:begin
				Tx			= stop_bit;
		 		TX_done		= 1'b1;
		 		TX_ERROR	= 1'b0; 
			end
			default:begin
				Tx	  		= 1'b1;
				TX_done		= 1'b0;
				TX_ERROR	= 1'b0;			
			end
		endcase
	end
endmodule


