`define UART_START_ADDR 32'd0
`define UART_END_ADDR 32'd5
`define I2C_START_ADDR 32'd6
`define I2C_END_ADDR 32'd12
`define SPI_START_ADDR 32'd13
`define SPI_END_ADDR 32'd20

class apb_config extends uvm_object;

    //  Group: Variables
    rand bit[31:0] slave_Addr;
         bit[2:0]  psel_Index;

    uvm_active_passive_enum is_active = UVM_ACTIVE;

    //  UVM Factory: Registration    
    `uvm_object_utils_begin(apb_config)
        `uvm_field_int(slave_Addr, UVM_DEFAULT)
        `uvm_field_int(psel_Index, UVM_DEFAULT)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_object_utils_end

    //  Group: Constraints
    constraint addr_cst {slave_Addr inside {[0:5]};}

    //  Group: Functions
    function void AddrCalcFunc();
        if ((slave_Addr >= ` UART_START_ADDR) && (slave_Addr <= ` UART_END_ADDR))
            psel_Index = 1; 
        else if ((slave_Addr >= ` I2C_START_ADDR) && (slave_Addr <= ` I2C_END_ADDR))
            psel_Index = 2; 
        else if ((slave_Addr >= ` SPI_START_ADDR) && (slave_Addr <= ` SPI_END_ADDR))
            psel_Index = 4; 
        else
            psel_Index = 0;
    endfunction

    //  Constructor: new
    function new(string name = "apb_config");
        super.new(name);
    endfunction: new
    
endclass: apb_config
