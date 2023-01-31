.MODEL SMALL
.STACK 64
.DATA

	won DB 'YOU WON		PRESS a TO PLAY AGAIN		PRESS e TO EXIT$$'

	lose DB 'GAME OVER		PRESS a TO PLAY AGAIN		PRESS e TO EXIT$'

	ball_h_d DB 2 ; Horizontal direction of Ball
	ball_v_d DB 1 ; Vertical direction of Ball

    ball_h_s DB 40 ; Board location
    ball_v_s DB 24 ; Ball location

    board_s  DB 40 ; Board location
    board_d  DB 2   ; Direction of Board

	greade 	 DB 0 	; greade of player

    alive 	 DB 1 ; Just for test

	block_h  DB	40
	block_v	 DB 9
	block_alive  DB 5

	rand0	 DB 0
	rand1	 DB 0

.CODE

SECOND_FUNC PROC FAR

	MOV DL, won
	MOV DX, OFFSET lose
	MOV AH, 9
	INT 21h
	RET

SECOND_FUNC ENDP

FIRST_FUNC PROC FAR

	MOV DL, won
	MOV DX, OFFSET won
	MOV AH, 9
	INT 21h
	POP BP
	CALL SECOND_FUNC

FIRST_FUNC ENDP

MAIN	PROC FAR

    MOV	AX, @DATA
	MOV	DS, AX

	CALL FIRST_FUNC

	MOV AH, 4CH
	INT	21H

MAIN	ENDP
	END	MAIN
