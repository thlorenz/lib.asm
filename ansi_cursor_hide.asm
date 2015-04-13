; vim: ft=nasm
extern sys_write_stdout

section .data
  ansi_hide: db 27,'[?25l'
  ansi_hide_len equ $-ansi_hide
section .text

; --------------------------------------------------------------
; ansi_cursor_hide
;     hides cursor
;
; args  : none
; out   : nothing, all registers preserved
; calls : sys_write_stdout
; --------------------------------------------------------------
global ansi_cursor_hide
ansi_cursor_hide:
  push  ecx
  push  edx

  mov   ecx, ansi_hide
  mov   edx, ansi_hide_len
  call sys_write_stdout

  pop   edx
  pop   ecx
  ret
