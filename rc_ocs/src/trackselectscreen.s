LOAD_TRACK_THUMBNAIL_HEIGHT EQU 64

SCREEN_TRACK_SELECT:

   ; Init tiles bitplanes
    move.l              #PHAZELOGO,d0
    lea                 BPLPTR1_TRACK,a1
    bsr.w               POINTINCOPPERLIST_FUNCT

    move.l              #PHAZELOGO+256*40*1,d0
    lea                 BPLPTR2_TRACK,a1
    bsr.w               POINTINCOPPERLIST_FUNCT

    move.l              #PHAZELOGO+256*40*2,d0
    lea                 BPLPTR3_TRACK,a1
    bsr.w               POINTINCOPPERLIST_FUNCT

    move.l              #PHAZELOGO_4,d0
    lea                 BPLPTR4_TRACK,a1
    bsr.w               POINTINCOPPERLIST_FUNCT

    move.l              #PHAZELOGO_5,d0
    lea                 BPLPTR5_TRACK,a1
    bsr.w               POINTINCOPPERLIST_FUNCT

    move.l				#COPPERLIST_TRACK,$dff080	; Copperlist point
	move.w				d0,$dff088			; Copperlist start

    jsr LOAD_TRACK

    ; clean banner on top (LOAD_TRACK_THUMBNAIL_HEIGHT lines)
    move.w #(LOAD_TRACK_THUMBNAIL_HEIGHT*40/4)-1,d7
    clr.l d6
.topbanner:
    lea PHAZELOGO+256*40*0,a0
    clr.l 0(a0,d6.w)
    lea PHAZELOGO+256*40*1,a0
    clr.l 0(a0,d6.w)
    lea PHAZELOGO+256*40*2,a0
    clr.l 0(a0,d6.w)
    lea PHAZELOGO_4,a0
    clr.l 0(a0,d6.w)
    lea PHAZELOGO_5,a0
    clr.l 0(a0,d6.w)
    addq #4,d6
    dbra d7,.topbanner

    ; print image thumbnail scaled
    ; reset counters
    moveq #0,d4
    moveq #0,d5

    ; for each line
    move.w #(240/2)-1,d7
.drawthumbnailstart_y:
    ; 40 bytes for each row (source image)
    moveq #20,d6
.drawthumbnailstart_x:

    ; fetch a word from source image bpl1
    lea TRACK_DATA_1,a0
    move.w 0(a0,d4.w),d0
    jsr HALF_WORD

    ; write into screen bpl1
    lea 10+PHAZELOGO+LOAD_TRACK_THUMBNAIL_HEIGHT*40,a1
    move.b d0,0(a1,d5.w)

    ; fetch a word from source image bpl2
    lea TRACK_DATA_2,a0
    move.w 0(a0,d4.w),d0
    jsr HALF_WORD

    ; write into screen bpl2
    lea 10+PHAZELOGO+256*40*1+LOAD_TRACK_THUMBNAIL_HEIGHT*40,a1
    move.b d0,0(a1,d5.w)

    ; fetch a word from source image bpl3
    lea TRACK_DATA_3,a0
    move.w 0(a0,d4.w),d0
    jsr HALF_WORD

    ; write into screen bpl3
    lea 10+PHAZELOGO+256*40*2+LOAD_TRACK_THUMBNAIL_HEIGHT*40,a1
    move.b d0,0(a1,d5.w)

    ; fetch a word from source image bpl4
    lea TRACK_DATA_4,a0
    move.w 0(a0,d4.w),d0
    jsr HALF_WORD

    ; write into screen bpl4
    lea 10+PHAZELOGO_4+LOAD_TRACK_THUMBNAIL_HEIGHT*40,a1
    move.b d0,0(a1,d5.w)

    ; fetch a word from source image bpl5
    lea TRACK_DATA_5,a0
    move.w 0(a0,d4.w),d0
    jsr HALF_WORD

    ; write into screen bpl4
    lea 10+PHAZELOGO_5+LOAD_TRACK_THUMBNAIL_HEIGHT*40,a1
    move.b d0,0(a1,d5.w)

    addq #2,d4
    addq #1,d5

    dbra d6,.drawthumbnailstart_x

    ; skip next 40 bytes for source image
    add.w #40-2,d4
    add.w #20-1,d5

    dbra d7,.drawthumbnailstart_y

    ; clean banner on bottom (remaining lines)
    move.w #((256-120-LOAD_TRACK_THUMBNAIL_HEIGHT)*40/4)-1,d7
    clr.l d6
.downbanner:
    lea PHAZELOGO+256*40*0+120*40+LOAD_TRACK_THUMBNAIL_HEIGHT*40,a0
    clr.l 0(a0,d6.w)
    lea PHAZELOGO+256*40*1+120*40+LOAD_TRACK_THUMBNAIL_HEIGHT*40,a0
    clr.l 0(a0,d6.w)
    lea PHAZELOGO+256*40*2+120*40+LOAD_TRACK_THUMBNAIL_HEIGHT*40,a0
    clr.l 0(a0,d6.w)
    lea PHAZELOGO_4+120*40+LOAD_TRACK_THUMBNAIL_HEIGHT*40,a0
    clr.l 0(a0,d6.w)
    lea PHAZELOGO_5+120*40+LOAD_TRACK_THUMBNAIL_HEIGHT*40,a0
    clr.l 0(a0,d6.w)
    addq #4,d6
    dbra d7,.downbanner

    ; copy colors
    moveq #32-1,d7
    lea 				TRACK_DATA_COLORS,a0
    lea                 COPCOLOR_TRACK_0+2,a1
.colortrackthumb
    move.w              (a0)+,(a1)
    addq                #4,a1
    dbra d7,.colortrackthumb

trackselectscreen_start:

fireloadtrack:
    btst				#7,$bfe001	; joy 1 fire pressed?
	bne.s				fireloadtrack_end
fireloadtrackrel:
    btst				#7,$bfe001	; joy i fire released?
	beq.s				fireloadtrackrel
    bra.s               trackselectscreen_end
fireloadtrack_end:
    tst.b 				KEY_ESC
	bne.w 				trackselectscreen_end
    bra.s               trackselectscreen_start
trackselectscreen_end:
    rts