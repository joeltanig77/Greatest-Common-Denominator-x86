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
        call    readNumber





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

        mov     ecx,[ebp+8] ; This is the string I hope
        ;push    ecx
        ;call    printf
        ;add     esp, 4



        mov     DH, 1  ; unsigned int digitValue = 1; ; TODO: start here
        mov     DL, 0  ; unsigned int result = 0;
        mov     eax, ecx ; char* digit = string;


    ; do func stuff

while:
        cmp     byte[ecx], 10
        je      lastDigit
        inc     ecx
        jmp     while


lastDigit:
        dec     ecx ; This should be the last digit
        jmp     while2


while2:
        cmp     ecx, eax  ; while (digit >= string)
        jnge    break

        cmp     byte[ecx], 32   ; if (*digit == ' ')
        je      break

        cmp     byte[ecx], 48 ; if (*digit < '0')
        jl      badNumber
        cmp     byte[ecx], 57 ; if (*digit > '9')
        jg      badNumber



        ;// use the MUL (dword) instruction here (unsigned multiply)
        ;// be careful to understand its operands and results
      ; mov      AL, byte[ecx]
      ; sub      AL, 48  ; (*digit - '0')
      ; push     ecx

      ; movzx      eax, AL        ; TODO: when you MUL, it only takes one arg and the second arg and stored in AL for 8 bit and different ones for each size each staring with AX (result)

      ; movzx      ecx, DH       ; digitvalue

      ; mul        ecx           ; (*digit - '0') * digitValue

       ;mov        AL, byte[eax]       ; This is result i think       ; TODO: Something is wrong here

       ;mov        AH, 10

       ;mul        DH                  ; digitValue *= 10;

      ; pop        ecx
       dec        ecx                  ; digit--;

       jmp        while2

      ; mov      AX, DL
       ;MUL      byte[DL], byte[DX]        ; (*digit - '0') * digitValue
       ;add      byte[DL], AX            ; This is result i think
       ;mov      AX, 10
       ;mul      DX                  ; digitValue *= 10;

       ;dec     ecx                      ; digit--;
       ;jmp     while2

break:
; We get out of the while loop here
; TODO: put stuff here

        ; clean up clean up
        mov     esp , ebp   ; restore caller;s stack pointer
        pop     ebp ; restore original ebp



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


