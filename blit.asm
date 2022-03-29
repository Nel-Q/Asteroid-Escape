; #########################################################################
;
;   blit.asm - Assembly file for CompEng205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc


.DATA

	;; If you need to, you can place global variables here
	
.CODE

DrawPixel PROC USES eax ebx ecx x:DWORD, y:DWORD, color:DWORD
	mov ebx, x
	mov ecx, y

	cmp ebx, 639
	jg Done
	cmp ebx, 0
	jl Done

	cmp ecx, 479
	jg Done
	cmp ecx, 0
	jl Done

	imul ecx, 640
	add ecx, ebx
	mov eax, color

	mov ebx, [ScreenBitsPtr]
	mov Byte PTR [ebx + ecx], al

Done:

	ret 			; Don't delete this line!!!
DrawPixel ENDP

BasicBlit PROC USES edi edx ebx ecx esi eax ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
		LOCAL orginx: DWORD, startx: DWORD, starty: DWORD, colorpoint: DWORD, yoffset: DWORD, bitmapwidth: DWORD, bitmapheight: DWORD
		
		mov edi, xcenter
		mov startx, edi
		mov edi, ycenter
		mov starty, edi

		mov edx, [ptrBitmap]
		mov ebx, (EECS205BITMAP PTR [edx]).dwWidth
		mov edi, (EECS205BITMAP PTR [edx]).dwHeight
		mov bitmapwidth, ebx
		mov bitmapheight, edi

		;; find the start of the map
		shr ebx, 1
		shr edi, 1

		sub startx, ebx
		mov ebx, startx
		mov orginx, ebx
		sub starty, edi
		xor edi, edi

		;;loop through the whole bitmap
		xor ecx, ecx
		xor ebx, ebx

		jmp EvalOut
	BodyOuter:
			xor ebx, ebx
			jmp EvalInner
		BodyInner:
			mov eax, ecx
			imul eax, bitmapwidth

			mov yoffset, eax
			add yoffset, ebx
			xor eax, eax
			mov edi, (EECS205BITMAP PTR [edx]).lpBytes
			mov esi, yoffset
			mov al, Byte PTR [edi + esi]
			movsx eax, al
			mov colorpoint, eax
			xor eax, eax
			mov al, (EECS205BITMAP PTR [edx]).bTransparent
			movsx eax, al
			cmp eax, colorpoint
			je Incr

			invoke DrawPixel, startx, starty, colorpoint

		Incr:
			inc ebx
			add startx, 1
		EvalInner:
			cmp ebx, bitmapwidth
			jl BodyInner

		mov ebx, orginx
		mov startx, ebx
		add starty, 1
		inc ecx
EvalOut:
	cmp ecx, bitmapheight
	jl BodyOuter

	ret 			; Don't delete this line!!!	
BasicBlit ENDP


RotateBlit PROC USES eax ebx ecx edi esi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
		LOCAL cosa: DWORD, sina: DWORD, shiftX: DWORD, shiftY: DWORD, dstWidth: DWORD, dstHeight: DWORD, srcX: DWORD, srcY: DWORD,
		colorpixel: DWORD, x: DWORD, y: DWORD

		invoke FixedCos, angle
		mov cosa, eax

		invoke FixedSin, angle
		mov sina, eax

		mov esi, [lpBmp]

		mov ebx, (EECS205BITMAP PTR [esi]).dwWidth
		shl ebx, 16
		;;find shiftX fixedpoint
		mov ecx, cosa
		sar ecx, 1

		mov eax,ebx
		imul ecx

		mov shiftX, edx
		mov edi, (EECS205BITMAP PTR [esi]).dwHeight
		shl edi, 16

		mov ecx, sina
		sar ecx, 1

		mov eax, edi
		imul ecx

		sub shiftX, edx
		mov eax, shiftX

		mov ebx, (EECS205BITMAP PTR [esi]).dwHeight
		shl ebx, 16

		mov ecx, cosa
		sar ecx, 1

		mov eax, ebx
		imul ecx

		mov shiftY, edx
		mov edi, (EECS205BITMAP PTR [esi]).dwWidth
		shl edi, 16
		mov ecx, sina
		sar ecx, 1
		mov eax, edi
		imul ecx

		add shiftY, edx
		mov eax, shiftY

		;;find dstWidth
		mov edi, (EECS205BITMAP PTR [esi]).dwWidth
		mov ebx, (EECS205BITMAP PTR [esi]).dwHeight
		add edi, ebx
		mov dstWidth, edi
		mov dstHeight, edi

		;;for loop
		xor ebx, ebx
		xor edi, edi
		mov ebx, dstWidth
		neg ebx
		jmp EvalOuterL
	BodyOuterL:
			;;inner loop
			mov edi, dstHeight
			neg edi
			jmp EvalInnerL
		BodyInnerL:
			;; src = dstX*cosa + dstY*sina
			mov eax, ebx
			sal eax, 16
			imul cosa
			mov srcX, edx
			;;find dstY*sina
			mov eax, edi
			sal eax, 16
			imul sina
			add srcX, edx
			mov eax, srcX

			;;get srcY
			;; find dstX*cosa
			mov eax, edi
			sal eax, 16
			imul cosa
			mov srcY, edx

			;;dstX*sina
			mov eax, ebx
			sal eax, 16
			imul sina
			sub srcY, edx
			mov eax, srcY

			;;if statement
			cmp srcX, 0
			jl Increment

			mov edx, (EECS205BITMAP PTR [esi]).dwWidth
			cmp srcX, edx
			jge Increment

			cmp srcY, 0
			jl Increment

			mov edx, (EECS205BITMAP PTR [esi]).dwHeight
			cmp srcY, edx
			jge Increment

			;;xcenter + dstX- shiftX
			mov edx, xcenter
			add edx,ebx
			sub edx, shiftX
			
			cmp edx, 0
			jl Increment

			cmp edx, 639
			jge Increment
			
			;;ycenter + dstY - shiftY
			mov edx, ycenter
			add edx, edi
			sub edx, shiftY

			cmp edx, 0
			jl Increment

			cmp edx, 479
			jge Increment

			;; transparency check
			mov ecx, srcY
			;;offset in the y dir
			imul ecx, (EECS205BITMAP PTR [esi]).dwWidth
			add ecx, srcX ;;x offset

			mov edx, (EECS205BITMAP PTR [esi]).lpBytes
			mov al, Byte PTR [edx + ecx]
			movsx eax, al
			mov colorpixel, eax

			xor eax, eax
			mov al, (EECS205BITMAP PTR [esi]).bTransparent ;; transparency value
			movsx eax, al
			cmp eax, colorpixel
			je Increment

			;; otherwise
			mov ecx, xcenter
			add ecx, ebx
			sub ecx, shiftX
			mov x, ecx

			mov ecx, ycenter
			add ecx, edi
			sub ecx, shiftY
			mov y, ecx

			invoke DrawPixel, x, y, colorpixel
		Increment:
			inc edi
		EvalInnerL:
			cmp edi, dstHeight
			jl BodyInnerL
	
	inc ebx
EvalOuterL:
	cmp ebx, dstWidth
	jl BodyOuterL

	ret 			; Don't delete this line!!!		
RotateBlit ENDP



END
