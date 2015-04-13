; vim: ft=nasm
extern sys_write_stdout

section .data
  ansi_clear: db 27,'[2J'
  ansi_clear_len equ $-ansi_clear
section .text

; --------------------------------------------------------------
; ansi_term_clear
;     clears the terminal
;
; args: none
; out : nothing, all registers preserved
; calls: sys_write_stdout
; --------------------------------------------------------------
global ansi_term_clear
ansi_term_clear:
  push  ecx
  push  edx

  mov   ecx, ansi_clear
  mov   edx, ansi_clear_len
  call sys_write_stdout

  pop   edx
  pop   ecx
  ret

;-------+
; TESTS ;
;-------+

%ifenv ansi_term_clear

global _start
_start:
  nop
  call ansi_term_clear

.exit:
  mov eax, 1
  mov ebx, 0
  int 80H
%endif
