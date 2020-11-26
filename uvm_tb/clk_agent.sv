class clk_rst_agent extends uvm_agent;

  //clk_rst_monitor   monitor;
  clk_rst_sequencer sequencer;
  clk_rst_driver    driver;
  clk_rst_monitor   monitor;
  clk_rst_cfg       clk_cfg;
  virtual clk_rst_interface vifclk;

  `uvm_component_utils_begin(clk_rst_agent)
  `uvm_component_utils_end

  function new(string name = "clk_rst_agent", uvm_component parent);
    super.new(name, parent);
    if(!uvm_config_db#(clk_rst_cfg)::get(this, "", "clk_cfg", clk_cfg))
      `uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".clk_cfg"})
    if(!uvm_config_db#(virtual clk_rst_interface)::get(this, "", "vifclk", vifclk))
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vifclk"})
    if (parent == null)
      `uvm_fatal("new", "Null parent is not legal for this component")
    this.is_active = clk_cfg.is_active;
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(clk_rst_cfg)::set(this, "monitor", "clk_cfg", this.clk_cfg);
    uvm_config_db#(virtual clk_rst_interface)::set(this, "monitor", "vifclk", this.vifclk);
    monitor = clk_rst_monitor::type_id::create("monitor", this);

    if (clk_cfg.is_active == UVM_ACTIVE) begin
      uvm_config_db#(clk_rst_cfg)::set(this, "sequencer", "clk_cfg", this.clk_cfg);
      uvm_config_db#(virtual clk_rst_interface)::set(this, "sequencer", "vifclk", this.vifclk);
      sequencer = clk_rst_sequencer::type_id::create("sequencer", this);

      uvm_config_db#(clk_rst_cfg)::set(this, "driver", "clk_cfg", this.clk_cfg);
      uvm_config_db#(virtual clk_rst_interface)::set(this, "driver", "vifclk", this.vifclk);
      driver = clk_rst_driver::type_id::create("driver", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (clk_cfg.is_active == UVM_ACTIVE) begin
      driver.seqr = sequencer;
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction
endclass