SRCS=$(EXEC).asm ./strlen.asm ./hex2decimal.asm
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

ifdef debug_strlen
	TASK=debug_strlen
else ifdef debug_hex2decimal
	TASK=debug_hex2decimal
else
	TASK=help
endif

all: $(TASK)

gdb: clean $(EXEC)
	gdb -- $(EXEC)

.SUFFIXES: .asm .o
.asm.o:
	@nasm -f $(NASM_FMT) -g -F $(DBGI) $< -o $@

strlen: strlen.o
	@ld -m $(LD_EMM) -o $@ $^

hex2decimal: hex2decimal.o
	@ld -m $(LD_EMM) -o $@ $^

help:
	@echo "Please run make with a task, i.e.: make debug_strlen=1"

clean:
	@rm -f $(OBJS) $(EXECS)

.PHONY: all clean gdb
