TITLE Low-Level String to Integer Procedure

; Author: Nicholas Schmidt
; Last Modified: 06/05/2022
; Description: This program takes user input of 10 integers as strings capable of fitting in a 32-bit register. The strings are converted to integers
;			   and are stored as SDWORDS in an array. The program will calculate the sum and average of the array. Finally, the program will 
;			   convert the SDWORDS back to strings and display them, in addition to the sum and average of the array.

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Displays a prompt, then accepts an integer (as a string) from the user.
;
; Preconditions: None
;
; Receives: prompt = prompt1, string_length = slength, buffer_size = SIZEOF buffer,
; buffer_address = buffer, usr_string = str_b4_int
;
; Returns: usr_string = str_b4_int (string that will be converted to integer
; ---------------------------------------------------------------------------------
mGetString MACRO prompt, string_length, buffer_size, buffer_address, usr_string
	
	PUSH		EDX
	MOV			EDX, prompt
	CALL		WriteString
	POP			EDX
	PUSH		ECX
	MOV			EDX, buffer_address
	MOV			ECX, buffer_size
	PUSH		EAX
	PUSH		EDX
	CALL		ReadString
	PUSH		EDI
	MOV			EDI, string_length
	MOV			[EDI], EAX
	POP			EDI
	PUSH		EDI
	MOV			EDI, usr_string
	MOV			[EDI], EDX
	POP			EDI
	POP			EDX
	POP			EAX
	POP			ECX

ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Receives the address of a string and writes the string to the console.
;
; Preconditions: None
;
; Receives: string_to_display = memory address of a string
;
; Returns: None
; ---------------------------------------------------------------------------------
mDisplayString MACRO string_to_display

	PUSH		EDX
	MOV			EDX, string_to_display
	CALL		WriteString
	POP			EDX

ENDM

INTFACTOR = 10
	
.stack 4096

.data

header_string		BYTE	"Low-Level String to Integer Procedure, by Nicholas Schmidt",13,10,13,10,0
instructs			BYTE	"Enter 10 signed decimal integers, each of which must fit in a 32-bit register. Once you have done so, ",13,10,
							"the program will display a list of the integers, their sum, and their truncated average value (decimal is dropped).",13,10,13,10,0
prompt1				BYTE	"Enter a signed integer: ",0
buffer				BYTE	32 DUP(?)
slength				SDWORD	?
int_array			SDWORD	10 DUP(?)
str_b4_int			SDWORD	0
array_count			SDWORD	0	
length_array		SDWORD	LENGTHOF int_array
array_sum			SDWORD	0
sum_string			BYTE	12 DUP(?)
rev_sum_string		BYTE	12 DUP(?)
array_avg			SDWORD	0
avg_string			BYTE    12 DUP(?)
rev_avg_string		BYTE	12 DUP(?)
temp_in_string		BYTE	12 DUP(?)
temp_out_string		BYTE	12 DUP(?)
space_char			BYTE	" ",0
build_int			SDWORD	0
minus_sign			BYTE	"-",0
nums_msg			BYTE	"The integers you entered were: ",13,10,0
sum_msg				BYTE	"The sum of your valid integers is: ",0
avg_msg				BYTE	"The truncated average of your valid integers is: ",0
error_msg			BYTE	"Invalid integer. Integers must fit in a 32-bit register and not contain non-numeric characters other than (+,-).",13,10,0
farewell_msg		BYTE	13,10,"Thank you for using my program, good bye!",13,10,0


.code
main PROC
	
	; Display Title, Author, and Instructions for the User
	PUSH		OFFSET header_string    ;12
	PUSH		OFFSET instructs		;8
	CALL		introduction


	;------------------------------------------------------------------------
	; Display prompt 10x for user to enter integers fitting the proper 
	; parameters. These integers are stored as SDWORDs in 'int_array', which
	; will be converted from integers back to strings later on in WriteVal.
	;------------------------------------------------------------------------
	PUSH		ECX
	MOV			ECX, 10
	_fillArray:
	PUSH		ECX
	PUSH		OFFSET build_int    ;40
	PUSH		OFFSET error_msg    ;36
	PUSH		OFFSET array_count  ;32
	PUSH		OFFSET int_array    ;28
	PUSH		OFFSET str_b4_int   ;24
	PUSH		OFFSET buffer       ;20
	PUSH		SIZEOF buffer       ;16
	PUSH		OFFSET slength      ;12
	PUSH		OFFSET prompt1      ;8
	CALL		ReadVal
	POP			ECX
	LOOP		_fillArray
	POP			ECX


	; Calculate the array sum and array average to be converted to strings and displayed later.
	PUSH		length_array        ;20
	PUSH		OFFSET array_avg    ;16
	PUSH		OFFSET array_sum    ;12
	PUSH		OFFSET int_array    ;8
	CALL		CalcSumAvg


	; Display description for the strings (numbers) that will be displayed
	CALL		CrLf
	CALL		CrLf
	mDisplayString OFFSET nums_msg

	;---------------------------------------------------------------------------------
	; Moves the address of the first integer in the array into ESI and pushes
	; it as a parameter. After each iteration, ESI is incremented by 4 bytes
	; (SDWORD) to display the next integer as a string from the array using WriteVal.
	;---------------------------------------------------------------------------------
	PUSH		ECX
	PUSH		ESI
	MOV			ECX, 10
	MOV			ESI, OFFSET int_array
	MOV			EDX, 0
	_WriteNums:
	PUSH		ECX
	PUSH		ESI
	PUSH		OFFSET temp_out_string			;20
	PUSH		OFFSET minus_sign				;16
	PUSH		OFFSET temp_in_string	        ;12	
	PUSH		ESI								;8
	CALL		WriteVal
	mDisplayString OFFSET space_char
	CLD									    ; This section of code from CLD to REP will 0 out the 
	MOV			ESI, OFFSET temp_out_string	    ; temp_out_string to be re-used to store the next SDWORD
	MOV			EDI, OFFSET temp_out_string
	MOV			ECX, 12
	MOV			AL, 0
	REP			STOSB
	POP			ESI
	ADD			ESI, 4
	POP			ECX
	LOOP		_WriteNums
	POP			ESI
	POP			ECX

	; Display the description for the sum that will be displayed
	CALL		CrLf
	CALL		CrLf
	mDisplayString OFFSET sum_msg
	CALL		CrLf


	; Display the sum as a string using WriteVal
	PUSH		OFFSET rev_sum_string     ;20
	PUSH		OFFSET minus_sign         ;16
	PUSH		OFFSET sum_string         ;12
	PUSH		OFFSET array_sum          ;8
	CALL		WriteVal


	; Display the description for the average that will be displayed
	CALL		CrLf
	CALL		CrLf
	mDisplayString OFFSET avg_msg
	CALL		CrLf


	; Display the average as a string using WriteVal
	PUSH		OFFSET rev_avg_string     ;20
	PUSH		OFFSET minus_sign         ;16
	PUSH		OFFSET avg_string         ;12
	PUSH		OFFSET array_avg          ;8
	CALL		WriteVal

	
	; Display a farewell message for the user
	CALL		CrLf
	PUSH		OFFSET farewell_msg       ;8
	CALL		outro
	CALL		CrLf

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ---------------------------------------------------------------------------------
; Name: introduction
;
; Displays the Program Tite, Author's Name, and Instructions for the Program.
;
; Preconditions: header_string and instructs are strings
;
; Postconditions: None
;
; Receives: header_string [EBP + 8] & instructs [EBP + 12]
;
; Returns: None
; ---------------------------------------------------------------------------------
introduction PROC

	PUSH		EBP
	MOV			EBP, ESP
	PUSH		EDX
	MOV			EDX, [EBP + 12]		; Reference to header_string
	CALL		WriteString
	MOV			EDX, [EBP + 8]		; Reference to instructs
	CALL		WriteString
	POP			EDX
	POP			EBP
	RET			8

introduction ENDP


; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Receives an integer as a string as input. Converts the string to an SDWORD, then
; stores it in int_array. This procedure will repeat 10 times until the array is filled.
;
; Preconditions: prompt1, str_b4_int, error_msg are strings. slength, array_count, and
; build_int are SDWORDS initialized to 0. buffer is initialized to 32 empty bytes.
; int_array is an SDWORD array of length 10, initialized to 0s. Any user input must fit
; in a 32-bit register.
;
; Postconditions: int_array is filled with 10 SDWORDS as integers. 
;
; Receives: prompt1 [EBP + 8], slength [EBP + 12], SIZEOF buffer [EBP + 16], 
;			buffer [EBP + 20], str_b4_int [EBP + 24], int_array [EBP + 28], 
;			array_count [EBP + 32], error_msg [EBP + 36], build_int [EBP + 40]
;
; Returns: int_array filled with 10 SDWORD integers
; ---------------------------------------------------------------------------------
ReadVal PROC
	LOCAL	isNeg:DWORD

_getNum:
	MOV			isNeg, 0
	mGetString	[EBP + 8], [EBP + 12], [EBP + 16], [EBP + 20], [EBP + 24]
	;			 prompt1	slength   SIZEOF buffer  buffer    str_b4_int

	PUSH		EBX
	MOV			EBX, [EBP + 24]		; Move user input string to ESI
	MOV			ESI, [EBX]
	POP			EBX

	MOV			ECX, [EBP + 12]		; Move string length to ECX
	MOV			ECX, [ECX]
	CMP			ECX, 11
	JA			_invalidNum
	MOV			EDX, 0
	MOV			EAX, 0
	
	CLD
	_convert:
	LODSB							; _convert starts by loading the first byte in AL, then comparing against invalid input.
	CMP			AL, 45
	JE			_setNegative
	CMP			AL, 43
	JE			_nextDigit
	CMP			AL, 46
	JE			_invalidNum
	CMP			AL, 47
	JE			_invalidNum
	CMP			AL, 44
	JE			_invalidNum
	CMP			AL, 42
	JBE			_invalidNum
	CMP			AL, 58
	JAE			_invalidNum
	CMP			isNeg, 1
	JE			_negativeVal
	JMP			_positiveVal

_nextDigit:
	MOV			EAX, 0
	LOOP		_convert

_finalArrayStep:
	MOV			EDI, [EBP + 28]		; Move int_array to destination, set proper index for storing integer
	MOV			EBX, [EBP + 32]		
	MOV			EBX, [EBX]			
	IMUL		EBX, 4				
	ADD			EDI, EBX			


_last:
	MOV			EAX, [EBP + 40]		; Add integer to array
	MOV			EAX, [EAX]
	MOV			[EDI], EAX			
	MOV			EBX, [EBP + 32]		; Update count of integers
	MOV			EBX, [EBX]			
	INC			EBX					
	MOV			EDI, [EBP + 32]		
	MOV			[EDI], EBX			
	
	PUSH		EDI
	PUSH		EBX
	MOV			EBX, 0
	MOV			EDI, [EBP + 40]		; Zero out build_int for next integer
	MOV			[EDI], EBX
	POP			EBX
	POP			EDI

	MOV			isNeg, 0
	RET			36


_invalidNum:
	mDisplayString [EBP + 36]		; Display error message
	
	PUSH		EDI
	PUSH		EBX
	MOV			EBX, 0
	MOV			EDI, [EBP + 40]		; Zero out build_int for next integer
	MOV			[EDI], EBX
	POP			EBX
	POP			EDI
	JMP			_getNum

_negativeVal:						; Handles all negative integer inputs
	SUB			AL, 48
	PUSH		EAX
	MOV			EAX, [EBP + 40]
	MOV			EAX, [EAX]
	MOV			EBX, INTFACTOR
	IMUL		EAX, EBX
	POP			EBX
	JO			_invalidNum
	SUB			EAX, EBX
	
	PUSH		EDI
	MOV			EDI, [EBP + 40]
	MOV			[EDI], EAX
	JO			_invalidNum
	JMP			_nextDigit

_positiveVal:						; Handles all positive integer inputs
	SUB			AL, 48
	PUSH		EAX
	MOV			EAX, [EBP + 40]
	MOV			EAX, [EAX]
	MOV			EBX, INTFACTOR
	IMUL		EAX, EBX
	POP			EBX
	JO			_invalidNum
	ADD			EAX, EBX

	PUSH		EDI
	MOV			EDI, [EBP + 40]
	MOV			[EDI], EAX
	JO			_invalidNum
	JMP			_nextDigit

_setNegative:
	MOV			isNeg, 1
	JMP			_nextDigit
	
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: CalcSumAvg
;
; Iterates over the now-filled int_array, calculating the total sum of each integer,
; then calculating the truncated average (no decimal) and storing them in memory.
;
; Preconditions: [EBP + 8] is a reference to int_array. [EBP + 12] is a reference to
;				the array_sum variable. [EBP + 16] is a reference to the array_avg
;				variable, [EBP + 20] is the LENGTHOF int_array.
;
; Postconditions: array_sum and array_avg have their proper values
;
; Receives: [EBP + 8] = reference to int_array
;			[EBP + 12] = reference to array_sum (initially 0)
;			[EBP + 16] = reference to array_avg (initially 0)
;			[EBP + 20] = reference to LENGTHOF int_array
;
; Returns: array_sum, array_avg
; ---------------------------------------------------------------------------------
CalcSumAvg PROC
	PUSH		EBP
	MOV			EBP, ESP

	MOV			ECX, [EBP + 20]				; Length of array 
	MOV			EDI, [EBP + 12]				; Sum of Array
	MOV			ESI, [EBP + 8]				; Refernce to array

_sumLoop:									; Calculates the sum of all integers in the array
	PUSH		EBX
	MOV			EBX, [ESI]
	ADD			[EDI], EBX
	ADD			ESI, 4
	POP			EBX
	LOOP		_sumLoop

_avgCalc:									; Calculates the truncated average of all integers in the array
	PUSH		EAX
	PUSH		EBX
	PUSH		EDX
	MOV			EAX, [EDI]
	MOV			EBX, INTFACTOR
	CDQ			
	IDIV		EBX
	MOV			ESI, [EBP + 16]
	MOV			[ESI], EAX
	POP			EDX
	POP			EBX
	POP			EAX

	POP			EBP
	RET			16

CalcSumAvg ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Receives an integer as an SDWORD as input. Converts the integer to a string, then
; displays it for the user. This procedure will repeat 10 times until all integers
; are displayed.
;
; Preconditions: [EBP + 8] must be an SDWORD to be converted and displayed. [EBP + 12]
;				must be a placeholder string for the conversion. [EBP + 16] must be 
;				a reference to minus_sign. [EBP + 20] must be a placeholder output string.
;
; Postconditions: 10 integers are displayed as strings
;
; Receives: [EBP + 8] = SDWORD to be converted
;			[EBP + 12] = empty string of at least size 12
;			[EBP + 16] = reference to minus_sign ('-') stored in memory
;			[EBP + 20] = empty string of at least size 12
;
; Returns: None
; ---------------------------------------------------------------------------------
WriteVal PROC
	LOCAL		int_length:DWORD, isNeg:DWORD

	MOV			int_length, 0
	MOV			isNeg, 0

	MOV			ESI, [EBP + 8]				; Reference to SDWORD to be converted
	MOV			EDI, [EBP + 12]				; Reference to temp string
	MOV			EBX, INTFACTOR
	MOV			EDX, 0

	CLD
	LODSD
	CMP			EAX, 2147483648
	JAE			_negativeNum


_convertLoop:								; Converts the integer to a string,
	IDIV		EBX							; one digit at a time
	ADD			EDX, 48
	MOV			[EDI], DL
	ADD			EDI, 1
	MOV			EDX, 0
	INC			int_length
	CMP			EAX, 0
	JE			_finishReverse
	JMP			_convertLoop


_finishReverse:
	MOV			ECX, int_length
	MOV			ESI, [EBP + 12]				; Reference to temp string
	ADD			ESI, ECX
	DEC			ESI
	MOV			EDI, [EBP + 20]				; Reference to output string

_reverseLoop:								; Reverses the output string so it displays in proper order
	STD
	LODSB
	CLD
	STOSB
	LOOP		_reverseLoop

_display:
	CMP			isNeg, 1
	JE			_printMinus


_print:
	mDisplayString [EBP + 20]				; Reference to Output String
	RET			16

_negativeNum:
	NEG			EAX
	MOV			isNeg, 1
	JMP			_convertLoop

_printMinus:
	mDisplayString [EBP + 16]				; Reference to minus_sign
	JMP			_print

WriteVal ENDP


; ---------------------------------------------------------------------------------
; Name: outro
;
; Displays a farewell message for the user.
;
; Preconditions: farewell_msg is a string
;
; Postconditions: None
;
; Receives: farewell_msg [EBP + 8]
;
; Returns: None
; ---------------------------------------------------------------------------------
outro PROC

	PUSH		EBP
	MOV			EBP, ESP
	mDisplayString [EBP + 8]
	POP			EBP
	RET			4

outro ENDP

END main
