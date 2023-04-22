START_RACE_SCREEN_FILENAME:
    dc.b "carstartrace.data",0
    even

START_RACE_TXT:
    dc.b "START RACE",$FF
    even

SELECT_TRACK_TXT:
    dc.b "CHANGE TRACK",$FF
    even

MAIN_MENU_TXT:
    dc.b "MAIN MENU",$FF
    even

START_RACE_TRACK_NAME_TXT:
    dc.b "NEXT   TRACKLOL     ",$FF
    even

MENU_START_RACE_SCREEN:

    dc.w 1,10
    dc.l START_RACE_TXT
    dc.l ACTION_START_RACE_NEW
    dc.l 0
    dc.w 16
    dc.w 16

    dc.w 1,12
    dc.l SELECT_TRACK_TXT
    dc.l ACTION_SELECT_TRACK_NEW
    dc.l 0
    dc.w 16
    dc.w 16

    dc.w 1,14
    dc.l MAIN_MENU_TXT
    dc.l MENU_CARS_SETUP_SCREEN_BACK_FUNCT
    dc.l 0
    dc.w 16
    dc.w 16

    dcb.b  menu_SIZEOF,$00 ; terminator

TXT_START_RACE_SCREEN:

    dc.w 1,5
    dc.l START_RACE_TRACK_NAME_TXT
    dc.w 16
    dc.w 16

    dcb.b  txt_SIZEOF,$00

MENU_START_RACE_CURRENTLY_SELECTED:
    dc.l    MENU_START_RACE_SCREEN

ACTION_START_RACE_NEW:
    move.w  #1,MAIN_EXIT
    clr.w   LOAD_NEXT_TRACK_FLAG

    ; Cars init
    jsr 	SET_CAR1_START_STATUS
    jsr 	SET_CAR2_START_STATUS
    jsr 	SET_CAR3_START_STATUS
    jsr 	SET_CAR4_START_STATUS

    ;disable non playing car
    ; for each car
	lea 				MOVERS,a0
	move.w 				#MAX_CARS-1,d7
.disablecarloop:
    tst.l               INPUT_ROUTINE_OFFSET(a0)
    beq.s               .disablecar
    bset                d7,CARS_IN_PLAY+1
    bra.s               .afterdisablecar
.disablecar:
    bclr                d7,CARS_IN_PLAY+1
.afterdisablecar
	adda.w  			#MOVER_SIZE,a0
	dbra 				d7,.disablecarloop
    rts

ACTION_SELECT_TRACK_NEW:
    move.w              #1,SET_TRACK_SELECT_BITPLANE
    movem.l             a0-a6/d0/d7,-(sp)

    ; clean background image
    lea                 PHAZELOGO,a3
    lea                 PHAZELOGO+40*256*1,a4
    lea                 PHAZELOGO+40*256*2,a5

    move.w              #40*256/4-1,d7
.clearbakgroundloop
    clr.l               40*256*1(a5)
    clr.l               40*256*2(a5)

    clr.l              (a3)+
    clr.l              (a4)+
    clr.l              (a5)+
    dbra                d7,.clearbakgroundloop

    jsr                 SCREEN_TRACK_SELECT

    ; restore background image
    lea                 SCREEN_0,a0
    lea                 SCREEN_1,a1
    lea                 SCREEN_00,a2

    lea                 PHAZELOGO,a3
    lea                 PHAZELOGO+40*256*1,a4
    lea                 PHAZELOGO+40*256*2,a5

    move.w              #40*256/4-1,d7
.restorebakgroundloop
    clr.l               40*256*1(a5)
    clr.l               40*256*2(a5)

    move.l              (a0)+,(a3)+
    move.l              (a1)+,(a4)+
    move.l              (a2)+,(a5)+
    dbra                d7,.restorebakgroundloop

    lea                 TXT_START_RACE_SCREEN(PC),a1
    jsr                 REFRESH_TXT_ENTRY

    movem.l             (sp)+,a0-a6/d0/d7

    move.l				#COPPERLIST_MAIN,$dff080	; Copperlist point
	move.w				d0,$dff088			; Copperlist start
    rts

START_RACE_SCREEN:

    ; load track
    addi.w              #1,TRACK_NUMBER
    jsr     LOAD_TRACK

    ; print screen
    move.l  #START_RACE_SCREEN_FILENAME,MENUSCREEN_IMAGE
    move.l  #MENU_START_RACE_SCREEN,MENUSCREEN_ENTRIES
    move.l  #TXT_START_RACE_SCREEN,TXTSCREEN_ENTRIES
    move.l  MENU_START_RACE_CURRENTLY_SELECTED,MENUSCREEN_SELECTED_ENTRY
    jsr     MENUSCREEN
    rts