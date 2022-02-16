section .bss
	printSpace resb 8
	digit resb 1


; Prints a string until it reaches 0
%macro print 1
	mov rax, %1
	mov [printSpace], rax ; Storing beginning of string
	mov rbx, 0 ; Working as a counter

	; counting the amount of characters in rbx
%%printLoop:
	mov cl, [rax] ; Getting only last byte of rax into rcx
	cmp cl, 0
	je %%endPrintLoop
	inc rax
	inc rbx
	jmp %%printLoop

%%endPrintLoop:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, [printSpace]
	mov rdx, rbx
	syscall
	
%endmacro

%macro printDigit 1
%%printDigit:
	mov rcx, %1
	add rcx, 48
	mov [digit], cl
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, digit
	mov rdx, 1
	syscall

%endmacro

%macro printChar 1
	mov rcx, %1
	mov [digit], cl
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, digit
	mov rdx, 1
	syscall

%endmacro


%macro exit 0
	mov rax, 60
	mov rdi, 0
	syscall
%endmacro



SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60

STDIN equ 0
STDOUT equ 1
STDERR equ 2

