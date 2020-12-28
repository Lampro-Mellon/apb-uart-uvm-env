module uart_rx_BB (
		input	logic			rx_tick,
		input	logic			PRESETn,
		input	logic			RX,
		input	logic	[3:0]		frame_length,
		input	logic			stop_bit,
		input	logic	[1:0]		parity,
		input	logic			RX_detect,
	
		output	logic	[`DATA_WIDTH-1:0] rx_data_out,
		output	logic			  rx_done,
		output	logic			  prx_error
);

localparam	IDLE    		=	3'b000,	 
			RX_START_BIT 	=	3'b001,	
			RX_DATA_BITS 	=	3'b010,
			RX_PARITY	    =	3'b011,	 
			RX_STOP_BIT1	=	3'b100,		
			RX_STOP_BIT2	=	3'b101,
			RX_DONE_STATE	= 	3'b110;
			
logic		[2:0]	p_state, n_state;
logic		[7:0]	parity_temp;
logic		[3:0]	tick_count = 0;
logic		[5:0]	index_count = 0;
logic		[3:0] 	bit_count = 0;
logic		[31:0]	store_data = 0;
logic			found_15 = 0;
logic			parity_clear;
logic			stop_done;
logic			count_enable;
logic			bit_enable;
logic			index_enable;
logic			bit_count_rst;
logic			index_cnt_oprtr;	
logic			Start_Bit_Detected;
logic			done;
logic			parity_detected;
logic			no_parity;
logic			start_bit_detected;
logic			parity_enable;
logic			Sec_Stop_Detected;
logic			Stop_Bit2_To_Start;
logic			done_two;
logic 			parity_check;
logic 			rx_error;
logic			p_error;


assign parity_enable      = parity[1];
assign Start_Bit_Detected = (p_state == RX_STOP_BIT1 && tick_count == 15 && index_count < (`DATA_WIDTH) && ~stop_bit && ~RX ); 
assign done               = (p_state == RX_STOP_BIT1 && tick_count == 15 && index_count >= (`DATA_WIDTH-1) && ~stop_bit);
assign parity_detected    = (p_state == RX_DATA_BITS && tick_count == 15 &&  (bit_count ==	frame_length - 1)  && parity_enable);	
assign no_parity          = (p_state == RX_DATA_BITS && tick_count == 15 &&  (bit_count ==	frame_length - 1)  && ~parity_enable);
assign start_bit_detected = (p_state == IDLE && RX_detect && ~RX);	
assign Sec_Stop_Detected  = (p_state == RX_STOP_BIT1 && tick_count == 15  && stop_bit);
//assign Stop_Bit2_To_Start = (p_state == RX_STOP_BIT2 && tick_count == 15 && index_count < (`DATA_WIDTH-1)  && ~RX); 
assign Stop_Bit2_To_Start = (p_state == RX_STOP_BIT2 && tick_count == 15 && index_count < (`DATA_WIDTH-1)  && ~RX); 
assign done_two		  = (p_state == RX_STOP_BIT2 && tick_count == 15 && index_count >= (`DATA_WIDTH-1) );
//assign  CTS_RX	=	( (p_state == IDLE) && (rts_cts_enable) && RX_detect)?(1'b1):(1'bx);		//( (current_state == IDLE) && (TX_detect) )

assign prx_error = p_error;

//------------------------------------State register------------------------------------
always @(posedge rx_tick or negedge PRESETn)
begin: state_mem
	p_state <= (~PRESETn)?(IDLE):(n_state); 
end: state_mem

// Logic for receiver Error
always @(posedge rx_tick or negedge PRESETn)
begin: rcv_error_reg
    if(~PRESETn || p_state == IDLE)
        p_error <= 1'b0 ;
    else if (rx_error)
        p_error <= 1'b1;
    else
        p_error <= p_error;
end: rcv_error_reg
//-------------------------------------------------

//------------------------------------Next State Comb Logic--------------------------
always @(*)
begin:next_state_logic
case(p_state)
			IDLE:
			begin
				n_state = (start_bit_detected)?(RX_START_BIT):(IDLE);
			end

			RX_START_BIT:
				begin
					if(tick_count == 7)	
							n_state		=	RX_DATA_BITS;
					else if	(tick_count == 7 && RX)					//START MIDDLE NOT FOUND
							n_state		=	IDLE;
					else	
							n_state		=	RX_START_BIT;
				end
		
			RX_DATA_BITS:
				begin
					n_state	= (parity_detected)?(RX_PARITY):( (no_parity) ?(RX_STOP_BIT1):(RX_DATA_BITS));			
				end	

			RX_PARITY:
				begin
					n_state	= (tick_count == 15)?(RX_STOP_BIT1):(RX_PARITY);
				end
				
			RX_STOP_BIT1:
				begin
					n_state = (Start_Bit_Detected)?(RX_START_BIT):( (done)?(RX_DONE_STATE):( (Sec_Stop_Detected)?(RX_STOP_BIT2):(RX_STOP_BIT1)));	
				end
 			
			RX_STOP_BIT2:
				begin
					n_state = (Stop_Bit2_To_Start)?(RX_START_BIT):( (done_two)?(RX_DONE_STATE):(RX_STOP_BIT2));
				end			

			RX_DONE_STATE:
				begin
						n_state			=	IDLE;
				end
			default:
						n_state			=	IDLE;
endcase
end:next_state_logic

//------------------------------------------------------Output Logic--------------------------
always @(*)
begin
	case(p_state)
		IDLE:
			begin
				{rx_done, rx_error, count_enable, parity_check, bit_enable, index_enable, stop_done, parity_clear  } = 1'b0;
				rx_data_out		=	'dx;
				index_cnt_oprtr	=	1;
				bit_count_rst	=	1;
			end
		RX_START_BIT:
			begin	
				rx_done			=	1'b0;
				rx_error		=	1'b0;
				rx_data_out		=	'dx;
				bit_count_rst	=	1;	
				parity_check 	= 0;
				bit_enable		=	1'b0;
				index_enable	=	1'b1;
				stop_done		=	1'b0;	
				index_cnt_oprtr	=	0;
				parity_clear	=	1;
			
				if (tick_count  == 7)
					count_enable	=	1'b0;
				else
					count_enable	=	1'b1;
			end			
		RX_DATA_BITS:
			begin
				rx_done			=	0;
				rx_error		=	1'b0;
				rx_data_out		=	'dx;
				parity_clear	=	0;
				bit_count_rst	=	0;
				parity_check 	=	0;					
				bit_enable		=	1;
				index_enable	=	1;
				index_cnt_oprtr	=	0;				
				stop_done		=	0;

				if (tick_count  == 15)
					count_enable	=	0;
				else
					count_enable	=	1;
			end
	
		RX_PARITY:
			begin
				rx_done			=	0;
				parity_clear	=	0;				
				rx_data_out		=	'dx;
				bit_enable		=	0;
				bit_count_rst	=	1;
				index_enable	=	0;
				index_cnt_oprtr	=	0;
				stop_done		=	0;

				case (parity)	//check parity
					2'b10:
						parity_check	=  ~^(parity_temp); 
						
					2'b11:
						parity_check	=  ^parity_temp; 
					default:
						parity_check	=	0;
				endcase

				if (tick_count  == 15 )	
				begin
					if (parity_check != RX ) begin //for parity check
						rx_error	=	1'b1;
					end
					else begin  
						rx_error	=	1'b0;
					end	
						count_enable=	0;
				end
				else
				begin
					count_enable	=	1;
					rx_error		=	1'b0;
				end
			end
			
		RX_STOP_BIT1:
			begin
				rx_done			=	0;
				parity_clear	=	0;
				index_cnt_oprtr	=	0;
				rx_data_out		=	'dx;
				bit_enable		=	0;
				bit_count_rst	=	1;
				index_enable	=	0;
				rx_error		=	1'b0;
				parity_check	=	0;
				
				if (tick_count  == 15)
				begin
					count_enable	=	0;
					//stop_done		=	1;
					stop_done		=	stop_bit ? 0 : 1;
				end
				else
				begin
					count_enable	=	1;
					stop_done	=	0;
				end

				if (tick_count  == 14) begin
                    if(RX != 1'b1) begin
                        rx_error = 1'b1;
                    end else begin
                        rx_error = 1'b0;
                    end
				end

			end
		
		RX_STOP_BIT2:
			begin
				rx_done			=	0;
				rx_error		=	1'b0;
				rx_data_out		=	'dx;
				parity_check = 0;				
				bit_enable		=	0;
				index_enable	=	0;
				bit_count_rst	=	1;	
				index_cnt_oprtr		=	0;
				parity_clear	=	0;
			
				if (tick_count  == 15)
				begin
					count_enable	=	0;
					stop_done		=	1;
				end
				else
				begin
					count_enable	=	1;
					stop_done	=	0;
				end
				
				if (tick_count  == 14) begin
                    if(RX != 1'b1) begin
                        rx_error = 1'b1;
                    end 
					else begin
                        rx_error = 1'b0;
                    end
				end
			end
		RX_DONE_STATE:
			begin
						stop_done		=	0;
						parity_clear	=	0;
						rx_done			=	1;
						rx_error		=	1'b0;
						rx_data_out		= 	store_data;
						count_enable	=	0;
						bit_enable		=	0;
						index_enable	=	0;
						bit_count_rst	=	1;
						parity_check 	= 0;
						index_cnt_oprtr	=	1;
			end
		default:
			begin
				rx_done			=	0;
				rx_error		=	1'b0;
				rx_data_out		=	'dx;
				parity_clear	=	0;
				bit_count_rst	=	1;		
				count_enable 	=	0;
				bit_enable		=	0;
				index_enable	=	0;
				stop_done		=	0;
				parity_check 	= 	0;
				index_cnt_oprtr	=	0;
			end			
	endcase
end

//--------------------------------------Counters----------------------------------//
always @ (posedge rx_tick)
begin
	if(count_enable)
		tick_count 	<=	tick_count + 1'b1;	
	else if(stop_done)	
		tick_count	<=	tick_count;
	else
		tick_count	<=	0;

	if (tick_count	==	15 && ~stop_done)
			found_15	<=	1'b1;
	else
			found_15		<=	0;

	if(index_enable && found_15)
		index_count	<=	index_count + 1'b1;
	else if(index_cnt_oprtr)
			index_count	<=	0;
	else
		index_count	<=	index_count;

	if(bit_enable)
	begin
		store_data[index_count]	<=	RX;	
		parity_temp[bit_count]	<=	RX;
	end
	else if(index_cnt_oprtr)
			store_data	<=	'bx;
	else if(parity_clear)
		parity_temp		<=	'b0;
	else
		store_data	<=	store_data;

	if(~bit_count_rst && tick_count == 15)
			bit_count		<=	bit_count + 1'b1;
	else if(bit_count_rst)
			bit_count		<=	0;
	else
			bit_count		<=	bit_count;		
		
end


endmodule
