module apbuart_property(
    input   logic           PCLK,
    input   logic           PRESETn,
    input   logic           PSELx,
    input   logic           PENABLE,
    input   logic           PWRITE,
    input   logic           PREADY,
    input   logic           PSLVERR,
    input   logic [32-1:0]  PWDATA,
    input   logic [32-1:0]  PADDR,
    input   logic [32-1:0]  PRDATA
	);

  sequence APB_WRITE_CYCLE;
    PWRITE throughout (PSELx && PENABLE) ;
  endsequence

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//------------------- :: Check#1: SETUP_state ::-------------------------
//   In the setup_state PSELx should HIGH and PENABLE should LOW
//   SETUP_state can be determined by detecting rising edge of PSELx
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//	`ifdef SETUP_state
		property SETUP_state;
			@(posedge PCLK) disable iff (!PRESETn)
				$rose(PSELx) |->  !(PENABLE); 
		endproperty
		assert property(SETUP_state)
            $display("-------------------Check#1: SETUP_state PASS------------------");
		else
            `uvm_error("ASSERTION_FAILED",$sformatf("------ :: Check#1: SETUP_state FAILED :: ------"))
//	`endif

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//------------------- :: Check#2: ACCESS_state ::-------------------------
//   In the ACCESS_state occurs right after one cycle of SETUP_state
//   so PENABLE should rise HIGH after one cycle of rising PSELx
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//	`ifdef ACCESS_state
		property ACCESS_state;
			@(posedge PCLK) disable iff (!PRESETn)
				$rose(PSELx) |->  ##1($rose(PENABLE));
		endproperty
		assert property(ACCESS_state)
            $display("-------------------Check#2: ACCESS_state PASS------------------");
		else
            `uvm_error("ASSERTION_FAILED",$sformatf("------ :: Check#2: ACCESS_state FAILED :: ------"))
//	`endif

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//------------------- :: Check#3: valid_PWRITE_PADDR_in_SETUP ::-----------------
//   In SETUP_state, PWRITE and PADDR shouldn't be unknown 
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//	`ifdef valid_PWRITE_PADDR_in_SETUP
		property valid_PWRITE_PADDR_in_SETUP;
			@(posedge PCLK) disable iff (!PRESETn)
				(PSELx && !PENABLE) |-> !($isunknown(PWRITE)) && !($isunknown(PADDR));
		endproperty
		assert property(valid_PWRITE_PADDR_in_SETUP)
            $display("-------------------Check#3: valid_PWRITE_PADDR_in_SETUP PASS------------------");
		else
            `uvm_error("ASSERTION_FAILED",$sformatf("------ :: Check#3: valid_PWRITE_PADDR_in_SETUP FAILED :: ------"))
//	`endif

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//------------------- :: Check#4: valid_PWDATA_in_write_operation ::-----------------
//   In SETUP_state, PWDATA shouldn't be unknown during write operation
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//	`ifdef valid_PWDATA_in_write_operation
		property valid_PWDATA_in_write_operation;
			@(posedge PCLK) disable iff (!PRESETn)
				(PSELx && !PENABLE && PWRITE) |-> !($isunknown(PWDATA));
		endproperty
		assert property(valid_PWDATA_in_write_operation)
            $display("-------------------Check#4: valid_PWDATA_in_write_operation PASS------------------");
		else
            `uvm_error("ASSERTION_FAILED",$sformatf("------ :: Check#4: valid_PWDATA_in_write_operation FAILED :: ------"))
//	`endif

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//------------------- :: Check#5: stable_PWRITE_PADDR_in_ACCESS ::----------------
//   In ACCESS_state, PWRITE and PADDR shouldn't be changed 
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//	`ifdef stable_PWRITE_PADDR_in_ACCESS
		property stable_PWRITE_PADDR_in_ACCESS;
			@(posedge PCLK) disable iff (!PRESETn)
				(PSELx && PENABLE) |-> $stable({PWRITE, PADDR});
		endproperty
		assert property(stable_PWRITE_PADDR_in_ACCESS)
            $display("-------------------Check#5: stable_PWRITE_PADDR_in_ACCESS PASS------------------");
		else
            `uvm_error("ASSERTION_FAILED",$sformatf("------ :: Check#5: stable_PWRITE_PADDR_in_ACCESS FAILED :: ------"))
//	`endif

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//------------------- :: Check#6: stable_PWDATA_during_write_operation ::----------------
//   PWDATA should remains same throught during write operation
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//	`ifdef stable_PWDATA_during_write_operation
		property stable_PWDATA_during_write_operation;
			@(posedge PCLK) disable iff (!PRESETn)
				(PSELx && PENABLE && PWRITE) |-> $stable(PWDATA);
		endproperty
		assert property(stable_PWDATA_during_write_operation)
            $display("-------------------Check#6: stable_PWDATA_during_write_operation PASS------------------");
		else
            `uvm_error("ASSERTION_FAILED",$sformatf("------ :: Check#6: stable_PWDATA_during_write_operation FAILED :: ------"))
//	`endif

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//------------------- :: Check#7: valid_PRDATA_in_read_operation ::----------------
//   PRDATA shouldn't be unknown in read operation upon the assertion of PREADY
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//	`ifdef valid_PRDATA_in_read_operation
		property valid_PRDATA_in_read_operation;
			@(posedge PCLK) disable iff (!PRESETn)
				(PREADY && ~PWRITE) |-> !($isunknown(PRDATA));
		endproperty
		assert property(valid_PRDATA_in_read_operation)
            $display("-------------------Check#7: valid_PRDATA_in_read_operation PASS------------------");
		else
            `uvm_error("ASSERTION_FAILED",$sformatf("------ :: Check#7: valid_PRDATA_in_read_operation FAILED :: ------"))
//	`endif
endmodule
