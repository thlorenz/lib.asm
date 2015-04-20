# lib.asm

Collection of assembly routines in one place to facilitate reuse.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [debugging and testing](#debugging-and-testing)
- [functions](#functions)
  - [conventions](#conventions)
  - [[`ansi_cursor_hide`](ansi_cursor_hide.asm)](#ansi_cursor_hideansi_cursor_hideasm)
    - [documentation](#documentation)
    - [code](#code)
    - [installation](#installation)
  - [[`ansi_cursor_position`](ansi_cursor_position.asm)](#ansi_cursor_positionansi_cursor_positionasm)
    - [documentation](#documentation-1)
    - [code](#code-1)
    - [example](#example)
    - [installation](#installation-1)
  - [[`ansi_cursor_show`](ansi_cursor_show.asm)](#ansi_cursor_showansi_cursor_showasm)
    - [documentation](#documentation-2)
    - [code](#code-2)
    - [installation](#installation-2)
  - [[`ansi_term_clear`](ansi_term_clear.asm)](#ansi_term_clearansi_term_clearasm)
    - [documentation](#documentation-3)
    - [code](#code-3)
    - [example](#example-1)
    - [installation](#installation-3)
  - [[`dword2str`](dword2str.asm)](#dword2strdword2strasm)
    - [documentation](#documentation-4)
    - [code](#code-4)
    - [example](#example-2)
    - [installation](#installation-4)
  - [[`hex2decimal`](hex2decimal.asm)](#hex2decimalhex2decimalasm)
    - [documentation](#documentation-5)
    - [code](#code-5)
    - [example](#example-3)
    - [installation](#installation-5)
  - [[`strlen`](strlen.asm)](#strlenstrlenasm)
    - [documentation](#documentation-6)
    - [code](#code-6)
    - [example](#example-4)
    - [installation](#installation-6)
  - [[`strncmp`](strncmp.asm)](#strncmpstrncmpasm)
    - [documentation](#documentation-7)
    - [code](#code-7)
    - [example](#example-5)
    - [installation](#installation-7)
  - [[`sys_nanosleep`](sys_nanosleep.asm)](#sys_nanosleepsys_nanosleepasm)
    - [documentation](#documentation-8)
    - [code](#code-8)
    - [example](#example-6)
    - [installation](#installation-8)
  - [[`sys_signal`](sys_signal.asm)](#sys_signalsys_signalasm)
    - [documentation](#documentation-9)
    - [code](#code-9)
    - [example](#example-7)
    - [installation](#installation-9)
  - [[`sys_write_stdout`](sys_write_stdout.asm)](#sys_write_stdoutsys_write_stdoutasm)
    - [documentation](#documentation-10)
    - [code](#code-10)
    - [example](#example-8)
    - [installation](#installation-10)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

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

<!-- START lib.asm documentation, generated via `make docs` -->

### [`ansi_cursor_hide`](ansi_cursor_hide.asm)

#### documentation

```asm
; --------------------------------------------------------------
; ansi_cursor_hide
;     hides cursor
;
; args  : none
; out   : nothing, all registers preserved
; calls : sys_write_stdout
; --------------------------------------------------------------
```

#### code

```asm
ansi_cursor_hide:
  push  ecx
  push  edx

  mov   ecx, ansi_hide
  mov   edx, ansi_hide_len
  call sys_write_stdout

  pop   edx
  pop   ecx
```
#### installation

```sh
curl -L https://raw.githubusercontent.com/thlorenz/lib.asm/master/ansi_cursor_hide.asm > ansi_cursor_hide.asm
```
### [`ansi_cursor_position`](ansi_cursor_position.asm)

#### documentation

```asm
; --------------------------------------------------------------
; ansi_cursor_position
;     moves cursor to given position
;
; args: al = column (x)
;       ah = row    (y)
; out : nothing, all registers preserved
; calls: sys_write_stdout, hex2decimal
; --------------------------------------------------------------
```

#### code

```asm
ansi_cursor_position:
  push  eax
  push  ecx
  push  edx
  push  esi

  mov esi, ansi_cursor

  ; clear high part of positions
  mov   word [ ansi_cursor_x ], '00'
  mov   word [ ansi_cursor_y ], '00'

  ; poke coordinates into positions
  mov   ecx, eax
  shr   eax, 8                  ; isolate ah

  mov   esi, ansi_cursor_x + 3  ; hex2decimal stores right before esi
  call hex2decimal

  mov   eax, ecx
  and   eax, 00ffh              ; isolate al

  mov   esi, ansi_cursor_y + 3
  call  hex2decimal

  mov esi, ansi_cursor

  ; sys_write to stdout
  mov   ecx, ansi_cursor
  mov   edx, ansi_cursor_len
  call  sys_write_stdout

  pop   esi
  pop   edx
  pop   ecx
  pop   eax
```

#### example

```asm
  mov ah, 10
  mov al, 30
  call ansi_cursor_position
```

#### installation

```sh
curl -L https://raw.githubusercontent.com/thlorenz/lib.asm/master/ansi_cursor_position.asm > ansi_cursor_position.asm
```
### [`ansi_cursor_show`](ansi_cursor_show.asm)

#### documentation

```asm
; --------------------------------------------------------------
; ansi_cursor_show
;     shows cursor
;
; args: none
; out : nothing, all registers preserved
; calls: sys_write_stdout
; --------------------------------------------------------------
```

#### code

```asm
ansi_cursor_show:
  push  ecx
  push  edx

  mov   ecx, ansi_show
  mov   edx, ansi_show_len
  call sys_write_stdout

  pop   edx
  pop   ecx
```
#### installation

```sh
curl -L https://raw.githubusercontent.com/thlorenz/lib.asm/master/ansi_cursor_show.asm > ansi_cursor_show.asm
```
### [`ansi_term_clear`](ansi_term_clear.asm)

#### documentation

```asm
; --------------------------------------------------------------
; ansi_term_clear
;     clears the terminal
;
; args: none
; out : nothing, all registers preserved
; calls: sys_write_stdout
; --------------------------------------------------------------
```

#### code

```asm
ansi_term_clear:
  push  ecx
  push  edx

  mov   ecx, ansi_clear
  mov   edx, ansi_clear_len
  call sys_write_stdout

  pop   edx
  pop   ecx
```

#### example

```asm
  call ansi_term_clear
```

#### installation

```sh
curl -L https://raw.githubusercontent.com/thlorenz/lib.asm/master/ansi_term_clear.asm > ansi_term_clear.asm
```
### [`dword2str`](dword2str.asm)

#### documentation

```asm
; --------------------------------------------------------------
; dword2str
;   writes given dword (i.e. 32-bit) register BEFORE the given address
;   the written string is 14 (2 + 3 * 4) bytes long
;
; args: eax = dword to store
; out : esi = address of the 48 bytes string in which the result is stored
;       all other registers preserved
; --------------------------------------------------------------
```

#### code

```asm
dword2str:
  push  eax
  push  ebx

  mov   ebx, eax                          ; copy input
  mov   esi, 3                            ; start writing at most right slot

  xor   eax, eax

.process_bx:
  mov   al, bl                            ; lowest nyble          00 0f
  and   al, 0fh                           ; mask out high nybble
  mov   al, byte [ digits + eax ]
  mov   byte [ hexstr + 3 * esi + 2 ], al

  mov   al, bl                            ; second lowest nybble  00 f0
  shr   al, 4
  mov   al, byte [ digits + eax ]
  mov   byte [ hexstr + 3 * esi + 1 ], al

  dec   esi                               ; move over one slot for writing

  mov   al, bh                            ; third lowest nyble    0f 00
  and   al, 0fh                           ; mask out high nybble
  mov   al, byte [ digits + eax ]
  mov   byte [ hexstr + 3 * esi + 2 ], al

  mov   al, bh                            ; fourth lowest nyble   f0 00
  shr   al, 4
  mov   al, byte [ digits + eax ]
  mov   byte [ hexstr + 3 * esi + 1 ], al

  or    esi, 0
  jz   .done
                                          ; repeat same for upper upper 16-bits
  dec   esi                               ; start at 3rd slot from right
  shr   ebx, 16                           ; push upper 16 bits of ebx into bx
  jmp   .process_bx

.done:
  mov   esi, hexstr_start

  pop  ebx
  pop  eax

```

#### example

```asm
  mov   eax, 0x0123abcd           ; number we are printing
  call  dword2str

  ; esi points to start of 14 byte string
  mov   eax, 4
  mov   ebx, 1
  mov   ecx, esi
  mov   edx, 14
  int   80H
```

#### installation

```sh
curl -L https://raw.githubusercontent.com/thlorenz/lib.asm/master/dword2str.asm > dword2str.asm
```
### [`hex2decimal`](hex2decimal.asm)

#### documentation

```asm
; --------------------------------------------------------------
; hex2decimal
;   converts given number to decimal string and stores it BEFORE the given address
;
; args: esi = address of the end of the string in which to store the decimal number
;       eax = number to store
; out : esi = addr in string at which the number starts
;       eax = length of stored string
;       all other registers preserved
; --------------------------------------------------------------
```

#### code

```asm
hex2decimal:

  push  ebx
  push  ecx
  push  edx

  mov   ebx, 10             ; base is 10
  mov   ecx, esi            ; remember end of string
.convert:
  xor   edx, edx            ; clear edx
  div   ebx                 ; -> quotient in eax, remainder in edx

  add   dl, '0'             ; make printable
  cmp   dl, '9'             ; is it a hex digit?
  jbe   .store              ; if not store as is

  add   dl, 'A' - '0' - 10  ; adjust hexdigit

.store:
  dec   esi                 ; move back one position
  mov   byte [esi], dl      ; store converted digit
                            ;   stosb would be faster here, but then we'd need to
                            ;   rearrange which is in what register which also takes time
  or    eax, eax            ; did division result in 0?
  jnz   .convert            ; if not keep converting

  sub   ecx, esi            ; calculate length of string
  mov   eax, ecx

  pop   edx
  pop   ecx
  pop   ebx

```

#### example

```asm
  mov   eax, 0x123f           ; number we are printing
  mov   esi, buffer + 32      ; end of buffer
  call  hex2decimal
```

#### installation

```sh
curl -L https://raw.githubusercontent.com/thlorenz/lib.asm/master/hex2decimal.asm > hex2decimal.asm
```
### [`strlen`](strlen.asm)

#### documentation

```asm
; --------------------------------------------------------------
; strlen
;   determines length of given string (not counting the 0 terminator)
;
; args: esi = address of the string whose length to determine
;             string needs to end with 0 terminator (ala C strings)
; out : eax = the length of the string including the 0 terminator
;       all other registers preserved
; --------------------------------------------------------------
```

#### code

```asm
strlen:

  push  ecx
  push  edi

  mov   edi, esi
  xor   eax, eax          ; we are searching for 0
  mov   ecx, 0000ffffh    ; expecting strings no longer than 65535 bytes
  cld                     ; search upwards in memory

  repne scasb             ; read starting at edi until we find 0 or run out of bytes
  jnz    .fail

  mov   eax, 0000fffeh    ; ecx was decremented each time (one too many since it includes 0 terminator)
  sub   eax, ecx          ; so substracting from original (ecx - 1) gets us the string length

  pop   edi
  pop   ecx

  ret

.fail:
  mov eax, 4              ; log error
  mov ebx, 1
  mov ecx, ENDNOTFOUNDMSG
  mov edx, ENDNOTFOUNDLEN
  int 80H

  mov eax, 1              ; exit with code 1
  mov ebx, 1
  int 80H

section .data
  ENDNOTFOUNDMSG: db "FATAL: Unable to find end of string, max size exceeded"
```

#### example

```asm
  mov esi, SAMPLEMSG
  call strlen
```

#### installation

```sh
curl -L https://raw.githubusercontent.com/thlorenz/lib.asm/master/strlen.asm > strlen.asm
```
### [`strncmp`](strncmp.asm)

#### documentation

```asm
; --------------------------------------------------------------
; strncmp
;   compares two strings for char by char until the given length
;
; args: esi = address of first string
;       edi = address of second string
;       eax = index until which to check (string length)
; out : eax = 0 if strings are equal, otherwise > 0
;       all other registers preserved
; --------------------------------------------------------------
```

#### code

```asm
strncmp:
  push  ecx
  push  edi
  push  esi

  mov   ecx, eax      ; loop until we reach given length

  cld
.while_equal:
  lodsb               ; loads si into al and incs si
  scasb               ; compares di to al and incs di
  loopz .while_equal  ; loop until cmp unsets ZF or ecx becomes zero

  mov   eax, ecx      ; ecx will be zero unless loop finished due to inequality

  pop   esi
  pop   edi
  pop   ecx

```

#### example

```asm
  mov   esi, uno
  mov   edi, one_in_es
  mov   eax, uno.len
  call  strncmp

  or    eax, eax        ; eax is zero if strings were equal
  jnz   .fail
```

#### installation

```sh
curl -L https://raw.githubusercontent.com/thlorenz/lib.asm/master/strncmp.asm > strncmp.asm
```
### [`sys_nanosleep`](sys_nanosleep.asm)

#### documentation

```asm
; --------------------------------------------------------------
; sys_nanosleep
;     sleeps for given amount of seconds + nanoseconds
;     @see 'man nanosleep'
;
; args: ecx = number of seconds to sleep for
;       edx = number of nanoseconds to sleep for
; out : nothing, all registers preserved
; --------------------------------------------------------------
```

#### code

```asm
sys_nanosleep:
  push  eax
  push  ebx
  push  ecx

                                ; build timespec struct on top of the stack
  mov   dword [ esp - 8 ], ecx  ; push seconds (tv_sec)
  mov   dword [ esp - 4 ], edx  ; followed by nanoseconds (tv_nsec)
                                ; esp now points @ecx

  mov   eax, SYS_NANOSLEEP
  lea   ebx, [ esp - 8]         ; point ebx at timespec
  xor   ecx, ecx                ; don't need updates about time slept
  int   80h

  pop   ecx
  pop   ebx
  pop   eax
```

#### example

```asm
  mov   ecx, 1                  ; sleep exactly one and
  mov   edx, 500 * milliseconds ; a half second
  call  sys_nanosleep
```

#### installation

```sh
curl -L https://raw.githubusercontent.com/thlorenz/lib.asm/master/sys_nanosleep.asm > sys_nanosleep.asm
```
### [`sys_signal`](sys_signal.asm)

#### documentation

```asm
; --------------------------------------------------------------
; sys_signal
;     installs a signal handler
;
; args: ebx = the signal number to handle (see signals.mac)
;       ecx = the address of the handler
; out : nothing, all registers preserved
; --------------------------------------------------------------
```

#### code

```asm
sys_signal:
  push  eax
  mov   eax, 48 ; sys_signal
  int   80h
  pop   eax
```

#### example

```asm
%include "signals.mac"

section .text

sig_int_handler:
  mov   ecx, caught_sigint
  mov   edx, caught_sigint_len
  call  sys_write_stdout
  jmp   exit

sig_term_handler:
  mov   ecx, caught_sigterm
  mov   edx, caught_sigterm_len
  call  sys_write_stdout
  jmp   exit

  mov   ebx, SIGINT           ; install SIGINT handler (Ctrl-C)
  mov   ecx, sig_int_handler
  call  sys_signal

  mov   ebx, SIGTERM          ; install SIGTERM handler (kill <pid>)
  mov   ecx, sig_term_handler
  call  sys_signal
```

#### installation

```sh
curl -L https://raw.githubusercontent.com/thlorenz/lib.asm/master/sys_signal.asm > sys_signal.asm
```
### [`sys_write_stdout`](sys_write_stdout.asm)

#### documentation

```asm
; --------------------------------------------------------------
; sys_write_stdout
;     writes string at given address to stdout
;
; args: ecx = address of string to write
;       edx = length of string to write
; out : nothing, all registers preserved
; --------------------------------------------------------------
```

#### code

```asm
sys_write_stdout:
  push  eax
  push  ebx

  mov   eax, 4
  mov   ebx, 1
  int   80h

  pop   ebx
  pop   eax
```

#### example

```asm
section .data
  msg:      db 10,"Hello World!",10
  msg_len   equ $-msg

section .text

  mov   ecx, msg
  mov   edx, msg_len
  call sys_write_stdout
```

#### installation

```sh
curl -L https://raw.githubusercontent.com/thlorenz/lib.asm/master/sys_write_stdout.asm > sys_write_stdout.asm
```

<!-- END lib.asm documentation -->
