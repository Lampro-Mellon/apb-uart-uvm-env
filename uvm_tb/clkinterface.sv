
interface clk_rst_interface (
    output logic reset_n,
    output logic clk
  );
  //import clk_rst_pkg::*;
  logic reset_n_drv = 'z;
  logic clk_drv = 'z;
    
  // TBD do we need the 2 modports at all?
  modport driver (
    output reset_n     ,
    output clk         ,
    output reset_n_drv ,
    output clk_drv
  );

  modport monitor (
    input  reset_n     ,
    input  clk
  );
  // Drivable signals (not net type). Defaults to 'z so it works when the agent is passive

  // Continous assignments to drive the modport wires
  assign reset_n = reset_n_drv;
  assign clk     = clk_drv;

  bit first_reset_started = 0;

  initial begin
    wait ($isunknown({reset_n, clk}) == 1'b0);
    fork
      forever @({reset_n, clk}) begin
          assert ($isunknown({reset_n, clk}) == 1'b0); // From the moment both reset_n and clk become valid, they can never again be unknown.
        end
      begin
        wait (reset_n == 1'b0); // TBD is this needed?
        first_reset_started = 1;
      end
    join
  end

endinterface
