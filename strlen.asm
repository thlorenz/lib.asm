; vim: ft=nasm

section .text
; --------------------------------------------------------------
; strlen
;   determines length of given string (not counting the 0 terminator)
;
; args: esi = address of the string whose length to determine
;             string needs to end with 0 terminator (ala C strings)
; out : eax = the length of the string including the 0 terminator
;       all other registers preserved
; --------------------------------------------------------------
global strlen
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
  ENDNOTFOUNDLEN  equ $-ENDNOTFOUNDMSG

;-------+
; TESTS ;
;-------+

%ifenv strlen

%macro _sys_write 2
  mov eax, 4
  mov ebx, 1
  mov ecx, %1
  mov edx, %2
  int 80H
%endmacro

section .data

SAMPLEMSG:   db "0123456789",0
SAMPLELEN    equ $-SAMPLEMSG
STRLEN       equ SAMPLELEN-1

FAILMSG:  db "FAILED!",10,0
FAILLEN   equ $-FAILMSG
PASSMSG:  db "PASSED!",10,0
PASSLEN   equ $-PASSMSG

section .text

global _start

_start:
  nop
;;;
  mov esi, SAMPLEMSG
  call strlen
;;;
  cmp eax, STRLEN

  jz .pass

.fail:
  _sys_write FAILMSG, FAILLEN
  mov ebx, 1
  jmp .exit
.pass:
  _sys_write PASSMSG, PASSLEN
  mov ebx, 0
.exit:
  mov eax, 1
  int 80H

%endif
