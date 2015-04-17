; vim: ft=nasm

section .text

; --------------------------------------------------------------
; sys_signal
;     installs a signal handler
;
; args: ebx = the signal number to handle (see signals.mac)
;       ecx = the address of the handler
; out : nothing, all registers preserved
; --------------------------------------------------------------
global sys_signal
sys_signal:
  push  eax
  mov   eax, 48 ; sys_signal
  int   80h
  pop   eax
  ret

;-------+
; TESTS ;
;-------+

%ifenv sys_signal

extern sys_write_stdout
;;;
%include "signals.mac"

section .text

sig_int_handler:
  mov   ecx, caught_sigint
  mov   edx, caught_sigint_len
  call  sys_write_stdout
  jmp   exit

sig_term_handler:
  mov   ecx, caught_sigterm
  mov   edx, caught_sigterm_len
  call  sys_write_stdout
  jmp   exit
;;;
sig_hup_handler:
  mov   ecx, caught_sighup
  mov   edx, caught_sighup_len
  call  sys_write_stdout
  jmp   exit

exit:
  mov eax, 1
  mov ebx, 0
  int 80H

global _start
_start:
  mov   ecx, instructions     ; Instructions
  mov   edx, instructions_len
  call  sys_write_stdout
;;;

  mov   ebx, SIGINT           ; install SIGINT handler (Ctrl-C)
  mov   ecx, sig_int_handler
  call  sys_signal

  mov   ebx, SIGTERM          ; install SIGTERM handler (kill <pid>)
  mov   ecx, sig_term_handler
  call  sys_signal
;;;
  mov   ebx, SIGHUP          ; install SIGHUP handler (kill -HUP <pid>)
  mov   ecx, sig_hup_handler
  call  sys_signal

.wait:                        ; spin in endless loop
  mov   ecx, period           ; print . to show we're still alive
  mov   edx, period_len
  call  sys_write_stdout

  mov   ecx, 0afffffh
.delay:
  mov   eax, 0aah
  mov   ebx, 0bbh
  div   eax
  loop  .delay
  jmp   .wait

section .data

period:             db "."
period_len          equ $-period

instructions:       db "Press Ctrl-C to exit or kill the process, i.e. kill `pgrep sys_signal`",10
instructions_len    equ $-instructions

caught_sigint:      db 10,"Caught SIGINT, exiting ...",10
caught_sigint_len   equ $-caught_sigint

caught_sigterm:     db 10,"Caught SIGTERM, exiting ...",10
caught_sigterm_len  equ $-caught_sigterm

caught_sighup:      db 10,"Caught SIGHUP, exiting ...",10
caught_sighup_len   equ $-caught_sighup
%endif
