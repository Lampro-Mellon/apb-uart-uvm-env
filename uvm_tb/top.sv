module top (
);

    logic               PCLK;
    logic               PRESETn;
    logic               PSELx;
    logic               PENABLE;
    logic               PWRITE;
    logic [32-1 : 0]    PWDATA;
    logic [32-1 : 0]    PADDR;
    logic               RX;
    logic [32-1 : 0]    PRDATA;
    logic               PREADY;
    logic               PSLVERR;
    logic               Tx;

    testbench     VIP   (.*);
    apb_uart_top  DUT   (.*);

endmodule