TITLE Program Template(template.asm)

; Author: Jeffrey Schachtsick
; Course / Project ID : CS290 - Computer Architecture and Assembly / Programming Assignment #4               Date :
; Date: 02 / 20 / 2016
; Description: Write and test a MASM program to perform the following tasks:
;    1. Introduce the program.
;    2. Get a user request in the range[min = 10...max = 200].
;    3. Generate request random integers in the range[lo = 100...hi = 999], storing them in consecutive elements of an array.
;    4. Display the list of integers before sorting, 10 numbers per line.
;    5. Sort the list in descending order(i.e., largest first).
;    6. Calculate and display the median value, rounded to the nearest integer.
;    7. Display the sorted list, 10 numbers per line.


INCLUDE Irvine32.inc

; insert constant definitions here
MIN equ 10; minimum user range request
MAX equ 200; maximum user range request
LO_NUM equ 100; lowest random integer in range
HI_NUM equ 999; highest random integer in range
TAB equ 9; spacing for printing numbers


.data
; (insert variable definitions here)
title_Prog     BYTE "Sorting Random Integers          Programmed by Jeffrey Schachtsick", 0
intro          BYTE "This program generates random numbers in the range [100 .. 999], displays the original list, sorts the list, and calculates the median value.  Finally, it displays the list sorted in descending order.", 0
invalid_Err    BYTE "Invalid input", 0 
ask_Nums       BYTE "How many numbers should be generated? [10 .. 200]: ", 0
unsort_NumLine BYTE "The unsorted random numbers: ", 0; FIX 
median_Line    BYTE "The median is: ", 0
sort_NumLine   BYTE "The sorted list: ", 0
goodbye        BYTE "Results certified by Jeffrey Schachtsick.     Goodbye.", 0
req_value      DWORD ? ; user requested number of random numbers
sort_array   DWORD MAX DUP(? )


.code
main PROC
; (insert executable instructions here)
push OFFSET intro
push OFFSET title_Prog
call introduction; Introductions to the program

push OFFSET invalid_Err 
push OFFSET ask_Nums 
push OFFSET req_value
call getData; User asks for number of random numbers

push OFFSET unsort_NumLine
push OFFSET sort_array
push req_value
call fillArray; make array of unsorted random numbers

push req_value
push OFFSET sort_array
call sortList; sort the array in descending order 

push OFFSET median_Line
push req_value
push OFFSET sort_array
call displayMedian; calculate the median value from the list.

push OFFSET sort_NumLine
push req_value
push OFFSET sort_array
call displayList; display the sorted list 

push OFFSET goodbye
call fin


exit; exit to operating system
main ENDP


; (insert additional procedures here)
; Procedure to introduce the program.
; receives: 2 BYTEs, titleProg and intro
; returns: none
; preconditions:  none
introduction PROC
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
introduction ENDP


; Procedure to get data from user
; receives: 1 reference of the request
; returns: user input of number of randoms 
; preconditions:  none
getData PROC
push ebp
mov ebp, esp
mov ebx, [ebp + 8]
outtaRange :
mov edx, [ebp + 12]
call WriteString
call ReadInt
mov [ebp + 8], eax

; validate number
cmp eax, MIN
jl error
cmp eax, MAX
jle goodValue

error:
mov edx, [ebp + 16]
call WriteString
call CrLf
jmp outtaRange

goodValue:
mov eax, [ebp + 8]
; call WriteDec
call CrLf
mov[ebx], eax

pop ebp
ret 4
getData ENDP


; Procedure to formally end the program.
; receives: 1 request passed as value, and 1 array passed by reference
; returns: an unsorted array of random numbers.
; preconditions:  none
; Referncing below code to demo5.asm,
;    Lecture 20: Displaying Arrays & Using Random Numbers,
;    and pg 174 and 175 of the text for Randome number generator 
fillArray PROC
push ebp
mov ebp, esp

mov edx, [ebp + 16]
call WriteString
call CrLf

mov ecx, [ebp + 8]; count in ecx 
mov edi, [ebp + 12]; address of unsorted array 

more:
mov eax, HI_NUM
mov ebx, LO_NUM
inc ebx; 
sub eax, ebx; range of 0 to HI
call RandomRange; IRVINE library for Random number generator
add eax, LO_NUM; range now of LO to HI
call WriteDec
mov[edi], eax; move number into element of array
add edi, 4
mov al, TAB
call WriteChar
loop more

call CrLf
call CrLf
pop ebp
ret 8
fillArray ENDP


; Procedure to sort the array in decsending order
; receives: request value passed by value, and unsorted array passed as reference
; returns: returns the sorted array
; preconditions:  fillArray has already occured with random numbers
; Referncing code below partially from bubble sort algorithm in Assembly Language for x86 pg 375 
sortList PROC
push ebp
mov ebp, esp

mov ecx, [ebp + 12]; counter
dec ecx; decrement the count by one 

outerLoop: 
push ecx; save the counter of the outer loop
mov esi, [ebp + 8]; point to the first value 

innerLoop: 
mov eax, [esi]
cmp[esi + 4], eax
jle skipSwap

push eax
push esi 
call exchElements

skipSwap:
add esi, 4
loop innerLoop
pop ecx
loop outerLoop

pop ebp
ret
sortList ENDP


; Procedure for exchanging elements in an array
; receives: 2 elements from an array as passed by reference
; returns: returns the swapped elements from the array
; preconditions:  two elements in an array are compared, where the previous element is less than the other
; Referncing code below partially from bubble sort algorithm in Assembly Language for x86 pg 375
exchElements PROC
push ebp
mov ebp, esp
mov eax, [ebp + 12]
mov esi, [ebp + 8]

xchg eax, [esi + 4]
mov[esi], eax

pop ebp
ret 8
exchElements ENDP


; Procedure to display the median value for all values in the list.
; receives: request value passed by value, sorted array passed as reference, and the title passed by reference
; returns: returns both the sorted array and title, no change is done to either
; preconditions:  unsorted array is now sorted after completing sort_list algorithm
; References: some design from this function are taken from demo5.asm
displayMedian PROC
push ebp
mov ebp, esp

mov edx, [ebp + 16]
call WriteString

mov esi, [ebp + 8]

; divide number by 2 to determine even or odd
mov eax, [ebp + 12]
cdq
mov ebx, 2
div ebx
cmp edx, 0
jne itsOdd

; itsEven
mov edx, eax
mov eax, [esi + eax * 4]
; mov eax, edx
mov ebx, [esi+4+edx*4]
add eax, ebx 
cdq 
mov ebx, 2 
div ebx 
call WriteDec
jmp skipOdd

itsOdd:
mov eax, [esi+eax*4]
call WriteDec 

skipOdd:
call CrLf 
call CrLf 
pop ebp 
ret 
displayMedian ENDP 



; Procedure to display the list as a sorted array.
; receives: request value passed by value, sorted array passed as reference, and the title passed by reference
; returns: returns both the sorted array and title, no change is done to either
; preconditions:  unsorted array is now sorted after completing sort_list algorithm
displayList PROC
push ebp
mov ebp, esp

mov edx, [ebp + 16]
call WriteString
call CrLf

mov ecx, [ebp + 12]; count to ecx
mov esi, [ebp + 8]; address of sorted array in esi
cld

printMore:
lodsd
call WriteDec 
mov al, TAB
call WriteChar
loop printMore 

call CrLf
call CrLf

pop ebp 
ret 
displayList ENDP 


; Procedure to formally end the program.
; receives: 1 BYTE, goodbye
; returns: none
; preconditions:  none
fin PROC 
push ebp 
mov ebp, esp 
mov edx, [ebp + 8]
call WriteString 
call CrLf 
pop ebp 
ret
fin ENDP 

END main