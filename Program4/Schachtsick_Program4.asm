TITLE Program 4 (Schachtsick_Program4.asm)

; Author: Jeffrey Schachtsick
; Course / Project ID : CS290 - Computer Architecture and Assembly / Programming Assignment #4               Date :
; Date: 02 / 12 / 2016
; Description: Write a program to calculate composite numbers from a range of[1..400]
;    1. The programmer's name must appear in the output.
;    2. The counting loop(1 to n) must be implemented using the MASM loop instruction
;    3. The main procedure must consist(mostly) of procedure calls.It should be a reachable "list" of what the program will do.
;    4. Each procedure will implement a section of the program logic
;    5. Upper limit should be defined and used as a constant
;    6. Data validation is required.


INCLUDE Irvine32.inc

; (insert constant definitions here)
UPPER_LIMIT equ 400; top range of valid numbers of n

.data

; (insert variable definitions here)
introd         BYTE "Composite Numbers     Programmed by Jeffrey Schachtsick", 0
instruct_1     BYTE "Enter the number of composite numbers you would like to see."
instruct_2     BYTE "I'll accept orders for up to 400 composites.", 0
goodbye        BYTE "Results certified by Jeffrey Schachtsick.     Goodbye.", 0
askNum         BYTE "Enter the number of composites to display [1 .. 400]: ", 0
errRange       BYTE "Out of range.  Try agian.", 0
user_num       DWORD ? ; nth number entered by user.
validation     DWORD ? ; Either 1 true or 0 false for the validate algorithm
bot_range      DWORD 1;  bottom range of valid numbers
test_comp      DWORD ? ; test the number for composition
valid_comp     DWORD ? ; either 1 true or 0 false for valid composition number
tester         DWORD 2; iterates to find composite numbers
spacing        BYTE "   ", 0



.code
main PROC
call intro
call getUserData
call showComposites
call farewell


exit; exit to operating system
main ENDP

; (insert additional procedures here)

; Procedure to introduce the program.
; receives: none
; returns: none
; preconditions:  none
intro PROC
mov edx, OFFSET introd
call WriteString
call CrLf
call CrLf
mov edx, OFFSET instruct_1
call WriteString
call CrLf
mov edx, OFFSET instruct_2
call WriteString
call CrLf
call CrLf
ret
intro ENDP

; Procedure to get users number.
; receives: none
; returns: number
; preconditions:  none
getUserData PROC
outtaRange:
mov edx, OFFSET askNum
call WriteString
call ReadInt
mov user_num, eax
; validate
call validate
; if validation is 0, go back and ask again 
mov ebx, validation
cmp ebx, 0
je outtaRange
ret 
getUserData ENDP 

; Procedure validate users number.
; receives: user number 
; returns: none
; preconditions:  none
validate PROC 
cmp eax, bot_range
jl error
cmp eax, UPPER_LIMIT 
jle goodValue 

error:
mov validation, 0
mov edx, OFFSET errRange
call WriteString 
call CrLf
jmp returValid 

goodValue:
mov validation, 1

returValid:

ret
validate ENDP

; Procedure to show Composite numbers.
; receives: none
; returns: none
; preconditions:  validated n is between 1 and 400
showComposites PROC

mov ecx, user_num 
mov test_comp, 3
comp:
skipPrint:
inc test_comp
call isComposite

; Return true?  No, skip the print
mov ebx, valid_comp 
cmp ebx, 0
je skipPrint 

mov eax, test_comp 
call WriteDec 
mov edx, OFFSET spacing 
call WriteString 

loop comp 
ret
showComposites ENDP 

; Procedure to validate whether number is composite .
; receives: none
; returns: number
; preconditions:  validated n is between 1 and 400
isComposite PROC
mov tester, 1
keepGoing:
inc tester 
mov eax, test_comp 
cdq
mov ebx, tester 
div ebx 
cmp edx, 0  
jne keepGoing 
cmp eax, 1
je returnFalse 
mov valid_comp, 1
jmp returning 

returnFalse:
mov valid_comp, 0

returning:
ret
isComposite ENDP

; Procedure to goodbye the program.
; receives: none
; returns: none
; preconditions:  none
farewell PROC 
call CrLf 
call CrLf 
mov edx, OFFSET goodbye 
call WriteString 
ret 
farewell ENDP 

END main
