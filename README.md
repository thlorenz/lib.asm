# lib.asm

Collection of assembly routines in one place to facilitate reuse.

## debugging and testing

In order to debug the routines you should first clone this repository or download the included `Makefile`.

Each file will hold one routine. Most include a `_start` entry for testing and you can create an executable via `make
<id>`.
For example to create an executable `strlen` that runs tests when executed or debugged, do: `make strlen`.

The following targets can be run:

```
ansi_cursor_position
ansi_term_clear
hex2decimal
strlen
sys_write_stdout
```


## functions

### conventions

- all registers are preserved unless a return value is required
- values are returned inside of EAX and if needed in EDX
- args differ from function to function with the general rule that EAX is used for most inputs and ESI for pointers to
  strings

### [strlen](strlen.asm)

```asm
; --------------------------------------------------------------
; strlen
;   determines length of given string (not counting the 0 terminator)
;
; ARGS:
;   edi:  address of the string whose length to determine
;         string needs to end with 0 terminator (ala C strings)
; RETURNS:
;   edx:  the length of the string including the 0 terminator
; --------------------------------------------------------------
```

#### Installation

```sh
curl -L https://raw.githubusercontent.com/thlorenz/lib.asm/master/strlen.asm > strlen.asm
```

### [hex2decimal](hex2decimal.asm)

```asm
; --------------------------------------------------------------
; hex2decimal
;   converts given number to decimal string and stores it BEFORE the given address
;
; ARGS:
;   esi:  address of the end of the string in which to store the decimal number
;   eax:  number to store
; RETUNRS:
;   esi:  addr in string at which the number starts
;   edx:  length of stored string
; --------------------------------------------------------------
```

#### Installation

```sh
curl -L https://raw.githubusercontent.com/thlorenz/lib.asm/master/hex2decimal.asm > hex2decimal.asm
```
