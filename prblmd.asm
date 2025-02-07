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
        mov ecx, lens
        mov esi, 0
        mov edi, 0
        
        repeat:
            mov bx, 0
            mov dl, 0
            mov dh, 0
            mov eax, dword[S+esi]
            shifting:   
                clc
                inc dl
                shl eax, 1
                jc addition
                cmp dl, 32
                jnz shifting
                jz final
                
                addition:
                    inc bx
                    cmp dl, 32
                    jnz shifting
                    jz final
            final:
                inc dh
                cmp dh, 2
                jnz next
                
                test bx, 01b
                jnz odd
                add esi, 4
                loop repeat
                
            next:
                add esi, 4
                mov eax, dword[S+esi]
                mov dl, 0
                jmp shifting
                
                
            odd:
                mov edx, dword[S+esi-4]
                mov eax, dword[S+esi]
                mov [D+edi], edx
                mov [D+edi+4], eax
                add esi, 4
                add edi, 8
                loop repeat
                
            
            
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
