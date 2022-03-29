; #########################################################################
;
;   lines.asm - Assembly file for CompEng205 Assignment 2
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here
	
.CODE
	

;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved
	
;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
DrawLine PROC USES eax ebx ecx esi edi edx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD
	
	;; Place your code here
	LOCAL delta_x:DWORD, delta_y:DWORD, inc_x: DWORD, inc_y: DWORD, error: DWORD, curr_x:DWORD, curr_y: DWORD,prev_error:DWORD
	
	mov eax, x1
	sub eax, x0
	mov delta_x, eax
	cmp delta_x, 0
	jl ABSX
	jmp CONTINUE
ABSX:
	neg delta_x

CONTINUE:
	mov ebx, y1
	sub ebx, y0
	mov delta_y, ebx
	cmp delta_y, 0
	jl ABSY
	jmp CONTINUE1
ABSY:
	neg delta_y

CONTINUE1:
	
	mov ecx, x0
	cmp ecx, x1
	jnl INCX
	mov inc_x, 1
	jmp CONTINUE2
INCX:
	mov inc_x, -1
CONTINUE2:
	mov esi, y0
	cmp esi, y1
	jnl INCY
	mov inc_y, 1
	jmp CONTINUE3
INCY:
	mov inc_y, -1
CONTINUE3:
	
	mov eax, delta_x
	mov edi, 2
	mov edx, 0
	cmp eax, delta_y
	jng error_label
	idiv edi
	mov error, eax
	jmp CONTINUE4
error_label:
	mov edx, 0
	mov eax, delta_y
	mov edi,2
	idiv edi
	neg eax
	mov error, eax
CONTINUE4:
	mov ebx, x0
	mov curr_x, ebx
	mov edi, y0
	mov curr_y, edi

	invoke DrawPixel, curr_x, curr_y, color

	
	jmp eval


body:
	invoke DrawPixel, curr_x, curr_y, color
	



	mov ecx, error
	mov prev_error, ecx

	mov esi, delta_x
	neg esi
	mov ecx, prev_error
	cmp ecx, esi
	jng if_body
	mov edx, error
	sub edx, delta_y
	mov error, edx
	mov ebx, curr_x
	add ebx, inc_x
	mov curr_x, ebx
if_body:
	mov ecx, prev_error
	cmp ecx, delta_y
	jnl eval
	mov edx, error
	add edx, delta_x
	mov error, edx
	mov edi, curr_y
	add edi, inc_y
	mov curr_y, edi
eval:
	
	mov ebx, curr_x
	mov edi, curr_y
	cmp ebx, x1
	jne body
	cmp edi, y1
	jne body
	
after_body:
	

	ret        	;;  Don't delete this line...you need it
DrawLine ENDP




END
