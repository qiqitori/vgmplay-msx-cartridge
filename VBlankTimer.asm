;
; VDP VBlank timer
;
; 50 / 60 Hz resolution
;
VBlankTimer_SAMPLES_60HZ: equ 735
VBlankTimer_SAMPLES_50HZ: equ 882

JIFFY: equ 0FC9Eh

VDP_MIRROR_8: equ 0FFE7H - 8
; f <- z: 60Hz, nz: 50Hz
; Modifies: af
VDP_Is60Hz:
	ld a,(VDP_MIRROR_8 + 9)
	and 00000010B
	ret

VBlankTimer: PROC
	lastJiffy:
		db 0

	; ix = this
	Update: PROC
		ld a,(VBlankTimer.lastJiffy)
		ld b,a
	Wait:
		ld a,(JIFFY)
		cp b
		jr z,Wait
		ld (VBlankTimer.lastJiffy),a
		sub b
		ld b,a
		ld hl,0
		ld de,VBlankTimer_SAMPLES_60HZ
	Loop:
		add hl,de
		djnz Loop
		ex de,hl
		jp 0 ; TODO: check if this works
	callback: equ $-2
		ENDP
	ENDP

; ix = this
VBlankTimer_Start: equ VBlankTimer_Reset
;	jp VBlankTimer_Reset

; ix = this
VBlankTimer_Stop: equ System_Return
;	ret

; ix = this
VBlankTimer_Reset:
	ld a,(JIFFY)
	ld (VBlankTimer.lastJiffy),a
	ret
