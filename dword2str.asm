; vim: ft=nasm

section .data
  hexstr_start: db "0x"
  hexstr: db " 00 00 00 00"
    .len: equ $-hexstr
  digits: db "0123456789abcdef"

section .text
; --------------------------------------------------------------
; dword2str
;   writes given dword (i.e. 32-bit) register BEFORE the given address
;   the written string is 14 (2 + 3 * 4) bytes long
;
; args: eax = dword to store
; out : esi = address of the 14 bytes string in which the result is stored
;       all other registers preserved
; --------------------------------------------------------------
global dword2str
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
                                          ; repeat same for upper 16-bits
  dec   esi                               ; start at 3rd slot from right
  shr   ebx, 16                           ; push upper 16 bits of ebx into bx
  jmp   .process_bx

.done:
  mov   esi, hexstr_start

  pop  ebx
  pop  eax

  ret

;-------+
; TESTS ;
;-------+

%ifenv dword2str

extern strncmp

section .data
  fail        : db 10,"FAILED!",10,0
    .len      : equ $-fail
  pass        : db 10, "PASSED!",10,0
    .len      : equ $-pass
  expected    : db "0x 01 23 ab cd"
    .len      : equ $-expected

section .text

global _start

_start:
  nop

;;;
  mov   eax, 0x0123abcd           ; number we are printing
  call  dword2str

  ; esi points to start of 14 byte string
  mov   eax, 4
  mov   ebx, 1
  mov   ecx, esi
  mov   edx, 14
  int   80H
;;;

; Assert result (in esi) is 0x01 23 ab cd
.test:
  mov   edi, expected
  mov   eax, expected.len
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
