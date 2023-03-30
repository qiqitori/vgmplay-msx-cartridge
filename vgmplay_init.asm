    org 8000H
    db "AB"
    dw entry_point
    db 00,00,00,00,00,00

entry_point:
    ld a,01010000b ; set pages 0: rom 1: rom 2: cart 3: cart
    out (0a8h),a

copy_c000_f000:
    ld hl,0c000h ; start at c000
copy_c000_f000_loop:
    ld a,(hl) ; read from ROM address (hl)
    ld d,a
    in a,(0a8h)
    ld b,a ; store original value
    ld a,000010000b ; set pages 0: rom, 1: rom, 2: cart, 3: ram
    out (0a8h),a ; set port
    ld (hl),d ; store value read from ROM address (hl) to RAM address (also hl of course)
    ld a,b ; load a with original value
    out (0a8h),a ; set port back
    inc hl
    ld a,h
    cp 0f0h
    jp z,copy_8000_bfff ; done with this copy
    jp copy_c000_f000_loop

done_copying:
    ld a,000000000b ; set pages 0: rom, 1: rom, 2: ram, 3: ram
    out (0a8h),a
    jp vgm_init

    include "vgmplay.asm"

    ds 0f000h-$ ; creates 0s until we are at position f000
    org 0f000h

    ; copy 8000-bfff
copy_8000_bfff:
    ld hl,08000h ; start at 8000
copy_8000_bfff_loop:
    ld a,(hl) ; read from ROM address (hl)
    ld d,a
    in a,(0a8h)
    ld b,a ; store original value
    ld a,001000000b ; set pages 0: rom, 1: rom, 2: ram, 3: cart
    out (0a8h),a ; set port
    ld (hl),d ; store value read from ROM address (hl) to RAM address (also hl of course)
    ld a,b ; load a with original value
    out (0a8h),a ; set port back
    inc hl
    ld a,h
    cp 0c0h
    jp z,done_copying ; done with this copy
    jp copy_8000_bfff_loop
