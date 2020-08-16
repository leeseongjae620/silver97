	const_def 2 ; object constants
	const CELADONGAMECORNERPRIZEROOM_GENTLEMAN
	const CELADONGAMECORNERPRIZEROOM_PHARMACIST

KantoGameCornerPrizeRoom_MapScripts:
	db 0 ; scene scripts

	db 0 ; callbacks

KantoGameCornerPrizeRoomGentlemanScript:
	jumptextfaceplayer KantoGameCornerPrizeRoomGentlemanText

KantoGameCornerPrizeRoomPharmacistScript:
	jumptextfaceplayer KantoGameCornerPrizeRoomPharmacistText

KantoGameCornerPrizeRoomTMVendor:
;	faceplayer
	opentext
	writetext CeladonPrizeRoom_PrizeVendorIntroText
	waitbutton
	checkitem COIN_CASE
	iffalse CeladonPrizeRoom_NoCoinCase
	writetext CeladonPrizeRoom_AskWhichPrizeText
CeladonPrizeRoom_tmcounterloop:
	special DisplayCoinCaseBalance
	loadmenu CeladonPrizeRoom_TMMenuHeader
	verticalmenu
	closewindow
	ifequal 1, .doubleteam
	ifequal 2, .psychic
	ifequal 3, .hyperbeam
	jump CeladonPrizeRoom_cancel

.doubleteam
	checkcoins 1500
	ifequal HAVE_LESS, CeladonPrizeRoom_notenoughcoins
	itemtotext TM_DOUBLE_TEAM, MEM_BUFFER_0
	scall CeladonPrizeRoom_askbuy
	iffalse CeladonPrizeRoom_cancel
	giveitem TM_DOUBLE_TEAM
	iffalse CeladonPrizeRoom_notenoughroom
	takecoins 1500
	jump CeladonPrizeRoom_purchased

.psychic
	checkcoins 3500
	ifequal HAVE_LESS, CeladonPrizeRoom_notenoughcoins
	itemtotext TM_PSYCHIC_M, MEM_BUFFER_0
	scall CeladonPrizeRoom_askbuy
	iffalse CeladonPrizeRoom_cancel
	giveitem TM_PSYCHIC_M
	iffalse CeladonPrizeRoom_notenoughroom
	takecoins 3500
	jump CeladonPrizeRoom_purchased

.hyperbeam
	checkcoins 7500
	ifequal HAVE_LESS, CeladonPrizeRoom_notenoughcoins
	itemtotext TM_HYPER_BEAM, MEM_BUFFER_0
	scall CeladonPrizeRoom_askbuy
	iffalse CeladonPrizeRoom_cancel
	giveitem TM_HYPER_BEAM
	iffalse CeladonPrizeRoom_notenoughroom
	takecoins 7500
	jump CeladonPrizeRoom_purchased

CeladonPrizeRoom_askbuy:
	writetext CeladonPrizeRoom_ConfirmPurchaseText
	yesorno
	end

CeladonPrizeRoom_purchased:
	waitsfx
	playsound SFX_TRANSACTION
	writetext CeladonPrizeRoom_HereYouGoText
	waitbutton
	jump CeladonPrizeRoom_tmcounterloop

CeladonPrizeRoom_notenoughcoins:
	writetext CeladonPrizeRoom_NotEnoughCoinsText
	waitbutton
	closetext
	end

CeladonPrizeRoom_notenoughroom:
	writetext CeladonPrizeRoom_NotEnoughRoomText
	waitbutton
	closetext
	end

CeladonPrizeRoom_cancel:
	writetext CeladonPrizeRoom_ComeAgainText
	waitbutton
	closetext
	end

CeladonPrizeRoom_NoCoinCase:
	writetext CeladonPrizeRoom_NoCoinCaseText
	waitbutton
	closetext
	end

CeladonPrizeRoom_TMMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 2, 15, TEXTBOX_Y - 1
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 4 ; items
	db "TM32    1500@"
	db "TM29    3500@"
	db "TM15    7500@"
	db "CANCEL@"

KantoGameCornerPrizeRoomPokemonVendor:
;	faceplayer
	opentext
	writetext CeladonPrizeRoom_PrizeVendorIntroText
	waitbutton
	checkitem COIN_CASE
	iffalse CeladonPrizeRoom_NoCoinCase
.loop
	writetext CeladonPrizeRoom_AskWhichPrizeText
	special DisplayCoinCaseBalance
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .pikachu
	ifequal 2, .porygon
	ifequal 3, .wolfan
	jump CeladonPrizeRoom_cancel

.pikachu
	checkcoins 2222
	ifequal HAVE_LESS, CeladonPrizeRoom_notenoughcoins
	checkcode VAR_PARTYCOUNT
	ifequal PARTY_LENGTH, CeladonPrizeRoom_notenoughroom
	pokenamemem PIKACHU, MEM_BUFFER_0
	scall CeladonPrizeRoom_askbuy
	iffalse CeladonPrizeRoom_cancel
	waitsfx
	playsound SFX_TRANSACTION
	writetext CeladonPrizeRoom_HereYouGoText
	waitbutton
	writebyte PIKACHU
	special GameCornerPrizeMonCheckDex
	givepoke PIKACHU, 25
	takecoins 2222
	jump .loop

.porygon
	checkcoins 5555
	ifequal HAVE_LESS, CeladonPrizeRoom_notenoughcoins
	checkcode VAR_PARTYCOUNT
	ifequal PARTY_LENGTH, CeladonPrizeRoom_notenoughroom
	pokenamemem PORYGON, MEM_BUFFER_0
	scall CeladonPrizeRoom_askbuy
	iffalse CeladonPrizeRoom_cancel
	waitsfx
	playsound SFX_TRANSACTION
	writetext CeladonPrizeRoom_HereYouGoText
	waitbutton
	writebyte PORYGON
	special GameCornerPrizeMonCheckDex
	givepoke PORYGON, 15
	takecoins 5555
	jump .loop

.wolfan
	checkcoins 8888
	ifequal HAVE_LESS, CeladonPrizeRoom_notenoughcoins
	checkcode VAR_PARTYCOUNT
	ifequal PARTY_LENGTH, CeladonPrizeRoom_notenoughroom
	pokenamemem WOLFAN, MEM_BUFFER_0
	scall CeladonPrizeRoom_askbuy
	iffalse CeladonPrizeRoom_cancel
	waitsfx
	playsound SFX_TRANSACTION
	writetext CeladonPrizeRoom_HereYouGoText
	waitbutton
	writebyte WOLFAN
	special GameCornerPrizeMonCheckDex
	givepoke WOLFAN, 40
	takecoins 8888
	jump .loop

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 2, 17, TEXTBOX_Y - 1
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 4 ; items
	db "PIKACHU    2222@"
	db "PORYGON    5555@"
	db "WOLFAN     8888@"
	db "CANCEL@"
	
DummyVendorScript:
	end

KantoGameCornerPrizeRoomGentlemanText:
	text "I wanted PORYGON,"
	line "but I was short by"
	cont "100 coins…"
	done

KantoGameCornerPrizeRoomPharmacistText:
	text "Whew…"

	para "I've got to stay"
	line "calm and cool…"

	para "I can't lose my"
	line "cool, or I'll lose"
	cont "all my money…"
	done

CeladonPrizeRoom_PrizeVendorIntroText:
	text "Welcome!"

	para "We exchange your"
	line "coins for fabulous"
	cont "prizes!"
	done

CeladonPrizeRoom_AskWhichPrizeText:
	text "Which prize would"
	line "you like?"
	done

CeladonPrizeRoom_ConfirmPurchaseText:
	text "OK, so you wanted"
	line "a @"
	text_ram wStringBuffer3
	text "?"
	done

CeladonPrizeRoom_HereYouGoText:
	text "Here you go!"
	done

CeladonPrizeRoom_NotEnoughCoinsText:
	text "You don't have"
	line "enough coins."
	done

CeladonPrizeRoom_NotEnoughRoomText:
	text "You have no room"
	line "for it."
	done

CeladonPrizeRoom_ComeAgainText:
	text "Oh. Please come"
	line "back with coins!"
	done

CeladonPrizeRoom_NoCoinCaseText:
	text "Oh? You don't have"
	line "a COIN CASE."
	done

KantoGameCornerPrizeRoom_MapEvents:
	db 0, 0 ; filler

	db 2 ; warp events
	warp_event  4,  7, KANTO_REGION, 7
	warp_event  5,  7, KANTO_REGION, 7

	db 0 ; coord events

	db 2 ; bg events
	bg_event  3,  2, BGEVENT_READ, KantoGameCornerPrizeRoomTMVendor
	bg_event  6,  2, BGEVENT_READ, KantoGameCornerPrizeRoomPokemonVendor

	db 4 ; object events
	object_event  0,  3, SPRITE_GENTLEMAN, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, KantoGameCornerPrizeRoomGentlemanScript, -1
	object_event  8,  4, SPRITE_PHARMACIST, SPRITEMOVEDATA_WALK_UP_DOWN, 0, 1, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, KantoGameCornerPrizeRoomPharmacistScript, -1
	object_event  3,  1, SPRITE_CLERK, SPRITEMOVEDATA_STANDING_DOWN, 0, 1, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, DummyVendorScript, -1
	object_event  6,  1, SPRITE_CLERK, SPRITEMOVEDATA_STANDING_DOWN, 0, 1, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, DummyVendorScript, -1
