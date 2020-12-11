
class clk_rst_monitor extends uvm_monitor;

  virtual clk_rst_interface vifclk;
  clk_rst_cfg clk_cfg;

  protected clk_rst_seq_item clk_item;
  protected realtime prev_clk_rise;
  protected realtime prev_clk_fall;
  protected realtime t_high;
  protected realtime t_low;
  protected realtime t_reset;

  // Collected item is broadcast on this port
  uvm_analysis_port #(clk_rst_seq_item) mon_item_port;

  `uvm_component_utils(clk_rst_monitor)

  function new (string name, uvm_component parent);
    super.new(name, parent);
    mon_item_port = new("mon_item_port", this);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(clk_rst_cfg)::get(this, "", "clk_cfg", clk_cfg))
      `uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".clk_cfg"})
    if(!uvm_config_db#(virtual clk_rst_interface)::get(this, "", "vifclk", vifclk))
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vifclk"})
    this.clk_item = clk_rst_seq_item::type_id::create("clk_item", this);
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    fork
      collect_clk();
      collect_rst();
    join // None of these are expected to return
    `uvm_fatal(get_name(),$sformatf("clk_rst_monitor threads ended! This should never happen."));
  endtask : run_phase

  // Monitors and broadcasts changes in the clock status
  virtual protected task collect_clk();
    forever begin
      @(posedge vifclk.clk);
      this.t_low = $realtime() - this.prev_clk_fall;
      this.prev_clk_rise = $realtime();
      @(negedge vifclk.clk);
      this.t_high = $realtime() - this.prev_clk_rise;
      this.prev_clk_fall = $realtime();
      
      // If changed, broadcast new clock parameters
      if(   this.t_high != this.clk_item.t_high
         || this.t_low  != this.clk_item.t_low )
      begin
        this.clk_item.kind = clk_rst_seq_item::NEW_CLOCK_SETTING;
        this.clk_item.t_high = this.t_high;
        this.clk_item.t_low  = this.t_low ;
       `uvm_info(get_name(),$sformatf("clk_item: %s",clk_item.convert2string()), UVM_NONE)
        mon_item_port.write(clk_rst_seq_item'(clk_item.clone()));
      end

    end
  endtask : collect_clk

  // Monitors and broadcasts changes in the reset
  virtual protected task collect_rst();
    forever begin
      clk_rst_seq_item rst_item = clk_rst_seq_item::type_id::create("rst_item", this);
      //rst_loop:
      fork
        begin
          @(negedge vifclk.reset_n);
          `uvm_info(get_name(),$sformatf("Reset started..."), UVM_NONE);
          rst_item.kind = clk_rst_seq_item::RESET_ASSERTED;
          this.t_reset = $realtime();
        end
        begin
          @(posedge vifclk.reset_n);
          `uvm_info(get_name(),$sformatf("Reset finished!"), UVM_NONE);
          rst_item.kind = clk_rst_seq_item::RESET_DEASSERTED;
          rst_item.t_reset = $realtime() - this.t_reset;
        end
      join_any
      mon_item_port.write(rst_item);
    end
  endtask : collect_rst
endclass : clk_rst_monitor