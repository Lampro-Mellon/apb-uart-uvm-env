module top #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 32
)
();

    logic                       t_PCLK;
    logic                       t_PRESETn;
    logic                       t_PSELx;
    logic                       t_PENABLE;
    logic                       t_PWRITE;
    logic [DATA_WIDTH-1 : 0]    t_PWDATA;
    logic [ADDR_WIDTH-1 : 0]    t_PADDR;
    logic [DATA_WIDTH-1 : 0]    t_PRDATA;
    logic                       t_PREADY;
    logic                       t_PSLVERR;
    logic                       RX;
    logic                       Tx;

    testbench #(DATA_WIDTH,ADDR_WIDTH) VIP   (.*);
    apb_uart_top                       DUT   (
                                              .PCLK(t_PCLK),
                                              .PRESETn(t_PRESETn),
                                              .PSELx(t_PSELx),
                                              .PENABLE(t_PENABLE),
                                              .PWRITE(t_PWRITE),
                                              .PREADY(t_PREADY),
                                              .PSLVERR(t_PSLVERR),
                                              .PWDATA(t_PWDATA),
                                              .PADDR(t_PADDR),
                                              .PRDATA(t_PRDATA),
                                              .RX(RX),
                                              .Tx(Tx)
                                             );

endmodule