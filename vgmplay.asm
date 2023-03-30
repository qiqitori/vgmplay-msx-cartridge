ALIGN: MACRO ?boundary
       ds ?boundary - 1 - ($ + ?boundary - 1) % ?boundary
       ENDM

vgm_init:
    ; Init Scanner
    call Player_InitCommandsJumpTable
    ld de,Player_commandsJumpTable
    ld a,d
    ld (Scanner.jumpTable),a
    ld de,Player_Update
    ld a,d
    ld (VBlankTimer.Update.callback+1),a
    ld a,e
    ld (VBlankTimer.Update.callback),a

    ld de,0
    call Player_Play

Reader_Read_IY:
    ld a,(vgm_data)
current_offset: equ $ - 2
    ld hl,(current_offset) ; kinda slow no? :p we could probably use iy
    inc hl
    ld (current_offset),hl
    ret

Reader_ReadWord_IY:
    push hl ; slow
    call Reader_Read_IY
    ld e,a
    call Reader_Read_IY
    ld d,a
    pop hl ; slow
    ret

; ix = this
Player_Play: PROC
    call VBlankTimer_Start ; Timer_Start
Loop:
    call VBlankTimer.Update
    jr Loop
    ret
    ENDP

; de = time passed
; ix = this
Player_Update:
        ld hl,0
time: equ $ - 2
        and a
        sbc hl,de
        exx
        ld ix,Scanner.Process
        call c,Scanner.Process
        exx
        ld (time),hl
        ret

Scanner: PROC
    ; ix = this
    ; iy = reader
    Process:
        push ix  ; return to Process
        call Reader_Read_IY ; get byte
        ld l,a ; put it in a
        ld h,0 ; first byte of jumptable address, hl == jumptable entry
    jumpTable: equ $ - 1
        ld a,(hl)
        inc h
        ld h,(hl)
        ld l,a
        jp hl
    ENDP

Scanner_Yield_M: MACRO
    pop af  ; break out of Process
    ret
    ENDM


; dehl = size
; ix = this
; iy = reader
Player_SkipDataBlock: equ MappedReader_Skip_IY
;    jp MappedReader_Skip_IY

; hl' = time remaining
; ix = this
; iy = reader
Player_EndOfSoundData: PROC
    push ix
    ; call Player_GetHeader ; TODO
    ; call Header_GetLoopOffset ; TODO
    pop ix
    jr z,NoLoop
;     call MappedReader_SetPosition_IY ; TODO
;     ld a,(ix + Player.loops) ; TODO
    and a
    ret z
;     dec (ix + Player.loops) ; TODO
    ret nz
NoLoop:
;     ld (ix + Player.ended),-1 ; TODO
    Scanner_Yield_M
    ENDP

; hl' = time remaining
; ix = this
; iy = reader
Player_Wait_M: MACRO ?time
    exx
    ld de,?time
    add hl,de
    exx
    ret nc
    Scanner_Yield_M ; TODO
    ENDM

; hl' = time remaining
; ix = this
; iy = reader
Player_Wait1Samples:
    Player_Wait_M 1
Player_Wait2Samples:
    Player_Wait_M 2
Player_Wait3Samples:
    Player_Wait_M 3
Player_Wait4Samples:
    Player_Wait_M 4
Player_Wait5Samples:
    Player_Wait_M 5
Player_Wait6Samples:
    Player_Wait_M 6
Player_Wait7Samples:
    Player_Wait_M 7
Player_Wait8Samples:
    Player_Wait_M 8
Player_Wait9Samples:
    Player_Wait_M 9
Player_Wait10Samples:
    Player_Wait_M 10
Player_Wait11Samples:
    Player_Wait_M 11
Player_Wait12Samples:
    Player_Wait_M 12
Player_Wait13Samples:
    Player_Wait_M 13
Player_Wait14Samples:
    Player_Wait_M 14
Player_Wait15Samples:
    Player_Wait_M 15
Player_Wait16Samples:
    Player_Wait_M 16
Player_Wait735Samples:
    Player_Wait_M 735
Player_Wait882Samples:
    Player_Wait_M 882
Player_WaitNSamples:
    exx
    call Reader_ReadWord_IY
    add hl,de
    exx
    ret nc
    Scanner_Yield_M

; hl' = time remaining
; ix = this
; iy = reader
Player_Skip12:
    call Reader_Read_IY
Player_Skip11:
    call Reader_Read_IY
    call Reader_Read_IY
    call Reader_Read_IY
    call Reader_Read_IY
    call Reader_Read_IY
Player_Skip6:
    call Reader_Read_IY
Player_Skip5:
    call Reader_Read_IY
Player_Skip4:
    call Reader_Read_IY
Player_Skip3:
    call Reader_Read_IY
    jp Reader_Read_IY
Player_Skip2: equ Reader_Read_IY
;    jp Reader_Read_IY
Player_Skip1: equ Player_UnsupportedCommand
;    ret

YM2151_ProcessCommand:
    call Reader_ReadWord_IY
    jp SFG.SafeWriteRegister

; ix = this
Player_UnsupportedCommand:
    jp 0 ; restart
    ; TODO: display message?
;     ld hl,Player_unsupportedCommandError
;     call System_ThrowExceptionWithMessage

;

FastLDIR: PROC
    xor a
    sub c
    and 16-1
    add a,a
    di
    ld (jumpOffset),a
    ei
    jr nz,$
jumpOffset: equ $ - 1
Loop:
    REPT 16
    ldi
    ENDM
    jp pe,Loop
    ret
    ENDP


Player_InitCommandsJumpTable: PROC
	ld bc,256
	ld hl,Player_commandsJumpTable + 1
	ld de,READBUFFER  ; scratch
MSBExtractionLoop:
	ldi
	inc hl
	jp pe,MSBExtractionLoop
	ld bc,255
	ld hl,Player_commandsJumpTable + 2
	ld de,Player_commandsJumpTable + 1
LSBExtractionLoop:
	ldi
	inc hl
	jp pe,LSBExtractionLoop
	ld bc,256
	ld hl,READBUFFER  ; scratch
	ld de,Player_commandsJumpTable + 256
	jp FastLDIR
	ENDP

READBUFFER:
    ds 256


    ALIGN 100H
Player_commandsJumpTable:
    dw Player_Skip1               ; 00H
    dw Player_Skip1               ; 01H
    dw Player_Skip1               ; 02H
    dw Player_Skip1               ; 03H
    dw Player_Skip1               ; 04H
    dw Player_Skip1               ; 05H
    dw Player_Skip1               ; 06H
    dw Player_Skip1               ; 07H
    dw Player_Skip1               ; 08H
    dw Player_Skip1               ; 09H
    dw Player_Skip1               ; 0AH
    dw Player_Skip1               ; 0BH
    dw Player_Skip1               ; 0CH
    dw Player_Skip1               ; 0DH
    dw Player_Skip1               ; 0EH
    dw Player_Skip1               ; 0FH
    dw Player_Skip1               ; 10H
    dw Player_Skip1               ; 11H
    dw Player_Skip1               ; 12H
    dw Player_Skip1               ; 13H
    dw Player_Skip1               ; 14H
    dw Player_Skip1               ; 15H
    dw Player_Skip1               ; 16H
    dw Player_Skip1               ; 17H
    dw Player_Skip1               ; 18H
    dw Player_Skip1               ; 19H
    dw Player_Skip1               ; 1AH
    dw Player_Skip1               ; 1BH
    dw Player_Skip1               ; 1CH
    dw Player_Skip1               ; 1DH
    dw Player_Skip1               ; 1EH
    dw Player_Skip1               ; 1FH
    dw Player_Skip1               ; 20H
    dw Player_Skip1               ; 21H
    dw Player_Skip1               ; 22H
    dw Player_Skip1               ; 23H
    dw Player_Skip1               ; 24H
    dw Player_Skip1               ; 25H
    dw Player_Skip1               ; 26H
    dw Player_Skip1               ; 27H
    dw Player_Skip1               ; 28H
    dw Player_Skip1               ; 29H
    dw Player_Skip1               ; 2AH
    dw Player_Skip1               ; 2BH
    dw Player_Skip1               ; 2CH
    dw Player_Skip1               ; 2DH
    dw Player_Skip1               ; 2EH
    dw Player_Skip1               ; 2FH
    dw Player_Skip2               ; 30H ; TODO: Skip1 or Skip2?
;     dw SN76489_instance.ProcessCommandDual        ; 30H
    dw Player_Skip2               ; 31H
    dw Player_Skip2               ; 32H
    dw Player_Skip2               ; 33H
    dw Player_Skip2               ; 34H
    dw Player_Skip2               ; 35H
    dw Player_Skip2               ; 36H
    dw Player_Skip2               ; 37H
    dw Player_Skip2               ; 38H
    dw Player_Skip2               ; 39H
    dw Player_Skip2               ; 3AH
    dw Player_Skip2               ; 3BH
    dw Player_Skip2               ; 3CH
    dw Player_Skip2               ; 3DH
    dw Player_Skip2               ; 3EH
    dw Player_Skip2               ; 3FH
    dw Player_Skip3               ; 40H
    dw Player_Skip3               ; 41H
    dw Player_Skip3               ; 42H
    dw Player_Skip3               ; 43H
    dw Player_Skip3               ; 44H
    dw Player_Skip3               ; 45H
    dw Player_Skip3               ; 46H
    dw Player_Skip3               ; 47H
    dw Player_Skip3               ; 48H
    dw Player_Skip3               ; 49H
    dw Player_Skip3               ; 4AH
    dw Player_Skip3               ; 4BH
    dw Player_Skip3               ; 4CH
    dw Player_Skip3               ; 4DH
    dw Player_Skip3               ; 4EH
    dw Player_Skip2               ; 4FH
;     dw SN76489_instance.ProcessCommand            ; 50H
;     dw YM2413_instance.ProcessCommand             ; 51H
;     dw YM2612_instance.ProcessPort0Command        ; 52H
;     dw YM2612_instance.ProcessPort1Command        ; 53H
    dw Player_Skip2               ; 50H
    dw Player_Skip3               ; 51H
    dw Player_Skip3               ; 52H
    dw Player_Skip3               ; 53H
    dw YM2151_ProcessCommand      ; 54H
;     dw YM2203_instance.ProcessCommand             ; 55H
;     dw YM2608_instance.ProcessPort0Command        ; 56H
;     dw YM2608_instance.ProcessPort1Command        ; 57H
;     dw YM2610_instance.ProcessPort0Command        ; 58H
;     dw YM2610_instance.ProcessPort1Command        ; 59H
;     dw YM3812_instance.ProcessCommand             ; 5AH
;     dw YM3526_instance.ProcessCommand             ; 5BH
;     dw Y8950_instance.ProcessCommand              ; 5CH
    dw Player_Skip3               ; 55H
    dw Player_Skip3               ; 56H
    dw Player_Skip3               ; 57H
    dw Player_Skip3               ; 58H
    dw Player_Skip3               ; 59H
    dw Player_Skip3               ; 5AH
    dw Player_Skip3               ; 5BH
    dw Player_Skip3               ; 5CH
    dw Player_Skip3               ; 5DH
;     dw YMF262_instance.ProcessPort0Command        ; 5EH
;     dw YMF262_instance.ProcessPort1Command        ; 5FH
    dw Player_Skip3               ; 5EH
    dw Player_Skip3               ; 5FH
    dw Player_UnsupportedCommand  ; 60H
    dw Player_WaitNSamples        ; 61H
    dw Player_Wait735Samples      ; 62H
    dw Player_Wait882Samples      ; 63H
    dw Player_UnsupportedCommand  ; 64H
    dw Player_UnsupportedCommand  ; 65H
;     dw Player_EndOfSoundData      ; 66H ; TODO ?
;     dw Player_ProcessDataBlock    ; 67H
    dw Player_UnsupportedCommand  ; 66H
    dw Player_UnsupportedCommand  ; 67H
    dw Player_Skip12              ; 68H
    dw Player_UnsupportedCommand  ; 69H
    dw Player_UnsupportedCommand  ; 6AH
    dw Player_UnsupportedCommand  ; 6BH
    dw Player_UnsupportedCommand  ; 6CH
    dw Player_UnsupportedCommand  ; 6DH
    dw Player_UnsupportedCommand  ; 6EH
    dw Player_UnsupportedCommand  ; 6FH
    dw Player_Wait1Samples        ; 70H
    dw Player_Wait2Samples        ; 71H
    dw Player_Wait3Samples        ; 72H
    dw Player_Wait4Samples        ; 73H
    dw Player_Wait5Samples        ; 74H
    dw Player_Wait6Samples        ; 75H
    dw Player_Wait7Samples        ; 76H
    dw Player_Wait8Samples        ; 77H
    dw Player_Wait9Samples        ; 78H
    dw Player_Wait10Samples       ; 79H
    dw Player_Wait11Samples       ; 7AH
    dw Player_Wait12Samples       ; 7BH
    dw Player_Wait13Samples       ; 7CH
    dw Player_Wait14Samples       ; 7DH
    dw Player_Wait15Samples       ; 7EH
    dw Player_Wait16Samples       ; 7FH
    dw Player_Skip1               ; 80H
    dw Player_Wait1Samples        ; 81H
    dw Player_Wait2Samples        ; 82H
    dw Player_Wait3Samples        ; 83H
    dw Player_Wait4Samples        ; 84H
    dw Player_Wait5Samples        ; 85H
    dw Player_Wait6Samples        ; 86H
    dw Player_Wait7Samples        ; 87H
    dw Player_Wait8Samples        ; 88H
    dw Player_Wait9Samples        ; 89H
    dw Player_Wait10Samples       ; 8AH
    dw Player_Wait11Samples       ; 8BH
    dw Player_Wait12Samples       ; 8CH
    dw Player_Wait13Samples       ; 8DH
    dw Player_Wait14Samples       ; 8EH
    dw Player_Wait15Samples       ; 8FH
    dw Player_Skip5               ; 90H
    dw Player_Skip5               ; 91H
    dw Player_Skip6               ; 92H
    dw Player_Skip11              ; 93H
    dw Player_Skip2               ; 94H
    dw Player_Skip5               ; 95H
    dw Player_UnsupportedCommand  ; 96H
    dw Player_UnsupportedCommand  ; 97H
    dw Player_UnsupportedCommand  ; 98H
    dw Player_UnsupportedCommand  ; 99H
    dw Player_UnsupportedCommand  ; 9AH
    dw Player_UnsupportedCommand  ; 9BH
    dw Player_UnsupportedCommand  ; 9CH
    dw Player_UnsupportedCommand  ; 9DH
    dw Player_UnsupportedCommand  ; 9EH
    dw Player_UnsupportedCommand  ; 9FH
;     dw AY8910_instance.ProcessCommand             ; A0H
    dw Player_Skip3               ; A0H
    dw Player_Skip3               ; A1H
;     dw YM2612_instance.ProcessPort0CommandDual    ; A2H
;     dw YM2612_instance.ProcessPort1CommandDual    ; A3H
    dw Player_Skip3               ; A2H
    dw Player_Skip3               ; A3H
;     dw YM2151_instance.ProcessCommandDual         ; A4H
;     dw YM2203_instance.ProcessCommandDual         ; A5H
    dw Player_Skip3               ; A4H
    dw Player_Skip3               ; A5H
    dw Player_Skip3               ; A6H
    dw Player_Skip3               ; A7H
    dw Player_Skip3               ; A8H
    dw Player_Skip3               ; A9H
;     dw YM3812_instance.ProcessCommandDual         ; AAH
;     dw YM3526_instance.ProcessCommandDual         ; ABH
;     dw Y8950_instance.ProcessCommandDual          ; ACH
    dw Player_Skip3               ; AAH
    dw Player_Skip3               ; ABH
    dw Player_Skip3               ; ACH
    dw Player_Skip3               ; ADH
;     dw YMF262_instance.ProcessPort0CommandDual    ; AEH
;     dw YMF262_instance.ProcessPort1CommandDual    ; AFH
    dw Player_Skip3               ; AEH
    dw Player_Skip3               ; AFH
    dw Player_Skip3               ; B0H
    dw Player_Skip3               ; B1H
    dw Player_Skip3               ; B2H
    dw Player_Skip3               ; B3H
    dw Player_Skip3               ; B4H
    dw Player_Skip3               ; B5H
    dw Player_Skip3               ; B6H
    dw Player_Skip3               ; B7H
    dw Player_Skip3               ; B8H
    dw Player_Skip3               ; B9H
    dw Player_Skip3               ; BAH
    dw Player_Skip3               ; BBH
    dw Player_Skip3               ; BCH
    dw Player_Skip3               ; BDH
    dw Player_Skip3               ; BEH
    dw Player_Skip3               ; BFH
    dw Player_Skip4               ; C0H
    dw Player_Skip4               ; C1H
    dw Player_Skip4               ; C2H
    dw Player_Skip4               ; C3H
    dw Player_Skip4               ; C4H
    dw Player_Skip4               ; C5H
    dw Player_Skip4               ; C6H
    dw Player_Skip4               ; C7H
    dw Player_Skip4               ; C8H
    dw Player_Skip4               ; C9H
    dw Player_Skip4               ; CAH
    dw Player_Skip4               ; CBH
    dw Player_Skip4               ; CCH
    dw Player_Skip4               ; CDH
    dw Player_Skip4               ; CEH
    dw Player_Skip4               ; CFH
    dw Player_Skip4               ; D0H
;     dw YMF278B_instance.ProcessCommand            ; D0H
    dw Player_Skip4               ; D1H
;     dw K051649_instance.ProcessCommand            ; D2H
    dw Player_Skip4              ; D2H
    dw Player_Skip4               ; D3H
    dw Player_Skip4               ; D4H
    dw Player_Skip4               ; D5H
    dw Player_Skip4               ; D6H
    dw Player_Skip4               ; D7H
    dw Player_Skip4               ; D8H
    dw Player_Skip4               ; D9H
    dw Player_Skip4               ; DAH
    dw Player_Skip4               ; DBH
    dw Player_Skip4               ; DCH
    dw Player_Skip4               ; DDH
    dw Player_Skip4               ; DEH
    dw Player_Skip4               ; DFH
;     dw YM2612_instance.ProcessPCMDataSeek         ; E0H
    dw Player_UnsupportedCommand  ; E0H
    dw Player_Skip5               ; E1H
    dw Player_Skip5               ; E2H
    dw Player_Skip5               ; E3H
    dw Player_Skip5               ; E4H
    dw Player_Skip5               ; E5H
    dw Player_Skip5               ; E6H
    dw Player_Skip5               ; E7H
    dw Player_Skip5               ; E8H
    dw Player_Skip5               ; E9H
    dw Player_Skip5               ; EAH
    dw Player_Skip5               ; EBH
    dw Player_Skip5               ; ECH
    dw Player_Skip5               ; EDH
    dw Player_Skip5               ; EEH
    dw Player_Skip5               ; EFH
    dw Player_Skip5               ; F0H
    dw Player_Skip5               ; F1H
    dw Player_Skip5               ; F2H
    dw Player_Skip5               ; F3H
    dw Player_Skip5               ; F4H
    dw Player_Skip5               ; F5H
    dw Player_Skip5               ; F6H
    dw Player_Skip5               ; F7H
    dw Player_Skip5               ; F8H
    dw Player_Skip5               ; F9H
    dw Player_Skip5               ; FAH
    dw Player_Skip5               ; FBH
    dw Player_Skip5               ; FCH
    dw Player_Skip5               ; FDH
    dw Player_Skip5               ; FEH
    dw Player_Skip5               ; FFH

    ds 256 ; leave space for "unpacked" jump table

    include "SFG.asm"

    include "VBlankTimer.asm"

vgm_data:
    include "vgm_data.asm" ; actual music data (converted from VGM file to list of "db"s)
