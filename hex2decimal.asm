; vim: ft=nasm

section .text
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
global hex2decimal
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
  and   eax, eax            ; did division result in 0?
  jnz   .convert            ; if not keep converting

  sub   ecx, esi            ; calculate length of string
  mov   eax, ecx

  pop   edx
  pop   ecx
  pop   ebx

  ret

;-------+
; TESTS ;
;-------+

%ifenv hex2decimal

extern strncmp

section .data
  buffer      : times 32 db 0
  afterbuffer : db "!!!you should not see this"
  expected    : db "4671"
  fail        : db 10,"FAILED!",10,0
    .len      : equ $-fail
  pass        : db 10, "PASSED!",10,0
    .len      : equ $-pass

section .text

global _start

_start:

  nop

.example:
;;;
  mov   eax, 0x123f           ; number we are printing
  mov   esi, buffer + 32      ; end of buffer
  call  hex2decimal
;;;
  ; syswrite
  ; esi points to start of number string
  ; eax set to length of number string
  mov   edx, eax
  mov   eax, 4
  mov   ebx, 1
  mov   ecx, esi
  int   80H

; Assert result (in esi) is 4671
.test:
  mov   edi, expected
  mov   eax, 4
  call  strncmp  

  and   eax, eax
  jnz   .fail

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
