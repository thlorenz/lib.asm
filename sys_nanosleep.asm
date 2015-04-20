; vim: ft=nasm

; https://github.com/torvalds/linux/blob/v4.0-rc7/arch/sh/include/uapi/asm/unistd_32.h#L174
%define SYS_NANOSLEEP 162

; https://github.com/torvalds/linux/blob/v4.0-rc7/include/uapi/linux/time.h#L9
; struc timespec        ; time.h
;   tv_sec:   resd 1    ; __kernel_time_t
;   tv_nsec:  resd 1    ; long
; endstruc

section .text
; --------------------------------------------------------------
; sys_nanosleep
;     sleeps for given amount of seconds + nanoseconds
;     @see 'man nanosleep'
;
; args: ecx = number of seconds to sleep for
;       edx = number of nanoseconds to sleep for
; out : nothing, all registers preserved
; --------------------------------------------------------------
global sys_nanosleep
sys_nanosleep:
  push  eax
  push  ebx
  push  ecx

                                ; build timespec struct in stack 
  mov   dword [ esp - 8 ], ecx  ; seconds (tv_sec)
  mov   dword [ esp - 4 ], edx  ; nanoseconds (tv_nsec)

  mov   eax, SYS_NANOSLEEP
  lea   ebx, [ esp - 8]         ; point ebx at timespec
  xor   ecx, ecx                ; don't need updates about time slept
  int   80h

  pop   ecx
  pop   ebx
  pop   eax
  ret

;-------+
; TESTS ;
;-------+

%ifenv sys_nanosleep

%define milliseconds 1000000

extern sys_write_stdout

section .data
  msg:      db 10,"Done sleeping!",10
  msg_len   equ $-msg

section .text
global _start

_start:

  nop
;;;
  mov   ecx, 1                  ; sleep exactly one and
  mov   edx, 500 * milliseconds ; a half second
  call  sys_nanosleep
;;;
  mov   ecx, msg
  mov   edx, msg_len
  call sys_write_stdout

.exit:
  mov eax, 1
  mov ebx, 0
  int 80H

%endif
