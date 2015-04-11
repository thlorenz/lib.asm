SRCS=$(wildcard *.asm)
OBJS= $(subst .asm,.o, $(SRCS))
EXECS=$(subst .asm,, $(SRCS))

BITS:=32
ifeq ($(BITS),64)
NASM_FMT=elf64
LD_EMM=elf_x86_64
else
NASM_FMT=elf32
LD_EMM=elf_i386
endif

DBGI=dwarf

# This env var is picked up by the macro assembly step via `%ifenv id` to include `_start`
export $(MAKECMDGOALS)

all:
	@echo "Please run make with a task, i.e.: \"make strlen\""
	@echo "In case you get any of the below errors, run: \"make clean\""
	@echo "  - \"multiple definition of '_start'\""
	@echo "  - \"cannot find entry symbol _start\""

.SUFFIXES: .asm .o
.asm.o:
	@nasm -f $(NASM_FMT) -g -F $(DBGI) $< -o $@

.o:
	@ld -m $(LD_EMM) -o $@ $^

# Targets (routines that include example/test at optional `_start` section)
# included here to show as explicit make targets (i.e. for 'make <Tab>' autocomplete)
ansi_cursor_position: sys_write_stdout.o hex2decimal.o

ansi_cursor_up: sys_write_stdout.o

ansi_term_clear: sys_write_stdout.o


hex2decimal:

sys_signal: sys_write_stdout.o

strlen:

sys_write_stdout:

# End executable targets

clean:
	@rm -f $(OBJS) $(EXECS)

.PHONY: all clean
