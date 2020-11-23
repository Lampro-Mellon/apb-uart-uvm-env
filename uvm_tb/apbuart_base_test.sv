class apbuart_base_test extends uvm_test;
	`uvm_component_utils(apbuart_base_test)

   	apbuart_env env_sq;
	uart_config	cfg;   
  
  	function new (string name="apbuart_base_test", uvm_component parent = null);
    	super.new(name,parent);
 	endfunction

	extern virtual function void build_phase(uvm_phase phase);
  	extern virtual function void set_config_params(input [3:0] frm_len , input sb , input [1:0] parity , input [31:0] bd_rate , input flag);
  	extern virtual function void end_of_elaboration();
  	extern virtual function void report_phase(uvm_phase phase);
endclass

function void apbuart_base_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	env_sq = apbuart_env::type_id::create("env_sq",this);
	cfg = new();
	uvm_config_db#(uart_config)::set(this,"*","cfg",cfg);
	set_config_params(6,0,3,9600,0);
endfunction

function void apbuart_base_test::set_config_params(input [3:0] frm_len , input sb , input [1:0] parity , input [31:0] bd_rate , input flag);
	if(flag)
	begin
		if (!cfg.randomize()) 
			`uvm_error("RNDFAIL", "Demo Config Randomization")	
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
    
