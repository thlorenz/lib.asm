; vim: ft=nasm
extern sys_write_stdout

section .data
  ansi_show: db 27,'[?25h'
  ansi_show_len equ $-ansi_show
section .text

; --------------------------------------------------------------
; ansi_cursor_show
;     shows cursor
;
; CALLS: sys_write_stdout
; --------------------------------------------------------------
global ansi_cursor_show
ansi_cursor_show:
  push  ecx
  push  edx

  mov   ecx, ansi_show
  mov   edx, ansi_show_len
  call sys_write_stdout

  pop   edx
  pop   ecx
  ret
