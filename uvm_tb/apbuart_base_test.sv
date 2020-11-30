class apbuart_base_test extends uvm_test;
	`uvm_component_utils(apbuart_base_test)

   	apbuart_env 	env_sq;
	uart_config		cfg;
	clk_rst_cfg   	clk_cfg;
	apb_config		apb_cfg;
	
  	function new (string name="apbuart_base_test", uvm_component parent = null);
    	super.new(name,parent);
 	endfunction

	extern virtual function void build_phase(uvm_phase phase);
  	extern virtual function void set_config_params(input [31:0] bd_rate , input [3:0] frm_len , input [1:0] parity , input sb , input flag);
	extern virtual function void set_apbconfig_params (input [31:0] addr , input flag);
	extern virtual function void end_of_elaboration();
	extern virtual function void report_phase(uvm_phase phase);
	  
endclass

function void apbuart_base_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	env_sq = apbuart_env::type_id::create("env_sq",this);
	cfg = new();
	uvm_config_db#(uart_config)::set(this,"*","cfg",cfg);
	clk_cfg = new();
	uvm_config_db#(clk_rst_cfg)::set(this,"*","clk_cfg",clk_cfg);
	set_config_params(9600,8,3,1,0); // Baud Rate , Frame Len , Parity , Stop Bit , Randomize Flag (1 for random , 0 for directed)
	apb_cfg = new();
	uvm_config_db#(apb_config)::set(this,"*","apb_cfg",apb_cfg);
	set_apbconfig_params(2,0); // Slave Bus Address, Randomize flag (1 for random , 0 for directed)
endfunction

function void apbuart_base_test::set_apbconfig_params(input [31:0] addr, input flag);
	if(flag)
	begin
		if (!apb_cfg.randomize()) 
			`uvm_error("RNDFAIL", " APB Config Randomization")	
	end
	else
	begin
		apb_cfg.slave_Addr 	= addr;
	end
	apb_cfg.AddrCalcFunc();
	//$diplay("Slave Index is ",apb_cfg.AddrCalcFunc());
endfunction

function void apbuart_base_test::set_config_params(input [31:0] bd_rate , input [3:0] frm_len , input [1:0] parity , input sb , input flag);
	if(flag)
	begin
		if (!cfg.randomize()) 
			`uvm_error("RNDFAIL", " Config Randomization")	
	end
	else
	begin
		cfg.frame_len 	= frm_len;
		cfg.n_sb 		= sb;
		cfg.parity		= parity;
		cfg.bRate		= bd_rate;
	end
	cfg.baudRateFunc();	
endfunction

function void apbuart_base_test::end_of_elaboration();
	print();
endfunction 

// ---------------------------------------
//  end_of_elobaration phase
// ---------------------------------------   
function void apbuart_base_test::report_phase(uvm_phase phase);
	uvm_report_server svr;
	super.report_phase(phase);
   
   	svr = uvm_report_server::get_server();
   	if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) 
	begin
   		`uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
   		`uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
   		`uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
   	 end
   	 else 
	begin
   		`uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
   		`uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
   		`uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
   	 end
endfunction 
    
