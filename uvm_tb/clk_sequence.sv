virtual class clk_rst_seq_base extends uvm_sequence#(clk_rst_seq_item);

  `uvm_declare_p_sequencer(clk_rst_sequencer)

  function new(string name="clk_rst_base_sequence");
    super.new(name);
  endfunction : new

  virtual task pre_body();
    uvm_phase starting_phase = get_starting_phase();
    if (starting_phase!=null) begin
      `uvm_info(get_type_name(),
        $sformatf("%s pre_body() raising %s objection",
          get_sequence_path(),
          starting_phase.get_name()), UVM_MEDIUM)
      starting_phase.raise_objection(this);
    end
  endtask : pre_body

  virtual task post_body();
    uvm_phase starting_phase = get_starting_phase();
    if (starting_phase!=null) begin
      `uvm_info(get_type_name(),
        $sformatf("%s post_body() dropping %s objection",
          get_sequence_path(),
          starting_phase.get_name()), UVM_MEDIUM)
      starting_phase.drop_objection(this);
    end
  endtask : post_body

  virtual task body();
    req = clk_rst_seq_item::type_id::create("req",this.p_sequencer,this.get_full_name);
    start_item(req);
    init_item(req);
    randomize_item(req);
    finish_item(req);
  endtask : body

  // Hook to initialize sequence item
  virtual function void init_item(clk_rst_seq_item item);
  endfunction : init_item

  // Hook to randomize sequence item (possibility to add randomize with
  virtual function void randomize_item(clk_rst_seq_item item);
    if (!req.randomize())
      `uvm_fatal(this.get_name(), "Failed to randomize sequence item");
  endfunction : randomize_item

endclass : clk_rst_seq_base

// This sequence can be used to update either or both the clock setting and pull the reset.
class clk_rst_default_seq extends clk_rst_seq_base;

  // Add local random fields and constraints here
  rand bit  [7:0]  t_clk_period ;
  rand bit  [2:0]  t_reset;

  `uvm_object_utils_begin(clk_rst_default_seq)
    `uvm_field_int (t_clk_period, UVM_ALL_ON)
    `uvm_field_int (t_reset, UVM_ALL_ON)
  `uvm_object_utils_end

  // Default constraint
  constraint c_t_period 
  {
    t_clk_period inside {10,20,100}; // constraint on 10 , 50 and 100 MHz Clock
  }

  function new(string name="clk_rst_example_sequence");
    super.new(name);
  endfunction : new

  // Hook to initialize this sequence
  virtual function void init_clk(realtime period);
    this.t_clk_period.rand_mode(0);
    this.t_clk_period = period;
  endfunction : init_clk

  virtual function void init_rst(realtime rst);
    this.t_reset.rand_mode(0);
    this.t_reset = rst;
  endfunction : init_rst

  // Hook to initialize sequence item
  virtual function void init_item(clk_rst_seq_item item);
    item.t_high  = this.t_clk_period / 2;
    item.t_low   = this.t_clk_period / 2;
    item.t_reset = this.t_reset;
  endfunction : init_item

endclass : clk_rst_default_seq

// This sequence can be used to update update the clock settings using frequency as an input.
// No reset will be applied
class clk_rst_update_clock_freq_seq extends clk_rst_seq_base;

  // Add local random fields and constraints here
  rand bit [1:0] freq_mhz;

  `uvm_object_utils_begin(clk_rst_update_clock_freq_seq)
    `uvm_field_real(freq_mhz, UVM_ALL_ON | UVM_NOPRINT)
  `uvm_object_utils_end

  function new(string name="clk_rst_update_clock_freq_seq");
    super.new(name);
  endfunction : new

  // Hook to initialize this sequence
  virtual function void init(real freq);
    this.freq_mhz.rand_mode(0);
    this.freq_mhz = freq;
  endfunction : init

  // Hook to initialize sequence item
  virtual function void init_item(clk_rst_seq_item item);
    realtime period = clk_rst_pkg::freq2period($sformatf("%f MHz",freq_mhz), 1.0);
    $display(period);
    item.t_high  = period / 2;
    item.t_low   = period / 2;
  endfunction : init_item

endclass : clk_rst_update_clock_freq_seq


// This sequence can be used to pull the reset for a specific amount of time.
// Clock settings will not be changed
class clk_rst_reset_seq extends clk_rst_seq_base;

  // Add local random fields and constraints here
  rand bit [3:0] t_reset = 1; //Default value if user does not call .init() or .randomize()

  // Default constraint
  constraint c_t_reset 
  {
    soft this.t_reset >= 1;
    soft this.t_reset <= 10;
  }

  `uvm_object_utils_begin(clk_rst_reset_seq)
    `uvm_field_real(t_reset, UVM_ALL_ON | UVM_NOPRINT)
  `uvm_object_utils_end

  function new(string name="clk_rst_reset_seq");
    super.new(name);
  endfunction : new

  // Hook to initialize this sequence
  virtual function void init(realtime rst);
    this.t_reset.rand_mode(0);
    this.t_reset = rst;
  endfunction : init

  // Hook to initialize sequence item
  virtual function void init_item(clk_rst_seq_item item);
    item.t_reset = this.t_reset;
  endfunction : init_item

endclass : clk_rst_reset_seq
