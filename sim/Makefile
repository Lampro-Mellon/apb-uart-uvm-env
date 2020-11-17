TEST=apbuart_config_test
FILE = testname.f
TEST_NAMES =`cat $(FILE)`

compile:
			@echo "Compiling Design"
			vcs -sverilog -ntb_opts uvm-1.2 -f flist -full64 -LDFLAGS '-Wl,--no-as-needed'

run:
			@echo "Running Tests"
			@for i in $(TEST_NAMES); do \
				./simv -l $$i.log +UVM_TIMEOUT=900000000 +UVM_TESTNAME=$$i;\
			done

test-list:
			@for i in $(TEST_NAMES); do \
				echo $$i; \
			done

run-test:
			@echo "Running $(TEST) Test"
			./simv -l ${TEST}.log +UVM_TIMEOUT=900000000 +UVM_TESTNAME=${TEST}


clean:
			@echo "Cleaning up...."
			rm -rf csrc DVEfiles inter.vpd dump.vcd simv simv.daidir ucli.key vc_hdrs.h vcs.log .inter.vpd.uvm *.log
