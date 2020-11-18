// -----------------------------------------------------------------------------------
//  Using the `uvm_analysis_imp_decl() macro allows the construction of two analysis 
//  implementation ports with corresponding, uniquely named, write methods
// -----------------------------------------------------------------------------------

`uvm_analysis_imp_decl(_monapb)
`uvm_analysis_imp_decl(_monuart) 
`uvm_analysis_imp_decl(_drvapb)
`uvm_analysis_imp_decl(_drvuart) 

class apbuart_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(apbuart_scoreboard)
  
  	// ---------------------------------------
  	//  declaring pkt_qu to store the pkt's 
  	//  recived from monitor and driver
  	// ---------------------------------------
  	apb_transaction 	pkt_qu_monapb[$];
	uart_transaction 	pkt_qu_monuart[$];
  	apb_transaction 	pkt_qu_drvapb[$];
	uart_transaction 	pkt_qu_drvuart[$];  
	
  	// ----------------------------------------------
  	//  scoreboad CONFIGURATION ADDRESS memory map 
  	//  and specific configuration register value
  	// ----------------------------------------------
  	`define		baud_config_addr			0	      // 9600
	`define		frame_config_addr			1	      // 8
	`define		parity_config_addr			2	      // 3 (Even)
	`define		stop_bits_config_addr		3         // 1 (Two Stop bits)
  	`define		trans_data_addr		      	4         // transmission address
    `define		receive_data_addr		    5         // recieve address

  	`define		baud_config_reg				9600	  // 9600
	`define		frame_config_reg			8	      // 8
	`define		parity_config_reg			3	      // 3 (Even)
	`define		stop_bits_config_reg		1         // 1 (Two Stop bits)

  	reg [47:0] 	transmitter_reg;   // included 4 frames and partiy bit plus stop bits
  	reg [47:0] 	checker_transmt_reg;
  	reg [31:0] 	receiver_reg;      // only 4 frames
	reg [5:0]  	tx_count= 0 ;  

  	// ------------------------------------------------------------------------------
  	//  port to recive packets from monitor first argument is transation type and 
  	//  other is defining which subscriber is attached
  	// ------------------------------------------------------------------------------
    uvm_analysis_imp_monapb 	#(apb_transaction, apbuart_scoreboard)		item_collected_export_monapb;
	uvm_analysis_imp_monuart 	#(uart_transaction, apbuart_scoreboard) 	item_collected_export_monuart;
  	uvm_analysis_imp_drvapb  	#(apb_transaction, apbuart_scoreboard) 		item_collected_export_drvapb;
	uvm_analysis_imp_drvuart  	#(uart_transaction, apbuart_scoreboard) 	item_collected_export_drvuart;  

  	//---------------------------------------
  	// new - constructor
  	//---------------------------------------
  	function new (string name, uvm_component parent);
  		super.new(name, parent);
  	endfunction : new
  
  	// ---------------------------------------
  	//  build_phase - create port 
  	// ---------------------------------------
  	function void build_phase(uvm_phase phase);
  		super.build_phase(phase);
      	item_collected_export_monapb 	= new("item_collected_export_monapb", this);
		item_collected_export_monuart 	= new("item_collected_export_monuart", this);
      	item_collected_export_drvapb 	= new("item_collected_export_drvapb", this);
		item_collected_export_drvuart 	= new("item_collected_export_drvuart", this);  
  	endfunction: build_phase
  
  	// --------------------------------------------------
  	//  write task - recives the pkt from monitor (APB) 
  	//  and pushes into queue
  	// --------------------------------------------------
  	virtual function void write_monapb(apb_transaction pkt);
  		pkt_qu_monapb.push_back(pkt); // Pushing the transactions from the end of queue
  	endfunction : write_monapb
  
	// --------------------------------------------------
  	//  write task - recives the pkt from monitor (UART) 
  	//  and pushes into queue
  	// --------------------------------------------------
  	virtual function void write_monuart(uart_transaction pkt);
  		pkt_qu_monuart.push_back(pkt); // Pushing the transactions from the end of queue
  	endfunction : write_monuart
  
  	// ----------------------------------------------
  	//  write task - recives the pkt from driver(apb) 
  	//  and pushes into queue
  	// ----------------------------------------------
  	virtual function void write_drvapb(apb_transaction pkt);
  		pkt_qu_drvapb.push_back(pkt); // Pushing the transactions from the end of queue
  	endfunction : write_drvapb

	// ------------------------------------------------
  	//  write task - recives the pkt from driver (Uart)
  	//  and pushes into queue
  	// ------------------------------------------------
  	virtual function void write_drvuart(uart_transaction pkt);
  		pkt_qu_drvuart.push_back(pkt); // Pushing the transactions from the end of queue
  	endfunction : write_drvuart  

  	// --------------------------------------------------------------------------------------
  	//  run_phase - compare's the read data with the expected data(stored in register)
  	//  Transmitter register will be updated on value of config address=4 and Tx_detect = 1
  	// --------------------------------------------------------------------------------------
  	virtual task run_phase(uvm_phase phase);
    	apb_transaction 	apb_pkt_mon;
		uart_transaction 	uart_pkt_mon;
      	apb_transaction 	apb_pkt_drv;
		uart_transaction 	uart_pkt_drv;
    
    	forever 
    	begin
          	wait(pkt_qu_drvapb.size() > 0);	    			// checking the fifo that it contains any valid entry from driver
      		apb_pkt_drv = pkt_qu_drvapb.pop_front(); 		// getting the entry from the start of fifo
          	if(apb_pkt_drv.PWRITE == 0 && (apb_pkt_drv.PADDR == `baud_config_addr || apb_pkt_drv.PADDR == `frame_config_addr || apb_pkt_drv.PADDR == `parity_config_addr || apb_pkt_drv.PADDR == `stop_bits_config_addr))
			begin
				wait(pkt_qu_monapb.size() > 0);	    		// checking the fifo that it contains any valid entry from monitor apb
      			apb_pkt_mon = pkt_qu_monapb.pop_front(); 	// getting the entry from the start of fifo
          		compare_config (apb_pkt_mon) ;
			end
			else if (apb_pkt_drv.PADDR == `trans_data_addr)
			begin
				trasmitter_ref_model (apb_pkt_drv);
				wait(pkt_qu_monuart.size() > 0);	    	// checking the fifo that it contains any valid entry from monitor apb
				uart_pkt_mon = pkt_qu_monuart.pop_front(); 	// getting the entry from the start of fifo
				compare_transmission (uart_pkt_mon) ;
			end
			else if (apb_pkt_drv.PADDR == `receive_data_addr)
			begin
				wait(pkt_qu_drvuart.size() > 0);	    	// checking the fifo that it contains any valid entry from driver
      			uart_pkt_drv = pkt_qu_drvuart.pop_front(); 	// getting the entry from the start of fifo
				receive_ref_model(uart_pkt_drv);
				wait(pkt_qu_monapb.size() > 0);	    		// checking the fifo that it contains any valid entry from monitor apb
				apb_pkt_mon = pkt_qu_monapb.pop_front(); 	// getting the entry from the start of fifo
				compare_receive (apb_pkt_mon,uart_pkt_drv);
			end
    	end
  	endtask : run_phase
  
  	function trasmitter_ref_model (apb_transaction apb_pkt);
  	    checker_transmt_reg[0]      = 1'b0;
  	    checker_transmt_reg[8:1]    = apb_pkt.PWDATA[7:0];
  	    checker_transmt_reg[9]      = ^(apb_pkt.PWDATA[7:0]); 
  	    checker_transmt_reg[11:10]  = 3; 

  	    checker_transmt_reg[12]     = 1'b0;
  	    checker_transmt_reg[20:13]  = apb_pkt.PWDATA[15:8];
  	    checker_transmt_reg[21]     = ^(apb_pkt.PWDATA[15:8]); 
  	    checker_transmt_reg[23:22]  = 3; 

  	    checker_transmt_reg[24]     = 1'b0;
  	    checker_transmt_reg[32:25]  = apb_pkt.PWDATA[23:16];
  	    checker_transmt_reg[33]     = ^(apb_pkt.PWDATA[23:16]); 
  	    checker_transmt_reg[35:34]  = 3; 

  	    checker_transmt_reg[36]     = 1'b0;
  	    checker_transmt_reg[44:37]  = apb_pkt.PWDATA[31:24];
  	    checker_transmt_reg[45]     = ^(apb_pkt.PWDATA[31:24]); 
  	    checker_transmt_reg[47:46]  = 3; 
  	endfunction  
  
  	function compare_config (apb_transaction apb_pkt);
    	if(apb_pkt.PADDR == `baud_config_addr && apb_pkt.PRDATA == `baud_config_reg)
    	begin
    	    `uvm_info(get_type_name(),$sformatf("------ :: Baud Rate Config Match :: ------"),UVM_LOW)
    	    `uvm_info(get_type_name(),$sformatf("Expected Baud Rate: %0h Actual Baud Rate: %0h",`baud_config_reg,apb_pkt.PRDATA),UVM_LOW)
    	    `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
    	end
    	else if(apb_pkt.PADDR == `baud_config_addr && apb_pkt.PRDATA != `baud_config_reg)
    	begin
    	    `uvm_error(get_type_name(),$sformatf("------ :: Baud Rate Config MisMatch :: ------"))
    	    `uvm_info(get_type_name(),$sformatf("Expected Baud Rate: %0h Actual Baud Rate: %0h",`baud_config_reg,apb_pkt.PRDATA),UVM_LOW)
    	    `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
    	end
    	else if(apb_pkt.PADDR == `frame_config_addr && apb_pkt.PRDATA == `frame_config_reg)
    	begin
    		`uvm_info(get_type_name(),$sformatf("------ :: Frame Rate  Match :: ------"),UVM_LOW)
    	    `uvm_info(get_type_name(),$sformatf("Expected Frame Rate: %0h Actual Frame Rate: %0h",`frame_config_reg,apb_pkt.PRDATA),UVM_LOW)
    	    `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
    	end
    	else if(apb_pkt.PADDR == `frame_config_addr && apb_pkt.PRDATA != `frame_config_reg)
    	begin
    	    `uvm_error(get_type_name(),$sformatf("------ :: Frame Rate  MisMatch :: ------"))
    	    `uvm_info(get_type_name(),$sformatf("Expected Frame Rate: %0h Actual Frame Rate: %0h",`frame_config_reg,apb_pkt.PRDATA),UVM_LOW)
    	    `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
    	end
    	else if(apb_pkt.PADDR == `parity_config_addr && apb_pkt.PRDATA == `parity_config_reg)
    	begin
    		`uvm_info(get_type_name(),$sformatf("------ :: Even Parity Match :: ------"),UVM_LOW)
    	    `uvm_info(get_type_name(),$sformatf("Expected Parity Value : %0h Actual Parity Value: %0h",`parity_config_reg,apb_pkt.PRDATA),UVM_LOW)
    	    `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
    	end
    	else if(apb_pkt.PADDR == `parity_config_addr && apb_pkt.PRDATA != `parity_config_reg)
    	begin
    	    `uvm_error(get_type_name(),$sformatf("------ :: Even Parity MisMatch :: ------"))
    	    `uvm_info(get_type_name(),$sformatf("Expected Parity Value : %0h Actual Parity Value: %0h",`parity_config_reg,apb_pkt.PRDATA),UVM_LOW)
    	    `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
    	end
    	else if(apb_pkt.PADDR == `stop_bits_config_addr && apb_pkt.PRDATA == `stop_bits_config_reg)
    	begin
    	    `uvm_info(get_type_name(),$sformatf("------ :: Stop Bit Match :: ------"),UVM_LOW)
    	    `uvm_info(get_type_name(),$sformatf("Expected Stop Bit Value : %0h Actual Stop Value: %0h",`stop_bits_config_reg,apb_pkt.PRDATA),UVM_LOW)
    	    `uvm_info(get_type_name(),"------------------------------------\n",UVM_LOW)
    	end
    	else if(apb_pkt.PADDR == `stop_bits_config_addr && apb_pkt.PRDATA != `stop_bits_config_reg)
    	begin
    	    `uvm_error(get_type_name(),$sformatf("------ :: Stop Bit MisMatch :: ------"))
    	    `uvm_info(get_type_name(),$sformatf("Expected Stop Bit Value : %0h Actual Stop Value: %0h",`stop_bits_config_reg,apb_pkt.PRDATA),UVM_LOW)
    	    `uvm_info(get_type_name(),"------------------------------------\n",UVM_LOW)
    	end
  	endfunction  
  
  	function compare_transmission (uart_transaction uart_pkt);  
  		if(checker_transmt_reg == uart_pkt.transmitter_reg)
  		begin
  	    	`uvm_info(get_type_name(),$sformatf("------ :: Transmission Data Packet Match :: ------"),UVM_LOW)
  	    	`uvm_info(get_type_name(),$sformatf("Expected Transmission Data Value : %0h Actual Transmission Data Value: %0h",checker_transmt_reg,uart_pkt.transmitter_reg),UVM_LOW)
  	    	`uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
  	    end
  	  	else if(checker_transmt_reg != uart_pkt.transmitter_reg)
  	    begin
  	      	`uvm_error(get_type_name(),$sformatf("------ :: Transmission Data Packet MisMatch :: ------"))
  	      	`uvm_info(get_type_name(),$sformatf("Expected Transmission Data Value : %0h Actual Transmission Data Value: %0h",checker_transmt_reg,uart_pkt.transmitter_reg),UVM_LOW)
  	      	`uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
  	    end
  	endfunction  
  
  
  	function receive_ref_model (uart_transaction uart_pkt); 
  	  	receiver_reg = {uart_pkt.rec_temp[44:37],uart_pkt.rec_temp[32:25],uart_pkt.rec_temp[20:13],uart_pkt.rec_temp[8:1]} ; // reference model for reciving register
	endfunction  
	  
  	function compare_receive (apb_transaction apb_pkt , uart_transaction uart_pkt); 
        if(apb_pkt.PRDATA == receiver_reg)
        begin
        	`uvm_info(get_type_name(),$sformatf("------ :: Reciever Data Packet Match :: ------"),UVM_LOW)
        	`uvm_info(get_type_name(),$sformatf("Expected Reciever Data Value : %0h Actual Reciever Data Value: %0h",receiver_reg,apb_pkt.PRDATA),UVM_LOW)
        	`uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
            if(uart_pkt.fpn_flag == 1 && apb_pkt.PSLVERR == 1'b1) // framing PSLVERR check
            begin
            	`uvm_info(get_type_name(),$sformatf("------ :: Framing Error Match :: ------"),UVM_LOW)
        		`uvm_info(get_type_name(),$sformatf("Expected Framing Error Value : %0h Actual Framing Error Value: %0h",1'b1,apb_pkt.PSLVERR),UVM_LOW)
        		`uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
            end  
          	else if(uart_pkt.fpn_flag == 1 && apb_pkt.PSLVERR == 1'b0) // framing PSLVERR check
            begin
                `uvm_error(get_type_name(),$sformatf("------ :: Framing Error MisMatch :: ------"))
        		`uvm_info(get_type_name(),$sformatf("Expected Framing Error Value : %0h Actual Framing Error Value: %0h",1'b1,apb_pkt.PSLVERR),UVM_LOW)
        		`uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
            end  
          	else if(uart_pkt.fpn_flag == 2 && apb_pkt.PSLVERR == 1'b1) // Parity PSLVERR check
            begin
                `uvm_info(get_type_name(),$sformatf("------ :: Parity Error Match :: ------"),UVM_LOW)
                `uvm_info(get_type_name(),$sformatf("Expected Parity Error Value : %0h Actual Parity Error Value: %0h",1'b1,apb_pkt.PSLVERR),UVM_LOW)
        		`uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
            end  
          	else if(uart_pkt.fpn_flag == 1 && apb_pkt.PSLVERR == 1'b0) // Parity PSLVERR check
            begin
                `uvm_error(get_type_name(),$sformatf("------ :: Parity Error MisMatch :: ------"));
                `uvm_info(get_type_name(),$sformatf("Expected Parity Error Value : %0h Actual Parity Error Value: %0h",1'b1,apb_pkt.PSLVERR),UVM_LOW);
                `uvm_info(get_type_name(),"------------------------------------",UVM_LOW);
            end  
          	else if(uart_pkt.fpn_flag == 3 && apb_pkt.PSLVERR == 1'b0) // Error Free sequence check
            begin
                `uvm_info(get_type_name(),$sformatf("------ :: No Error :: ------"),UVM_LOW)
                `uvm_info(get_type_name(),$sformatf("Expected Error Value : %0h Actual Error Value: %0h",1'b0,apb_pkt.PSLVERR),UVM_LOW)
        		`uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
            end  
          	else if(uart_pkt.fpn_flag == 3 && apb_pkt.PSLVERR == 1'b1) // Error Free sequence check
            begin
                `uvm_error(get_type_name(),$sformatf("------ :: Error Signal Detected :: ------"));
                `uvm_info(get_type_name(),$sformatf("Expected Error Value : %0h Actual Error Value: %0h",1'b0,apb_pkt.PSLVERR),UVM_LOW);
        		`uvm_info(get_type_name(),"------------------------------------",UVM_LOW)

            end  
        end  
		else
        begin
        	`uvm_error(get_type_name(),$sformatf("------ :: Reciever Data Packet MisMatch :: ------"))
        	`uvm_info(get_type_name(),$sformatf("Expected Reciever Data Value : %0h Actual Reciever Data Value: %0h",receiver_reg,apb_pkt.PRDATA),UVM_LOW)
        	`uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
        end     
  	endfunction
endclass
