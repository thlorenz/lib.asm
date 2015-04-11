; vim: ft=nasm

section .text
; --------------------------------------------------------------
; sys_write_stdout
;     writes string at given address to stdout
;
; ARGS:
;   ecx:  address of string to write
;   edx:  length of string to write
;
; --------------------------------------------------------------
global sys_write_stdout
sys_write_stdout:
  push  eax
  push  ebx

  mov   eax, 4
  mov   ebx, 1
  int   80h

  pop   ebx
  pop   eax
  ret

;-------+
; TESTS ;
;-------+

%ifenv sys_write_stdout
section .data
  msg:      db 10,"Hello World!",10
  msg_len   equ $-msg

section .text
global _start

_start:

  nop

  mov   ecx, msg
  mov   edx, msg_len
  call sys_write_stdout

.exit:
  mov eax, 1
  mov ebx, 0
  int 80H

%endif
