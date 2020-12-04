module top #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 32
)
();

    logic                       PCLK;
    logic                       PRESETn;
    logic                       PSELx;
    logic                       PENABLE;
    logic                       PWRITE;
    logic [DATA_WIDTH-1 : 0]    PWDATA;
    logic [ADDR_WIDTH-1 : 0]    PADDR;
    logic                       RX;
    logic [DATA_WIDTH-1 : 0]    PRDATA;
    logic                       PREADY;
    logic                       PSLVERR;
    logic                       Tx;

    testbench #(DATA_WIDTH,ADDR_WIDTH) VIP   (.*);
    apb_uart_top                       DUT   (.*);

endmodule