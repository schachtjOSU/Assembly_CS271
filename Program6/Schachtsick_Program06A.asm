TITLE Program Schachtsick_Program06A(Schachtsick_Program06A.asm)

; Author: Jeffrey Schachtsick
; Course / Project ID : CS290 - Computer Architecture and Assembly / Programming Assignment #6A 
; Date: 03 / 06 / 2016
; Description: Write and test a MASM program to perform the following tasks :
;    -Implement and test your own ReadVal and WriteVal procedures for unsigned integers
;    -Implement macros getString and displayString.The macros may use Irvine's ReadString to get input from the user, and WriteString to display output.
;       -getString should display a prompt, then get the user's keyboard input into a memory location.
;       -displayString should the string stored in a specified memory location.
;       -realVal should invoke the getString macro to get the user's string of digits.  It should then convert the digit string to numeric, while validating the user's input.
;       -writeVal should convert a numeric value to a string of digits, and invoke the displayString macro to produce the output.
;    -Write a small test program that gets 10 valid integers from the user and stores the numeric values in an array.The program then displays the integers, their sum, and their average.

INCLUDE Irvine32.inc

; (insert constant definitions here)
MAX equ 10; maximum user can enter in array


; Macro for Reading String procedure
; Source found in Lecture26.pdf of CS 271 course lectures
getString MACRO varName
push ecx
push edx
mov edx, OFFSET varName
mov ecx, (SIZEOF varName) - 1
call ReadString
pop edx
pop ecx
ENDM

; Macro for Writing String procedure
; Source found in Lecture26.pdf of CS 271 course lectures
displayString MACRO buffer
push edx
mov edx, OFFSET buffer
call WriteString
pop edx
ENDM


.data
; (insert variable definitions here)
title_assign   BYTE "PROGRAMMING ASSIGNMENT 6A: Designing low-level I/O procedures", 0
write_by       BYTE "Written by: Jeffrey Schachtsick", 0
intro_1        BYTE "Please provide 10 unsigned decimal integers.", 0
intro_2        BYTE "Each number needs to be small enough to fit inside a 32 bit register.", 0
intro_3        BYTE "After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.", 0
fare_well      BYTE "Thanks for playing!", 0
enter_num      BYTE "Please enter an unsigned number: ", 0
error_msg1     BYTE "ERROR: You did not enter an unsigned number or your number was too big.", 0
error_msg2     BYTE "Please try again: ", 0
validate_nums  BYTE "You entered the following numbers: ", 0
sum_msg        BYTE "The sum of these numbers is: ", 0
avg_msg        BYTE "The average is: ", 0
nums_array     DWORD MAX DUP(? ); array of numbers
create_space   BYTE ", ", 0
in_string      BYTE 30 DUP(? ); input to the string for ReadString
out_num        DWORD ?
sum_num        DWORD 0


.code
main PROC
; (insert executable instructions here)
; Write the title sentences
push OFFSET write_by
push OFFSET title_assign
call titlePrint

; Write the introduction sentences
push OFFSET intro_3
push OFFSET intro_2
push OFFSET intro_1
call introPrint

; fill array with numbers
push OFFSET error_msg2
push OFFSET error_msg1
push OFFSET enter_num 
push OFFSET nums_array
call readVal

; write array and push the in_string
push OFFSET avg_msg
push OFFSET sum_msg
push OFFSET create_space
push OFFSET validate_nums
push sum_num
push OFFSET nums_array
call writeVal


; Write the goodbye sentence
push OFFSET fare_well
call byePrint


exit; exit to operating system
main ENDP

; (insert additional procedures here)
; Procedure to print the title strings
; receives: 2 BYTEs, title_assign and write_by
; returns: none
; preconditions:  none
titlePrint PROC
push ebp
mov ebp, esp
mov edx, [ebp + 8]
call WriteString
call CrLf
mov edx, [ebp + 12]
call WriteString
call CrLf
call CrLf
pop ebp
ret
titlePrint ENDP


; Procedure to print the intro strings
; receives: 3 BYTEs, intro_1, intro_2, and intro_3
; returns: none
; preconditions:  none
introPrint PROC
push ebp
mov ebp, esp
mov edx, [ebp + 8]
call WriteString
call CrLf
mov edx, [ebp + 12]
call WriteString
call CrLf
mov edx, [ebp + 16]
call WriteString
call CrLf
call CrLf
pop ebp
ret
introPrint ENDP


; Procedure to read in string to the array, makes sure string is integers
; receives: 1 DWORD array of 10 elements, nums_array
; returns: nums_array
; preconditions: none
readVal PROC
push ebp
mov ebp, esp
mov edi, [ebp + 8]; address of number array

; set a count for the loop
mov ecx, MAX

; make array of numbers
more:
mov edx, [ebp + 12]
call WriteString

; Get string 
findString:
push ecx
xor eax, eax
xor ebx, ebx 
getString in_string; Macros for reading string
mov esi, OFFSET in_string
mov ecx, eax; set size to loop counter
cld

; Processing the string
stringProcess :
lodsb
cmp al, 48; '0' in ascii is 48
jl writeError
cmp al, 57; '9' in ascii is 57
jg writeError
sub al, 48; convert the string byte to number
lea ebx, [ebx + ebx * 4]
lea ebx, [eax + ebx * 2]
loop stringProcess

mov[edi], ebx

jmp skipError 

; Write an error and try again 
writeError:
pop ecx 
mov edx, [ebp + 16]
call WriteString
call CrLf 
mov edx, [ebp + 20]
call WriteString 
jmp findString 

skipError:
pop ecx 
add edi, 4
loop more

call CrLf

pop ebp
ret 8
readVal ENDP


; Procedure to write array to display, makes sure transitioned int to string
; receives: 1 DWORD array of 10 elements, nums_array
; returns: nums_array
; preconditions: none
writeVal PROC
push ebp
mov ebp, esp
mov edi, OFFSET out_num 

; Write all values to output
mov edx, [ebp + 16]
call WriteString
call CrLf
mov ecx, MAX
mov esi, [ebp + 8]; point to array
mov ebx, 0
cld 

writingNums:
lodsd
push eax
add[ebp + 12], eax
mov ebx, 10
getSingleDigits:
xor edx, edx 
div ebx 
add edx, 48
push edx 
test eax, eax
jnz getSingleDigits 
pop edx

convertInts:
stosb
mov out_num, edx
displayString out_num
pop edx
cmp esp, ebp
jne convertInts

xor eax, eax
stosb

; getting the sum into ebx 
add ebx, eax 

cmp ecx, 1
je skipComma 
mov edx, [ebp + 20]
call WriteString 
skipComma:
loop writingNums

; Sum all the numbers
call CrLf
mov edx, [ebp + 24]
call WriteString
mov eax, [ebp + 12]
call WriteDec
call CrLf

; Get the average 
mov edx, [ebp + 28]
call WriteString 
cdq 
mov ebx, MAX 
div ebx 
call WriteDec 
call CrLf 

pop ebp
ret 12
writeVal ENDP


; Procedure to print the goodbye string
; receives: 1 BYTEs, fare_well 
; returns: none
; preconditions:  none
byePrint PROC
push ebp
mov ebp, esp
mov edx, [ebp + 8]
call CrLf
call WriteString
call CrLf
call CrLf
pop ebp
ret
byePrint ENDP

END main