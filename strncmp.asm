; vim: ft=nasm

section .text
; --------------------------------------------------------------
; strncmp
;   compares two strings for char by char until the given length
;
; args: esi = effective address of first string  (lea)
;       edi = effective address of second string (lea)
;       eax = index until which to check (string length)
; out : eax = 0 if strings are equal, otherwise > 0
;       all other registers preserved
; --------------------------------------------------------------
global strncmp
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

  ret

;-------+
; TESTS ;
;-------+

%ifenv strncmp
section .data
  fail      : db 10,"FAILED!",10,0
    .len    : equ $-fail
  pass      : db 10, "PASSED!",10,0
    .len    : equ $-pass
  uno       : db "uno"
    .len    : equ $-uno
  one_in_es : db "uno"
    .len    : equ $-one_in_es
  eins      : db "eins"
    .len    : equ $-eins

section .text

global _start

_start:
  nop

;;;
  mov   esi, uno
  mov   edi, one_in_es
  mov   eax, uno.len
  call  strncmp

  and   eax, eax        ; eax is zero if strings were equal
  jnz   .fail
;;;

  mov   esi, uno
  mov   edi, eins 
  mov   eax, uno.len
  call strncmp

  and  eax, eax
  jz   .fail

.pass:
  mov   eax, 4
  mov   ebx, 1
  mov   ecx, pass
  mov   edx, pass.len
  int   80h

  mov   ebx, 0
  jmp   .exit

.fail:
  mov   eax, 4
  mov   ebx, 1
  mov   ecx, fail
  mov   edx, fail.len
  int   80h

  mov   ebx, 1
.exit:
  mov   eax, 1
  int   80H
%endif
