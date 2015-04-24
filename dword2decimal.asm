; vim: ft=nasm

section .bss
  buffer:             ; make space for maximum case, may not all be used
    .exx:     resb 10 ; largest 32-bit int is 2,147,483,647 (10 digits)
    .xx:      resb  7 ; largest 16-bit int is 65,535 (7 digits)
    .xh:      resb  3 ; largest  8-bit int is 255 (3 digits)
    .xl:      resb  3
    .colons:  resb  3 ; each : takes one byte

section .text
extern hex2decimal

; --------------------------------------------------------------
; dword2decimal
;   converts given dword register value to decimal string
;   the output format is as follows, using eax as example: 'eax:ax:ah:al'
;
; args: eax = dword (register content) number to store
; out : esi = addr in string at which the number starts
;       eax = length of stored string
;       all other registers preserved
; --------------------------------------------------------------
global dword2decimal
dword2decimal:
  push  ebx

  mov   ebx, eax

  lea   esi, [ buffer.colons + 3 ]  ; start writing at end of available buffer
                                    ; hex2decimal will write before esi and update it for us

  and   eax, 0x000000ff             ; al
  call  hex2decimal                 ; esi now at start of string we just stored

  dec   esi
  mov   byte [esi], ':'

  mov   eax, ebx                    ; ah
  shr   eax, 8
  and   eax, 0x000000ff
  call  hex2decimal

  dec   esi
  mov   byte [esi], ':'

  mov   eax, ebx                    ; ax
  and   eax, 0x0000ffff
  call  hex2decimal

  dec   esi
  mov   byte [ esi ], ':'

  mov   eax, ebx                    ; eax
  call  hex2decimal

  lea   eax, [ buffer.colons + 3 ]    ; calculate length of string (including last char)
  sub   eax, esi

  pop  ebx
  ret

;-------+
; TESTS ;
;-------+

%ifenv dword2decimal

extern strncmp

section .data
  expected    : db "3134870785:21761:85:1" ; 0xbada5501:0x00005501:0x00005500:0x00000001
  fail        : db 10,"FAILED!",10,0
    .len      : equ $-fail
  pass        : db 10, "PASSED!",10,0
    .len      : equ $-pass

section .text

global _start

_start:

  nop

;;;
  mov   eax, 0xbada5501
  call  dword2decimal

  mov   ecx, esi      ; print string that holds the result
  mov   edx, eax
  mov   eax, 4
  mov   ebx, 1
  int   80h
;;;

  mov   edi, expected
  mov   eax, 4
  call  strncmp

  or    eax, eax
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
