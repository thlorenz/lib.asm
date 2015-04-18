; vim: ft=nasm
extern sys_write_stdout
extern hex2decimal

section .data
  ansi_cursor   : db 27,"["
  ansi_cursor_x : db '000;'
  ansi_cursor_y : db '000H'
  ansi_cursor_len equ $-ansi_cursor
section .text

; --------------------------------------------------------------
; ansi_cursor_position
;     moves cursor to given position
;
; args: al = column (x)
;       ah = row    (y)
; out : nothing, all registers preserved
; calls: sys_write_stdout, hex2decimal
; --------------------------------------------------------------
global ansi_cursor_position
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
  ret


;-------+
; TESTS ;
;-------+

%ifenv ansi_cursor_position

global _start
_start:
  nop
;;;
  mov ah, 10
  mov al, 30
  call ansi_cursor_position
;;;
  mov   ecx, x
  mov   edx, x_len
  call sys_write_stdout

.exit:
  mov eax, 1
  mov ebx, 0
  int 80H

section .data
  x:    db 'x'
  x_len equ $-x
%endif
