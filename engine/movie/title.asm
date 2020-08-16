TITLE_LOGO_TILE EQU $80
TITLE_COPYRIGHT_TILE EQU $0C
TITLE_BORDER_TILE EQU $1C
TITLE_LUGIA_TILE EQU $24

TitleScreen:
; Initialize variables
	xor a
	ld hl, wJumptableIndex
	ld [hli], a ; wJumptableIndex
	ld [hli], a ; wTitleScreenSelectedOption
	ld [hli], a ; wTitleScreenTimer
	ld [hl], a  ; wTitleScreenTimer + 1
	ldh [hTitleScreenLastPressed], a

; Prepare screen
	farcall ClearSpriteAnims
	call TitleScreenLoadGFX

	call ChannelsOff
	call SFXChannelsOff

; Temporarily replace color 3 of pokemon logo with red
	ld hl, TitleScreenPalettes palette 1 color 2
	ld de, wBGPals1 palette 0 color 2
	ld bc, PAL_COLOR_SIZE
	ld a, BANK(wBGPals1)
	call FarCopyWRAM

; Start actually drawing screen
	call TitleScreenFireballs
	ld a, 152
	ldh [hSCX], a
	xor a
	ldh [hSCY], a
	ld a, %00101010
	call DmgToCgbBGPals

; Play starting sound effect
	ld de, SFX_TITLE_SCREEN_ENTRANCE
	call PlaySFX

.loop
	farcall PlaySpriteAnimationsAndDelayFrame
	ld a, [wJumptableIndex]
	bit 7, a
	ret nz
	call TitleScreenScene
	jr .loop

TitleScreenScene:
	ld e, a
	ld d, 0
	ld hl, .scenes
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.scenes
	dw TitleScreenScrollin
	dw TitleScreenFlash
	dw TitleScreenBorder
	dw TitleScreenGameTitle
	dw TitleScreenCopyright
	dw TitleScreenLugia
	dw TitleScreenTimer
	dw TitleScreenMain
	dw TitleScreenEnd

TitleScreenScrollin:
	ldh a, [hSCX]
	add 2
	ldh [hSCX], a
	ret nc

	xor a
	ldh [hSCX], a

; Play the title screen music.
	ld de, MUSIC_TITLE
	call PlayMusic

	ld de, 20
	jp TitleScreenSetTimerNextScene

TitleScreenFlash:
	ld a, [wTitleScreenTimer]
	ld c, 3
	call SimpleDivide

	and a
	jr nz, .no_switch

	ld a, %00000000
	bit 0, b
	jr z, .switch
	ld a, %00101010
.switch
	call DmgToCgbBGPals

.no_switch
	call TitleScreenRunTimer
	ret nz

; Restore normal colors
	ld hl, TitleScreenPalettes palette 0 color 2
	ld de, wBGPals1 palette 0 color 2
	ld bc, PAL_COLOR_SIZE
	ld a, BANK(wBGPals1)
	call FarCopyWRAM
	ld a, %11100100
	call DmgToCgbBGPals

	ld de, 20
	jp TitleScreenSetTimerNextScene

TitleScreenBorder:
	call TitleScreenRunTimer
	ret nz

; Draw tm
	hlcoord 18, 6
	ld a, (TITLE_LOGO_TILE + 138) & $ff
	ld [hl], a

; Draw border
	hlcoord 0, 8
	ld a, TITLE_BORDER_TILE
	call DrawTitleBorder
	hlcoord 0, 16
	ld a, TITLE_BORDER_TILE + 4
	call DrawTitleBorder

	ld de, 20
	jp TitleScreenSetTimerNextScene

TitleScreenGameTitle:
	call TitleScreenRunTimer
	ret nz

; Draw game title
	hlcoord 6, 6
	lb bc, 1, 9
	lb de, TITLE_LOGO_TILE + 126, 9
	call DrawTitleGraphic

	ld de, 20
	jp TitleScreenSetTimerNextScene

TitleScreenCopyright:
	call TitleScreenRunTimer
	ret nz

; Draw copyright text
	hlcoord 3, 17
	lb bc, 1, 13
	lb de, TITLE_COPYRIGHT_TILE, 0
	call DrawTitleGraphic

	ld de, 20
	jp TitleScreenSetTimerNextScene

TitleScreenLugia:
	call TitleScreenRunTimer
	ret nz

; Draw Lugia
	hlcoord 7, 9
	lb bc, 7, 7
	lb de, TITLE_LUGIA_TILE, 7
	call DrawTitleGraphic

	ld hl, wJumptableIndex
	inc [hl]
	ret

TitleScreenTimer:
; Start a timer
	ld de, 82 * 60 + 30
	jp TitleScreenSetTimerNextScene

TitleScreenMain:
; Run the timer down.
	call TitleScreenRunTimer
	jr z, .end

	call GetJoypad
	ld hl, hJoyDown

; Change to musical notes and back with Left + B
	ld a, [hl]
	and D_LEFT + B_BUTTON
	cp  D_LEFT + B_BUTTON
	jr nz, .reset_last_pressed

	ldh a, [hTitleScreenLastPressed]
	cp D_LEFT + B_BUTTON
	jr z, .no_switch

	ld a, [hl]
	ldh [hTitleScreenLastPressed], a

	ld hl, wTitleScreenSelectedOption
	ld a, [hl]
	xor 1
	ld [hl], a

	jp TitleScreenSwitchObjectGFX

.reset_last_pressed
	xor a
	ldh [hTitleScreenLastPressed], a
.no_switch

; Save data can be deleted by pressing Up + B + Select.
	ld a, [hl]
	and D_UP + B_BUTTON + SELECT
	cp  D_UP + B_BUTTON + SELECT
	jr z, .delete_save_data

; To bring up the clock reset dialog, hold Down + B + Select
	ld a, [hl]
	and D_DOWN + B_BUTTON + SELECT
	cp  D_DOWN + B_BUTTON + SELECT
	jr z, .clock_reset

; Press Start or A to start the game.
	ld a, [hl]
	and START | A_BUTTON
	jr nz, .incave
	ret

.incave
	ld a, 0
	jr .done

.delete_save_data
	ld a, 1

.done
	ld [wTitleScreenSelectedOption], a

; Return to the intro sequence.
	ld hl, wJumptableIndex
	set 7, [hl]
	ret

.end
; Next scene
	ld hl, wJumptableIndex
	inc [hl]

; Fade out the title screen music
	xor a
	ld [wMusicFadeID], a
	ld [wMusicFadeID + 1], a
	ld hl, wMusicFade
	ld [hl], 8 ; 1 second

	ld hl, wTitleScreenTimer
	inc [hl]
	ret

.clock_reset
	ld a, 4
	ld [wTitleScreenSelectedOption], a

; Return to the intro sequence.
	ld hl, wJumptableIndex
	set 7, [hl]
	ret

TitleScreenEnd:
; Wait until the music is done fading.

	ld hl, wTitleScreenTimer
	inc [hl]

	ld a, [wMusicFade]
	and a
	ret nz

	ld a, 2
	ld [wTitleScreenSelectedOption], a

; Back to the intro.
	ld hl, wJumptableIndex
	set 7, [hl]
	ret

TitleScreenSetTimerNextScene:
	ld hl, wTitleScreenTimer
	ld a, e
	ld [hli], a
	ld [hl], d

	ld hl, wJumptableIndex
	inc [hl]
	ret

TitleScreenRunTimer:
	ld hl, wTitleScreenTimer
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, e
	or d
	ret z

	dec de
	ld [hl], d
	dec hl
	ld [hl], e
	ret

TitleScreenFireballs:
	ld hl, .Fireballs
	ld d, 6
.loop
	push de
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	push hl
	push bc
	ld a, SPRITE_ANIM_INDEX_TITLE_FLAME
	call _InitSpriteAnimStruct

	ld hl, SPRITEANIMSTRUCT_0C
	add hl, bc
	pop de
	ld a, d
	ld [hli], a
	ld a, e
	ld [hli], a

	pop hl
	pop de
	dec d
	jr nz, .loop
	ret

.Fireballs:
	; x pos, y pos, sine offset, speed
	db $E0, $4C, $10, 2
	db $A0, $58, $20, 3
	db $90, $64, $30, 4
	db $D0, $70, $00, 1
	db $B0, $7C, $10, 2
	db $00, $88, $20, 3

TitleScreenSwitchObjectGFX:
	add a
	ld l, a
	ld h, 0
	ld bc, .array
	add hl, bc
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, vTiles0
	lb bc, BANK(TitleFlamesGFX), 8
	jp Get2bpp

.array
	dw TitleFlamesGFX
	dw TitleNotesGFX

TitleScreenLoadGFX:
	call DisableLCD
	call ClearPalettes
	call ClearSprites
	call ClearTileMap

; Disable background updates
	xor a
	ldh [hBGMapMode], a

; Decompress graphics
	ld de, vTiles1
	ld hl, TitleLogoGFX
	call Decompress
	ld hl, TitleBorderGFX
	call Decompress
	ld hl, TitleLugiaGFX
	call Decompress
	xor a
	call TitleScreenSwitchObjectGFX

; Clear the background map
	hlbgcoord 0, 0
	ld bc, vBGMap1 - vBGMap0
	ld a, $80 ; Will be loaded white
	call ByteFill

; Draw Pokemon logo
	hlcoord 0, 0
	lb bc, 7, 20
	lb de, TITLE_LOGO_TILE, 20
	call DrawTitleGraphic
; ...except game title and tm
	hlcoord 6, 6
	ld bc, 9
	ld a, $80
	call ByteFill
	ld bc, 3
	add hl, bc
	ld [hl], a

; Fill tile palettes:
	ld a, 1
	ldh [rVBK], a

; Logo
	hlbgcoord 0, 0
	ld bc, 7 * BG_MAP_WIDTH
	ld a, 0
	call ByteFill

; 'GOLD VERSION'
	hlbgcoord 6, 6
	ld bc, 9 ; length of version text
	ld a, 1
	call ByteFill

; Border, Lugia and copyright text
	hlbgcoord 0, 8
	ld bc, 10 * BG_MAP_WIDTH
	ld a, 2
	call ByteFill

	ld a, 0
	ldh [rVBK], a

; Load palettes
	ldh a, [rSVBK]
	push af
	ld a, BANK(wBGPals1)
	ldh [rSVBK], a

	ld hl, TitleScreenPalettes
	ld de, wBGPals1
	ld bc, 3 palettes
	call CopyBytes

	ld hl, TitleScreenFlamesPalette
	ld de, wOBPals2
	ld bc, 1 palettes
	call CopyBytes

	pop af
	ldh [rSVBK], a

; Commit everything
	call EnableLCD
	jp WaitBGMap

DrawTitleGraphic:
; input:
;   hl: draw location
;   b: height
;   c: width
;   d: tile to start drawing from
;   e: number of tiles to advance for each bgrows
.bgrows
	push de
	push bc
	push hl
.col
	ld a, d
	ld [hli], a
	inc d
	dec c
	jr nz, .col
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop bc
	pop de
	ld a, e
	add d
	ld d, a
	dec b
	jr nz, .bgrows
	ret

DrawTitleBorder:
	ld c, 5
.loop
	push af
	ld b, 4
.loop_inner
	ld [hli], a
	inc a
	dec b
	jr nz, .loop_inner
	pop af
	dec c
	jr nz, .loop
	ret

TitleLugiaGFX:
INCBIN "gfx/title/Lugia.2bpp.lz"

TitleLogoGFX:
INCBIN "gfx/title/logo.2bpp.lz"

TitleBorderGFX:
INCBIN "gfx/title/border.2bpp.lz"

TitleFlamesGFX:
INCBIN "gfx/title/flames.2bpp"

TitleNotesGFX:
INCBIN "gfx/title/notes.2bpp"

TitleScreenFlamesPalette:
INCBIN "gfx/title/flames.gbcpal"

TitleScreenPalettes:
INCLUDE "gfx/title/title.pal"
