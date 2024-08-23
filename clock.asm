section .bss
    buffer resb 64
    time resb 16   ;timespec structure a data structure that specifies time interval to use


section .text
    global _start

_start:
clockloop:
    mov rax, 228    ; sys_clock_gettime 
    xor rdi, rdi     ; Ensuring that the system call retrieves the real time
    lea rsi, [time]  ; lea(load effective Address)
    syscall         

    ;checking of error
    cmp rax, 0
    js error

    ; Converting time into seconds, minutes, and hours
    mov rax, qword [time] ; qword specifies that 8 byte of the time is used
    xor rdx, rdx
    mov rcx, 60
    div rcx               ; rax = rax / rcx; rax = minutes, rdx = seconds
    mov rbx, rdx          ; rbx = seconds

    xor rdx, rdx
    mov rcx, 60
    div rcx             
    mov rsi, rdx          ; rsi = minutes

    xor rdx, rdx
    mov rcx, 24
    div rcx               
    mov rdi, rdx          ; rdi = hours

    ; Convert hours to string and store in buffer
    mov rax, rdi
    call int2str
    mov byte [buffer], al
    mov byte [buffer + 1], ah

   
    mov byte [buffer + 2], ':'

    ; Convert minutes to string and store in buffer
    mov rax, rsi
    call int2str
    mov byte [buffer + 3], al
    mov byte [buffer + 4], ah

    
    mov byte [buffer + 5], ':'

    ; Convert seconds to string and store in buffer
    mov rax, rbx
    call int2str
    mov byte [buffer + 6], al
    mov byte [buffer + 7], ah

   
    mov byte [buffer + 8], 0

    ; Sys_write to output
    mov rax, 1             
    mov rdi, 1             
    lea rsi, [buffer]      
    mov rdx, 9             ; number of bytes to write (8 digits + 1 colon)
    syscall                

    ;sys_write to add a newline
    mov rax, 1             ; sys_write system call number
    mov rdi, 1             ; file descriptor 1 (stdout)
    lea rsi, [newline]     ; address of newline character
    mov rdx, 1             ; number of bytes to write (1 byte for newline)
    syscall                

    ; Add a 1-second delay using nanosleep
    call delay

    ; Infinite loop is achieved
    jmp clockloop


error:
    ; Handle error
    mov rax, 60    ; sys_exit system call number
    mov rdi, 1     ; Exit code 1 for error
    syscall

; Converts a number in rax to a string in buffer (2 bytes)
int2str:
    xor rdx, rdx          ; Clear rdx (remainder)
    mov rcx, 10           ; Divisor for modulo 10 operation
    div rcx               ; Divide rax by 10, quotient in rax, remainder in rdx
    add dl, '0'           ; Convert remainder to ASCII
    mov ah, dl            ; Store units digit in ah
    cmp rax, 0            ; If quotient is 0
    je ntensdigit         ; If zero, skip the next step
    add al, '0'           ; Convert quotient to ASCII
    ret
ntensdigit:
    mov al, '0'           ; Ensure leading '0' is set
    ret

; Add a delay using nano sleep

delay:
    mov rax, 35            ; sys_nanosleep
    lea rdi, [rel ts]      ; Pointer to timespec structure
    xor rsi, rsi           ; Null pointer for remaining time
    syscall
    ret

newline db 10             ;


    
section .data
ts:
    dq 1                   ; seconds
    dq 0                   ; nanoseconds
    
    


