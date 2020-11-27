class clk_rst_cfg extends uvm_object;

  real clock_period = 20; // 20 ns for 50 Mhz
  real initial_reset_cycles = 1; // Apply reset for 20ns

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  `uvm_object_utils_begin(clk_rst_cfg)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "clk_rst_cfg");
    super.new(name);
  endfunction
endclass