
class uart_config extends uvm_object;
    // From APB AGENTs 
    rand bit [31:0] frame_len;
    rand bit [31:0] n_sb;
    rand bit [31:0] parity;
    rand bit [31:0] bRate;
    // To UART Monitor 
         bit [31:0] baud_rate;


    // constants address field
    const bit[31:0] baud_config_addr        = 32'd0;
    const bit[31:0] frame_config_addr       = 32'd4;
    const bit[31:0] parity_config_addr      = 32'd8;
    const bit[31:0] stop_bits_config_addr   = 32'd12;
    const bit[31:0] trans_data_addr         = 32'd16; 
    const bit[31:0] receive_data_addr       = 32'd20;

    const int loop_time = 50;
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    `uvm_object_utils_begin(uart_config)
        `uvm_field_int(bRate, UVM_DEFAULT + UVM_DEC)
        `uvm_field_int(frame_len, UVM_DEFAULT)
        `uvm_field_int(parity, UVM_DEFAULT )  
        `uvm_field_int(n_sb, UVM_DEFAULT)
        `uvm_field_int(baud_rate, UVM_DEFAULT + UVM_DEC)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_object_utils_end

    constraint c_frame_len  {frame_len  inside {5,6,7,8};}
    constraint c_n_sb       {n_sb       inside {0,1};}
    constraint c_parity     {parity     inside {0,1,2,3};}
    constraint c_bgen       {bRate      inside {4800,9600,14400,19200,38400,57600,115200,128000,63,0};} // 4800,9600,14400,19200,38400,57600,115200,128000

    function void baudRateFunc();
        case (bRate)
            32'd4800: 	baud_rate = 32'd10416;
            32'd9600: 	baud_rate = 32'd5208;
	        32'd14400:	baud_rate = 32'd3472;
            32'd19200: 	baud_rate = 32'd2604;
            32'd38400: 	baud_rate = 32'd1302;
	        32'd57600: 	baud_rate = 32'd868;
            32'd115200: baud_rate = 32'd434;
            32'd128000: baud_rate = 32'd392;
            default:  	baud_rate = 32'd5208;
        endcase
    endfunction

    function new(string name = "uart_config");
        super.new(name);
    endfunction 
endclass
