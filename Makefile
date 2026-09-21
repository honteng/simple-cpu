IVERILOG := iverilog
VVP      := vvp
FLAGS    := -g2012

RTL := \
	alu.v \
	alu_control.v \
	register_file.v \
	instruction_decoder.v \
	program_counter.v \
	instruction_memory.v \
	data_memory.v \
	simple_cpu.v \
	control_unit.v \
	csr_file.v \
	trap_controller.v \
	control_flow_unit.v \
	interrupt_controller.v

UNIT_TESTS := \
	exception_tb \
	csr_tb \
	control_flow_unit_tb

INTEGRATION_TESTS := \
	external_interrupt_tb \
	timer_interrupt_tb

TESTS := $(UNIT_TESTS) $(INTEGRATION_TESTS)

.PHONY: all test clean $(TESTS)

all: test

test: $(TESTS)
	@echo ""
	@echo "All tests passed."

# --------------------------------------------------
# Unit and integration tests
# --------------------------------------------------

$(TESTS):
	@echo "==> Running $@"
	@$(IVERILOG) $(FLAGS) -s $@ -o $@ $@.v $(RTL)
	@$(VVP) $@

clean:
	@rm -f $(TESTS) *.vcd *.fst
