class clk_rst_driver extends uvm_driver#(clk_rst_seq_item);

  clk_rst_cfg clk_cfg;
  virtual clk_rst_interface vifclk;
  clk_rst_sequencer seqr;
  clk_rst_seq_item item;
  realtime t_high  = 1;
  realtime t_low   = 1;
  realtime t_reset = 1;
  
  `uvm_component_utils_begin(clk_rst_driver)
  `uvm_component_utils_end

  function new(string name = "clk_rst_driver", uvm_component parent = null);
    super.new(name, parent);
    if (parent == null) begin
      `uvm_fatal("new", "Null parent is not legal for this component")
    end
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(clk_rst_cfg)::get(this, "", "clk_cfg", clk_cfg))
      `uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".clk_cfg"})
    if(!uvm_config_db#(virtual clk_rst_interface)::get(this, "", "vifclk", vifclk))
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vifclk"})
    this.init_from_cfg();
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  // Initializes the driver from the config object
  function void init_from_cfg();
    this.t_high = this.clk_cfg.clock_period / 2.0;
    this.t_low  = this.clk_cfg.clock_period / 2.0;
    this.t_reset = this.clk_cfg.initial_reset_cycles * this.clk_cfg.clock_period  ;
  endfunction : init_from_cfg

  virtual task run_phase(uvm_phase phase);
    fork
      run_reset();
      run_clock();
      run_sqr_api();
      drive_items();
    join // We don't expect any of these functions to return
    `uvm_fatal(get_name(),$sformatf("clk_rst_driver threads ended! This should never happen."));
  endtask

  // Clock generation thread
  task run_clock();
    forever begin
      vifclk.driver.clk_drv <= 1'b1;
      #(this.t_high);
      // TBD: Should changing the clock period on a falling edge be allowed?
      vifclk.driver.clk_drv <= 1'b0;
      #(this.t_low);
    end
  endtask : run_clock

  // Reset generation thread
  task run_reset();
    forever begin
      // TBD: Should asynchronous reset be allowed?
      wait (this.t_reset > 0)
      vifclk.driver.reset_n_drv <= 1'b0;
      #(this.t_reset);
      vifclk.driver.reset_n_drv <= 1'b1;
      this.t_reset = 0;
    end
  endtask : run_reset

  // Keeps the sequencer updated (This must be in the driver - no sequencer in passive mode)
  task run_sqr_api();
    fork
      // Update sequencer when reset goes inactive
      forever begin
        @(negedge vifclk.reset_n);
        seqr.set_reset(1'b1);
      end
      // Update sequencer when reset goes active
      forever begin
        @(posedge vifclk.reset_n);
        seqr.set_reset(1'b0);
      end
    join_none
  endtask : run_sqr_api

  // Process driver transaction items
  virtual task drive_items();
    // Get item and update driver class members - these will then be processed by the forever loops running in the driver
    forever begin
      seq_item_port.get_next_item(item); // Waits until the next item becomes available
      // We never want a clock half-period that is 0!
      if (item.t_high > 0) this.t_high  = item.t_high;
      if (item.t_low  > 0) this.t_low   = item.t_low;
      #(clk_cfg.initial_reset_cycles*clk_cfg.clock_period);
      this.t_reset = item.t_reset;  
      seq_item_port.item_done();
    end
  endtask : drive_items


endclass
