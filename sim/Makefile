TEST=apbuart_config_test
SCALE=1ns
FILE = testname.f
TEST_NAMES =`cat $(FILE)`

compile:
			@echo "Compiling Design"
			vcs -sverilog -ntb_opts uvm-1.2 -f flist -timescale=1ns/1ps -cm line+tgl+cond+branch+assert+fsm -assert -full64 -LDFLAGS '-Wl,--no-as-needed'

run:
			@echo "Running Tests"
			@for i in $(TEST_NAMES); do \
				./simv -l $$i.log +UVM_TIMEOUT=900000000 +UVM_TESTNAME=$$i;\
			done

test-list:
			@for i in $(TEST_NAMES); do \
				echo $$i; \
			done

run_cov_all:		
			@echo "Running Tests with Coverage"
			rm -rf ${TEST_NAMES} ; mkdir ${TEST_NAMES}
			@for i in $(TEST_NAMES); do \
				./simv -l $$i.log +UVM_TIMEOUT=900000000 +UVM_TESTNAME=$$i -cm line+tgl+cond+branch+assert+fsm; \
				cp -rf simv.vdb $$i/; \
				mv $$i.log $$i/; \
			done
			urg -dir *_test/*.vdb -elfile exclusion.el -excl_bypass_checks	

run-test:
			@echo "Running $(TEST) Test"
			./simv -l ${TEST}.log +UVM_TIMEOUT=900000000 +UVM_TESTNAME=${TEST}

dve: 		
			dve -covdir *_test/*.vdb &

clean:
			@echo "Cleaning up...."
			rm -rf csrc DVEfiles urgReport simv.vdb ${TEST_NAMES} inter.vpd dump.vcd simv simv.daidir ucli.key vc_hdrs.h vcs.log .inter.vpd.uvm *.log
