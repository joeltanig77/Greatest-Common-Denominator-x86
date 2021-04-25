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

extern printf			; same for printf

; Create some space for our strings

SECTION .bss

digitsPromptOne: equ      21
inbufPromptOne:  resb     digitsPromptOne

digitsPromptTwo: equ      21
inbufPromptTwo:  resb     digitsPromptTwo

SECTION .text

global  _start

_start:  ; This is like the main
        ; Ask for the first user string
        push    ebx
        push    ecx                 ; TODO: Need to fix overwriting values
        call    readNumber
        pop     ecx
        pop     ebx
        mov     ebx, eax    ; ebx is a = readNumber();
        nop
        push    ebx
        push    ecx
        call    readNumber
        pop     ecx
        pop     ebx
        mov     ecx, eax    ; ecx is b = readNumber();

        nop
        jmp     fin




readNumber:
        PUSH 	ebp ; Do this every time we make a new function
        MOV		ebp, esp            ; Make stack pointer = to the base pointer
        mov     eax, 4              ; call the janitor to write
		mov     ebx, 1              ; to standard output
		mov     ecx, promptOne      ; the prompt string
		mov     edx, promptOneLength ; length of prompt
		int     80H                   ; syscall

		mov     eax, 3              ; call the janitor to read
		mov     ebx, 0              ; to standard input
		mov     ecx, inbufPromptOne ; into the input buffer (This is where the string is stored)
		mov     edx, digitsPromptOne
		int     80H                 ; syscall
		mov     ecx, inbufPromptOne ; into the input buffer (This is where the string is stored)
		push    ecx
		;call    printf

        call    getInt              ; call the other func get Int
        add     esp, 4
        mov     esp , ebp   ; restore caller;s stack pointer
        pop     ebp ; restore original ebp



        ret


; +4 for each argument




getInt:
	    PUSH 	ebp ; Do this every time we make a new function
	    MOV		ebp, esp            ; Make stack pointer = to the base pointer


	    push    esi

        mov     esi,[ebp+8] ; This is the string I hope
        nop
        ;push    ecx
        ;call    printf
        ;add     esp, 4



       ; mov     edx, ecx ; char* digit = string;

        mov     ecx, 1  ; unsigned int digitValue = 1; ;
        mov     ebx, 0  ; unsigned int result = 0;
        push    ebx     ; 0
        mov     edx, esi ; char* digit = string;
        mov     ebx, esi ; this one too

    ; do func stuff

while:
        lodsb
        cmp     AL, 10
        jz      lastDigit
        jmp     while


lastDigit:
        pop     ebx           ; unload result for updating
        dec     esi  ; This should be the last digit
        dec     esi
        lodsb

        jmp     while2


while2:
     ;   cmp     AL, byte[ebx]  ; while (digit >= string)
      ;  jnge    break

        cmp     AL, 0   ; if (*digit == ' ') was 32
        je      break

        cmp     AL, 48 ; if (*digit < '0')
        jl      badNumber
        cmp     AL, 57 ; if (*digit > '9')
        jg      badNumber



        ;// use the MUL (dword) instruction here (unsigned multiply)
        ;// be careful to understand its operands and results

       sub      AL, 48  ; (*digit - '0')
       ;push     edx     ; digit is in ground
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        movzx      eax, AL       ; TODO: when you MUL, it only takes one arg and the second arg and stored in AL for 8 bit and different ones for each size each staring with AX ; eax = (*digit - '0')
                                ; digit value

        mul        ecx           ; (*digit - '0') * digitValue


        mov        ebx, eax     ; this is result




        mov        eax, 10      ; digitValue *= 10

        mul        ecx

        mov        ecx, eax     ; Move the digitValue to the original place


        dec         esi  ; Dec twice to move back a char as lodsb defaults to taking one char out no matter what
        dec         esi
        lodsb     ; dec the pointer to $al char cursor

        jmp        while2




break:
; We get out of the while loop here
; TODO: put stuff here
        ; clean up clean up
        mov     esp , ebp   ; restore caller;s stack pointer
        pop     ebp ; restore original ebp
        nop
        mov     eax, ebx    ; this is restore i hope

        ret




fin:
        mov     eax, 1				; set up process exit
        mov     ebx, 0				; and
        int	    80H				    ; terminate




; Helper functions
badNumber:
        mov     eax, 4              ; call the janitor to write
		mov     ebx, 1              ; to standard output
		mov     ecx, errorMessage     ; the prompt string
		mov     edx, errorMessageLength ; length of prompt
		int     80H                 ; syscall
		mov     eax, 4
		mov     ebx, 1
		mov     ecx, newLine
		mov     edx, newLineLength
		int     80H                 ; syscall
		jmp     fin


