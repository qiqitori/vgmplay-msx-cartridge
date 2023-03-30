    org 4000H
    db "AB"
    dw entry_point
    db 00,00,00,00,00,00

entry_point:
    ld a,01010100b ; set rom - cart - cart - cart
    out (0a8h),a

    ; copy 8000-bfff
    copy_8000_bfff:
    ld hl,08000h ; start at 8000
copy_8000_bfff_loop:
    ld a,(hl) ; read from ROM address (hl)
    ld d,a
    in a,(0a8h)
    ld b,a ; store original value
    or 000110000b ; set bits 5-4 to 11 (RAM) (actual value depends on machine)
    out (0a8h),a ; set port
    ld (hl),d ; store value read from ROM address (hl) to RAM address (also hl of course)
    ld a,b ; load a with original value
    out (0a8h),a ; set port back
    inc hl
    ld a,h
    cp 0c0h
    jp z,copy_c000_f000 ; done with this copy
    jp copy_8000_bfff_loop
    
copy_c000_f000:
    ld hl,0c000h ; start at c000
copy_c000_f000_loop:
    ld a,(hl) ; read from ROM address (hl)
    ld d,a
    in a,(0a8h)
    ld b,a ; store original value
    or 011000000b ; set bits 5-4 to 11 (RAM) (actual value depends on machine)
    out (0a8h),a ; set port
    ld (hl),d ; store value read from ROM address (hl) to RAM address (also hl of course)
    ld a,b ; load a with original value
    out (0a8h),a ; set port back
    inc hl
    ld a,h
    cp 0f0h
    jp z,copy_4000_7fff ; done with this copy
    jp copy_c000_f000_loop

done_copying:
    ld a,011111100b ; switch to 4000-ffff to RAM
    out (0a8h),a
    jp vgm_init

    include "vgmplay.asm"

    ds 0f000h-$ ; creates 0s until we are at position f000 (b000 in the output file; our output file will be loaded at offset 4000, so the code at b000 will be at b000+4000 = f000 on the MSX)
    org 0f000h

copy_4000_7fff:
    ld hl,04000h ; start at c000
copy_4000_7fff_loop:
    ld a,(hl) ; read from ROM address (hl)
    ld d,a
    in a,(0a8h)
    ld b,a ; store original value
    or 000001100b ; set bits 5-4 to 11 (RAM) (actual value depends on machine)
    out (0a8h),a ; set port
    ld (hl),d ; store value read from ROM address (hl) to RAM address (also hl of course)
    ld a,b ; load a with original value
    out (0a8h),a ; set port back
    inc hl
    ld a,h
    cp 080h
    jp z,done_copying ; done with this copy
    jp copy_4000_7fff_loop
