typedef class clk_rst_seq_item;
class clk_rst_sequencer extends uvm_sequencer#(clk_rst_seq_item);

  clk_rst_cfg clk_cfg;
  virtual clk_rst_interface vifclk;

  bit reset = 0; // 1 = Reset, 0 = Not reset.

  `uvm_component_utils_begin(clk_rst_sequencer)
  `uvm_component_utils_end

  function new(string name = "clk_rst_sequencer", uvm_component parent = null);
    super.new(name, parent);
    if (parent == null) begin
      `uvm_fatal("new", "Null parent is not legal for this component")
    end
    set_arbitration(UVM_SEQ_ARB_RANDOM);
    uvm_config_db#(clk_rst_sequencer)::set(parent, "", "sequencer", this); // Put myself in cfg db so others can get access to my reset set/get methods. Look me up by agent + "sequencer".
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(clk_rst_cfg)::get(this, "", "clk_cfg", clk_cfg))
      `uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".clk_cfg"})
    if(!uvm_config_db#(virtual clk_rst_interface)::get(this, "", "vifclk", vifclk))
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vifclk"})
  endfunction

  virtual task wait_reset_exit();
    wait (reset == 0);
  endtask

  virtual task wait_reset_entry();
    wait (reset == 1);
  endtask

  virtual function void set_reset(bit value);
    reset = value;
  endfunction

  virtual function bit get_reset();
    return reset;
  endfunction
endclass
