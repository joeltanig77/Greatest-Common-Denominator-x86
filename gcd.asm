SECTION .data

; Some setup for the prompts we are about to print

promptOne:       db   "Enter a positive integer: "
promptOneLength: equ    $-promptOne

errorMessage:    db    "Bad Number"
errorMessageLength:  equ    $-errorMessage

gcdMessage:      db     "Greatest common divisor = "
gcdMessageLength:   equ    $-gcdMessage

newLine:         db     10
newLineLength:   equ    $-newLine


; Create some space for our strings

SECTION .bss

digitsPromptOne: equ      21
inbufPromptOne:  resb     digitsPromptOne

digitsPromptTwo: equ      21
inbufPromptTwo:  resb     digitsPromptTwo

charStorage:     resb     1

SECTION .text

global  _start

_start:
        push    ebx                 ; Preserve registers
        push    ecx
        ; Ask for the first user string
        call    readNumber
        pop     ecx                   ; Pop in correct order
        pop     ebx
        mov     ebx, eax              ; ebx is a = readNumber();
        nop
        push    ebx                   ; Preserve registers
        push    ecx
        ; Ask for the second user string
        call    readNumber
        pop     ecx                   ; Pop in correct order
        pop     ebx
        mov     ecx, eax              ; ecx is b = readNumber();
        nop

        pusha

        mov     eax, 4                ; call the janitor to write
		mov     ebx, 1                ; to standard output
		mov     ecx, gcdMessage       ; the prompt string
		mov     edx, gcdMessageLength ; length of prompt
		int     80H                   ; syscall
        popa

; Send our arguments that we are going to use in reverse order to not mess up the stack
        push    ecx
        push    ebx
        call    gcd
        pop     ebx
        pop     ecx
        mov     edx, eax               ; Our return value here answer = gcd(a,b);

        push    edx
        call    makeDecimal
        add     esp, 4
        mov     esp , ebp               ; restore caller;s stack pointer

        jmp     fin


readNumber:
        PUSH 	ebp                     ; Do this every time we make a new function
        MOV		ebp, esp                ; Make stack pointer = to the base pointer
        mov     eax, 4                  ; call the janitor to write
		mov     ebx, 1                  ; to standard output
		mov     ecx, promptOne          ; the prompt string
		mov     edx, promptOneLength    ; length of prompt
		int     80H                     ; syscall

		mov     eax, 3                  ; call the janitor to read
		mov     ebx, 0                  ; to standard input
		mov     ecx, inbufPromptOne     ; into the input buffer (This is where the string is stored)
		mov     edx, digitsPromptOne
		int     80H                     ; syscall
		mov     ecx, inbufPromptOne     ; into the input buffer (This is where the string is stored)
		push    ecx


        call    getInt                  ; call the other func get Int
        add     esp, 4
        mov     esp , ebp               ; restore caller;s stack pointer
        pop     ebp                     ; restore original ebp
        ret


getInt:
	    PUSH 	ebp                     ; Do this every time we make a new function
	    MOV		ebp, esp                ; Make stack pointer = to the base pointer


	    push    esi

        mov     esi,[ebp+8]             ; This is the string I hope
        nop


        mov     ecx, 1                  ; unsigned int digitValue = 1; ;
        mov     ebx, 0                  ; unsigned int result = 0;
        push    ebx                     ; 0
        mov     edx, esi                ; char* digit = string;
        mov     ebx, esi                ; this one too


while:
        lodsb
        cmp     AL, 10
        jz      lastDigit
        jmp     while


lastDigit:
        pop     ebx                     ; Unload result for updating
        dec     esi                     ; This should be the last digit
        dec     esi
        lodsb

        jmp     while2


while2:
        cmp     AL, 0                   ; if (*digit == ' ') was 32
        je      break

        cmp     AL, 32
        je      break

        cmp     AL, 48                  ; if (*digit < '0')
        jl      badNumber
        cmp     AL, 57                  ; if (*digit > '9')
        jg      badNumber


        sub      AL, 48                 ; (*digit - '0')


        movzx      eax, AL
                                        ; digit value

        mul        ecx                  ; (*digit - '0') * digitValue


        add        ebx, eax             ; this is result

        mov        eax, 10              ; digitValue *= 10

        mul        ecx

        mov        ecx, eax             ; Move the digitValue to the original place

        dec         esi                 ; Dec twice to move back a char as lodsb defaults to taking one char out no matter what
        dec         esi
        lodsb                           ; dec the pointer to $al char cursor

        jmp        while2


break:
        ; We get out of the while loop here
        ; clean up clean up
        mov     esp , ebp               ; restore caller;s stack pointer
        pop     ebp                     ; restore original ebp
        nop
        mov     eax, ebx

        ret


gcd:
	    PUSH 	ebp                     ; Do this every time we make a new function
	    MOV		ebp, esp                ; Make stack pointer = to the base pointer

        mov    ebx, [ebp+8]             ; Retrieve the args we pushed (arg 1-n)

        mov    ecx, [ebp+12]            ; (arg 2-m)
        nop

        ; if statement 1
        cmp     ebx, ecx
        jg      ifStatementA            ; if (n > m) return gcd(n - m, m    );   // recursion

        ; if statement 2
        cmp    ebx, ecx
        jl     ifStatementB


baseCase:
        ; clean up clean up
        mov     esp , ebp               ; restore caller;s stack pointer
        pop     ebp                     ; restore original ebp
        nop
        mov     eax, ebx
        ret


ifStatementA:
        sub     ebx, ecx
        push    ecx
        push    ebx
        call    gcd
        add     esp, 8
        mov     esp , ebp               ; restore caller;s stack pointer
        pop     ebp                     ; restore original ebp
        ret


ifStatementB:
        sub     ecx, ebx
        push    ecx
        push    ebx
        call    gcd
        add     esp, 8
        mov     esp , ebp               ; restore caller;s stack pointer
        pop     ebp                     ; restore original ebp
        ret


fin:
		mov     eax, 4
		mov     ebx, 1
		mov     ecx, newLine
		mov     edx, newLineLength
		int     80H                     ; syscall
        mov     eax, 1				    ; set up process exit
        mov     ebx, 0				    ; and
        int	    80H				        ; terminate


; Helper functions
badNumber:
        mov     eax, 4                  ; call the janitor to write
		mov     ebx, 1                  ; to standard output
		mov     ecx, errorMessage       ; the prompt string
		mov     edx, errorMessageLength ; length of prompt
		int     80H                     ; syscall
		jmp     fin


makeDecimal:
        PUSH 	ebp                     ; Do this every time we make a new function
        MOV		ebp, esp                ; Make stack pointer = to the base pointer
        pushad
        mov    edx, [ebp+8]             ; Retrieve the args we pushed (arg 1-n)
        mov    eax, edx
        mov    edx, 0
        mov    ecx, 10                  ; Reassign it to ecx as edx stores the remainder
        div    ecx
        ; eax is quotient
        ; edx is remainder
        cmp    eax, 0
        jg     recurse
        jmp    ifNotRecurseS


recurse:
        mov    ebx, eax
        push   ebx                      ; unsigned int quotient = n / 10;
        call   makeDecimal
        add     esp, 4


ifNotRecurseS:
        add     edx, 48                    ; char digit = remainder + '0';
        mov     [charStorage], edx         ; Print the char
		mov     eax, 4
		mov     ebx, 1
		mov     ecx, charStorage
		mov     edx, 1
		int     80H                        ; syscall
        nop
        popad
        mov     esp , ebp                  ; restore caller;s stack pointer
        pop     ebp                        ; restore original ebp
        ret