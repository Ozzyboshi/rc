START_RACE_SCREEN_FILENAME:
    dc.b "carstartrace.shr",0
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
    dc.b "NEXT   TRACKLOL      ",$FF
    even

START_RACE_NEXT_TRACK_TXT:
    dc.b "NEXT TRACK",$FF
    even

LAPS_TXT:
    dc.b "LAP COUNT",$FF
    even

LAP_COUNTER_TXT:
    dc.b "XX",$FF
    even

MENU_START_RACE_SCREEN:

    dc.w 1,8
    dc.l START_RACE_TXT
    dc.l ACTION_START_RACE_NEW
    dc.l 0
    dc.w 16
    dc.w 16

    dc.w 1,10
    dc.l LAPS_TXT
    dc.l ACTION_CHANGE_LAPS
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

    dc.w 10,3
    dc.l START_RACE_NEXT_TRACK_TXT
    dc.w 16
    dc.w 16

    dc.w 20,11
    dc.l START_RACE_TRACK_NAME_TXT
    dc.w 8
    dc.w 7

LAP_COUNTER_TXT_PTR:
    dc.w 12,10
    dc.l LAP_COUNTER_TXT
    dc.w 16
    dc.w 16

    dcb.b  txt_SIZEOF,$00

MENU_START_RACE_CURRENTLY_SELECTED:
    dc.l    MENU_START_RACE_SCREEN

ACTION_START_RACE_NEW:
    move.w  #1,MAIN_EXIT
    clr.w   LOAD_NEXT_TRACK_FLAG

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
    move.l              #SELECT_TRACK_SCREEN,NEXT_SCREEN
    move.w              #1,MAIN_EXIT
    rts

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
    lea                 SCREEN_11,a6

    lea                 PHAZELOGO,a3
    lea                 PHAZELOGO+40*256*1,a4
    lea                 PHAZELOGO+40*256*2,a5

    move.w              #40*256/4-1,d7
.restorebakgroundloop
    move.l              (a6)+,40*256*1(a5)
    clr.l               40*256*2(a5)

    move.l              (a0)+,(a3)+
    move.l              (a1)+,(a4)+
    move.l              (a2)+,(a5)+
    dbra                d7,.restorebakgroundloop

    bsr.w               PRINT_TRACK_NAME_NEW

    lea                 TXT_START_RACE_SCREEN(PC),a1
    jsr                 REFRESH_TXT_ENTRY

    lea                 TXT_START_RACE_SCREEN+txt_SIZEOF,a1
    jsr                 REFRESH_TXT_ENTRY

    lea                 MENU_START_RACE_SCREEN+menu_SIZEOF*0,a1
    jsr                 REFRESH_MENU_ENTRY

    lea                 MENU_START_RACE_SCREEN+menu_SIZEOF*1,a1
    jsr                 REFRESH_MENU_ENTRY

    lea                 MENU_START_RACE_SCREEN+menu_SIZEOF*2,a1
    jsr                 REFRESH_MENU_ENTRY

    movem.l             (sp)+,a0-a6/d0/d7

    move.l				#COPPERLIST_MAIN,$dff080	; Copperlist point
	move.w				d0,$dff088			; Copperlist start
    rts

ACTION_CHANGE_LAPS:
    move.w              LAP_RACE,d0
    cmpi.w              #MAX_LAPS,d0
    bne.s               .lap_no_max
    ; handle max
    moveq               #2,d0
    bra.s               .change_lap
.lap_no_max:
    addq                #1,d0
.change_lap:
    move.w              d0,LAP_RACE
    bsr.w               REFRESH_LAP_RACE_COUNTER
    lea                 LAP_COUNTER_TXT_PTR(PC),a1
    jsr                 REFRESH_TXT_ENTRY
    rts

START_RACE_SCREEN:

    ; clear sprites pointers
    move.w              #0,Sprite0pointers+2
    move.w              #0,Sprite0pointers+6
    move.w              #0,Sprite1pointers+2
    move.w              #0,Sprite1pointers+6
    move.w              #0,Sprite2pointers+2
    move.w              #0,Sprite2pointers+6
    move.w              #0,Sprite3pointers+2
    move.w              #0,Sprite3pointers+6
    move.w              #0,Sprite4pointers+2
    move.w              #0,Sprite4pointers+6
    move.w              #0,Sprite5pointers+2
    move.w              #0,Sprite5pointers+6
    move.w              #0,Sprite6pointers+2
    move.w              #0,Sprite6pointers+6
    move.w              #0,Sprite7pointers+2
    move.w              #0,Sprite7pointers+6

    ;reset race flag in case we are returning here after the race
    move.w              #0,START_RACE_FLAG

    move.w 	   			#DMASET,d1
    MOVE.W				d1,$dff096		; DMACON - enable bitplane, copper, sprites and audio (optional).
    move.w              #$000F,$dff096

    ; load track
    tst.w               LOAD_NEXT_TRACK_FLAG
    beq.s               .no_load_next_track
    addi.w              #1,TRACK_NUMBER
    clr.w               TRACK_OPEN_FILE
    jsr                 LOAD_TRACK
.no_load_next_track:

    bsr.w               PRINT_TRACK_NAME_NEW

    bsr.w               REFRESH_LAP_RACE_COUNTER

    ; print screen
    move.l              #START_RACE_SCREEN_FILENAME,MENUSCREEN_IMAGE
    move.l              #12586,MENUSCREEN_IMAGE_SIZE
    move.l              #MENU_START_RACE_SCREEN,MENUSCREEN_ENTRIES
    move.l              #TXT_START_RACE_SCREEN,TXTSCREEN_ENTRIES
    move.l              MENU_START_RACE_CURRENTLY_SELECTED,MENUSCREEN_SELECTED_ENTRY
    jsr                 MENUSCREEN
    rts

REFRESH_MENU_ENTRY:
    movem.l              d0-d1/a0/a1/a6/d6/d3,-(sp)
    move.l               a1,a6
    move.w               menu_EntryX(a6),d0
    move.w               menu_EntryY(a6),d1
    move.l               menu_DescPtr(a6),a1
    cmp.w                #8,menu_FontWidthPx(a6)
    bne.s                refresh_menu_entry_printbigfonts
    bsr.w                restorebackground_small
    bsr.w                printstringhigh_small
    movem.l              (sp)+,d0-d1/a0/a1/a6/d6/d3
    rts
refresh_menu_entry_printbigfonts:
    bsr.w                printstringhigh
    movem.l              (sp)+,d0-d1/a0/a1/a6/d6/d3
    rts

PRINT_TRACK_NAME_NEW:
     ; now that the track is loaded we can copy
    ; the filename into the text
    lea                 TRACK_FILENAME+TRACKDIR_LENGTH,a0
    lea                 START_RACE_TRACK_NAME_TXT(PC),a1
.copytrackfilename
    move.b              (a0)+,(a1)+
    cmp.b               #46,-1(a1)
    bne.s               .copytrackfilename
    move.b              #$FF,-1(a1)
    rts

REFRESH_LAP_RACE_COUNTER:
    move.w              LAP_RACE,d0
    addi.w              #$2F,d0
    lsl.w               #8,d0
    ori.w               #$FF,d0
    move.w              d0,LAP_COUNTER_TXT
    rts