package clk_rst_pkg;

  import uvm_pkg::*;

  function realtime freq2period(string freq, real conversion); // The conversion factor is the time units of the result, e.g. if conversion = 1ps, result is in ps.
    real value;
    string units;
    realtime scale;
    if ($sscanf(freq, "%f %s", value, units) != 2) begin
      `uvm_fatal("freq2period", $sformatf("Unable to parse '%s' as a <value><units> string", freq))
    end
    case (units.tolower())
      "hz" : begin
        scale = 1s;
      end
      "khz" : begin
        scale = 1ms;
      end
      "mhz" : begin
        scale = 1us;
      end
      "ghz" : begin
        scale = 1ns;
      end
      default : begin
        `uvm_fatal("freq2period", $sformatf("Unrecognized units of freq value '%s' to convert. Only Hz, kHz, MHz, GHz units supported (case insensitive)", freq))
      end
    endcase
    return (1.0 / value) * (scale / conversion);
  endfunction


endpackage
