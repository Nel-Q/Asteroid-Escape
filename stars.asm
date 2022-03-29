; #########################################################################
;
;   stars.asm - Assembly file for CompEng205 Assignment 1
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc

	;; Place your code here
	invoke DrawStar, 150, 200
	invoke DrawStar, 10, 45
	invoke DrawStar, 630,475
	invoke DrawStar, 40, 85
	invoke DrawStar, 250,300
	invoke DrawStar, 350,400
	invoke DrawStar, 100,150
	invoke DrawStar, 600,100
	invoke DrawStar, 500, 50
	invoke DrawStar, 639,479
	invoke DrawStar, 0,0
	invoke DrawStar, 433, 245
	invoke DrawStar, 63, 450
	invoke DrawStar, 112,34
	invoke DrawStar, 98,387
	invoke DrawStar, 26,478
	invoke DrawStar, 54, 357
	invoke DrawStar, 456, 424

	ret  			; Careful! Don't remove this line
DrawStarField endp



END
