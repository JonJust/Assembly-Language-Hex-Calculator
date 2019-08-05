; Lab 3 - Calculator
; Jonathan Just - EECS 2110
; May 2nd, 2019
; Professor Joseph Hobbs
.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO,dwExitCode:DWORD
INCLUDE Irvine32.inc

.data
;----------------------------------------------------
msgMenu BYTE "------ Calculator --------",0dh,0ah
BYTE 0dh,0ah
BYTE "1. x AND y",0dh,0ah
BYTE "2. x OR y",0dh,0ah
BYTE "3. NOT x",0dh,0ah
BYTE "4. x XOR y",0dh,0ah
BYTE "5. x + y",0dh,0ah
BYTE "6. x - y",0dh,0ah
BYTE "7. x * y",0dh,0ah
BYTE "8. x / y",0dh,0ah
BYTE "9. Exit program",0dh,0ah
BYTE "Enter Integer: ",0
;----------------------------------------------------

;----------------------------------------------------
msgAND BYTE "Boolean AND",0
msgOR BYTE "Boolean OR",0
msgNOT BYTE "Boolean NOT",0
msgXOR BYTE "Boolean XOR",0
msgSUM BYTE "Sum",0
msgDIF BYTE "Difference",0
msgPRD BYTE "Product",0
msgQUO BYTE "Quoutient",0
;----------------------------------------------------

;----------------------------------------------------------------------
msgOperand1 BYTE "Input the first 32-bit hexadecimal operand: ",0
msgOperand2 BYTE "Input the second 32-bit hexadecimal operand: ",0
msgSignedOperand1 BYTE "Input the first signed hex value: ",0
msgSignedOperand2 BYTE "Input the second signed hex value: ",0
msgResult BYTE "The 32-bit hexadecimal result is: ",0
msgSignError BYTE "Error, input must begin with valid sign (+ or -)",0
;----------------------------------------------------------------------

;----------------------------------------------------
caseTable BYTE '1'; caseTable for every operation
	DWORD AND_op

EntrySize = ($ - caseTable)
	BYTE'2'
	DWORD OR_op
	BYTE'3'
	DWORD NOT_op
	BYTE'4'
	DWORD XOR_op
	BYTE'5'
	DWORD SUM_op
	BYTE'6'
	DWORD DIF_op
	BYTE'7'
	DWORD PRD_op
	BYTE'8'
	DWORD QUO_op
	BYTE'9'
	DWORD ExitProgram
NumberOfEntries = ($ - caseTable)/EntrySize

;This case table
;contains the adresses for the
;subroutines of each operation.
;----------------------------------------------------

.code
;---------------
main PROC

;Draws the main menu for the user.
;Clears out the registers and then
;calls ChooseProcedure. This will
;loop indefinitley until ExitProgram
;is called within a deeper subroutine.
;----------------

	call Clrscr

	mov edx, OFFSET msgMenu
	Call WriteString

	LOOP1:

	mov EAX,0; 
	mov EBX,0; 
	mov EDX,0; Clearing Out Registers

	call ChooseProcedure

	jmp LOOP1


	quit:
	exit
main ENDP

;----------------------------
ChooseProcedure PROC

;Gets a character input from
;the user. If the input is a 
;number from 1 through 9, it
;will crawl through the caseTable
;declared in .data, and call the 
;relevant subroutine. 
;----------------------------

	ReadLoop:

		Call Readchar
		
		mov ebx, OFFSET caseTable

		mov ecx, NumberOfEntries

	FindMatch:

		cmp al,[ebx]
		jne nextByte
		call NEAR PTR [ebx + 1]

	jmp ReadLoop

	nextByte:

		add ebx,EntrySize

	loop FindMatch
			
	jmp ReadLoop

ChooseProcedure ENDP

;------------------
RecieveOperands PROC

;Asks user to input two
;hex values. The method
;returns with the first 
;value stored in EAX and
;the second in EBX
;-------------------

	mov EDX, OFFSET msgOperand1
	call WriteString

	call ReadHex

	push EAX

	mov EDX, OFFSET msgOperand2
	call WriteString

	call ReadHex

	push EAX
	pop EBX
	pop EAX

	ret

RecieveOperands ENDP

;-------------------
RecieveSignedOperands PROC

;Asks user to input two
;signed hex values. The method
;returns with the first 
;value stored in EAX and
;the second in EBX. The 
;sign for the first value
;is stored in dl, and the
;second in dh.
;-------------------

	mov EDX, OFFSET msgSignedOperand1
	call WriteString

	SignLoop:

		Call ReadChar
		cmp al,'+'
		je ReadOp1
		cmp al,'-'
		je ReadOp1

		call Crlf
		mov EDX, OFFSET msgSignError
		call WriteString

	jmp SignLoop

	ReadOp1:

	call WriteChar
	push EAX; pushing sign on the stack

	call ReadHex

	push EAX

	mov EDX, OFFSET msgSignedOperand2
	call WriteString

	SignLoop2:

		Call ReadChar
		cmp al,'+'
		je ReadOp2
		cmp al,'-'
		je ReadOp2

		call Crlf
		mov EDX, OFFSET msgSignError
		call WriteString

	jmp SignLoop2

	ReadOp2:

	call WriteChar

	push EAX

	call ReadHex

	push EAX

	pop EBX; op2 in EBX
	pop EAX
	mov dh,al; op2's sign is in dh
	pop ECX; (op1)
	pop EAX
	mov dl,al; op1's sign is in al
	mov EAX,ECX; op1 is moved into EAX


	ret

RecieveSignedOperands ENDP

;-------------------------
AND_op PROC

;ANDs EAX and EBX, then writes it as a hex value into the console.
;-------------------------

	call CRLF
	mov EDX, OFFSET msgAND
	call WriteString
	call CRLF
	call RecieveOperands

	AND EAX,EBX

	call WriteHex

	ret

AND_op ENDP

;--------------------------
OR_op PROC

;ORs EAX and EBX, then writes it as a hex value into the console.
;--------------------------

	call CRLF
	mov EDX, OFFSET msgOR
	call WriteString
	call CRLF
	call RecieveOperands

	OR EAX,EBX

	call WriteHex

	ret

OR_op ENDP

;--------------------------
NOT_op PROC

;Inverts the value of EAX, then writes it as a hex value into the console.
;--------------------------

	call CRLF
	mov EDX, OFFSET msgNOT
	call WriteString
	call CRLF

	mov EDX, OFFSET msgOperand1
	call WriteString

	call ReadHex

	NOT EAX

	call WriteHex

	ret

NOT_op ENDP

;--------------------------
XOR_op PROC

;XORs EAX and EBX, then writes it as a hex value into the console.
;--------------------------

	call CRLF
	mov EDX, OFFSET msgXOR
	call WriteString
	call CRLF
	call RecieveOperands

	XOR EAX,EBX

	call WriteHex

	ret

XOR_op ENDP

;--------------------------
SUM_op PROC

;Takes two signed integers and writes the sum into the console.
;Since these integers are signed, the subroutine will decide whether
;to subtract or add EAX and EBX. The result will be negative if the first
;operand is negative and there is no overflow, and the inverse of that statement.
;--------------------------

	call CRLF
	mov EDX, OFFSET msgSUM
	call WriteString
	call CRLF
	call RecieveSignedOperands

	cmp dh,'-'
	je negOp2

	cmp dl,'-'
	je negOp1


		add EAX,EBX; both results are positive
		push EAX
		mov al,'+'
		call WriteChar
		pop EAX
		call WriteHex
	ret

	negOp1: ;Op1 neg op2 pos
		cmp dh,'-'
		je negSumResult
		sub EBX,EAX
		mov EAX,EBX
		jc OverFlow
		mov EAX,EBX
		push EAX
		mov al,'+'
		call WriteChar
		pop EAX
		call WriteHex
	ret

	negOp2: ;Op1 pos op2 neg
		cmp dl,'-'
		je negSumResult
		sub EAX,EBX
		jc OverFlow
		push EAX
		mov al,'+'
		call WriteChar
		pop EAX
		call WriteHex
	ret

	OverFlow:
		mov EBX,0FFFFFFFFh
		sub EBX,EAX
		mov EAX,EBX
		inc EAX
		push EAX
		mov al,'-'
		call WriteChar
		pop EAX
		call WriteHex
	ret

	negSumResult: ;When both Numbers are Negative
		add EAX,EBX
		push EAX
		mov al,'-'
		call WriteChar
		pop EAX
		call WriteHex
	ret

SUM_op ENDP

;--------------------------
DIF_op PROC

;Functions nearly identically to SUM_op.
;All subtraction is is addition while inverting the second term.
;This method merely inverts the second operand and then carries
;on identically to the SUM_op method.
;--------------------------

	call CRLF
	mov EDX, OFFSET msgDIF
	call WriteString
	call CRLF
	call RecieveSignedOperands


	cmp dh,'-'
	je setPos
	mov dh,'-'
	jmp continue

	setPos:
	mov dh,'+'

	continue: 


	cmp dh,'-'
	je negOp2

	cmp dl,'-'
	je negOp1

		add EAX,EBX; both results are positive
		push EAX
		mov al,'+'
		call WriteChar
		pop EAX
		call WriteHex
	ret

	negOp1:
		cmp dh,'-'
		je negSumResult
		sub EBX,EAX
		mov EAX,EBX
		jc OverFlow
		mov EAX,EBX
		push EAX
		mov al,'+'
		call WriteChar
		pop EAX
		call WriteHex
	ret

	negOp2: ;When one number is negative and the other is positive
		cmp dl,'-'
		je negSumResult
		sub EAX,EBX
		jc OverFlow
		push EAX
		mov al,'+'
		call WriteChar
		pop EAX
		call WriteHex
	ret

	OverFlow:
		mov EBX,0FFFFFFFFh
		sub EBX,EAX
		mov EAX,EBX
		inc EAX
		push EAX
		mov al,'-'
		call WriteChar
		pop EAX
		call WriteHex
	ret

	negSumResult: ;When both Numbers are Negative
		add EAX,EBX
		push EAX
		mov al,'-'
		call WriteChar
		pop EAX
		call WriteHex
	ret

	ret

DIF_op ENDP

;--------------------------
PRD_op PROC

;Multiplies EBX and EAX together and writes the results
;as a hex value.
;The sign is found by checking if the two signs are identical or not.
;If the signs of the operands are identical, the result will be positive.
;When different, they are negative.
;--------------------------
	call CRLF
	mov EDX, OFFSET msgPRD
	call WriteString
	call CRLF
	call RecieveSignedOperands

	push EAX

	cmp dl,dh
		je isPos
		mov al,'-'
		jmp continue

	isPos:
		mov al,'+'

	continue:

	call WriteChar

	pop EAX

	mul EBX

	push EAX

	mov EAX,EDX

	call WriteHex

	pop EAX

	call WriteHex

	ret

PRD_op ENDP

;--------------------------
QUO_op PROC

;Divides EAX by EBX, and then writes the result as a hex value.
;The sign is found by checking if the two signs are identical or not.
;If the signs of the operands are identical, the result will be positive.
;When different, they are negative.
;--------------------------

	call CRLF
	mov EDX, OFFSET msgQUO
	call WriteString
	call CRLF
	call RecieveSignedOperands

	push EAX

	cmp dl,dh
		je isPos
		mov al,'-'
		jmp continue

	isPos:
		mov al,'+'

	continue:

	call WriteChar

	pop EAX

	mov EDX,0

	div EBX

	call writeHex

	ret

QUO_op ENDP


ExitProgram PROC

	invoke ExitProcess,0

ExitProgram ENDP


END main