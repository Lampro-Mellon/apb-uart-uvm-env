module tick_generator
#(
parameter IP_BAUD_RATE_VALUE = 17,		//17 Bits Due to  Baud Rate ConfigureAble UpTo ==> 128000 
parameter TX_CLOCK_COUNT_REG = 14,		//Bcz Max Clock Count will be 10416(For Transmitter)(2^14=16384)
parameter RX_CLOCK_COUNT_REG = 11		//Bcz Max Clock Count will be 1302 (For Receiver)(2^11=2048)
) 
(
//InPut Signals
	input wire								clk			, 	// Clock input
	input wire								resetn		, 	// Reset input
	input wire[(IP_BAUD_RATE_VALUE-1):0]	baud_rate	, 	// Value to divide the generator by
//OutPut Signal
		// Each "(Clk/(BaudRate*16))" pulses we create a tick pulse	
	output wire								tx_tick,	  		// Each "BaudRate" pulses we create a tick pulse
	output wire								rx_tick	  		
);
	 
	
//Register's for Counters(Tx & Rx)
	reg[(TX_CLOCK_COUNT_REG-1):0]			tx_clk_count;	// For Transmitter's Counter (14)
	reg[(RX_CLOCK_COUNT_REG-1):0]			rx_clk_count;	// For Receiver's Counter (11)

//Registers that will Hold Value How Much to Count (For Comparison)
	reg[(TX_CLOCK_COUNT_REG-1):0]			tx_reg;			// Register to store Configured Clock Count Value (14)
	reg[(RX_CLOCK_COUNT_REG-1):0]			rx_reg;			// Register to store Configured Clock Count Value (11)

	reg[(TX_CLOCK_COUNT_REG-1):0]           tx_reg_prev; // to store previous value
    reg[(RX_CLOCK_COUNT_REG-1):0]           rx_reg_prev; // to store previous value
	
	always@(posedge clk) begin
        if(!resetn)begin
            rx_reg_prev <= {RX_CLOCK_COUNT_REG{1'b0}};
            tx_reg_prev <= {TX_CLOCK_COUNT_REG{1'b0}};
        end//if
		else begin
        	rx_reg_prev     <= rx_reg;
        	tx_reg_prev     <= tx_reg;
		end
    end

	always@(posedge clk) begin
    	if(!resetn)begin
    	    rx_clk_count<= {RX_CLOCK_COUNT_REG{1'b0}};
    	    tx_clk_count<= {TX_CLOCK_COUNT_REG{1'b0}};
    	end//if
    	else begin
    	    if(rx_tick )
    	        rx_clk_count<= {RX_CLOCK_COUNT_REG{1'b0}};
    	    else begin
    	        if(rx_reg != rx_reg_prev)
    	        rx_clk_count<= 'b1;
    	        else
    	        rx_clk_count <= rx_clk_count + 1'b1;
    	    end
    	    if(tx_tick )
    	        tx_clk_count<= {TX_CLOCK_COUNT_REG{1'b0}};
    	    else begin
    	        if(tx_reg != tx_reg_prev)
    	            tx_clk_count<= 'b1;
    	        else
    	            tx_clk_count <= tx_clk_count + 1'b1;
    	    end
    	end//else
    end//always

//Case to Drive Input Values on Baud Rate Register (Receiver and Transmitter)
	always@(posedge clk) begin
		if(!resetn)begin
			rx_reg <= {RX_CLOCK_COUNT_REG{1'b0}};
			tx_reg <= 14'd5208;
			end//if
		else begin 		
			case(baud_rate)
				`BR_4800  :	begin rx_reg <=11'd651;
								  tx_reg <=14'd10416;	end
				`BR_9600  : begin rx_reg <=11'd325;
							  	  tx_reg <=14'd5208;	end
				`BR_14400 : begin rx_reg <=11'd217;
						 	 	  tx_reg <=14'd3472;	end
				`BR_19200 : begin rx_reg <=11'd163;
							  	  tx_reg <=14'd2604;	end
				`BR_38400 : begin rx_reg <=11'd81;
						 	 	  tx_reg <=14'd1302;	end
				`BR_57600 : begin rx_reg <=11'd54;
							  	  tx_reg <=14'd868;		end 						
				`BR_115200: begin rx_reg <=11'd27;
							 	  tx_reg <=14'd434;		end
				`BR_128000: begin rx_reg <=11'd24;
							  	  tx_reg <=14'd392;		end
				 default:	begin rx_reg <=11'd325;
							  	  tx_reg <=14'd5208;	end
			endcase
		end//else
	end//always

//OutPut Assignment
	assign tx_tick = (resetn==1'b0)?1'b0:(tx_clk_count==tx_reg)?1'b1:1'b0;
	assign rx_tick = (resetn==1'b0)?1'b0:(rx_clk_count==rx_reg)?1'b1:1'b0;	
endmodule

