TITLE Program 3 (Schachtsick_Program03.asm)

; Author: Jeffrey Schachtsick
; Course / Project ID : CS290 - Computer Architecture and Assembly / Programming Assignment #3
; Date: 01 / 30 / 2016
; Description: Write and test a MASM program to perform the following tasks:
;    1. Display the program title and programmer's name.
;    2. Get the user's name, and greet the user.
;    3. Display instructions for the user.
;    4. Repeatedly prompt the user to enter a number.Validate the user input to be in[-100, -1](inclusive).
;         Count and accumulate the valid user numbers until a non - negative number is entered. (The non - negative number is discarded).
;    5. Calculate the(rounded integer) average of the negative numbers.
;    6. Display:
;         i.the number of negative numbers entered(Note: if no negative numbers were entered, display a special message and skip to iv.)
;         ii.the sum of negative numbers entered
;         iii.the average, rounded to the nearest integer(eg - 20.5 round to - 20)
;         iv.a parting message(with the user's name)

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data

; (insert variable definitions here)
intro          BYTE "Welcome to the Integer Accumulator by Jeffrey Schachtsick", 0
ask_name       BYTE "What is your name? ", 0
userName       BYTE 33 DUP(0); string to be entered by user
greetUser      BYTE "Hello, ", 0
instruct_1     BYTE "Please enter numbers in [-100, -1].", 0
instruct_2     BYTE "Enter a non-negative number when you are finished to see results.", 0
parting_mes    BYTE "Thank you for playing Integer Accumulator!  It's been a pleasure to meet you, ", 0
enter_num      BYTE "Enter number: ", 0
display_val1   BYTE "You entered ", 0
display_val2   BYTE " valid numbers.", 0
display_sum    BYTE "The sum of your valid numbers is ", 0
display_round  BYTE "The rounded average is ", 0
user_num       DWORD ? ; number entered by user
count_num      DWORD 0; increments the number of negative numbers in range
sum_num        DWORD 0; sum of all negative numbers in range
range_bot      DWORD - 100; bottom range of valid numbers
range_up       DWORD - 1; upper range of valid numbers
round_av       DWORD ? ; Rounded average value
error_mes      BYTE "Your number is OUT OF RANGE!  Try Again!", 0
remain         DWORD ? ; remainder of division 


.code
main PROC

; Introductions(1)
mov edx, OFFSET intro
call WriteString
call CrLf

; Get user name and greet(2)
mov edx, OFFSET ask_name
call WriteString
mov edx, OFFSET userName
mov ecx, 32
call ReadString
mov edx, OFFSET greetUser
call WriteString
mov edx, OFFSET userName
call WriteString
call CrLf
call CrLf
mov ecx, 0

; Display instructions(3)
mov edx, OFFSET instruct_1
call WriteString
call CrLf
mov edx, OFFSET instruct_2
call WriteString
call CrLf

; Validation Loop, make decisions based on user input(4)
validate:
mov edx, OFFSET enter_num
call WriteString
call ReadInt
mov user_num, eax

; Conditional, number is less than -100, display error 
cmp eax, range_bot   
jl error
cmp eax, range_up 
jle increment  
jmp display 

error:
mov edx, OFFSET error_mes
call WriteString
call CrLf 
jmp validate

increment:
; Increment the count
mov eax, count_num
inc eax
mov count_num, eax
; Add current number to the sum
mov eax, sum_num
mov ebx, user_num 
add eax, ebx 
mov sum_num, eax
jmp validate

display:
; Calculate rounded average of numbers(5)
mov eax, 0
mov edx, 0
mov eax, sum_num
cdq
mov ebx, count_num
idiv ebx
mov round_av, eax
mov remain, edx
mov eax, remain
imul ebx
cmp eax, -5
jg nothing
dec round_av 

; skip to nothing if less than or equal to 5
nothing:

; Display output(6)
; number of negative numbers(part i)
; display special message if count is 0

mov edx, OFFSET display_val1
call WriteString
mov eax, count_num
call WriteDec
mov edx, OFFSET display_val2
call WriteString
call CrLf
; sum of negative numbers(part ii)
mov edx, OFFSET display_sum
call WriteString
mov eax, sum_num
call WriteInt
call CrLf
; average of negative numbers(part iii)
mov edx, OFFSET display_round 
call WriteString 
mov eax, round_av 
call WriteInt 
call CrLf 

; (insert executable instructions here)

; Parting Message(part iv)
mov edx, OFFSET parting_mes 
call WriteString 
mov edx, OFFSET userName 
call WriteString 
exit; exit to operating system
main ENDP

; (insert additional procedures here)

END main