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

	grade 	 DB 0 	; grade of player

    alive 	 DB 1 ; Just for test

	block_h  DB	40
	block_v	 DB 9
	block_alive  DB 5

	rand0	 DB 0
	rand1	 DB 0

.CODE

DISPLAY_SCREEN PROC FAR

	; SCREEN SIZE 24*79

	; SCROOL THE SCREEN
	MOV AX, 7 
	INT 10H

	; GRADE
	MOV AH, 02h   ;settin cursor position
	MOV BH, 00h   ;page number
	MOV DH, 0    ;row
	MOV DL, 0   ;column
	INT 10h

	MOV DX, 0

	MOV AL, BYTE PTR grade
	MOV AH, 0
	MOV CX, 10
	DIV CX
	ADD DX, 48
	PUSH DX
	ADD AX, 48
	PUSH AX
	POP DX
	MOV AH, 02H
	INT 21H
	POP DX
	MOV AH, 02H
	INT 21H

	; TOP MARGIN
	MOV AH, 02h   ;settin cursor position
	MOV BH, 00h   ;page number
	MOV DH, 1    ;row
	MOV DL, 0   ;column
	INT 10h

	MOV DX, '_' ; underline
	MOV CX, 79
	PRINT_1:
		MOV AH, 02H
		INT 21H
		CMP CX, 0
		LOOP PRINT_1

	; BLOCK
	MOV DL, BYTE PTR block_alive
	CMP DL, 0
	JZ BLOCK_PAINTED_OR_NOT
	MOV AH,02h   ;settin cursor position
	MOV BH,00h   ;page number
	MOV DH, BYTE PTR block_v
	MOV DL, BYTE PTR block_h
	INT 10H

	MOV DL, BYTE PTR block_alive
	ADD DL, 48
	MOV AH, 02h
	INT 21h

	JMP BLOCK_PAINTED_OR_NOT

	BLOCK_PAINTED_OR_NOT:

	; BOARD
	MOV AH,02h   ;settin cursor position
	MOV BH,00h   ;page number
	MOV DH, 23    ;row
	MOV DL, BYTE PTR board_s
	SUB DL, 5   ;column
	INT 10h

	MOV CX, 11
	BOARD_LINE:	
		MOV AH,02h
		MOV DL, '_'
		INT 21h
		LOOP BOARD_LINE

	; BALL
	MOV AH, 02h   ;settin cursor position
	MOV BH, 00h   ;page number
	MOV DH, BYTE PTR ball_v_s
	MOV DL, BYTE PTR ball_h_s
	INT 10h

	MOV AH,02h
	MOV DL, 'O'
	INT 21h

	; DOWN MARGIN
	MOV AH, 02h   ;settin cursor position
	MOV BH, 00h   ;page number
	MOV DH, 24    ;row
	MOV DL, 0   ;column
	INT 10h

	MOV DX, '_' ; underline
	MOV CX, 79
	PRINT_2:
		MOV AH, 02H
		INT 21H
		CMP CX, 0
		LOOP PRINT_2

	RET

DISPLAY_SCREEN ENDP

DISPLAY_WON PROC FAR

	; SET CURSOR CENTER
	MOV AH, 02h
	MOV BH, 00h
	MOV DH, 12
	MOV DL, 5  
	INT 10h

	MOV DL, won
	MOV DX, OFFSET won
	MOV AH, 9
	INT 21h
	RET

DISPLAY_WON ENDP

DISPLAY_GAMEOVER PROC FAR
	; SET CURSOR CENTER
	MOV AH, 02h
	MOV BH, 00h
	MOV DH, 12
	MOV DL, 5  
	INT 10h

	MOV DL, lose
	MOV DX, OFFSET lose
	MOV AH, 9
	INT 21h
	RET

DISPLAY_GAMEOVER ENDP

UPDATE_BOARD_LOCATION PROC FAR

	; KEYBOARD PRESSED OR NOT

	MOV AH, 1
	INT 16h
	JZ NOT_PRESSED
	MOV AH, 0
	INT 16h

	; UPDATE BOARD LOCATION AND DIRECTION

	MOV DL, BYTE PTR board_s
	CMP AL, 52
	JZ LEFT_PRESSED
	CMP AL, 54
	JZ RIGHT_PRESSED
	RET

	LEFT_PRESSED:
		MOV DH, BYTE PTR rand0
		
		ADD DH, 7
		MOV rand0, DH

		MOV board_d, 0
		CMP DL, 6
		JZ END_UPDATE_BOARD_LOCATION
		SUB DL, 1
		JMP END_UPDATE_BOARD_LOCATION
	RIGHT_PRESSED:
		MOV DH, BYTE PTR rand1
		ADD DH, 3
		MOV rand1, DH

		MOV board_d, 1
		CMP DL, 73
		JZ END_UPDATE_BOARD_LOCATION
		ADD DL, 1
		JMP END_UPDATE_BOARD_LOCATION
	END_UPDATE_BOARD_LOCATION:
		MOV board_s, DL
		RET

	NOT_PRESSED:
		RET

UPDATE_BOARD_LOCATION ENDP

UPDATE_VERTICAL_BALL PROC FAR

	MOV DL, BYTE PTR block_alive
	CMP DL, 0
	JZ CREATE_NEW_BLOCK
	JMP OLD_BLOCK_DETECTED

	CREATE_NEW_BLOCK:
		MOV AH, 0
		MOV DX, 0
		MOV AL, BYTE PTR rand0
		MOV CX, 61
		DIV CX
		ADD DX, 10
		MOV block_h, DL

		MOV AH, 0
		MOV DX, 0
		MOV AL, BYTE PTR rand1
		MOV CX, 11
		DIV CX
		ADD DX, 5
		MOV block_v, DL

		MOV block_alive, 5

		JMP OLD_BLOCK_DETECTED

	OLD_BLOCK_DETECTED:
	MOV DL, BYTE PTR block_h
	MOV DH, BYTE PTR block_v
	MOV AL, BYTE PTR ball_h_s
	MOV AH, BYTE PTR ball_v_s

	CMP DL, AL
	JNZ CONTINUE
	CMP DH, AH
	JNZ CONTINUE

	MOV DL, BYTE PTR block_alive
	SUB DL, 1
	MOV block_alive, DL

	MOV DL, BYTE PTR grade
	ADD DL, 1
	MOV grade, DL

	MOV DL, BYTE PTR ball_v_d
	CMP DL, 0
	JZ UP_DIRECTION
	JMP DOWN_DIRECTION

	CONTINUE:
	MOV DL, BYTE PTR ball_v_d
	MOV DH, BYTE PTR ball_v_s
	CMP DL, 0
	JZ DOWN_DIRECTION
	JMP UP_DIRECTION

	DOWN_DIRECTION:
		ADD DH, 1
		MOV ball_v_d, 0
		MOV ball_v_s, DH
		CMP DH, 24
		JZ INVERT_UP

		CMP DH, 15
		JL CLEAR_BOARD_DIRECTION
		RET
		CLEAR_BOARD_DIRECTION:
			MOV board_d, 2
			RET

		INVERT_UP:
			MOV ball_v_d, 1

			MOV DL, BYTE PTR grade
			ADD DL, 1
			MOV grade, DL

			MOV DL, BYTE PTR board_s
			MOV DH, BYTE PTR ball_h_s

			CMP DH, DL
			JL LOWER
			JMP GREATER
			LOWER:
				SUB DL, 5
				CMP DH, DL
				JL LOSER
				RET

			GREATER:
				ADD DL, 5
				CMP DL, DH
				JL LOSER
				RET

			LOSER:
				MOV alive, 0
			RET

	UP_DIRECTION:
		SUB DH, 1
		MOV ball_v_d, 1
		MOV ball_v_s, DH
		CMP DH, 3
		JZ INVERT_DOWN	
		RET

		INVERT_DOWN:
			MOV ball_v_d, 0
			RET

UPDATE_VERTICAL_BALL ENDP

UPDATE_HORIZONTAL_BALL_DIRECTION PROC FAR

	MOV DL, BYTE PTR ball_v_s
	CMP DL, 24
	JL CONTINUE
	JMP BALL_AT_LOWES_LEVEL

	CONTINUE:
		MOV AL, ball_h_s
		CMP AL, 1
		JZ FORCE_TO_1
		CMP AL, 78
		JZ FORCE_TO_0
		RET
		FORCE_TO_1:
			MOV ball_h_d, 1
			RET
		FORCE_TO_0:
			MOV ball_h_d, 0
			RET

	BALL_AT_LOWES_LEVEL:
		MOV DL, BYTE PTR board_d
		MOV DH, BYTE PTR ball_h_d

		CMP DL, 0
		JZ LEFT_DIRECTION
		CMP DL, 1
		JZ RIGHT_DIRECTION
		RET

		LEFT_DIRECTION:
			MOV ball_h_d, 0
			CMP DH, 1
			JZ ZIP_TWO
			RET

		RIGHT_DIRECTION:
			MOV ball_h_d, 1
			CMP DH, 0
			JZ ZIP_TWO
			RET

		ZIP_TWO:
			MOV ball_h_d, 2
			RET

UPDATE_HORIZONTAL_BALL_DIRECTION ENDP

UPDATE_HORIZONTAL_BALL_STATE PROC FAR

	MOV DH, BYTE PTR ball_h_s
	MOV DL, BYTE PTR ball_h_d
	CMP DL, 0
	JZ FORCE_TO_0_D
	CMP DL, 1
	JZ FORCE_TO_1_D
	RET
	FORCE_TO_0_D:
		SUB DH, 1
		MOV ball_h_s, DH
		RET
	FORCE_TO_1_D:
		ADD DH, 1
		MOV ball_h_s, DH
		RET

UPDATE_HORIZONTAL_BALL_STATE ENDP

DELAY PROC FAR

	MOV DX, 3
	MAIN_LOOP_2:
		MOV CX, 105000
		START_DELAY:
			CMP CX, 0
			LOOP START_DELAY
		SUB DX, 1
		CMP DX, 0
		JNZ MAIN_LOOP_2
	RET

DELAY ENDP

RESET_FACTORY PROC FAR

	MOV ball_h_d, 2 ; Horizontal direction of Ball
	MOV ball_v_d, 1 ; Vertical direction of Ball
    MOV ball_h_s, 40 ; Board location
    MOV ball_v_s, 24 ; Ball location
    MOV board_s , 40 ; Board location
    MOV board_d , 2   ; Direction of Board
	MOV grade 	, 0 	; grade of player
    MOV alive 	, 1 ; Just for test
	MOV block_alive, 5
	MOV block_h, 40
	MOV block_v, 9
	RET

RESET_FACTORY ENDP

FEED_BACK PROC FAR

	START_FEED_BACK:
		MOV AH, 1
		INT 16h
		JZ START_FEED_BACK
		MOV AH, 0
		INT 16h
		CMP AL, 65
		JZ RESTART
		CMP AL, 97
		JZ RESTART
		CMP AL, 69
		JZ END_GAME
		CMP AL, 101
		JZ END_GAME

		JMP START_FEED_BACK

		RESTART:
			MOV AX, 1
			RET
		END_GAME:
			MOV AX, 0
			RET

FEED_BACK ENDP

MAIN	PROC FAR

    MOV	AX, @DATA
	MOV	DS, AX

	; MOV AH, 00h
	; MOV AL, 01H
	; INT 10h

	MAIN_LOOP:
		CALL UPDATE_BOARD_LOCATION
		CALL DISPLAY_SCREEN
		CALL UPDATE_BOARD_LOCATION
		CALL UPDATE_BOARD_LOCATION
		CALL UPDATE_VERTICAL_BALL
		CALL UPDATE_BOARD_LOCATION
		CALL UPDATE_BOARD_LOCATION
		CALL UPDATE_HORIZONTAL_BALL_DIRECTION
		CALL UPDATE_BOARD_LOCATION
		CALL UPDATE_BOARD_LOCATION
		CALL UPDATE_HORIZONTAL_BALL_STATE
		CALL UPDATE_BOARD_LOCATION
		CALL UPDATE_BOARD_LOCATION
		CALL DELAY

		MOV DL, BYTE PTR alive
		CMP DL, 1
		JNZ GAMOVER_TEXT
		MOV DL, BYTE PTR grade
		CMP grade, 30
		JZ WON_TEXT

		MOV AH, 1
		INT 16h
		JZ MAIN_LOOP
		MOV AH, 0
		INT 16h
		CMP AL, 69
		JZ FINALY_EXIT
		CMP AL, 101
		JZ FINALY_EXIT
		JMP MAIN_LOOP

	GAMOVER_TEXT:
		CALL DISPLAY_GAMEOVER
		CALL RESET_FACTORY
		CALL FEED_BACK
		CMP AX, 0
		JZ FINALY_EXIT
		JMP MAIN_LOOP

	WON_TEXT:
		CALL DISPLAY_WON
		CALL RESET_FACTORY
		CALL FEED_BACK
		CMP AX, 0
		JZ FINALY_EXIT
		JMP MAIN_LOOP

	FINALY_EXIT:
		MOV AX, 7 
		INT 10H
		MOV 	AH, 4CH
		INT	21H

MAIN	ENDP
	END	MAIN
