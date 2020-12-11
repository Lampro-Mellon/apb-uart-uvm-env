`define DRIVUART_IF vifuart.DRIVER.driver_cb

class uart_driver extends uvm_driver #(uart_transaction);
	`uvm_component_utils(uart_driver)
  
  virtual uart_if	            vifuart;
  uart_config cfg;
  

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
  
  uvm_analysis_port #(uart_transaction) 	item_collected_port_drv;
	uart_transaction 						            trans_collected;
  logic [2:0] LT; 

  //functions
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task get_and_drive();
  extern virtual task cfg_settings();
  extern virtual task drive_rx(uart_transaction req);
  extern virtual task run_phase(uvm_phase phase);

endclass : uart_driver


// --------------------------------------- 
// build phase
// ---------------------------------------
function void uart_driver::build_phase(uvm_phase phase);
  	super.build_phase(phase);
    if(!uvm_config_db#(uart_config)::get(this, "", "cfg", cfg))
    	`uvm_fatal("NO_CFG",{"Configuration must be set for: ",get_full_name(),".cfg"});
    trans_collected = new();
    item_collected_port_drv = new("item_collected_port_drv", this);  
endfunction: build_phase

//--------------------------------------- 
// connect phase
//---------------------------------------
function void uart_driver::connect_phase(uvm_phase phase);
  	super.build_phase(phase);
    if(!uvm_config_db#(virtual uart_if)::get(this, "", "vifuart", vifuart))
    	`uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vifuart"});
endfunction: connect_phase

// ---------------------------------------  
// run phase
// --------------------------------------- 
task uart_driver::run_phase(uvm_phase phase);
	get_and_drive();
endtask : run_phase

// ---------------------------------------  
// cfg_settings
// ---------------------------------------  
task uart_driver::cfg_settings();
	case(cfg.frame_len)
	  5:		LT =7;
	  6:		LT =6;
	  7:		LT =5;
	  8:		LT =4;
    9:		LT =4;
		default:	 `uvm_error(get_type_name(),$sformatf("------ :: Incorrect frame length selected :: ------"))
  endcase
endtask

// ---------------------------------------  
// get_and_drive
// ---------------------------------------  
task uart_driver::get_and_drive();
	uart_transaction req;
	forever 
	begin
    `DRIVUART_IF.RX <= 1'b1 ;
	  @(posedge vifuart.PCLK iff (vifuart.PRESETn))
	  seq_item_port.get_next_item(req);
    trans_collected.payload = req.payload;
    trans_collected.bad_parity = req.bad_parity;
    trans_collected.sb_corr = req.sb_corr;
    cfg_settings();
	  drive_rx(req);
    item_collected_port_drv.write(trans_collected);
	  seq_item_port.item_done();
	end
endtask : get_and_drive

//---------------------------------------
// drive_rx - transaction level to signal level
// drives the value's from seq_item to interface signals
// It contains complete configurable trasmitter model
//---------------------------------------

task uart_driver::drive_rx(uart_transaction req);
  // ------Transmitter Model ------//
  logic [3:0] no_bits_sent = 0;
  logic [5:0] pay_offset = 0;
  logic [3:0] parity_of_frame = 0;
  logic [6:0] temp;                                                                       //for storing parity bits of all max 7 frames
  temp = req.calc_parity(req.payload,cfg.frame_len, req.bad_parity, cfg.parity[0]); 
  for(int i=0;i<LT;i++) 
  begin
      while (no_bits_sent < ((1 + cfg.frame_len + cfg.parity[1] + (cfg.n_sb+1)) )) 
      begin
        repeat(cfg.baud_rate)@(posedge vifuart.PCLK);                                  //waiting for baud rate pulse
        if (no_bits_sent == 0) 
        begin
          `DRIVUART_IF.RX <= req.start_bit;
          no_bits_sent++;
        end 
        else if ((no_bits_sent > 0) && (no_bits_sent < (1 + cfg.frame_len))) 
        begin
          `DRIVUART_IF.RX <= req.payld_func[pay_offset + (no_bits_sent-1)];                   // sending data bits
          `uvm_info(get_type_name(),$sformatf("Driver Sending Data bits:'b%b",(req.payld_func[pay_offset + (no_bits_sent-1)])), UVM_HIGH)
          no_bits_sent++;
        end 
        else if ((no_bits_sent == (1+cfg.frame_len)) && cfg.parity[1]) 
        begin
          `DRIVUART_IF.RX <= temp[parity_of_frame];
          parity_of_frame++;                                                              //sending parity bit
          no_bits_sent++;
        end 
        else 
        begin
          for (int i=0; i <= cfg.n_sb; i++) 
          begin
            if (req.sb_corr) 
            begin
              `DRIVUART_IF.RX <= 0;                                                        // sending corrupt stop bits
              no_bits_sent++;
              `uvm_info(get_type_name(),
                 $sformatf("Driver intensionally corrupting Stop bit since error_bits['b%b] is 'b%b", i, req.sb_corr),
                 UVM_LOW) 
            end 
            else 
            begin
            `DRIVUART_IF.RX <= req.stop_bits[i];                                           // Sending accurate stop bits
            `uvm_info(get_type_name(),$sformatf("Driver Sending Frame Stop bit:'b%b",req.stop_bits[i]), UVM_HIGH)
             no_bits_sent++;
            end
          end 
        end
      end
      pay_offset += cfg.frame_len;
      no_bits_sent = 0;
  end
      repeat(cfg.baud_rate)@(posedge vifuart.PCLK);
endtask: drive_rx

