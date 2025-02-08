bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit               ; tell nasm that exit exists even if we won't be defining it
import exit msvcrt.dll    ; exit is a function that ends the calling process. It is defined in msvcrt.dll
                          ; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions

; our data is declared here (the variables needed by our program)
segment data use32 class=data
    ; ... A string of quadwords is given. Save in D (string of quadwords) only the quadwords from S with an odd number of set bits (bits with value 1 in binary).
    S dq 000001b, 0010b, 0011b, 0101b, 000100b
    lens equ ($-S)/8
    D resq lens

; our code starts here
segment code use32 class=code
    start:
        ; ...
        mov ecx, lens               ;loop counter
        mov esi, 0                  ;index for S
        mov edi, 0                  ;index for D
        
        repeat:
            mov bx, 0               ;used for counting the 1's in the quadword in our loop
            mov dl, 0               ;used for counting the number of bits that we are looping through
            mov dh, 0               ;used for making sure we check both doublewords in the quad
            mov eax, dword[S+esi]
            shifting:               
                clc
                inc dl
                shl eax, 1          ;we shift the bits, each time placing the leftmost bit in our carry flag
                jc addition         ;if carry flag is set off, we have a 1 and it jumps to our label that handles the count
                cmp dl, 32          ;if it is not a 1, we check if we still need to loop through the doubleword
                jnz shifting        ;loops back to the next shift
                jz next             ;exits the loop and jumps to a label that handles moving to next doubleword
                
                addition:           ;when bit is 1, we increment our counter, and check if we still need to loop through the doubleword
                    inc bx
                    cmp dl, 32
                    jnz shifting
                    jz next         ;if we do not need to loop, we jump to next step
            next:
                inc dh              ;if we are done with one doubleword, we check if the quad still has a half that has not been iterated through
                cmp dh, 2           
                jnz final           ;if we iterated through the entire quad, we move on to the next quad in the string
                
                test bx, 01b        ;we check if our counter is odd
                jnz odd             
                add esi, 4          ;if it is not, we just increment our index for S and loop again
                loop repeat
                
            final:                  ;code segment that handles moving to the second part of the doubleword 
                add esi, 4
                mov eax, dword[S+esi]
                mov dl, 0
                jmp shifting
                
                
            odd:
                mov edx, dword[S+esi-4] ;in case our number needs to be added, we add both parts of it to D making sure to use the unmodified version
                mov eax, dword[S+esi]   
                mov [D+edi], edx
                mov [D+edi+4], eax
                add esi, 4              ;increment both indexes and loop 
                add edi, 8
                loop repeat
                
            
            
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
