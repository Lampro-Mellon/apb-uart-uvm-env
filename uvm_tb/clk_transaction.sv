class clk_rst_seq_item extends uvm_sequence_item;

  typedef enum {RESET_ASSERTED, RESET_DEASSERTED, NEW_CLOCK_SETTING} clk_rst_seq_item_kind_t;
  clk_rst_seq_item_kind_t kind;

  realtime t_high;
  realtime t_low;
  realtime t_reset;

  `uvm_declare_p_sequencer(clk_rst_sequencer)
  `uvm_object_utils_begin(clk_rst_seq_item)
    `uvm_field_enum(clk_rst_seq_item_kind_t, kind, UVM_ALL_ON | UVM_NOPRINT)
    `uvm_field_real(t_high, UVM_ALL_ON | UVM_NOPRINT)
    `uvm_field_real(t_low, UVM_ALL_ON | UVM_NOPRINT)
    `uvm_field_real(t_reset, UVM_ALL_ON | UVM_TIME | UVM_NOPRINT)
  `uvm_object_utils_end

  virtual function void init(realtime t_high, realtime t_low, realtime t_reset);
    this.t_high  = t_high  ;
    this.t_low   = t_low   ;
    this.t_reset = t_reset ;
  endfunction

  function new(string name = "clk_rst_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    convert2string = {
      super.convert2string(),
      $sformatf(" kind=%s t_high=%0t t_low=%0t t_reset=%0t",this.kind.name(),this.t_high,this.t_low,this.t_reset)
    };
  endfunction

endclass
