// -----------------------------------------------------------------------------------
//  Using the `uvm_analysis_imp_decl() macro allows the construction of two analysis 
//  implementation ports with corresponding, uniquely named, write methods
// -----------------------------------------------------------------------------------

`uvm_analysis_imp_decl(_monapb)
`uvm_analysis_imp_decl(_monuart) 
`uvm_analysis_imp_decl(_drvuart) 

class apbuart_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(apbuart_scoreboard)
  
  	// ---------------------------------------
  	//  declaring pkt_qu to store the pkt's 
  	//  recived from monitor and driver
  	// ---------------------------------------
  	apb_transaction 	pkt_qu_monapb[$];
	uart_transaction 	pkt_qu_monuart[$];
	uart_transaction 	pkt_qu_drvuart[$];  

	// Handle to  a cfg class
  	uart_config 		cfg;   

	// Registers to store configuration data

	logic [31:0] baud_rate_reg;
	logic [31:0] frame_len_reg;
	logic [31:0] parity_reg;
	logic [31:0] stopbit_reg;
 
  	// ------------------------------------------------------------------------------
  	//  port to recive packets from monitor first argument is transation type and 
  	//  other is defining which subscriber is attached
  	// ------------------------------------------------------------------------------
    uvm_analysis_imp_monapb 	#(apb_transaction, apbuart_scoreboard)		item_collected_export_monapb;
	uvm_analysis_imp_monuart 	#(uart_transaction, apbuart_scoreboard) 	item_collected_export_monuart;
	uvm_analysis_imp_drvuart  	#(uart_transaction, apbuart_scoreboard) 	item_collected_export_drvuart;  

  	//---------------------------------------
  	// new - constructor
  	//---------------------------------------
  	function new (string name, uvm_component parent);
  		super.new(name, parent);
  	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void write_monapb(apb_transaction pkt);
	extern virtual function void write_monuart(uart_transaction pkt);
	extern virtual function void write_drvuart(uart_transaction pkt);
	extern virtual function void compare_config (apb_transaction apb_pkt);
	extern virtual function void compare_transmission (apb_transaction apb_pkt, uart_transaction uart_pkt); 
	extern virtual function void compare_receive (apb_transaction apb_pkt , uart_transaction uart_pkt);
	extern virtual task run_phase(uvm_phase phase);  
  
endclass

// ---------------------------------------
//  build_phase - create port 
// ---------------------------------------
function void apbuart_scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(uart_config)::get(this, "", "cfg", cfg))
		`uvm_fatal("No cfg",{"Configuration must be set for: ",get_full_name(),".cfg"});  
  	item_collected_export_monapb 	= new("item_collected_export_monapb", this);
	item_collected_export_monuart 	= new("item_collected_export_monuart", this);
	item_collected_export_drvuart 	= new("item_collected_export_drvuart", this);  
endfunction: build_phase

// --------------------------------------------------
//  write task - recives the pkt from monitor (APB) 
//  and pushes into queue
// --------------------------------------------------
function void apbuart_scoreboard::write_monapb(apb_transaction pkt);
	pkt_qu_monapb.push_back(pkt); // Pushing the transactions from the end of queue
endfunction : write_monapb
  
// --------------------------------------------------
//  write task - recives the pkt from monitor (UART) 
//  and pushes into queue
// --------------------------------------------------
function void apbuart_scoreboard::write_monuart(uart_transaction pkt);
	pkt_qu_monuart.push_back(pkt); // Pushing the transactions from the end of queue
endfunction : write_monuart
  
// ------------------------------------------------
//  write task - recives the pkt from driver (Uart)
//  and pushes into queue
// ------------------------------------------------
function void apbuart_scoreboard::write_drvuart(uart_transaction pkt);
	pkt_qu_drvuart.push_back(pkt); // Pushing the transactions from the end of queue
endfunction : write_drvuart


// --------------------------------------------------------------------------------------
//  run_phase - compare's the read data with the expected data(stored in register)
//  Transmitter register will be updated on value of config address=4 and Tx_detect = 1
// --------------------------------------------------------------------------------------
task apbuart_scoreboard::run_phase(uvm_phase phase);
	apb_transaction 	apb_pkt_mon;
	uart_transaction 	uart_pkt_mon;
  	apb_transaction 	apb_pkt_drv;
	uart_transaction 	uart_pkt_drv;
    
    forever 
    begin
		wait(pkt_qu_monapb.size() > 0);	    			// checking the fifo that it contains any valid entry from monitor apb
    	apb_pkt_mon = pkt_qu_monapb.pop_front(); 		// getting the entry from the start of fifo
		if(apb_pkt_mon.PWRITE==1 && (apb_pkt_mon.PADDR == cfg.baud_config_addr || apb_pkt_mon.PADDR == cfg.frame_config_addr || apb_pkt_mon.PADDR == cfg.parity_config_addr || apb_pkt_mon.PADDR == cfg.stop_bits_config_addr))
		begin
			case(apb_pkt_mon.PADDR)
				cfg.baud_config_addr : baud_rate_reg 		=  apb_pkt_mon.PWDATA;
				cfg.frame_config_addr : frame_len_reg 		=  apb_pkt_mon.PWDATA;
				cfg.parity_config_addr : parity_reg 		=  apb_pkt_mon.PWDATA;
				cfg.stop_bits_config_addr : stopbit_reg 	=  apb_pkt_mon.PWDATA;
				default : `uvm_error(get_type_name(),$sformatf("------ :: Incorrect Config Address :: ------"))
			endcase
		end 
		else if(apb_pkt_mon.PWRITE==0 && (apb_pkt_mon.PADDR == cfg.baud_config_addr || apb_pkt_mon.PADDR == cfg.frame_config_addr || apb_pkt_mon.PADDR == cfg.parity_config_addr || apb_pkt_mon.PADDR == cfg.stop_bits_config_addr))
		begin
			compare_config (apb_pkt_mon) ;
		end
		else if (apb_pkt_mon.PADDR == cfg.trans_data_addr)
		begin
			wait(pkt_qu_monuart.size() > 0);	    		// checking the fifo that it contains any valid entry from monitor apb
			uart_pkt_mon = pkt_qu_monuart.pop_front(); 		// getting the entry from the start of fifo
			compare_transmission (apb_pkt_mon,uart_pkt_mon);
		end
		else if (apb_pkt_mon.PADDR == cfg.receive_data_addr)
		begin
			wait(pkt_qu_drvuart.size() > 0);	    	// checking the fifo that it contains any valid entry from driver
    		uart_pkt_drv = pkt_qu_drvuart.pop_front(); 	// getting the entry from the start of fifo
			compare_receive (apb_pkt_mon,uart_pkt_drv);
		end
    end
endtask : run_phase


function void apbuart_scoreboard::compare_config (apb_transaction apb_pkt);
	if(apb_pkt.PADDR == cfg.baud_config_addr)
	begin
		if(apb_pkt.PRDATA == baud_rate_reg)
			`uvm_info(get_type_name(),$sformatf("------ :: Baud Rate Match :: ------"),UVM_LOW)
		else
		    `uvm_error(get_type_name(),$sformatf("------ :: Baud Rate MisMatch :: ------"))
		`uvm_info(get_type_name(),$sformatf("Expected Baud Rate: %0d Actual Baud Rate: %0d",baud_rate_reg,apb_pkt.PRDATA),UVM_LOW)	
		`uvm_info(get_type_name(),"------------------------------------\n",UVM_LOW)
	end
	if(apb_pkt.PADDR == cfg.frame_config_addr)
	begin
		if(apb_pkt.PRDATA == frame_len_reg)
			`uvm_info(get_type_name(),$sformatf("------ :: Frame Rate Match :: ------"),UVM_LOW)
		else
		    `uvm_error(get_type_name(),$sformatf("------ :: Frame Rate MisMatch :: ------"))
		`uvm_info(get_type_name(),$sformatf("Expected Frame Rate: %0h Actual Frame Rate: %0h",frame_len_reg,apb_pkt.PRDATA),UVM_LOW)	
		`uvm_info(get_type_name(),"------------------------------------\n",UVM_LOW)
	end
	if(apb_pkt.PADDR == cfg.parity_config_addr)
	begin
		if(apb_pkt.PRDATA == parity_reg)
			`uvm_info(get_type_name(),$sformatf("------ :: Parity Match :: ------"),UVM_LOW)
		else
		    `uvm_error(get_type_name(),$sformatf("------ :: Parity MisMatch :: ------"))
		`uvm_info(get_type_name(),$sformatf("Expected Parity Value : %0h Actual Parity Value: %0h",parity_reg,apb_pkt.PRDATA),UVM_LOW)	    
		`uvm_info(get_type_name(),"------------------------------------\n",UVM_LOW)
	end
	if(apb_pkt.PADDR == cfg.stop_bits_config_addr)
	begin
		if(apb_pkt.PRDATA == stopbit_reg)
		    `uvm_info(get_type_name(),$sformatf("------ :: Stop Bit Match :: ------"),UVM_LOW)
		else
		    `uvm_error(get_type_name(),$sformatf("------ :: Stop Bit MisMatch :: ------"))
		`uvm_info(get_type_name(),$sformatf("Expected Stop Bit Value : %0h Actual Stop Value: %0h",stopbit_reg,apb_pkt.PRDATA),UVM_LOW)
		`uvm_info(get_type_name(),"------------------------------------\n",UVM_LOW)
	end
endfunction  
  
function void apbuart_scoreboard::compare_transmission (apb_transaction apb_pkt, uart_transaction uart_pkt);  
	if(apb_pkt.PWDATA == uart_pkt.transmitter_reg) 
    	`uvm_info(get_type_name(),$sformatf("------ :: Transmission Data Packet Match :: ------"),UVM_LOW)
  	else
      	`uvm_error(get_type_name(),$sformatf("------ :: Transmission Data Packet MisMatch :: ------"))
	`uvm_info(get_type_name(),$sformatf("Expected Transmission Data Value : %0h Actual Transmission Data Value: %0h",apb_pkt.PWDATA,uart_pkt.transmitter_reg),UVM_LOW)   
	`uvm_info(get_type_name(),"------------------------------------\n",UVM_LOW)
endfunction  

function void apbuart_scoreboard::compare_receive (apb_transaction apb_pkt , uart_transaction uart_pkt); 
    if(apb_pkt.PRDATA == uart_pkt.payload)
    	`uvm_info(get_type_name(),$sformatf("------ :: Reciever Data Packet Match :: ------"),UVM_LOW)
	else
    	`uvm_error(get_type_name(),$sformatf("------ :: Reciever Data Packet MisMatch :: ------"))
	`uvm_info(get_type_name(),$sformatf("Expected Reciever Data Value : %0h Actual Reciever Data Value: %0h",uart_pkt.payload,apb_pkt.PRDATA),UVM_LOW)
	`uvm_info(get_type_name(),"------------------------------------\n",UVM_LOW)
	//$display("uart_pkt.sb_corr::%0b\tuart_pkt.sb_corr_bit[0]::%0b\tcfg.n_sb::%d",uart_pkt.sb_corr,uart_pkt.sb_corr_bit,cfg.parity[1]);
	if((uart_pkt.bad_parity && cfg.parity[1]) || (uart_pkt.sb_corr && (cfg.n_sb || uart_pkt.sb_corr_bit[0])))
	begin
		//$display("uart_pkt.sb_corr::%0b\tuart_pkt.sb_corr_bit[0]::%0b\tcfg.n_sb::%d",uart_pkt.sb_corr,uart_pkt.sb_corr_bit[0],cfg.n_sb[0]);

		if(apb_pkt.PSLVERR == 1'b1)
			`uvm_info(get_type_name(),$sformatf("------ :: Error Match :: ------"),UVM_LOW)
		else
			`uvm_error(get_type_name(),$sformatf("------ :: Error MisMatch :: ------"))
		`uvm_info(get_type_name(),$sformatf("Expected Error Value : %0h Actual Error Value: %0h",1'b1,apb_pkt.PSLVERR),UVM_LOW)
		`uvm_info(get_type_name(),"------------------------------------\n",UVM_LOW)
	end
	else
	begin
		if(apb_pkt.PSLVERR == 1'b0)
			`uvm_info(get_type_name(),$sformatf("------ :: Error Match :: ------"),UVM_LOW)
		else
			`uvm_error(get_type_name(),$sformatf("------ :: Error MisMatch :: ------"))
		`uvm_info(get_type_name(),$sformatf("Expected Error Value : %0h Actual Error Value: %0h",1'b0,apb_pkt.PSLVERR),UVM_LOW)
		`uvm_info(get_type_name(),"------------------------------------\n",UVM_LOW)
	end
endfunction

