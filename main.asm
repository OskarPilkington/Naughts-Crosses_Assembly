%include "linux64.inc"

PLAYER_X equ 1
PLAYER_O equ 2

section .data
	text_Welcome db "Welcome to Naughts and Crosses written in Assembly!", 10, 0
	text_playerO db "Player 'O', make your move, type XY: ", 0	
	text_playerX db "Player 'X', make your move, type XY: ", 0
	text_horizontal db "-----", 10, 0
	text_vertical db "|", 0
	text_blank db " ", 0
	text_X db "X", 0
	text_O db "O", 0
	newline db 10, 0
	gameState db 0, 0, 0, 0, 0, 0, 0, 0, 0
	player db PLAYER_X 

section .bss
	input resb 20 
	inputVal resb 2
	inputIndex resb 1
;	gameState resb 9

section .text
	global _start

_start:
	print text_Welcome

_loop:
;	printDigit [player]
	; if player is 1 print message for x
	cmp byte [player], PLAYER_X
	je _playerXTurn
	
	; if player is 2 print message for O
	cmp byte [player], PLAYER_O
	je _playerOTurn
	
_playerXTurn:
	print text_playerX
	jmp _playerTurnDone

_playerOTurn:
	print text_playerO
	jmp _playerTurnDone
	
_playerTurnDone:

		
	call _readInput
	call _inputToVal
	call _inputToIndex
	call _updateGameState
	
	print newline
	printChar [input]
	printChar [input+1]	
	print newline	
	printDigit [inputIndex]
	print newline

	print newline
	call _printGameState
	print newline	

	cmp byte [player], PLAYER_X
	je _switchToPlayerO
	
	cmp byte [player], PLAYER_O
	je _switchToPlayerX

_switchToPlayerX:
	mov byte [player], PLAYER_X
	jmp _loop

_switchToPlayerO:
	mov byte [player], PLAYER_O
	jmp _loop
	

	exit


_readInput:
	mov rax, SYS_READ
	mov rdi, STDIN
	mov rsi, input
	mov rdx, 10
	
	syscall
	ret

_inputToVal:
	mov rax, [input]
	sub rax, 48
	mov [inputVal], rax
	mov rax,  [input+1]
	sub rax, 48
	mov [inputVal+1], rax
	ret

_inputToIndex:
	mov r8, 0
	mov r9, 0
	mov r8, [inputVal] ; X coordinate
	mov r9, [inputVal+1] ; Y coordinate
	
	; Decrement both X and Y to move from range 1-3 to 0-2
	dec r8
	dec r9

;	printDigit r9 ;Debug
;	printDigit r8 ;Debug


	; Multiply Y coordinate with 3 and add X coordinate to get global coordinate	
	mov rdx, 0
	mov rax, r9
	mov r11, 3
	mul r11
	add rax, r8
	mov r10, rax
	
	mov [inputIndex], r10
;	printDigit r10 ;Debug

	ret


; Function updates game state based on input index and player
_updateGameState:
	mov r8, 0
	mov r9, 0
	mov r8, gameState
	mov r9, [inputIndex]
	and r9, 0FFh ; Masking out the bits I need
	add r8, r9  ; Get array index of input index
	mov r11b, [player]
	
	mov [r8], r11b ; Insert player into array
	
	ret

; Function prints the game state as a 3x3 grid
; This is done using "nested loops"
; The grid should look something like the following

;X|O|X
;-----
; |X| 
;-----
;O| |O

_printGameState:
	mov r8, 0 ;Used as counter for all tiles
	
_printGameStateOuter:
	mov r10, 0 ; counter for position on current line
	cmp r8, 0
	je _skipHorizontal
	print newline
	print text_horizontal
_skipHorizontal:

_printGameStateInner:
	mov r9, r8 ;Used as intermediate register storage

	add r9, gameState

	cmp byte [r9], 0
	je _printBlank
	
	cmp byte [r9], PLAYER_X
	je _printX
	
	cmp byte [r9], PLAYER_O
	je _printO

_printBlank:
	print text_blank
	jmp _printCharFinished

_printX:
	print text_X
	jmp _printCharFinished	

_printO:
	print text_O
	jmp _printCharFinished

_printCharFinished:
	inc r8
	inc r10

	; if total counter = 9 print new line and return
	cmp r8, 9
	je _printGameStateFinished
	
	; if column counter = 3 go back to outer loop
	cmp r10, 3
	je _printGameStateOuter
	
	
	;else print vertical line and go back to inner loop
	print text_vertical
	jmp _printGameStateInner
	
_printGameStateFinished:
	print newline
	ret


