; #########################################################################
;
;   trig.asm - Assembly file for CompEng205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)


	;; If you need to, you can place global variables here
	
.CODE


;; helper function
SINTR Proc USES ebx edx angle:FXPT
	xor eax, eax
	xor edx, edx
	mov eax, angle
	mov ebx, PI_INC_RECIP
	mul ebx
	mov cx, WORD PTR [SINTAB + edx*2]
	movzx eax, cx

	ret
SINTR ENDP

;;adjust angle that is past pi
ADJANGLE PROC USES ecx angle:FXPT
		mov ecx, angle
		jmp Eval
	Whilebody:
		sub ecx, TWO_PI
	Eval:
		cmp ecx, TWO_PI
		jge Whilebody
		mov eax, ecx
	ret
ADJANGLE ENDP

FixedSin PROC USES edx ebx ecx angle:FXPT
		LOCAL tempang:DWORD, res: DWORD, quad: DWORD, s: DWORD
		mov edx, angle
		mov s, 0
		cmp edx, 0
		jge Posit
		mov s, 1
		xor ecx, ecx
		sub ecx, edx
		mov edx, ecx
	Posit:
		mov tempang, edx
		xor edx, edx
		mov ebx, tempang
		mov quad, 1
	Past2Pi:
		cmp ebx, TWO_PI
		jl Onequad
		invoke ADJANGLE, tempang
		mov ebx, eax
	Onequad:
		cmp ebx, PI_HALF
		jg Secquad
		mov tempang, ebx
		invoke SINTR, tempang
		
		cmp quad, 2
		jne allchecks
		neg eax
		jmp allchecks
	Secquad:
		cmp ebx, PI
		jge past2quad;
		mov ecx, PI
		sub ecx, ebx
		mov tempang, ecx
		invoke SINTR, tempang

		cmp quad, 2
		jne allchecks
		neg eax
		jmp allchecks
	past2quad:
		mov quad, 2
		sub ebx, PI
		jmp Onequad

		allchecks:
			cmp s, 1
			jne Done
			neg eax
		Done:

	ret			; Don't delete this line!!!
FixedSin ENDP 
	
FixedCos PROC angle:FXPT
	LOCAL tval: DWORD
	mov ebx, angle
	cmp ebx, 0
	jge pos
	xor ecx, ecx
	sub ecx, ebx
	mov ebx, ecx
pos:
	add ebx, PI_HALF
	mov tval, ebx
	invoke FixedSin, tval

	ret			; Don't delete this line!!!	
FixedCos ENDP	
END
