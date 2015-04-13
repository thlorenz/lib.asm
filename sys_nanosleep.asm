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
; ARGS:
;     ebx: number of seconds to sleep for
;     ecx: number of nanoseconds to sleep for
; --------------------------------------------------------------
global sys_nanosleep
sys_nanosleep:
  push  eax
                            ; build timespec struct on stack
  push  ebx                 ; push seconds (tv_sec)
  push  ecx                 ; followed by nanoseconds (tv_nsec)
                            ; esp now points @ecx

  mov   eax, SYS_NANOSLEEP
  lea   ebx, [ esp + 4 ]    ; point ebx at timespec
  xor   ecx, ecx            ; don't need updates about time slept
  int   80h

  pop   ecx
  pop   ebx
  pop   eax
  ret

;-------+
; TESTS ;
;-------+

%ifenv sys_nanosleep
extern sys_write_stdout

section .data
  msg:      db 10,"Done sleeping!",10
  msg_len   equ $-msg

section .text
global _start

_start:

  nop

  mov   ebx, 1          ; sleep exactly one second
  xor   ecx, ecx        ; not interested in nano seconds
  call  sys_nanosleep

  mov   ecx, msg
  mov   edx, msg_len
  call sys_write_stdout

.exit:
  mov eax, 1
  mov ebx, 0
  int 80H

%endif
