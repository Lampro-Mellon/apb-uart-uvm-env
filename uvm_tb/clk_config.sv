class clk_rst_cfg extends uvm_object;

  realtime clock_period = 2.0ns;
  real initial_reset_cycles = 1;

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  `uvm_object_utils_begin(clk_rst_cfg)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "clk_rst_cfg");
    super.new(name);
  endfunction
endclass