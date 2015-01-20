;STARTUP-SOURCE BY GHOST V1.0    (AXXXX compitable)
; Uyari
; Cocuk AKLIYLA 1990'larda kufurlu
; label tanimlamalari yapmisim 8)
; okurken bana kizmayin, ozur dilerim
; orijinalligi bozulmasin diye degistirmedim...
;
; vigo - 18 Ocak 2015
;
;
                        screen_length  = 40*200
                        screen_length2 = 40*100
                        screen_lengthx = 40*34
                        dmaconr        = $dff002
                        bltcon0        = $dff040
                        bltcon1        = $dff042
                        bltafwm        = $dff044
                        bltalwm        = $dff046
                        bltaptr        = $dff050
                        bltdptr        = $dff054
                        bltbptr        = $dff04c
                        bltcptr        = $dff048
                        bltsize        = $dff058
                        bltamod        = $dff064
                        bltdmod        = $dff066
                        bltbmod        = $dff062
                        bltcmod        = $dff060

                        ;incdir dh1:dino/
                        ;include file.i
                        
                        include includes/file.i

                        section startup,code
o:                      movem.l d0-d7/a0-a6,-(a7)
                        bsr ldo

                        move.l #pr_data,pr_module
                        bsr.w pr_init

                        move.l 4,a6
                        jsr -132(a6)

                        lea $dff000,a5
                        bsr.w start_copper
                        bsr ustu_bas
                        bsr set_tepe_renk

                        move.l ds_buffer,dn_number
                        move.l ds_buffer+4,hak
                        bsr dn_sayi
                        bsr kelle_setter
                        bsr set_colors
                        bsr set_colors_2
                        bsr press_back
                        bsr clrscreen
                        bsr anim_pisagor

                        move.l #1,testi_var
                        bsr testi_check

                        move.l #2,testi_var
                        bsr testi_check

                        move.l #3,testi_var
                        bsr testi_check

                        bsr flip_flop
                        bsr get_keys

main:                   cmp.b #0,$dff006
                        bne.s main

                        cmp.l #1,endflag
                        beq digerleri_set_et

                        bsr clrscreen
                        bsr kay_check
                        bsr set_hareket
                        bsr testi_check
                        bsr flip_flop
                        bsr kapi_check


w_left:                 cmp.b #$61,$bfec01
                        bne.s main

digerleri_set_et:       bsr get_stuffs
vb:                     cmpi.b    #0,$dff006
                        bne vb

                        cmp.l #1,endflag2
                        beq git_artik

                        bsr clrscreen
                        bsr testi_check
                        bsr anim_pisagor
                        bsr flip_flop


w_l2:                   cmp.b #$61,$bfec01
                        bne vb

git_artik:
.vb:                    cmpi.b #0,$dff006
                        bne .vb

                        cmp.l #1,endflag3
                        beq siktir_git
                        bsr sonuc_ne_oldu

.lp:                    cmp.b #$61,$bfec01
                        bne .vb
siktir_git:
.lp:                    cmp.b #$61,$bfec01
                        bne .lp
                        bra end
enD:                    bsr.w stop_copper
                        move.l 4,a6
                        jsr -138(a6)
                        move.l dn_number,ds_buffer
                        move.l hak,ds_buffer+4
                        bsr svo
                        movem.l (a7)+,d0-d7/a0-a6
                        moveq #0,d0
                        rts

svo:                    ld_save

ldo:                    ld_load
                        ld_data

start_copper:           move.l #sprite1,d7
                        move.w d7,mouse+6
                        swap d7
                        move.w d7,mouse+2
                        move.l 4,a6
                        lea gfxname,a1
                        jsr -408(a6)
                        move.l d0,a6
                        move.l d0,gfxbase
                        move.l 50(a6),oldcop
                        move.l #newcopper,50(a6)
                        move.l $6c,jpr+2
                        move.l #int,$6c
                        move.w $dff002,d0
                        bset #15,d0
                        move.w d0,olddma
                        move.w #$7fff,$dff096
                        move.w #$87c0,$dff096
                        rts

olddma:                 dc.w 0

stop_copper:            move.w #$7fff,$dff096
                        move.w    olddma,$dff096
                        move.l    jpr+2,$6c
                        move.l    gfxbase,a6
                        move.l    oldcop,50(a6)
                        rts

int:                    movem.l d0-a6,-(a7)
                        bsr pr_music
                        movem.l (a7)+,d0-a6
jpr:                    jmp 0

flip_flop:              cmp.l #scr1,nonactive
                        bne flop
flip:                   move.l #scr2,nonactive
                        lea flipscr,a0
                        lea plane_d,a1
                        move.w #7,d1        ;5*2-1
.lp_1:                  move.w (a0)+,2(a1)
                        lea 4(a1),a1
                        dbf d1,.lp_1
                        rts
flop:                   move.l #scr1,nonactive
                        lea flopscr,a0
                        lea plane_d,a1
                        move.w #7,d1
.lp_1:                  move.w (a0)+,2(a1)
                        lea 4(a1),a1
                        dbf d1,.lp_1
                        rts

endflag:                dc.l 0

;-----------------------------------------------------------------------------
set_tepe_renk:
                        lea renk_data+2,a0
                        lea cop_t+2,a1
                        move.w #15,d0
.lp:                    move.w (a0),(a1)
                        add.w #2,a0
                        add.w #4,a1
                        sub.w #1,d0
                        bne .lp
                        rts

                        incdir    dh1:real/color/
renk_data:              incbin    'tepe_renk.color'

;-----------------------------------------------------------------------------
ustu_bas:               move.l #ust_ekran,a0
                        lea tepe_p,a1
                        move.w #7,d1        ;5*2-1
.lp_1:                  move.w (a0)+,2(a1)
                        lea 4(a1),a1
                        dbf d1,.lp_1
                        rts

hak:                    dc.l    0
;-----------------------------------------------------------------------------
dn_sayi:                move.l #5,f_dx
                        bsr dn_change
                        bsr dn_press
                        rts

dn_change:              move.l dn_number(pc),d0
                        lea dn_numdata(pc),a0
                        lea dn_asci(pc),a1
                        moveq.l #7,d7
.loop:                  move.l (a0)+,d1
                        moveq.l #0,d2
                        bsr dn_sub
                        add.b #"0",d2
                        move.b d2,(a1)+
                        dbra d7,.loop
                        rts

dn_sub:                 cmp.l d0,d1
                        bgt dn_ret
                        sub.l d1,d0
                        addq #1,d2
                        bra dn_sub
dn_ret:                 rts
dn_numdata:             dc.l 10000000
                        dc.l 1000000
                        dc.l 100000
                        dc.l 10000
                        dc.l 1000
                        dc.l 100
                        dc.l 10
                        dc.l 1

dn_number:              dc.l 0
dn_asci:                dc.b '00000000'

dn_press:               lea dn_asci(pc),a0
                        moveq.l #0,d3
.loop:                  moveq.l #0,d2
                        move.b (a0)+,d2
                        sub.b #'0',d2
                        movem.l d3/a0,-(a7)
                        bsr press_font
                        movem.l (a7)+,d3/a0
                        addq #1,d3
                        cmp.w #8,d3
                        bne .loop
                        rts

press_font:             move.l #font,a0
                        mulu #2,d2
                        add.l d2,a0
                        move.l #scr3,a1
                        add.l #[40*15],a1
                        move.l f_dx,d1
                        add d3,d1
                        mulu #2,d1
                        add.l d1,a1
                        move.l #4,d0
.lp:                    move.l a0,bltaptr
                        move.l a1,bltdptr
                        move.w #18,bltamod
                        move.w #38,bltdmod
                        move.l #$ffffffff,bltafwm
                        move.w #$09f0,bltcon0
                        move.w #$000,bltcon1
                        move.w #[17*64]+1,bltsize
                        bsr bw
                        add.l #360,a0
                        add.l #1360,a1
                        sub.l #1,d0
                        bne .lp
                        rts

f_dx:                   dc.l 1
f_sx:                   dc.l 0
;-----------------------------------------------------------------------------
kelle_setter:           lea hak_tablolari,a0
                        move.l hak,d0
                        mulu #4,d0
                        add.l d0,a0
                        move.l (a0),a1
                        jmp (a1)

hak_tablolari:          dc.l hakki1_var
                        dc.l hakki2_var
                        dc.l hakki3_var
                        dc.l hakki4_var

hakki3_var:             move.l #16,kafa_x
                        bsr press_kelle
                        move.l #18,kafa_x
                        bsr press_kelle
                        rts

hakki4_var:             move.l #14,kafa_x
                        bsr press_kelle
                        move.l #16,kafa_x
                        bsr press_kelle
                        move.l #18,kafa_x
                        bsr press_kelle
                        rts

hakki2_var:             move.l #16,sil_k_x
                        bsr sil_kelle
                        move.l #18,kafa_x
                        bsr press_kelle
                        rts
hakki1_var:             move.l #18,sil_k_x
                        bsr sil_kelle
                        rts
;-----------------------------------------------------------------------------
Press_kelle:            move.l #kafa,a0
                        move.l #scr3,a1
                        move.l kafa_x,d1
                        mulu #2,d1
                        add.l d1,a1
                        move.l #4,d0
.lp:                    move.l a0,bltaptr
                        move.l a1,bltdptr
                        move.w #0,bltamod
                        move.w #36,bltdmod
                        move.l #$ffffffff,bltafwm
                        move.w #$09f0,bltcon0
                        move.w #$000,bltcon1
                        move.w #[34*64]+2,bltsize
                        bsr bw
                        add.l #136,a0
                        add.l #1360,a1
                        sub.l #1,d0
                        bne .lp
                        rts
kafa_x:                 dc.l    0
;-----------------------------------------------------------------------------
sil_kelle:              move.l #b_kafa,a0
                        move.l #scr3,a1
                        move.l sil_k_x,d1
                        mulu #2,d1
                        add.l d1,a1
                        move.l #4,d0
.lp:                    move.l a0,bltaptr
                        move.l a1,bltdptr
                        move.w #0,bltamod
                        move.w #36,bltdmod
                        move.l #$ffffffff,bltafwm
                        move.w #$09f0,bltcon0
                        move.w #$000,bltcon1
                        move.w #[34*64]+2,bltsize
                        bsr bw
                        add.l #136,a0
                        add.l #1360,a1
                        sub.l #1,d0
                        bne .lp
                        rts
sil_k_x:                dc.l 0
;-----------------------------------------------------------------------------
get_stuffs:             bsr set_random_er
                        bsr set_random_er2
                        rts
set_random_er:          lea random_tablosu,a0
                        move.l random_sayi,d0
                        mulu #4,d0
                        add.l d0,a0
                        move.l (a0),animno
                        rts
set_random_er2:         lea dj_tablosu,a0
                        move.l random_sayi,d0
                        mulu #4,d0
                        add.l d0,a0
                        move.l (a0),a1
                        jmp (a1)
                        rts

new_x_tablosu:          dc.l 50,130,210
new_x_tablosu2:         dc.l 17,97,177
random_tablosu:         dc.l 0
                        dc.l 1,2,3

dj_tablosu:             dc.l return_xxx
                        dc.l return_xxx
                        dc.l eger_tukurse
                        dc.l eger_morfsa

sonuc_tablosu_:         dc.l 0
                        dc.l hakvepuan_arttir
                        dc.l hak_sil
                        dc.l return3x

sonuc_ne_oldu:          lea sonuc_tablosu_,a0
                        move.l random_sayi,d0
                        mulu #4,d0
                        add.l d0,a0
                        move.l (a0),a1
                        jmp (a1)

hakvepuan_arttir:       move.l #2,hangi_sample
                        bsr play_chan_4
                        add.l #500,dn_number
                        bsr dn_sayi
                        add.l #1,artirma_sayisi
                        cmp.l #40,artirma_sayisi
                        bne return
                        move.l #1,hangi_sample_2
                        bsr play_chan_3
                        move.l #1,endflag3
                        add.l #1,hak
                        bsr kelle_setter
                        rts

hak_sil:                cmp.l #0,hak
                        bne .xx
                        move.l #1,endflag3
                        bra return

.xx:                    sub.l    #1,hak
                        bsr kelle_setter
                        move.l #1,endflag3
                        rts

return3x:               move.l #1,endflag3
                        rts

endflag3:               dc.l 0

return_xxx:             move.l #1,endflag2
                        rts

artirma_sayisi:         dc.l 0


eger_tukurse:           lea new_x_tablosu,a0
                        move.l kapi_onu,d0
                        mulu #4,d0
                        add.l d0,a0
                        move.l (a0),px
                        move.l    #49,py    
                        move.l #2,hangi_sample_2
                        bsr play_chan_3
                        rts

eger_morfsa:            lea new_x_tablosu2,a0
                        move.l kapi_onu,d0
                        mulu #4,d0
                        add.l d0,a0
                        move.l (a0),px
                        move.l    #50,py    
                        move.l #3,hangi_sample_2
                        bsr play_chan_3
                        rts
;-----------------------------------------------------------------------------
kapi_onu:               dc.l 0
random_sayi:            dc.l 1
;-----------------------------------------------------------------------------
pRess_Back:             move.l #Back_ekran,d0
                        lea plane_u,a0
                        move.l #3,d1
.lp:                    swap d0
                        move.w d0,2(a0)
                        swap d0
                        move.w d0,6(a0)
                        lea 8(a0),a0
                        add.l #$1f40,d0
                        dbra d1,.lp
                        rts
;-----------------------------------------------------------------------------
Set_colors:             lea Color_data,a0
                        lea col_d+2,a1
                        lea color_data2,a2
                        lea col_d2+2,a3
                        move.w #16,d0
.lp:                    move.w (a0),(a1)
                        move.w (a2),(a3)
                        add.w #2,a0
                        add.w #2,a2
                        add.w #4,a1
                        add.w #4,a3
                        sub.w #1,d0
                        bne .lp
                        rts
;-----------------------------------------------------------------------------
set_colors_2:           lea color_data3,a0
                        lea col_u+2,a1
                        move.w #16,d0
.lp:                    move.w (a0),(a1)
                        add.w #2,a0
                        add.w #4,a1
                        sub.w #1,d0
                        bne .lp
                        move.w #0,col_u+2
                        rts
;-----------------------------------------------------------------------------
ClrScrEen:              move.l #bosscr,a0
                        move.l nonactive,a1
                        add.l #[40*20],a1
                        move.l #4,d0
.lp:                    move.l a0,bltaptr
                        move.l a1,bltdptr
                        move.w #0,bltamod
                        move.w #0,bltdmod
                        move.l #$ffffffff,bltafwm
                        move.w #$09f0,bltcon0
                        move.w #$000,bltcon1
                        move.w #[100*64]+20,bltsize
                        bsr bw
                        add.l #$fa0,a0
                        add.l #$1f40,a1
                        sub.l #1,d0
                        bne .lp
                        rts
;-----------------------------------------------------------------------------
Press_kapi:             move.l #kapi,a0
                        move.l ksy,d2
                        mulu #8*112,d2
                        add.l d2,a0
                        move.l #back_ekran,a1
                        move.l kx,d1
                        mulu #2,d1
                        add.l d1,a1
                        move.l #4,d0
.lp:                    move.l a0,bltaptr
                        move.l a1,bltdptr
                        move.w #0,bltamod
                        move.w #32,bltdmod
                        move.l #$ffffffff,bltafwm
                        move.w #$09f0,bltcon0
                        move.w #$000,bltcon1
                        move.w #[112*64]+4,bltsize
                        bsr bw
                        add.l #4480,a0
                        add.l #$1f40,a1
                        sub.l #1,d0
                        bne .lp
                        rts

kx:                     dc.l 0
ksy:                    dc.l 0
;-----------------------------------------------------------------------------
kay_check:              lea jump_table2,a0
                        move.l kayma_x,d0
                        mulu #4,d0
                        add.l d0,a0
                        move.l (a0),a1
                        jmp (a1)
;-----------------------------------------------------------------------------
kapi_check:             lea jump_table,a0
                        move.l acikmi,d0
                        mulu #4,d0
                        add.l d0,a0
                        move.l (a0),a1
                        jmp (a1)
;-----------------------------------------------------------------------------
testi_check:            lea jump_2,a0
                        move.l testi_var,d0
                        mulu #4,d0
                        add.l d0,a0
                        move.l (a0),a1
                        jmp (a1)
;-----------------------------------------------------------------------------
testi_var:              dc.l 0

jump_2:                 dc.l return
                        dc.l testi_1,testi_2,testi_3

birinci:                move.l #3,kx
                        bsr anim_kapi
                        rts
ikinci:                 move.l #8,kx
                        bsr anim_kapi
                        rts
ucuncu:                 move.l #13,kx
                        bsr anim_kapi
                        rts
jump_table:             dc.l return
                        dc.l birinci,ikinci,ucuncu
jump_table2:            dc.l return
                        dc.l ilk,orta,son
ilk:                    move.l #1,testi_var
                        bsr testi_check
                        move.l #2,testi_var
                        bsr testi_check
                        move.l #3,testi_var
                        bsr testi_check
                        add.l #1,px
                        cmp.l #38,px
                        bne return
                        move.l #0,kayma_x
                        move.l #1,acikmi
                        move.l #1,animno
                        move.l #0,number
                        move.l #1,testi_var
                        rts

orta:                   move.l #1,testi_var
                        bsr testi_check
                        move.l #2,testi_var
                        bsr testi_check
                        move.l #3,testi_var
                        bsr testi_check
                        add.l #1,px
                        cmp.l #80+38,px
                        bne return
                        move.l #0,kayma_x
                        move.l #2,acikmi
                        move.l #1,animno
                        move.l #0,number
                        move.l #2,testi_var
                        rts

son:                    move.l #1,testi_var
                        bsr testi_check
                        move.l #2,testi_var
                        bsr testi_check
                        move.l #3,testi_var
                        bsr testi_check
                        add.l #1,px
                        cmp.l #198,px
                        bne return
                        move.l #0,kayma_x
                        move.l #3,acikmi
                        move.l #1,animno
                        move.l #0,number
                        move.l #3,testi_var
                        rts
acikmi:                 dc.l 0
kayma_x:                dc.l 0
;-----------------------------------------------------------------------------
hareket_tab:            dc.l pisagor,anim_pisagor

set_hareket:            lea hareket_tab,a0
                        move.l hangi_har,d0
                        mulu #4,d0
                        add.l d0,a0
                        move.l (a0),a1
                        jmp (a1)

hangi_har:              dc.l 0
renkptr:                dc.w 0
;-----------------------------------------------------------------------------
get_keys:               add.l #1,random_sayi
                        cmp.l #4,random_sayi
                        bne key1
                        move.l #1,random_sayi
key1:                   bsr joystick
                        bsr moving
                        cmp.l #1,stop_stik
                        bne get_keys
                        rts
stop_stik:              dc.l 0
;-----------------------------------------------------------------------------
joystick:               movem.l d0-d2,-(a7)
fire:                   move.l #%10000,d2
                        tst.b $bfe001    ; Test FIRE
                        bpl get_req
                        bclr #4,d2
get_req:                clr.l d0
                        move.w $dff00c,d0
rightmi:                btst #1,d0
                        beq leftmi
                        bset #1,d2
leftmi:                 btst #9,d0
                        beq upmi
                        bset #3,d2
upmi:                   bsr rotate
                        btst #8,d0
                        beq downmi
                        bset #0,d2
downmi:                 btst #0,d0
                        beq hicbiri
                        bset #2,d2
hicbiri:                move.w d2,stick+2
                        movem.l (a7)+,d0-d2
                        rts
rotate:                 move.l d0,d1
                        lsr.l #1,d0
                        eor.l d1,d0
                        rts
stick:                  dc.l 0
;­­­­­­­­­­­­­­­­­­­­­­­­­­­--------------------------------------------------
moving:                 move.l stick,d0
;                       and.l #%01111,d0

.J_fire:                cmp.l #16,d0
                        bne .J_right
                        move.l #2,kayma_x
                        move.l #1,hangi_har
                        move.l #1,kapi_onu
                        move.l #1,stop_stik
                        rts

.J_right:               cmp.l #2,d0
                        bne .J_left
                        move.l #3,kayma_x
                        move.l #1,hangi_har
                        move.l #2,kapi_onu
                        move.l #1,stop_stik
                        rts

.J_left:                cmp.l #8,d0
                        bne .J_up
                        move.l #1,kayma_x
                        move.l #1,hangi_har
                        move.l #0,kapi_onu
                        move.l #1,stop_stik
                        rts

.J_up:                  cmp.l #1,d0
                        bne .J_down
                        rts

.J_down:                cmp.l #4,d0
                        bne return
                        rts
;-----------------------------------------------------------------------------
set_kapi_frames:        lea kapi_senaryo,a0
                        move.l kapi_anim_no,d0
                        mulu #4,d0
                        add.l d0,a0
                        move.l (a0),ksy
                        bsr press_kapi
                        rts
;-----------------------------------------------------------------------------
kapi_senaryo:
                        dc.l 0,0,0,0,0,0,0,0,0,0
                        dc.l 1,1,1,1,1,1,1,1,1,1
                        dc.l 2,2,2,2,2,2,2,2,2,2
                        dc.l 3,3,3,3,3,3,3,3,3,3
                        dc.l 4,4,4,4,4,4,4,4,4,4
;-----------------------------------------------------------------------------
anim_kapi:              bsr set_kapi_frames
                        add.l #1,kapi_anim_no
                        cmp.l #50,kapi_anim_no
                        bne return
                        move.l #0,kapi_anim_no
                        move.l #0,acikmi
                        move.l #1,hangi_sample
                        bsr play_chan_4
                        rts


kapi_anim_no:           dc.l 0
;-----------------------------------------------------------------------------
press_testi:            move.l ty,d0
                        mulu #40,d0
                        move.l tx,d1
                        asr.l #3,d1
                        bclr #0,d1
                        add.w d1,d0
                        move.l #btesti,a0
                        move.l #mtesti,a3
                        move.l nonactive,a1
                        add.l d0,a1
                        move.l #4,d0         ; bitplane adedi
.lp:                    move.l a0,bltbptr
                        move.l a3,bltaptr
                        move.l a1,bltcptr
                        move.l a1,bltdptr
                        move.w #0,bltamod    ; screen modulo    
                        move.w #0,bltbmod    
                        move.w #34,bltcmod   ; brush modulo=[40-(bursh/8)]
                        move.w #34,bltdmod   ;
                        move.l #$ffffffff,bltafwm
                        move.b tx+3,d1
                        and.l #$f,d1
                        swap d1
                        asr.l #4,d1
                        move.w d1,bltcon1
                        ori.l #$fca,d1
                        move.w d1,bltcon0
                        move.w #[32*64]+3,bltsize    ;[y*64]+[x/16]
                        bsr bw
                        add.l #192,a0
                        add.l #$1f40,a1
                        sub.l #1,d0
                        bne .lp
                        rts

tx:                     dc.l 0    ;84,84+80,84+160
ty:                     dc.l 86
;-----------------------------------------------------------------------------
testi_1:                move.l #84+80,tx    ;2-3
                        bsr press_testi
                        move.l #84+160,tx
                        bsr press_testi
                        rts

testi_2:                move.l #84,tx        ;1-3
                        bsr press_testi
                        move.l #84+160,tx
                        bsr press_testi
                        rts

testi_3:                move.l #84,tx        ;1-2
                        bsr press_testi
                        move.l #84+80,tx
                        bsr press_testi
                        rts
;-----------------------------------------------------------------------------
anim_pisagor:           bsr chooseanim
                        add.l #1,number
                        cmp.l #2,animno
                        bne suko
                        cmp.l #24,number
                        bne kko
                        move.l #2,hangi_sample_2
                        bsr play_chan_3
kko:                    cmp.l #45,number
                        bne suko
                        move.l #2,hangi_sample_2
                        bsr play_chan_3
suko:                   cmp.l #3,animno
                        bne .xxxx
                        cmp.l #114,number
                        blt .xxxx
                        add.l #1,py
.xxxx:                  move.l number,d0
                        move.l frameptr,d1
                        cmp.l d0,d1
                        bne return
                        move.l #0,number
                        cmp.l #3,animno
                        bne .xx
                        move.l #1,endflag2
.xx:                    cmp.l #2,animno
                        bne .xxx
                        move.l #1,endflag2
.xxx:                   cmp.l #1,animno
                        bne return
                        move.l #0,hangi_har
                        move.l #1,endflag
                        move.l #0,number
return:                 rts
endflag2:               dc.l 0
;-----------------------------------------------------------------------------
Pisagor:                move.l py,d0
                        mulu #40,d0
                        move.l px,d1
                        asr.l #3,d1
                        bclr #0,d1
                        add.w d1,d0
                        move.l pbobptr,a0
                        move.l psy,d2
                        move.w moduloptr,d5
                        move.w #40,d6
                        sub.w d5,d6
                        move.l d6,d6
                        mulu d6,d2
                        move.l sizeyptr,d4
                        mulu d4,d2
                        add.l d2,a0
                        move.l pmaskptr,a3
                        add.l d2,a3
                        move.l nonactive,a1
                        add.l d0,a1
                        move.l #4,d0
.lp:                    move.l a0,bltbptr
                        move.l a3,bltaptr
                        move.l a1,bltcptr
                        move.l a1,bltdptr
                        move.w #0,bltamod           ; screen modulo
                        move.w #0,bltbmod
                        move.w moduloptr,bltcmod    ; brush modulo=[40-(bursh/8)]
                        move.w moduloptr,bltdmod    ;
                        move.l #$ffffffff,bltafwm
                        move.b px+3,d1
                        and.l #$f,d1
                        swap d1
                        asr.l #4,d1
                        move.w d1,bltcon1
                        ori.l #$fca,d1
                        move.w d1,bltcon0
                        move.w sizeptr,bltsize    ;[y*64]+[x/16]
                        bsr bw
                        add.l lenghtptr,a0
                        add.l #$1f40,a1
                        sub.l #1,d0
                        bne .lp
                        rts
;-----------------------------------------------------------------------------
bw:                     btst #14,dmaconr
                        bne bw
                        rts
;-----------------------------------------------------------------------------
ChOOseAnim:             lea Bobtable,a0
                        lea Masktable,a1
                        lea modulotable,a2
                        lea sizetable,a3
                        lea lenghttable,a4
                        move.l animno,d0
                        mulu #4,d0
                        add.l d0,a0
                        add.l d0,a1
                        add.l d0,a2
                        add.l d0,a3
                        add.l d0,a4
                        move.l (a0),pbobptr
                        move.l (a1),pmaskptr
                        move.w 2(a2),moduloptr
                        move.w 2(a3),sizeptr
                        move.l (a4),lenghtptr
                        bsr chOOseanim2
                        bsr senaryo_set
                        bsr pisagor
                        rts
;-----------------------------------------------------------------------------
ChOOseAnim2:            lea sizeytable,a0
                        lea framecounttable,a1
                        move.l animno,d0
                        mulu #4,d0
                        add.l d0,a0
                        add.l d0,a1
                        move.l (a0),sizeyptr
                        move.l (a1),frameptr
                        rts
;-----------------------------------------------------------------------------
bobtable:               dc.l bwalk,bdrink,btukur,bmorf
masktable:              dc.l mwalk,mdrink,mtukur,mmorf
modulotable:            dc.l 32,28,26,22
sizetable:              dc.l 4100,[67*64]+6,[72*64]+7,[70*64]+9
lenghttable:            dc.l 2096,4224,5782,9000
sizeytable:             dc.l 65,67,72,70
framecounttable:        dc.l 49,149,64,119
animno:                 dc.l 0
;-----------------------------------------------------------------------------
senaryotable:           dc.l kayma,icme,suyu_tukur,morfi
;-------------------------------------------------
kayma:                  dc.l 0,0,0,0,0,0,0,0,0,0
                        dc.l 1,1,1,1,1,1,1,1,1,1
                        dc.l 2,2,2,2,2,2,2,2,2,2
                        dc.l 3,3,3,3,3,3,3,3,3,3
                        dc.l 3,3,3,3,3,3,3,3,3,3

icme:                   dc.l 0,0,0,0,0,0,0,0,0,0
                        dc.l 1,1,1,1,1,1,1,1,1,1
                        dc.l 2,2,2,2,2,2,2,2,2,2
                        dc.l 3,3,3,3,3,3,3,3,3,3
                        dc.l 4,4,4,4,4,4,4,4,4,4
                        dc.l 3,3,3,3,3,3,3,3,3,3
                        dc.l 4,4,4,4,4,4,4,4,4,4
                        dc.l 3,3,3,3,3,3,3,3,3,3
                        dc.l 4,4,4,4,4,4,4,4,4,4
                        dc.l 3,3,3,3,3,3,3,3,3,3
                        dc.l 4,4,4,4,4,4,4,4,4,4
                        dc.l 3,3,3,3,3,3,3,3,3,3
                        dc.l 4,4,4,4,4,4,4,4,4,4
                        dc.l 3,3,3,3,3,3,3,3,3,3
                        dc.l 4,4,4,4,4,4,4,4,4,4

suyu_tukur:             dc.l 0,0,0,0,0
                        dc.l 1,1,1,1,1
                        dc.l 2,2,2,2,2
                        dc.l 3,3,3,3,3
                        dc.l 4,4,4,4,4
                        dc.l 1,1,1,1,1
                        dc.l 2,2,2,2,2
                        dc.l 3,3,3,3,3
                        dc.l 4,4,4,4,4
                        dc.l 1,1,1,1,1
                        dc.l 2,2,2,2,2
                        dc.l 3,3,3,3,3
                        dc.l 4,4,4,4,4

morfi:                  dc.l 0,0,0,0,0,0,0,0,0,0
                        dc.l 1,1,1,1,1,1,1,1,1,1
                        dc.l 2,2,2,2,2,2,2,2,2,2
                        dc.l 3,3,3,3,3,3,3,3,3,3
                        dc.l 4,4,4,4,4,4,4,4,4,4
                        dc.l 5,5,5,5,5,5,5,5,5,5
                        dc.l 6,6,6,6,6,6,6,6,6,6
                        dc.l 6,6,6,6,6,6,6,6,6,6
                        dc.l 6,6,6,6,6,6,6,6,6,6
                        dc.l 6,6,6,6,6,6,6,6,6,6
                        dc.l 6,6,6,6,6,6,6,6,6,6
                        dc.l 6,6,6,6,6,6,6,6,6,6
;-----------------------------------------------------------------------------
senaryo_set:
    lea    senaryotable,a0
    move.l    animno,d0
    mulu    #4,d0
    add.l    d0,a0
    move.l    (a0),vigoptr
    bsr    senaryo2
    rts
;-------------------------------------------------
senaryo2:
    move.l    vigoptr,a0
    move.l    number,d0
    mulu    #4,d0
    add.l    d0,a0
    move.l    (a0),psy
    rts

vigoptr:dc.l    0
number:    dc.l    0
;-------------------------------------------------
px:        dc.l    0
py:        dc.l    53
psy:        dc.l    0
pbobptr:    dc.l    0
pmaskptr:    dc.l    0
moduloptr:    dc.w    0
sizeptr:    dc.w    0
lenghtptr:    dc.l    0
sizeyptr:    dc.l    0
frameptr:    dc.l    0
;-------------------------------------------------
        incdir    dh1:real/color/
color_data:    incbin    palet1.bin
color_data2:    incbin    palet3.bin
color_data3:    incbin    xxx
;-------------------------------------------------
YES                EQU    1
NO                EQU    0
INCLUDEFADINGROUTINE        EQU    no
PACKEDSONGFORMAT        EQU    no
FADINGSTEPS            EQU    8    ; ( 0< FADINGSTEPS <9 )
MAXVOLUME            EQU    2^FADINGSTEPS
INTERRUPTTIME            EQU    $180

SAMPLELENGTHOFFSET        EQU    4
SAMPLEVOLUMEOFFSET        EQU    6
SAMPLEREPEATPOINTOFFSET        EQU    8
SAMPLEWITHLOOP            EQU    12
SAMPLEREPEATLENGTHOFFSET    EQU    14
SAMPLEFINETUNEOFFSET        EQU    16

* Init-Routine *******************************************************

pr_init:
    lea    pr_framecounter(pc),a6
    move.w    #$7fff,pr_oldledvalue-pr_framecounter(a6)
    move.l    pr_module(pc),a0
    cmp.l    #0,a0
    bne.s    pr_init1
    rts
pr_init1:
    IFEQ    PACKEDSONGFORMAT-YES
    cmp.l    #'SNT!',(a0)
    beq.s    pr_init2
    ELSE
    cmp.l    #'M.K.',1080(a0)
    beq.s    pr_init2
    cmp.l    #'SNT.',1080(a0)
    beq.s    pr_init2
    ENDC
    rts
pr_init2:
    IFEQ    PACKEDSONGFORMAT-YES
    lea    8(a0),a1
    ELSE
    lea    20(a0),a1
    ENDC
    lea    pr_Sampleinfos(pc),a2
    moveq.l    #32,d7
    moveq    #30,d0
pr_init3:
    IFNE    PACKEDSONGFORMAT-YES
    lea    22(a1),a1        ; Samplenamen überspringen
    ENDC
    move.w    (a1)+,SAMPLELENGTHOFFSET(a2)    ; Samplelength in Words
    lea    pr_periods(pc),a3
    moveq    #$f,d2
    and.b    (a1)+,d2        ; Finetuning
    mulu.w    #36*2,d2
    add.l    d2,a3
    move.l    a3,SAMPLEFINETUNEOFFSET(a2)
    moveq    #0,d1
    move.b    (a1)+,d1
    move.w    d1,SAMPLEVOLUMEOFFSET(a2)    ; Volume
    moveq.l    #0,d1
    move.w    (a1)+,d1        ; Repeatpoint in Bytes
    add.l    d1,d1
    move.l    d1,SAMPLEREPEATPOINTOFFSET(a2)
    move.w    (a1)+,d1
    clr.w    SAMPLEWITHLOOP(a2)
    cmp.w    #1,d1
    bls.s    pr_init3_2
    addq.w    #1,SAMPLEWITHLOOP(a2)
pr_init3_2:
    move.w    d1,SAMPLEREPEATLENGTHOFFSET(a2)    ; Repeatlength
    add.l    d7,a2
    dbf    d0,pr_init3

    moveq    #0,d0
    IFEQ    PACKEDSONGFORMAT-YES
    move.b    256(a0),d0
    ELSE
    move.b    950(a0),d0        ; Number of patterns
    ENDC
    subq.w    #1,d0
    move.w    d0,pr_highestpattern-pr_framecounter(a6)
    moveq.l    #0,d1
    lea    pr_Patternpositions(pc),a3
    IFEQ    PACKEDSONGFORMAT-YES
    lea    258(a0),a1        ; 1.Patternpos
    lea    770(a0),a2        ; 1.Patterndata
    lea    642(a0),a4        ; 1.Patternoffset
pr_init4:
    moveq.l    #0,d2
    move.b    (a1)+,d2
    add.w    d2,d2
    move.w    (a4,d2.w),d2
    add.l    a2,d2
    move.l    d2,(a3)+
    dbf    d0,pr_init4
    ELSE
    lea    952(a0),a1        ; 1. Patternpos
    lea    1084(a0),a2        ; 1. Patterndata
pr_init4:
    move.b    (a1)+,d2        ; x. Patternpos
    moveq.l    #0,d3
    move.b    d2,d3
    mulu.w    #1024,d3
    add.l    a2,d3
    move.l    d3,(a3)+
    dbf    d0,pr_init4
    ENDC

    IFEQ    PACKEDSONGFORMAT-YES
    move.l    4(a0),d2
    add.l    a0,d2
    ELSE
    lea    952(a0),a1
    moveq.l    #0,d1
    moveq    #127,d0
pr_init4_1:
    move.b    (a1)+,d2
    cmp.b    d1,d2            ; Highest Pattern ?
    bls.s    pr_init4_2
    move.b    d2,d1
pr_init4_2:
    dbf    d0,pr_init4_1
    addq.w    #1,d1
    move.l    a0,d2
    mulu.w    #1024,d1        ; Highest Pattern * 1024 Bytes
    add.l    #1084,d2
    add.l    d1,d2
    ENDC
    lea    pr_Sampleinfos(pc),a3
    lea    pr_Sampleinfos+SAMPLELENGTHOFFSET(pc),a2
    moveq.l    #32,d7
    move.l    d2,(a3)
    moveq    #29,d0
pr_init4_3:
    move.l    (a3),d1
    add.l    d7,a3
    moveq.l    #0,d2
    move.w    (a2),d2
    add.l    d7,a2
    add.l    d2,d2
    add.l    d2,d1
    move.l    d1,(a3)
    dbf    d0,pr_init4_3

    lea    pr_Sampleinfos(pc),a2
    lea    pr_Sampleinfos+SAMPLEREPEATPOINTOFFSET(pc),a3
    moveq.l    #32,d7
    moveq    #30,d0
pr_init4_4:
    move.l    (a2),d1
    add.l    d1,(a3)
    add.l    d7,a2
    add.l    d7,a3
    dbf    d0,pr_init4_4
    
    IFNE    PACKEDSONGFORMAT-YES
    
    cmp.l    #'SNT.',1080(a0)
    beq.s    pr_init7
    
    lea    1084(a0),a1
    move.l    pr_Sampleinfos(pc),a2
    move.b    #$f0,d6
    move.w    #$fff,d7
pr_init5:
    move.b    (a1),d0
    move.b    2(a1),d1
    move.w    (a1),d2
    and.w    d7,2(a1)
    and.w    d7,d2
    
    and.b    d6,d0
    lsr.b    #4,d1
    or.b    d1,d0
    move.b    d0,(a1)
    
    tst.w    d2
    beq.s    pr_init5_3
    lea    pr_periods(pc),a4
    moveq    #0,d1
pr_init5_2:
    addq.w    #1,d1
    cmp.w    (a4)+,d2
    bne.s    pr_init5_2
    move.b    d1,1(a1)
pr_init5_3:
    cmp.b    #$d,2(a1)
    bne.s    pr_init5_4

    moveq    #0,d1
    move.b    3(a1),d1
    moveq    #$f,d2
    and.w    d1,d2
    lsr.w    #4,d1
    mulu.w    #10,d1
    add.w    d2,d1
    cmp.b    #63,d1
    bls.s    pr_init5_3_2
    moveq    #63,d1
pr_init5_3_2:
    move.b    d1,3(a1)
pr_init5_4:
    addq.l    #4,a1
    cmp.l    a2,a1
    blt.s    pr_init5    

    move.l    #'SNT.',1080(a0)

    ENDC
    
pr_init7:
    lea    pr_Arpeggiofastlist(pc),a2
    lea    pr_Arpeggiofastlistperiods(pc),a1
    lea    35*2(a1),a1        ; to the end of list...
    moveq    #0,d0
    moveq    #35,d1
    move.w    #999,d2
    moveq    #0,d6
pr_init8:
    move.w    -(a1),d7
    addq.w    #1,d6
pr_init8_2:
    cmp.w    d7,d0
    blt.s    pr_init8_4
    subq.w    #1,d1
    tst.b    d1
    bne.s    pr_init8
pr_init8_3:
    move.b    d1,(a2)+
    dbf    d2,pr_init8_3
    bra.s    pr_init8_5    
pr_init8_4:
    move.b    d1,(a2)+
    addq.w    #1,d0
    dbf    d2,pr_init8_2
pr_init8_5:

    lea    pr_Channel0(pc),a1
    move.w    #1,pr_Channel1-pr_Channel0(a1)
    move.w    #1,pr_Channel2-pr_Channel0(a1)
    move.w    #1,pr_Channel3-pr_Channel0(a1)
    move.w    #1,(a1)+
    moveq    #(pr_Channel1-pr_Channel0)/2-2,d0
pr_init9_2:
    clr.w    pr_Channel1-pr_Channel0(a1)
    clr.w    pr_Channel2-pr_Channel0(a1)
    clr.w    pr_Channel3-pr_Channel0(a1)
    clr.w    (a1)+
    dbf    d0,pr_init9_2

    lea    pr_fastperiodlist(pc),a1
    lea    pr_periods(pc),a2
    move.l    a2,(a1)
    moveq.l    #36*2,d1
    moveq    #14,d0
pr_init9_3:
    move.l    (a1)+,d2
    add.l    d1,d2
    move.l    d2,(a1)
    dbf    d0,pr_init9_3
        
    lea    pr_Arpeggiofastdivisionlist(pc),a1
    moveq    #0,d1
    move.w    #$ff,d0
pr_init9_4:
    move.b    d1,(a1)+
    subq.b    #1,d1
    bpl.s    pr_init9_4_2
    moveq    #2,d1
pr_init9_4_2:
    dbf    d0,pr_init9_4
    
    move.w    #6,pr_speed-pr_framecounter(a6)
    move.w    pr_speed(pc),(a6)
    clr.w    pr_Patternct-pr_framecounter(a6)
    move.w    pr_highestpattern(pc),d0
    move.w    pr_startposition(pc),d1
    blt.s    pr_init9_5
    cmp.w    d0,d1
    bls.s    pr_init9_5_2
pr_init9_5:
    clr.w    pr_startposition-pr_framecounter(a6)
pr_init9_5_2:
    move.w    pr_startposition(pc),pr_currentpattern-pr_framecounter(a6)
    
    lea    pr_Patternpositions(pc),a3
    move.l    a3,d0
    moveq.l    #0,d1
    move.w    pr_startposition(pc),d1
    lsl.l    #2,d1
    add.l    d1,d0
    move.l    d0,pr_Patternpt-pr_framecounter(a6)
    move.l    pr_Patternpt(pc),a5
    move.l    (a5),pr_Currentposition-pr_framecounter(a6)
    
    lea    $dff000,a5
    lea    $bfd000,a0
    move.w    #$2000,d0
    move.w    d0,$9a(a5)
    move.w    d0,$9c(a5)
    
    lea    pr_int(pc),a1
    move.l    pr_Vectorbasept(pc),a3
    move.l    a1,$78(a3)

    move.b    #$7f,$d00(a0)
    move.b    #$08,$e00(a0)
    move.w    #INTERRUPTTIME,d0
    move.b    d0,$400(a0)
    lsr.w    #8,d0
    move.b    d0,$500(a0)
pr_init10:
    btst    #0,$bfdd00
    beq.s    pr_init10
    move.b    #$81,$d00(a0)
    move.w    #$2000,$9c(a5)
    move.w    #$a000,$9a(a5)
    move.w    #$f,$96(a5)
    move.w    #$8000,pr_dmacon-pr_framecounter(a6)
    clr.w    $a8(a5)
    clr.w    $b8(a5)
    clr.w    $c8(a5)
    clr.w    $d8(a5)
    moveq    #0,d0
    move.b    $bfe001,d0
    move.w    d0,pr_oldledvalue-pr_framecounter(a6)
    bset    #1,$bfe001
    rts

* End-Routine *********************************************************

pr_end:
    lea    $dff000,a5
    move.w    #$f,$96(a5)
    clr.w    $a8(a5)
    clr.w    $b8(a5)
    clr.w    $c8(a5)
    clr.w    $d8(a5)
    move.w    #$2000,$9a(a5)
    move.w    pr_oldledvalue(pc),d0
    cmp.w    #$7fff,d0
    beq.s    pr_end3
    btst    #1,d0
    beq.s    pr_end2
    bset    #1,$bfe001
    rts
pr_end2:
    bclr    #1,$bfe001
pr_end3:
    rts

* Music-Fading ********************************************************

    IFEQ    INCLUDEFADINGROUTINE-YES
pr_fademusic:    macro
    lea    pr_musicfadect(pc),a0
    move.w    pr_musicfadedirection(pc),d0
    add.w    d0,(a0)
    cmp.w    #MAXVOLUME,(a0)
    bls.s    pr_fademusicend
    bgt.s    pr_fademusictoohigh
    clr.w    (a0)
    clr.w    pr_musicfadedirection-pr_musicfadect(a0)
    rts
pr_fademusictoohigh:
    move.w    #MAXVOLUME,(a0)
    clr.w    pr_musicfadedirection-pr_musicfadect(a0)
pr_fademusicend:
    endm

pr_musicfadect:        dc.w    MAXVOLUME
pr_musicfadedirection:    dc.w    0
    ENDC
    
* MACROS **************************************************************

pr_playchannel:    macro                ; do not change: d7,a2-sa6
        moveq    #0,d2
        moveq    #0,d0
        moveq    #0,d1
        IFEQ    PACKEDSONGFORMAT-YES
        move.b    (a6),d6
        bpl.s    .pr_playchannel1
        btst    #6,d6
        bne.s    .pr_playchannel0
        subq.l    #2,a6
        clr.w    4(a4)
        bra.s    .pr_playchannelend
.pr_playchannel0:
        subq.l    #2,a6
        move.b    56(a4),d0
        move.b    57(a4),d1
        move.b    58(a4),d2
        move.w    58(a4),4(a4)
        bra.s    .pr_playchanneljump        
.pr_playchannel1:
        moveq    #$f,d0
        and.b    1(a6),d0
        move.b    d0,4(a4)
        move.b    d0,d2
        move.b    2(a6),5(a4)
        move.w    4(a4),58(a4)
        
        moveq    #1,d0
        and.b    (a6),d0
        move.b    1(a6),d1
        lsr.b    #3,d1
        bclr    #0,d1
        or.b    d1,d0
        move.b    d0,56(a4)        

        move.b    (a6),d1
        lsr.b    #1,d1
        move.b    d1,57(a4)
        ELSE
        move.w    2(a6),4(a4)
        move.b    2(a6),d2
        move.b    (a6),d0
        move.b    1(a6),d1
        ENDC
.pr_playchanneljump:
        add.w    d2,d2
        lea    pr_playchannellist(pc),a0
        move.w    (a0,d2.w),d2
        jsr    (a0,d2.w)
.pr_playchannelend:
        IFEQ    PACKEDSONGFORMAT-YES
        addq.l    #3,a6
        ELSE
        addq.l    #4,a6
        ENDC
        endm

pr_checkchannel:    macro            ; do not change: d7,a2-a6
        bsr.w    pr_checkfunkrepeat
        moveq    #0,d0
        move.b    4(a4),d0
        add.b    d0,d0
        lea    pr_Effectchecklist(pc),a0
        move.w    (a0,d0.w),d0
        jsr    (a0,d0.w)
        endm
        
pr_copyplayvalues:    macro
        tst.w    pr_commandnotedelay-pr_framecounter(a2)
        bne.s    .pr_copyplayvalues2
        move.w    2(a4),6(a3)
.pr_copyplayvalues2:
        IFEQ    INCLUDEFADINGROUTINE-YES
        move.w    12(a4),d0
        mulu.w    pr_musicfadect-pr_framecounter(a2),d0
         lsr.l    #FADINGSTEPS,d0
        move.w    d0,8(a3)
        ELSE
        move.w    12(a4),8(a3)
        ENDC
        endm

* Music-Routine *******************************************************

pr_music:
    IFEQ    INCLUDEFADINGROUTINE-YES
    pr_fademusic
    ENDC
    lea    $dff000,a5

    lea    pr_framecounter(pc),a2
    subq.w    #1,(a2)
    beq.s    pr_music2
    bra.w    pr_checkeffects
pr_music2:
    cmp.b    #1,pr_patterndelaytime-pr_framecounter+1(a2)
    blt.s    pr_music2_2
    bsr.w    pr_checkeffects
    bra.w    pr_music2_9
pr_music2_2:
    move.l    pr_Currentposition(pc),a6
    lea    pr_Channel0(pc),a4
    lea    $a0(a5),a3
    moveq    #1,d7
    pr_playchannel
    pr_copyplayvalues
pr_music2_3:    
    lea    pr_Channel1(pc),a4
    lea    $b0(a5),a3
    moveq    #2,d7
    pr_playchannel
    pr_copyplayvalues
pr_music2_4:
    lea    pr_Channel2(pc),a4
    lea    $c0(a5),a3
    moveq    #4,d7
;    pr_playchannel
    add.l    #4,a6
;    pr_copyplayvalues
pr_music2_5:
    lea    pr_Channel3(pc),a4
    lea    $d0(a5),a3
    moveq    #8,d7
;    pr_playchannel
    add.l    #4,a6
;    pr_copyplayvalues
    
    lea    pr_int(pc),a0
    move.l    pr_Vectorbasept(pc),a1
    move.l    a0,$78(a1)
    move.b    #$19,$bfde00

pr_music2_9:
    move.w    pr_speed(pc),(a2)
    tst.w    pr_patternhasbeenbreaked-pr_framecounter(a2)
    bne.s    pr_music3
    tst.w    pr_patterndelaytime-pr_framecounter(a2)
    beq.s    pr_music3_1
    subq.w    #1,pr_patterndelaytime-pr_framecounter(a2)
    beq.s    pr_music3_1
    bra.s    pr_nonextpattern
pr_music3:
    clr.w    pr_patternhasbeenbreaked-pr_framecounter(a2)
    tst.w    pr_patterndelaytime-pr_framecounter(a2)
    beq.s    pr_music3_1
    subq.w    #1,pr_patterndelaytime-pr_framecounter(a2)
pr_music3_1:
    lea    pr_Patternct(pc),a1
    tst.w    pr_dontcalcnewposition-pr_framecounter(a2)
    bne.s    pr_music3_2
    move.l    a6,pr_Currentposition-pr_framecounter(a2)
    addq.w    #1,(a1)
pr_music3_2:
    clr.w    pr_dontcalcnewposition-pr_framecounter(a2)
    moveq.l    #64,d1
    cmp.w    (a1),d1
    bgt.s    pr_nonextpattern
    sub.w    d1,(a1)
    lea    pr_currentpattern(pc),a0
    move.w    (a1),d1
    beq.s    pr_music3_3
    IFEQ    PACKEDSONGFORMAT-YES
    move.l    pr_module(pc),a1
    lea    386(a1),a1
    move.w    (a0),d1
    add.w    d1,d1
    move.w    (a1,d1.w),d1
    ELSE
    lsl.w    #4,d1
    ENDC
pr_music3_3:
    addq.l    #4,pr_Patternpt-pr_framecounter(a2)
    addq.w    #1,(a0)
    move.w    (a0),d0
    cmp.w    pr_highestpattern-pr_framecounter(a2),d0
    bls.s    pr_nohighestpattern
    lea    pr_Patternpositions(pc),a1
    move.l    a1,pr_Patternpt-pr_framecounter(a2)
    clr.w    (a0)
pr_nohighestpattern:
    move.l    pr_Patternpt-pr_framecounter(a2),a6
    move.l    (a6),d0
    add.l    d1,d0
    move.l    d0,pr_Currentposition-pr_framecounter(a2)
pr_nonextpattern:
    rts

    
pr_int:
    tst.b    $bfdd00
    move.b    #$19,$bfde00
    move.w    pr_dmacon(pc),$dff096
    move.w    #$2000,$dff09c
    move.l    a0,-(sp)
    move.l    pr_Vectorbasept(pc),a0
    add.l    #pr_int2-pr_int,$78(a0)
    move.l    (sp)+,a0
    rte

pr_int2:
    tst.b    $bfdd00
    movem.l    a5-a6,-(sp)
    lea    $dff000,a5
    lea    pr_Channel0+6(pc),a6
    move.l    (a6),$a0(a5)
    move.w    4(a6),$a4(a5)
    move.l    pr_Channel1-pr_Channel0(a6),$b0(a5)
    move.w    4+pr_Channel1-pr_Channel0(a6),$b4(a5)
;    move.l    pr_Channel2-pr_Channel0(a6),$c0(a5)
;    move.w    4+pr_Channel2-pr_Channel0(a6),$c4(a5)
;    move.l    pr_Channel3-pr_Channel0(a6),$d0(a5)
;    move.w    4+pr_Channel3-pr_Channel0(a6),$d4(a5)
    move.w    #$2000,$9c(a5)
    move.l    pr_Vectorbasept(pc),a6
    move.l    pr_old78(pc),$78(a6)
    movem.l    (sp)+,a5-a6
    rte
        
pr_playchannellist:
    dc.w    pr_playnormalchannel-pr_playchannellist        ; 0
    dc.w    pr_playnormalchannel-pr_playchannellist        ; 1
    dc.w    pr_playnormalchannel-pr_playchannellist        ; 2
    dc.w    pr_playtpchannel-pr_playchannellist        ; 3
    dc.w    pr_playnormalchannel-pr_playchannellist        ; 4
    dc.w    pr_playtpchannel-pr_playchannellist        ; 5
    dc.w    pr_playnormalchannel-pr_playchannellist        ; 6
    dc.w    pr_playnormalchannel-pr_playchannellist        ; 7
    dc.w    pr_playnormalchannel-pr_playchannellist        ; 8
    dc.w    pr_playsochannel-pr_playchannellist        ; 9
    dc.w    pr_playnormalchannel-pr_playchannellist        ; A
    dc.w    pr_playnormalchannel-pr_playchannellist        ; B
    dc.w    pr_playnormalchannel-pr_playchannellist        ; C
    dc.w    pr_playnormalchannel-pr_playchannellist        ; D
    dc.w    pr_playnormalchannel-pr_playchannellist        ; E
    dc.w    pr_playnormalchannel-pr_playchannellist        ; F
    
* KANAL NORMAL SPIELEN ************************************************

pr_playnormalchannel:
    lea    pr_Sampleinfos(pc),a0
    lea    (a0),a1
    lea    SAMPLEFINETUNEOFFSET(a1),a1
    clr.w    pr_commandnotedelay-pr_framecounter(a2)
    moveq    #-1,d4
    lsl.w    #4,d4
    and.w    4(a4),d4
    cmp.w    #$ed0,d4
    bne.s    pr_playnormalsamplenotedelay
    addq.w    #1,pr_commandnotedelay-pr_framecounter(a2)
pr_playnormalsamplenotedelay:
    tst.b    d0
    beq.w    pr_playnormalnonewsample    ; Irgendein Sample ?
    move.w    d0,(a4)                ; Trage Samplenummer ein
    tst.b    d1
    bne.s    pr_playnormalsample
    subq.b    #1,d0
    lsl.l    #5,d0
    add.l    d0,a0
    addq.l    #6,a0
    move.w    (a0)+,12(a4)
    move.l    (a0)+,d2
    move.l    d2,6(a4)
    tst.w    (a0)+
    beq.s    pr_playnormalchannel2
    move.l    d2,36(a4)
    move.l    d2,40(a4)
pr_playnormalchannel2:
    move.w    (a0)+,10(a4)
    bra.w    pr_playnormalnonewperiod
pr_playnormalsample:
    or.w    d7,pr_dmacon-pr_framecounter(a2)
    tst.w    pr_commandnotedelay-pr_framecounter(a2)
    beq.w    pr_playnormalsamplenoedcom
    subq.b    #1,d0
    lsl.l    #5,d0
    add.l    d0,a0
    move.w    6(a0),12(a4)
    move.l    8(a0),6(a4)
    move.w    14(a0),10(a4)
    bra.s    pr_playnormalnewperiod
pr_playnormalsamplenoedcom:
    move.w    d7,$96(a5)
    subq.b    #1,d0
    lsl.l    #5,d0
    add.l    d0,a0
    move.l    (a0)+,(a3)        ; Setze Samplestart
    move.w    (a0)+,4(a3)        ; Setze Audiodatenlänge
    move.w    (a0)+,12(a4)        ; Setze Samplelautstärke
    move.l    (a0)+,d2
    move.l    d2,6(a4)        ; Samplerepeatpoint eintragen
    tst.w    (a0)+
    beq.s    pr_playnormalsample2
    move.l    d2,36(a4)
    move.l    d2,40(a4)
pr_playnormalsample2:
    move.w    (a0)+,10(a4)        ; Samplerepeatlength eintragen
    bra.s    pr_playnormalnewperiod
pr_playnormalnonewsample:
    clr.l    14(a4)
    tst.b    d1
    beq.s    pr_playnormalnonewperiod    ; Irgend ne neue Frequenz ?
    move.w    (a4),d0            ; Alte Samplenummer holen
    or.w    d7,pr_dmacon-pr_framecounter(a2)
    tst.w    pr_commandnotedelay-pr_framecounter(a2)
    bne.s    pr_playnormalnewperiod
    move.w    d7,$96(a5)
pr_playnormalnonewsamplenoedcom:
    subq.b    #1,d0
    lsl.l    #5,d0
    add.l    d0,a0
    move.l    (a0)+,(a3)        ; Setze Samplestart
    move.w    (a0)+,4(a3)        ; Setze Audiodatenlänge
    addq.l    #2,a0
    move.l    (a0)+,d2
    move.l    d2,6(a4)        ; Samplerepeatpoint eintragen
    tst.w    (a0)+
    beq.s    pr_playnormalnonewsample2
    move.l    d2,36(a4)
    move.l    d2,40(a4)
pr_playnormalnonewsample2:
    move.w    (a0)+,10(a4)        ; Samplerepeatlength eintragen
pr_playnormalnewperiod:
    subq.b    #1,d1
    add.b    d1,d1
    move.w    (a4),d0
    subq.b    #1,d0
    lsl.w    #5,d0
    move.l    (a1,d0.w),a1
    move.w    (a1,d1.w),2(a4)        ; Frequenz eintragen
pr_playnormalnonewperiod:
    bra.w    pr_playeffect

* KANAL MIT OFFSET SPIELEN *********************************************

pr_playsochannel:
    lea    pr_Sampleinfos(pc),a0
    lea    (a0),a1
    lea    SAMPLEFINETUNEOFFSET(a1),a1
    tst.b    d0
    beq.w    pr_playsononewsample    ; Irgendein Sample ?
    move.w    d0,(a4)                ; Trage Samplenummer ein
    tst.b    d1
    bne.s    pr_playsosample
    subq.b    #1,d0
    lsl.l    #5,d0
    add.l    d0,a0
    addq.l    #6,a0
    move.w    (a0)+,12(a4)
    move.l    (a0)+,d2
    move.l    d2,6(a4)
    tst.w    (a0)+
    beq.s    pr_playsochannel2
    move.l    d2,36(a4)
    move.l    d2,40(a4)
pr_playsochannel2:
    move.w    (a0)+,10(a4)
    bra.w    pr_playsononewperiod
pr_playsosample:
    move.w    d7,$96(a5)
    or.w    d7,pr_dmacon-pr_framecounter(a2)
    moveq.l    #0,d6
    move.b    5(a4),d6
    lsl.w    #7,d6
    subq.b    #1,d0
    lsl.l    #5,d0
    add.l    d0,a0
    move.l    (a0)+,d2
    move.w    (a0)+,d3
    cmp.w    d3,d6
    bge.s    pr_playsosample2
    sub.w    d6,d3
    add.l    d6,d6
    add.l    d6,d2
    move.l    d2,(a3)            ; Setze Samplestart
    move.w    d3,4(a3)        ; Setze Audiodatenlänge
    move.w    (a0)+,12(a4)        ; Setze Samplelautstärke
    move.l    (a0)+,d2
    move.l    d2,6(a4)        ; Samplerepeatpoint eintragen
    tst.w    (a0)+
    beq.s    pr_playsosample1
    move.l    d2,36(a4)
    move.l    d2,40(a4)
pr_playsosample1:
    move.w    (a0)+,10(a4)        ; Samplerepeatlength eintragen
    bra.w    pr_playsonewperiod
pr_playsosample2:
    move.w    (a0)+,12(a4)
    move.l    (a0),(a3)
    move.w    4(a0),4(a3)
    move.l    (a0)+,d2
    move.l    d2,6(a4)
    tst.w    (a0)+
    beq.s    pr_playsosample4
    move.l    d2,36(a4)
    move.l    d2,40(a4)
pr_playsosample4:
    move.w    (a0)+,10(a4)
    bra.s    pr_playsonewperiod
pr_playsononewsample:
    clr.l    14(a4)
    tst.b    d1
    beq.b    pr_playsononewperiod    ; Irgend ne neue Frequenz ?
    move.w    (a4),d0            ; Alte Samplenummer holen
    move.w    d7,$96(a5)
    or.w    d7,pr_dmacon-pr_framecounter(a2)
    moveq.l    #0,d6
    move.b    5(a4),d6
    lsl.w    #7,d6
    subq.b    #1,d0
    lsl.l    #5,d0
    add.l    d0,a0
    move.l    (a0)+,d2
    move.w    (a0)+,d3
    cmp.w    d3,d6
    bge.s    pr_playsosample3
    sub.w    d6,d3
    add.l    d6,d6
    add.l    d6,d2
    move.l    d2,(a3)            ; Setze Samplestart
    move.w    d3,4(a3)        ; Setze Audiodatenlänge
    addq.l    #2,a0
    move.l    (a0)+,d2
    move.l    d2,6(a4)        ; Samplerepeatpoint eintragen
    tst.w    (a0)+
    beq.s    pr_playsononewsample2
    move.l    d2,36(a4)
    move.l    d2,40(a4)
pr_playsononewsample2:
    move.w    (a0)+,10(a4)        ; Samplerepeatlength eintragen
    bra.s    pr_playsonewperiod
pr_playsosample3:
    addq.l    #2,a0
    move.l    (a0),(a3)
    move.w    4(a0),4(a3)
    move.l    (a0)+,d2
    move.l    d2,6(a4)
    tst.w    (a0)+
    beq.s    pr_playsosample5
    move.l    d2,36(a4)
    move.l    d2,40(a4)
pr_playsosample5:
    move.w    (a0)+,10(a4)
    bra.w    pr_playsonewperiod
pr_playsonewperiod:
    subq.w    #1,d1
    add.b    d1,d1
    move.w    (a4),d0
    subq.b    #1,d0
    lsl.w    #5,d0
    move.l    (a1,d0.w),a1
    move.w    (a1,d1.w),2(a4)        ; Frequenz eintragen
pr_playsononewperiod:
    bra.b    pr_playeffect

* Kanal spielen mit TONE PORTAMENTO **********************************

pr_playtpchannel:
    lea    pr_Sampleinfos(pc),a0
    lea    (a0),a1
    lea    SAMPLEFINETUNEOFFSET(a1),a1
    tst.b    d0
    beq.s    pr_playtpnonewsample    ; Irgendein Sample ?
    move.w    d0,(a4)            ; Trage Samplenummer ein
    subq.b    #1,d0
    lsl.l    #5,d0
    add.l    d0,a0
    addq.l    #6,a0
    move.w    (a0)+,12(a4)        ; Lautstärke eintragen
    move.l    (a0)+,d2
    move.l    d2,6(a4)        ; Repeatpoint eintragen
    tst.w    (a0)+
    beq.s    pr_playtpchannel2
    move.l    d2,36(a4)
    move.l    d2,40(a4)
pr_playtpchannel2:
    move.w    (a0)+,10(a4)        ; Repeatlength eintragen
pr_playtpnonewsample:
    tst.b    d1
    beq.s    pr_playtpnonewperiod    ; Irgend ne neue Frequenz ?
pr_playtpnewperiod:
    move.w    2(a4),14(a4)
    subq.w    #1,d1
    add.b    d1,d1
    move.w    (a4),d0
    subq.b    #1,d0
    lsl.w    #5,d0
    move.l    (a1,d0.w),a1
    move.w    (a1,d1.w),d2
    move.w    d2,16(a4)        ; Frequenz eintragen
    bra.s    pr_playtpallowed
pr_playtpnonewperiod:
    tst.w    16(a4)
    bne.s    pr_playtpallowed
    clr.w    14(a4)
    clr.l    26(a4)
pr_playtpallowed:
    bra.w    pr_playeffect

pr_playeffect:
    bsr.w    pr_checkfunkrepeat
    moveq    #0,d0
    move.b    4(a4),d0
    add.b    d0,d0
    lea    pr_normaleffectlist(pc),a0
    move.w    (a0,d0.w),d0
    jmp    (a0,d0.w)
pr_playnoeffect:
    rts

pr_normaleffectlist:
    dc.w    pr_playnoeffect-pr_normaleffectlist        ; 0
    dc.w    pr_playnoeffect-pr_normaleffectlist        ; 1
    dc.w    pr_playnoeffect-pr_normaleffectlist        ; 2
    dc.w    pr_preptoneportamento-pr_normaleffectlist    ; 3
    dc.w    pr_prepvibrato-pr_normaleffectlist        ; 4
    dc.w    pr_playnoeffect-pr_normaleffectlist        ; 5
    dc.w    pr_prepvibandvolslide-pr_normaleffectlist    ; 6
    dc.w    pr_preptremolo-pr_normaleffectlist        ; 7
    dc.w    pr_playnoeffect-pr_normaleffectlist        ; 8
    dc.w    pr_playnoeffect-pr_normaleffectlist        ; 9
    dc.w    pr_playnoeffect-pr_normaleffectlist        ; A
    dc.w    pr_jumptopattern-pr_normaleffectlist        ; B
    dc.w    pr_newvolume-pr_normaleffectlist        ; C
    dc.w    pr_patternbreak-pr_normaleffectlist        ; D
    dc.w    pr_play_e_command-pr_normaleffectlist        ; E
    dc.w    pr_newspeed-pr_normaleffectlist            ; F

pr_play_e_command:
    moveq    #0,d0
    move.b    5(a4),d0
    lsr.b    #3,d0
    bclr    #0,d0
    lea    pr_e_commandeffectlist(pc),a0
    move.w    (a0,d0.w),d0
    jmp    (a0,d0.w)
    
pr_e_commandeffectlist:
    dc.w    pr_setfilter-pr_e_commandeffectlist        ; 0
    dc.w    pr_fineslideup-pr_e_commandeffectlist        ; 1
    dc.w    pr_fineslidedown-pr_e_commandeffectlist        ; 2
    dc.w    pr_setglissandocontrol-pr_e_commandeffectlist    ; 3
    dc.w    pr_setvibratowaveform-pr_e_commandeffectlist    ; 4
    dc.w    pr_playfinetune-pr_e_commandeffectlist        ; 5
    dc.w    pr_jumptoloop-pr_e_commandeffectlist        ; 6
    dc.w    pr_settremolowaveform-pr_e_commandeffectlist    ; 7
    dc.w    pr_playnoeffect-pr_e_commandeffectlist        ; 8
    dc.w    pr_prepretrignote-pr_e_commandeffectlist    ; 9
    dc.w    pr_finevolumeslideup-pr_e_commandeffectlist    ; A
    dc.w    pr_finevolumeslidedown-pr_e_commandeffectlist    ; B
    dc.w    pr_prepnotecut-pr_e_commandeffectlist        ; C
    dc.w    pr_prepnotedelay-pr_e_commandeffectlist        ; D
    dc.w    pr_preppatterndelay-pr_e_commandeffectlist    ; E
    dc.w    pr_prepfunkrepeat-pr_e_commandeffectlist    ; F

pr_preppatterndelay:
    cmp.b    #1,pr_patterndelaytime-pr_framecounter+1(a2)
    bge.s    pr_preppatterndelayend
    moveq    #$f,d0
    and.b    5(a4),d0
    addq.b    #1,d0
    move.b    d0,pr_patterndelaytime-pr_framecounter+1(a2)
pr_preppatterndelayend:
    rts

pr_setvibratowaveform:
    moveq    #$f,d0
    and.b    5(a4),d0
    move.w    d0,50(a4)
    rts

pr_settremolowaveform:
    moveq    #$f,d0
    and.b    5(a4),d0
    move.w    d0,52(a4)
    rts

pr_setglissandocontrol:
    moveq    #$f,d0
    and.b    5(a4),d0
    move.w    d0,48(a4)
    rts

pr_playfinetune:
    moveq    #$f,d0
    and.b    5(a4),d0
    lsl.w    #2,d0
    lea    pr_fastperiodlist(pc),a0
    move.l    (a0,d0.w),a0
    moveq    #0,d1
    IFEQ    PACKEDSONGFORMAT-YES
    move.b    (a6),d1
    lsr.b    #1,d1
    ELSE
    move.b    1(a6),d1
    ENDC
    beq.s    pr_playfinetuneend
    subq.b    #1,d1
    add.w    d1,d1
    move.w    (a0,d1.w),2(a4)        ; Frequenz eintragen
pr_playfinetuneend:
    rts
    
pr_jumptoloop:
    moveq    #$f,d0
    and.b    5(a4),d0
    beq.s    pr_prepjumptoloop
    addq.b    #1,47(a4)
    cmp.b    47(a4),d0
    blt.s    pr_jumptoloopend
    moveq.l    #0,d0
    move.w    44(a4),d0
    move.w    d0,pr_Patternct-pr_framecounter(a2)
    move.l    pr_Patternpt(pc),a0
    move.l    (a0),d5
    IFEQ    PACKEDSONGFORMAT-YES
    moveq.l    #0,d0
    move.w    60(a4),d0
    ELSE
    lsl.l    #4,d0
    ENDIF
    add.l    d0,d5
    move.l    d5,pr_Currentposition-pr_framecounter(a2)
    addq.w    #1,pr_dontcalcnewposition-pr_framecounter(a2)
    rts
pr_jumptoloopend:
    clr.w    46(a4)
    rts
pr_prepjumptoloop:
    tst.w    46(a4)
    bne.s    pr_prepjumptoloopend
    move.w    pr_Patternct-pr_framecounter(a2),44(a4)
    IFEQ    PACKEDSONGFORMAT-YES
    move.l    pr_Currentposition(pc),d0
    move.l    pr_Patternpt(pc),a1
    sub.l    (a1),d0
    move.w    d0,60(a4)
    ENDC
    clr.w    46(a4)
pr_prepjumptoloopend:
    rts

pr_prepnotedelay:
    IFEQ    PACKEDSONGFORMAT-YES
    tst.b    57(a4)
    ELSE
    tst.b    1(a6)
    ENDC
    beq.s    pr_prepnotedelayend2

    moveq    #$f,d0
    and.b    5(a4),d0
    bne.s    pr_prepnotedelay2
    move.w    #$fff,18(a4)
    bra.w    pr_checknotedelay2
pr_prepnotedelay2:
    move.w    d7,d0
    not.b    d0
    and.b    d0,pr_dmacon-pr_framecounter+1(a2)
    clr.w    18(a4)
    rts
pr_prepnotedelayend2:
    move.w    #$fff,18(a4)
    rts

pr_prepretrignote:
    clr.w    18(a4)
    IFEQ    PACKEDSONGFORMAT-YES
    tst.b    56(a4)
    ELSE
    tst.w    (a6)
    ENDC
    bne.s    pr_prepretrignoteend
    bra.w    pr_checkretrignote2    
pr_prepretrignoteend:
    rts

pr_prepnotecut:
    clr.w    18(a4)
    moveq    #$f,d0
    and.b    5(a4),d0
    tst.b    d0
    bne.s    pr_prepnotecutend
    clr.w    12(a4)
pr_prepnotecutend:
    rts
    
pr_finevolumeslideup:
    moveq    #$f,d0
    and.b    5(a4),d0
    move.w    12(a4),d1
    add.w    d0,d1
    moveq    #64,d0
    cmp.w    d0,d1
    bls.s    pr_finevolumeslideup2
    move.w    d0,d1
pr_finevolumeslideup2:
    move.w    d1,12(a4)
    rts

pr_finevolumeslidedown:
    moveq    #$f,d0
    and.b    5(a4),d0
    move.w    12(a4),d1
    sub.w    d0,d1
    bpl.s    pr_finevolumeslidedown2
    moveq    #0,d1
pr_finevolumeslidedown2:
    move.w    d1,12(a4)
    rts

pr_fineslideup:
    moveq    #$f,d0
    and.b    5(a4),d0
    move.w    2(a4),d1
    sub.w    d0,d1
    cmp.w    #108,d1
    bge.s    pr_fineslideup2
    move.w    #108,d1
pr_fineslideup2:
    move.w    d1,2(a4)
    rts

pr_fineslidedown:
    moveq    #$f,d0
    and.b    5(a4),d0
    move.w    2(a4),d1
    add.w    d0,d1
    cmp.w    #907,d1
    bls.s    pr_fineslidedown2
    move.w    #907,d1
pr_fineslidedown2:
    move.w    d1,2(a4)
    rts

pr_setfilter:
    btst    #0,5(a4)
    beq.s    pr_setfilteron
pr_setfilteroff:
    bset    #1,$bfe001
    rts
pr_setfilteron:
    bclr    #1,$bfe001
    rts

pr_prepvibandvolslide:
    cmp.b    #1,pr_speed-pr_framecounter+1(a2)
    beq.s    pr_prepvibandvolslide2
    IFEQ    PACKEDSONGFORMAT-YES
    move.b    (a6),d1
    lsr.b    #1,d1
    ELSE
    tst.b    1(a6)
    ENDC
    beq.s    pr_prepvibandvolslide2
    clr.w    18(a4)
pr_prepvibandvolslide2:
    rts

pr_preptoneportamento:
    tst.b    5(a4)
    beq.s    pr_preptoneportamento2
    move.w    4(a4),22(a4)
pr_preptoneportamento2:
    rts

pr_prepvibrato:
    cmp.b    #1,pr_speed-pr_framecounter+1(a2)
    beq.s    pr_prepvibrato2
    IFEQ    PACKEDSONGFORMAT-YES
    move.b    (a6),d1
    lsr.b    #1,d1
    ELSE
    tst.b    1(a6)
    ENDC
    beq.s    pr_prepvibrato0
    clr.w    18(a4)
pr_prepvibrato0:
    move.b    5(a4),d0
    move.b    d0,d1
    lsr.b    #4,d1
    beq.s    pr_prepvibrato1
    move.b    d1,24(a4)
pr_prepvibrato1:
    and.b    #$f,d0
    beq.s    pr_prepvibrato2
    move.b    d0,25(a4)
pr_prepvibrato2:
    rts

pr_preptremolo:
    cmp.b    #1,pr_speed-pr_framecounter+1(a2)
    beq.s    pr_preptremolo2
    IFEQ    PACKEDSONGFORMAT-YES
    move.b    (a6),d1
    lsr.b    #1,d1
    ELSE
    tst.b    1(a6)
    ENDC
    beq.s    pr_preptremolo0
    clr.w    18(a4)
pr_preptremolo0:
    move.w    12(a4),20(a4)
    move.b    5(a4),d0
    move.b    d0,d1
    lsr.b    #4,d1
    beq.s    pr_preptremolo1
    move.b    d1,30(a4)
pr_preptremolo1:
    and.b    #$f,d0
    beq.s    pr_preptremolo2
    move.b    d0,31(a4)
pr_preptremolo2:
    rts

pr_newvolume:
    move.b    5(a4),d0
    cmp.b    #64,d0
    bls.s    pr_newvolumeend
    moveq    #64,d0
pr_newvolumeend:
    move.b    d0,13(a4)
    rts

pr_newspeed:
    move.b    5(a4),d0
    tst.b    d0
    bne.s    pr_newspeed2
    moveq    #1,d0
pr_newspeed2:
    move.b    d0,pr_speed-pr_framecounter+1(a2)
    rts

pr_patternbreak:
    moveq    #0,d0
    move.b    5(a4),d0
    add.w    #64,d0
    move.w    d0,pr_Patternct-pr_framecounter(a2)
    addq.w    #1,pr_patternhasbeenbreaked-pr_framecounter(a2)
    addq.w    #1,pr_dontcalcnewposition-pr_framecounter(a2)
    rts
        
pr_jumptopattern:
    moveq.l    #0,d0
    move.b    5(a4),d0
    subq.b    #1,d0
    bpl.s    pr_playjumptopattern2
    move.w    #128,d0
pr_playjumptopattern2:
    move.b    d0,pr_currentpattern-pr_framecounter+1(a2)
    lsl.l    #2,d0
    lea    pr_Patternpositions(pc),a0
    add.l    a0,d0
    move.l    d0,pr_Patternpt-pr_framecounter(a2)
    move.w    #64,pr_Patternct-pr_framecounter(a2)
    addq.w    #1,pr_patternhasbeenbreaked-pr_framecounter(a2)
    addq.w    #1,pr_dontcalcnewposition-pr_framecounter(a2)
    rts

* Control FX every frame **********************************************

pr_checkeffects:
    moveq    #1,d7
    lea    $a0(a5),a3
    lea    pr_Channel0(pc),a4
    move.w    12(a4),54(a4)
    pr_checkchannel
    IFEQ    INCLUDEFADINGROUTINE-YES
    move.w    54(a4),d0
    mulu.w    pr_musicfadect-pr_framecounter(a2),d0
    lsr.l    #FADINGSTEPS,d0
    move.w    d0,8(a3)
    ELSE
    move.w    54(a4),8(a3)
    ENDC
    
    moveq    #2,d7
    lea    $b0(a5),a3
    lea    pr_Channel1(pc),a4
    move.w    12(a4),54(a4)
    pr_checkchannel
    IFEQ    INCLUDEFADINGROUTINE-YES
    move.w    54(a4),d0
    mulu.w    pr_musicfadect-pr_framecounter(a2),d0
    lsr.l    #FADINGSTEPS,d0
    move.w    d0,8(a3)
    ELSE
    move.w    54(a4),8(a3)
    ENDC

;    moveq    #4,d7
;    lea    $c0(a5),a3
;    lea    pr_Channel2(pc),a4
;    move.w    12(a4),54(a4)
;    pr_checkchannel
;    IFEQ    INCLUDEFADINGROUTINE-YES
;    move.w    54(a4),d0
;    mulu.w    pr_musicfadect-pr_framecounter(a2),d0
;    lsr.l    #FADINGSTEPS,d0
;    move.w    d0,8(a3)
;    ELSE
;    move.w    54(a4),8(a3)
;    ENDC
;
;    moveq    #8,d7
;    lea    $d0(a5),a3
;    lea    pr_Channel3(pc),a4
;    move.w    12(a4),54(a4)
;    pr_checkchannel
;    IFEQ    INCLUDEFADINGROUTINE-YES
;    move.w    54(a4),d0
;    mulu.w    pr_musicfadect-pr_framecounter(a2),d0
;    lsr.l    #FADINGSTEPS,d0
;    move.w    d0,8(a3)
;    ELSE
;    move.w    54(a4),8(a3)
;    ENDC

    lea    pr_int(pc),a0
    move.l    pr_Vectorbasept(pc),a1
    move.l    a0,$78(a1)
    move.b    #$19,$bfde00
    rts

***********************************************************************

pr_checknotchannel:
    rts

pr_check_e_commands
    moveq    #0,d0
    move.b    5(a4),d0
    lsr.b    #3,d0
    bclr    #0,d0
    lea    pr_E_Command_checklist(pc),a0
    move.w    (a0,d0.w),d0
    jmp    (a0,d0.w)
    
pr_Effectchecklist:
    dc.w    pr_checkarpeggio-pr_Effectchecklist        ; 0
    dc.w    pr_checkperiodslideup-pr_Effectchecklist    ; 1
    dc.w    pr_checkperiodslidedown-pr_Effectchecklist    ; 2
    dc.w    pr_checktoneportamento-pr_Effectchecklist    ; 3
    dc.w    pr_checkvibrato-pr_Effectchecklist        ; 4
    dc.w    pr_checktpandvolslide-pr_Effectchecklist    ; 5
    dc.w    pr_checkvibandvolslide-pr_Effectchecklist    ; 6
    dc.w    pr_checktremolo-pr_Effectchecklist        ; 7
    dc.w    pr_checknotchannel-pr_Effectchecklist        ; 8
    dc.w    pr_checknotchannel-pr_Effectchecklist        ; 9
    dc.w    pr_checkvolumeslide-pr_Effectchecklist        ; A
    dc.w    pr_checknotchannel-pr_Effectchecklist        ; B
    dc.w    pr_checknotchannel-pr_Effectchecklist        ; C
    dc.w    pr_checknotchannel-pr_Effectchecklist        ; D
    dc.w    pr_check_e_commands-pr_Effectchecklist        ; E
    dc.w    pr_checknotchannel-pr_Effectchecklist        ; F

pr_E_Command_checklist:
    dc.w    pr_checknotchannel-pr_E_Command_checklist    ; 0
    dc.w    pr_checknotchannel-pr_E_Command_checklist    ; 1
    dc.w    pr_checknotchannel-pr_E_Command_checklist    ; 2
    dc.w    pr_checknotchannel-pr_E_Command_checklist    ; 3
    dc.w    pr_checknotchannel-pr_E_Command_checklist    ; 4
    dc.w    pr_checknotchannel-pr_E_Command_checklist    ; 5
    dc.w    pr_checknotchannel-pr_E_Command_checklist    ; 6
    dc.w    pr_checknotchannel-pr_E_Command_checklist    ; 7
    dc.w    pr_checknotchannel-pr_E_Command_checklist    ; 8
    dc.w    pr_checkretrignote-pr_E_Command_checklist    ; 9
    dc.w    pr_checknotchannel-pr_E_Command_checklist    ; A
    dc.w    pr_checknotchannel-pr_E_Command_checklist    ; B
    dc.w    pr_checknotecut-pr_E_Command_checklist        ; C
    dc.w    pr_checknotedelay-pr_E_Command_checklist    ; D
    dc.w    pr_checknotchannel-pr_E_Command_checklist    ; E
    dc.w    pr_checknotchannel-pr_E_Command_checklist    ; F

pr_prepfunkrepeat:
    moveq    #$f,d0
    and.b    5(a4),d0
    move.b    d0,33(a4)
    tst.b    d0
    bne.s    pr_checkfunkrepeat
    rts
pr_checkfunkrepeat:
    move.w    32(a4),d0
    beq.s    pr_checkfunkrepeatend
    lea    pr_FunkTable(pc),a0
    move.b    (a0,d0.w),d0
    move.b    35(a4),d1
    add.b    d0,d1
    bmi.s    pr_checkfunkrepeat2
    move.b    d1,35(a4)
    rts
pr_checkfunkrepeat2:
    clr.b    35(a4)

    move.l    36(a4),d0
    beq.s    pr_checkfunkrepeatend
    move.l    d0,d2
    moveq.l    #0,d1
    move.w    10(a4),d1
    add.l    d1,d0
    add.l    d1,d0
    move.l    40(a4),a0
    addq.l    #1,a0
    cmp.l    d0,a0
    blo.s    pr_checkfunkrepeatok
    move.l    d2,a0
pr_checkfunkrepeatok:
    move.l    a0,40(a4)
    moveq    #-1,d0
    sub.b    (a0),d0
    move.b    d0,(a0)
pr_checkfunkrepeatend:
    rts

pr_checknotedelay:
    move.w    18(a4),d1
    addq.w    #1,d1
    cmp.w    d0,d1
    bne.s    pr_checknotedelayend
pr_checknotedelay2:
    move.w    d7,$96(a5)
    or.w    d7,pr_dmacon-pr_framecounter(a2)
    moveq.l    #0,d0
    move.w    (a4),d0
    subq.w    #1,d0
    lsl.w    #5,d0
    lea    pr_Sampleinfos(pc),a0
    add.l    d0,a0
    move.w    2(a4),6(a3)
    move.l    (a0)+,(a3)        ; Setze Samplestart
    move.w    (a0)+,4(a3)        ; Setze Audiodatenlänge
    addq.l    #2,a0
    move.l    (a0)+,d2
    move.l    d2,6(a4)        ; Samplerepeatpoint eintragen
    tst.w    (a0)+
    beq.s    pr_checknotedelay3
    move.l    d2,36(a4)
    move.l    d2,40(a4)
pr_checknotedelay3:
    move.w    (a0)+,10(a4)        ; Samplerepeatlength eintragen
pr_checknotedelayend:
    move.w    d1,18(a4)
    rts

pr_checkretrignote:
    moveq    #$f,d0
    and.b    5(a4),d0
    move.w    18(a4),d1
    addq.w    #1,d1
    cmp.w    d0,d1
    bne.s    pr_checkretrignoteend
pr_checkretrignote2:
    moveq    #0,d1
    move.w    d7,$96(a5)
    or.w    d7,pr_dmacon-pr_framecounter(a2)
    move.w    (a4),d0
    subq.w    #1,d0
    lsl.w    #5,d0
    lea    pr_Sampleinfos(pc),a0
    move.l    (a0,d0.w),(a3)
    move.w    4(a0,d0.w),4(a3)
pr_checkretrignoteend:
    move.w    d1,18(a4)
    rts

pr_checknotecut:
    moveq    #$f,d0
    and.b    5(a4),d0
    addq.w    #1,18(a4)
    move.w    18(a4),d1
    cmp.w    d0,d1
    blt.s    pr_checknotecutend
    clr.w    12(a4)
    clr.w    54(a4)
pr_checknotecutend:
    rts

pr_checkarpeggio:
    tst.b    5(a4)
    bne.s    pr_checkarpeggio0
    rts
pr_checkarpeggio0:
    move.w    (a2),d0
    lea    pr_Arpeggiofastdivisionlist(pc),a1
    move.b    (a1,d0.w),d0
    beq.s    pr_checkarpeggio2
    cmp.b    #2,d0
    beq.s    pr_checkarpeggio1
    moveq    #0,d0
    move.b    5(a4),d0
    lsr.b    #4,d0
    bra.s    pr_checkarpeggio3
pr_checkarpeggio2:
    move.w    2(a4),6(a3)
    rts
pr_checkarpeggio1:
    moveq    #$f,d0
    and.b    5(a4),d0
pr_checkarpeggio3:
    asl.w    #1,d0
    move.w    (a4),d1
    lsl.w    #5,d1
    lea    pr_Sampleinfos+SAMPLEFINETUNEOFFSET(pc),a0
    move.l    (a0,d1.w),a0
    move.w    2(a4),d1
    lea    pr_Arpeggiofastlist(pc),a1
    moveq.l    #0,d2
    move.b    (a1,d1.w),d2
    add.b    d2,d2
    add.l    d2,a0
    moveq    #36,d7
pr_checkarpeggioloop:
    cmp.w    (a0)+,d1
    bhs.s    pr_checkarpeggio4
    dbf    d7,pr_checkarpeggioloop
    rts
pr_checkarpeggio4:
    subq.l    #2,a0
    move.w    (a0,d0.w),6(a3)
    rts

pr_checktpandvolslide:
    bsr.w    pr_checkvolumeslide
    moveq    #0,d2
    move.b    23(a4),d2
    move.w    26(a4),d0
    move.w    28(a4),d1
    bsr.s    pr_checktoneportamento2
    move.w    14(a4),26(a4)
    rts
    
pr_checktoneportamento:
    moveq    #0,d2
    move.b    5(a4),d2
    bne.s    pr_checktoneportamento1
    move.b    23(a4),d2
pr_checktoneportamento1:
    move.w    14(a4),d0
    move.w    16(a4),d1
pr_checktoneportamento2:
    cmp.w    d0,d1
    bgt.s    pr_checktoneportamentoplus
    blt.s    pr_checktoneportamentominus
    cmp.w    #1,(a2)
    beq.s    pr_savetpvalues
    rts
pr_checktoneportamentoplus:
    add.w    d2,d0
    cmp.w    d0,d1
    bgt.s    pr_checktoneportamentoend
    move.w    d1,d0
    move.w    d1,14(a4)
    move.w    d1,2(a4)
    tst.w    48(a4)
    bne.s    pr_checktoneportamentoglissando
    move.w    d1,6(a3)
    cmp.w    #1,(a2)
    beq.s    pr_savetpvalues
    rts
pr_checktoneportamentominus:
    sub.w    d2,d0
    cmp.w    d0,d1
    blt.s    pr_checktoneportamentoend
    move.w    d1,d0
    move.w    d1,14(a4)
    move.w    d1,2(a4)
    tst.w    48(a4)
    bne.s    pr_checktoneportamentoglissando
    move.w    d1,6(a3)
    cmp.w    #1,(a2)
    beq.s    pr_savetpvalues
    rts
pr_checktoneportamentoend:
    move.w    d0,14(a4)
    move.w    d0,2(a4)
    tst.w    48(a4)
    bne.s    pr_checktoneportamentoglissando
    move.w    d0,6(a3)
    cmp.w    #1,(a2)
    beq.s    pr_savetpvalues
    rts    
pr_savetpvalues:
    move.l    14(a4),26(a4)
    rts
pr_checktoneportamentoglissando:
    move.w    (a4),d1
    lsl.w    #5,d1
    lea    pr_Sampleinfos+SAMPLEFINETUNEOFFSET(pc),a0
    move.l    (a0,d1.w),a0
    lea    pr_Arpeggiofastlist(pc),a1
    moveq.l    #0,d2
    move.b    (a1,d0.w),d2
    add.w    d2,d2
    add.l    d2,a0
    moveq    #0,d3
    moveq    #36*2,d1
pr_checktoneportamentoglissandoloop:
    cmp.w    (a0,d3.w),d0
    bhs.s    pr_checktoneportamentoglissando2
    addq.w    #2,d3
    cmp.w    d1,d3
    blo.s    pr_checktoneportamentoglissandoloop
    moveq    #35*2,d3
pr_checktoneportamentoglissando2:
    move.w    (a0,d3.w),6(a3)
    cmp.w    #1,(a2)
    beq.s    pr_savetpvalues
    rts

pr_checkvolumeslide:
    moveq    #0,d0
    move.b    5(a4),d0
    move.w    d0,d1
    lsr.b    #4,d1
    beq.s    pr_checkvolumeslidedown
    move.w    12(a4),d2
    add.w    d1,d2
    bmi.s    pr_checkvolumeslide0
    moveq    #64,d0
    cmp.w    d0,d2
    bgt.s    pr_checkvolumeslide64
    move.w    d2,12(a4)
    move.w    d2,54(a4)
    rts
pr_checkvolumeslidedown:    
    and.b    #$f,d0
    move.w    12(a4),d2
    sub.w    d0,d2
    bmi.s    pr_checkvolumeslide0
    moveq    #64,d0
    cmp.w    d0,d2
    bgt.s    pr_checkvolumeslide64
    move.w    d2,12(a4)
    move.w    d2,54(a4)
    rts
pr_checkvolumeslide64:
    move.w    d0,12(a4)
    move.w    d0,54(a4)
    rts
pr_checkvolumeslide0:
    clr.w    12(a4)
    clr.w    54(a4)
    rts
    
pr_checkperiodslidedown:
    moveq    #0,d0
    move.b    5(a4),d0
    add.w    d0,2(a4)
    cmp.w    #907,2(a4)
    bls.s    pr_checkperiodslidedown2
    move.w    #907,2(a4)
pr_checkperiodslidedown2:
    move.w    2(a4),6(a3)
    rts

pr_checkperiodslideup:
    moveq    #0,d0
    move.b    5(a4),d0
    sub.w    d0,2(a4)
    cmp.w    #108,2(a4)
    bge.s    pr_checkperiodslideup2
    move.w    #108,2(a4)
pr_checkperiodslideup2:
    move.w    2(a4),6(a3)
    rts

pr_checkvibandvolslide:
    bsr.w    pr_checkvolumeslide
    moveq.l    #0,d0
    moveq.l    #0,d1
    move.b    25(a4),d0
    move.b    24(a4),d1
    bra.s    pr_checkvibrato4

pr_checkvibrato:
    moveq.l    #0,d0
    moveq.l    #0,d1
    move.b    5(a4),d0    ; Tiefe
pr_checkvibrato2:
    move.w    d0,d1        ; Geschwindigkeit
    and.w    #$f,d0
    bne.s    pr_checkvibrato3
    move.b    25(a4),d0
pr_checkvibrato3:
    lsr.b    #4,d1
    bne.s    pr_checkvibrato4
    move.b    24(a4),d1
pr_checkvibrato4:
    move.w    18(a4),d2    ;Position
    lsr.w    #2,d2
    and.w    #$1f,d2
    move.w    50(a4),d3
    beq.s    pr_checkvibratosine
    btst    #0,d3
    bne.s    pr_checkvibratorampdown
    move.b    #255,d3
    bra.s    pr_checkvibratoset
pr_checkvibratorampdown:
    lsl.b    #3,d2
    tst.b    19(a4)
    bmi.s    pr_checkvibratorampdown2
    move.b    #255,d3
    sub.b    d2,d3
    bra.s    pr_checkvibratoset
pr_checkvibratorampdown2:
    move.b    d2,d3
    bra.s    pr_checkvibratoset
pr_checkvibratosine:
    lea    pr_VibratoTable(pc),a0
    moveq    #0,d3
    move.b    (a0,d2.w),d3
pr_checkvibratoset:
    mulu.w    d0,d3
    lsr.w    #7,d3
    move.w    2(a4),d2
    tst.b    19(a4)
    bpl.s    pr_checkvibratoneg
    add.w    d3,d2
    bra.s    pr_checkvibrato5
pr_checkvibratoneg:
    sub.w    d3,d2
pr_checkvibrato5:
    move.w    d2,6(a3)
    lsl.w    #2,d1
    add.b    d1,19(a4)
    rts

pr_checktremolo:
    moveq    #0,d0
    moveq.l    #0,d1
    move.b    5(a4),d0    ; Tiefe
pr_checktremolo2:
    move.w    d0,d1        ; Geschwindigkeit
    and.w    #$f,d0
    bne.s    pr_checktremolo3
    move.b    31(a4),d0
pr_checktremolo3:
    lsr.b    #4,d1
    bne.s    pr_checktremolo4
    move.b    30(a4),d1
pr_checktremolo4:
    move.w    18(a4),d2    ;Position
    lsr.w    #2,d2
    and.w    #$1f,d2
    move.w    52(a4),d3
    beq.s    pr_checktremolosine
    btst    #0,d3
    bne.s    pr_checktremolorampdown
    move.b    #255,d3
    bra.s    pr_checktremoloset
pr_checktremolorampdown:
    lsl.b    #3,d2
    tst.b    19(a4)
    bmi.s    pr_checktremolorampdown2
    move.b    #255,d3
    sub.b    d2,d3
    bra.s    pr_checktremoloset
pr_checktremolorampdown2:
    move.b    d2,d3
    bra.s    pr_checktremoloset
pr_checktremolosine:
    lea    pr_VibratoTable(pc),a0
    moveq    #0,d3
    move.b    (a0,d2.w),d3
pr_checktremoloset:
    mulu.w    d0,d3
    lsr.w    #6,d3
    move.w    20(a4),d2
    tst.b    19(a4)
    bpl.s    pr_checktremoloneg
    add.w    d3,d2
    moveq    #64,d4
    cmp.w    d4,d2
    bls.s    pr_checktremolo5
    move.w    d4,d2
    bra.s    pr_checktremolo5
pr_checktremoloneg:
    sub.w    d3,d2
    bpl.s    pr_checktremolo5
    moveq    #0,d2
pr_checktremolo5:
    move.w    d2,54(a4)
    lsl.w    #2,d1
    add.b    d1,19(a4)
    rts

pr_VibratoTable:    
    dc.b    0,24,49,74,97,120,141,161
    dc.b    180,197,212,224,235,244,250,253
    dc.b    255,253,250,244,235,224,212,197
    dc.b    180,161,141,120,97,74,49,24
pr_FunkTable:
    dc.b    0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
    
* Variables ***********************************************************

pr_module:            dc.l    0
pr_startposition:        dc.w    0
pr_speed:            dc.w    6
pr_highestpattern:        dc.w    0
pr_currentpattern:        dc.w    0
pr_framecounter:        dc.w    0
pr_patterndelaytime:        dc.w    0
pr_patternhasbeenbreaked:    dc.w    0
pr_Patternpositions:        ds.l    128
pr_Patternpt:            dc.l    0
pr_Currentposition:        dc.l    0
pr_Patternct:            dc.w    0
pr_oldledvalue:            dc.w    0
pr_dontcalcnewposition:        dc.w    0
pr_commandnotedelay:        dc.w    0
pr_old78:            dc.l    0
pr_Vectorbasept:        dc.l    0
pr_Channel0:            dc.w    1
                ds.w    30
pr_Channel1:            dc.w    1
                ds.w    30
pr_Channel2:            dc.w    1
                ds.w    30
pr_Channel3:            dc.w    1
                ds.w    30
pr_dmacon:            dc.w    $8000

pr_Arpeggiofastlist:        ds.b    1000
pr_Arpeggiofastdivisionlist:    ds.b    $100
pr_fastperiodlist:        ds.l    16
pr_Sampleinfos:            ds.b    32*32

pr_periods:
; Tuning 0, Normal
    dc.w    856,808,762,720,678,640,604,570,538,508,480,453
    dc.w    428,404,381,360,339,320,302,285,269,254,240,226
    dc.w    214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
    dc.w    850,802,757,715,674,637,601,567,535,505,477,450
    dc.w    425,401,379,357,337,318,300,284,268,253,239,225
    dc.w    213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
    dc.w    844,796,752,709,670,632,597,563,532,502,474,447
    dc.w    422,398,376,355,335,316,298,282,266,251,237,224
    dc.w    211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
    dc.w    838,791,746,704,665,628,592,559,528,498,470,444
    dc.w    419,395,373,352,332,314,296,280,264,249,235,222
    dc.w    209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
    dc.w    832,785,741,699,660,623,588,555,524,495,467,441
    dc.w    416,392,370,350,330,312,294,278,262,247,233,220
    dc.w    208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
    dc.w    826,779,736,694,655,619,584,551,520,491,463,437
    dc.w    413,390,368,347,328,309,292,276,260,245,232,219
    dc.w    206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
    dc.w    820,774,730,689,651,614,580,547,516,487,460,434
    dc.w    410,387,365,345,325,307,290,274,258,244,230,217
    dc.w    205,193,183,172,163,154,145,137,129,122,115,109
pr_Arpeggiofastlistperiods:
; Tuning 7
    dc.w    814,768,725,684,646,610,575,543,513,484,457,431
    dc.w    407,384,363,342,323,305,288,272,256,242,228,216
    dc.w    204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
    dc.w    907,856,808,762,720,678,640,604,570,538,508,480
    dc.w    453,428,404,381,360,339,320,302,285,269,254,240
    dc.w    226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
    dc.w    900,850,802,757,715,675,636,601,567,535,505,477
    dc.w    450,425,401,379,357,337,318,300,284,268,253,238
    dc.w    225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
    dc.w    894,844,796,752,709,670,632,597,563,532,502,474
    dc.w    447,422,398,376,355,335,316,298,282,266,251,237
    dc.w    223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
    dc.w    887,838,791,746,704,665,628,592,559,528,498,470
    dc.w    444,419,395,373,352,332,314,296,280,264,249,235
    dc.w    222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
    dc.w    881,832,785,741,699,660,623,588,555,524,494,467
    dc.w    441,416,392,370,350,330,312,294,278,262,247,233
    dc.w    220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
    dc.w    875,826,779,736,694,655,619,584,551,520,491,463
    dc.w    437,413,390,368,347,328,309,292,276,260,245,232
    dc.w    219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
    dc.w    868,820,774,730,689,651,614,580,547,516,487,460
    dc.w    434,410,387,365,345,325,307,290,274,258,244,230
    dc.w    217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
    dc.w    862,814,768,725,684,646,610,575,543,513,484,457
    dc.w    431,407,384,363,342,323,305,288,272,256,242,228
    dc.w    216,203,192,181,171,161,152,144,136,128,121,114

* END OF PRORUNNER ***************************************************
;-------------------------------------------------
play_chan_4:
    move.l    hangi_sample,d0
    lea    _s_jump_table,a0
    mulu    #4,d0
    add.l    d0,a0
    move.l    (a0),a1
    jmp    (a1)
;-------------------------------------------------
play_chan_3:
    move.l    hangi_sample_2,d0
    lea    jump_table_2,a0
    mulu    #4,d0
    add.l    d0,a0
    move.l    (a0),a1
    jmp    (a1)
;--------------------------------------------------

_s_jump_table:
    dc.l    return
    dc.l    kapi_zili
    dc.l    skor_art


kapi_zili:
    move.l    #0,sample_no
    bsr    calc_chan_4
    rts

skor_art:
    move.l    #1,sample_no
    bsr    calc_chan_4
    rts
;---------------------------------------------------
jump_table_2:
    dc.l    return
    dc.l    geyir
    dc.l    tukur
    dc.l    vahsi

geyir:    
    move.l    #0,sample_no_2
    bsr    calc_chan_3
    rts
tukur:
    move.l    #1,sample_no_2
    bsr    calc_chan_3
    rts

vahsi:
    move.l    #2,sample_no_2
    bsr    calc_chan_3
    rts

;-------------------------------------------------
hangi_sample:    dc.l    0
hangi_sample_2:    dc.l    0
;-------------------------------------------------
Calc_chan_4:
    move.l    sample_no,d0
    lea    sample_name,a0
    lea    sample_len,a1
    lea    sample_per,a2
    lea    sample_vol,a3
    lea    sample_loop,a4
    lea    loopun_basi,a5
    mulu    #4,d0
    add.l    d0,a0
    add.l    d0,a1
    add.l    d0,a2
    add.l    d0,a3
    add.l    d0,a4
    add.l    d0,a5
    move.l    (a0),startptr1
    move.w    2(a1),lenghtptr1
    move.w    2(a2),periodptr1
    move.w    2(a3),volumeptr1
    move.w    2(a4),loopptr1
    move.l    (a5),loop_bas_ptr
    bsr    chan_4
    rts
;--------------------------------------------------
Calc_chan_3:
    move.l    sample_no_2,d0
    lea    sample_name2,a0
    lea    sample_len2,a1
    lea    sample_per2,a2
    lea    sample_vol2,a3
    lea    sample_loop2,a4
    mulu    #4,d0
    add.l    d0,a0
    add.l    d0,a1
    add.l    d0,a2
    add.l    d0,a3
    add.l    d0,a4
    move.l    (a0),startptr2
    move.w    2(a1),lenghtptr2
    move.w    2(a2),periodptr2
    move.w    2(a3),volumeptr2
    move.w    2(a4),loopptr2
    bsr    chan_3
    rts
;-------------------------------------------------
CHAN_4:    move.w    #8,$dff096
    move.l    startptr1,$dff0d0

    move.w    lenghtptr1,$dff0d4
    move.w    periodptr1,$dff0d6
    move.w    volumeptr1,$dff0d8

    move.w    #$8008,$dff096
    move.l    #1500,d0
.1:    dbra    d0,.1
    move.l    loop_bas_ptr,$dff0d0
    move.w    loopptr1,$dff0d4
    rts
;-------------------------------------
CHAN_3:    move.w    #4,$dff096
    move.l    startptr2,$dff0c0
    move.w    lenghtptr2,$dff0c4
    move.w    periodptr2,$dff0c6
    move.w    volumeptr2,$dff0c8
    move.w    #$8004,$dff096
    move.l    #1500,d0
.1:    dbra    d0,.1
    move.l    startptr2,$dff0c0
    move.w    loopptr2,$dff0c4
    rts
;----------------------------------------------------
sample_no:    dc.l    0
sample_no_2:    dc.l    0

startptr1:    dc.l    0
lenghtptr1:    dc.w    0
periodptr1:    dc.w    0
volumeptr1:    dc.w    0
loopptr1:    dc.w    0
loop_bas_ptr:    dc.l    0
;---------------------------
startptr2:    dc.l    0
lenghtptr2:    dc.w    0
periodptr2:    dc.w    0
volumeptr2:    dc.w    0
loopptr2:    dc.w    0
;---------------------------

SamPle_name:    dc.l    sample1,sample3
SampLe_len:    dc.l    1599,399
Sample_per:    dc.l    600,300
sample_vol:    dc.l    64,64
Sample_loop:    dc.l    1,1
loopun_basi:    dc.l    sample1,sample3


SamPle_name2:    dc.l    sample2,sample4,sample5
SampLe_len2:    dc.l    1510,2199,10802
Sample_per2:    dc.l    400,200,500
sample_vol2:    dc.l    64,64,64
Sample_loop2:    dc.l    1,1,1
;-------------------------------------------------
    section    public_datas,data         
;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
gfxname:dc.b    'graphics.library',0,0
gfxbase:dc.l    0
oldcop:    dc.l    0

nonactive:
    dc.l    scr2
flipscr:dc.l    scr1+[screen_length*0]
    dc.l    scr1+[screen_length*1]
    dc.l    scr1+[screen_length*2]
    dc.l    scr1+[screen_length*3]

flopscr:dc.l    scr2+[screen_length*0]
    dc.l    scr2+[screen_length*1]
    dc.l    scr2+[screen_length*2]
    dc.l    scr2+[screen_length*3]
ust_ekran:
    dc.l    scr3+[screen_lengthx*0]
    dc.l    scr3+[screen_lengthx*1]
    dc.l    scr3+[screen_lengthx*2]
    dc.l    scr3+[screen_lengthx*3]

;-------------------------------------------------
    section    chip_datas,data_c
;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
NEWCOPPER:
coplist:
    dc.w    $0100,$020 bit-plane control reg.
    dc.w    $0102,$0000        ; hor-scroll
    dc.w    $0104,$0000    ;$0040     sprite pri
    dc.w    $0106,$1000    ; set color pallette for 16 colors
    dc.w    $0108,$0000    ;114  modulo (odd)
    dc.w    $010a,$0000    ; modulo (even)
    dc.w    $008e,$2c81    ; screen size
    dc.w    $0090,$2cc1    ; screen size
    dc.w    $0092,$0038    ; h-start
    dc.w    $0094,$00d0    ; h-stop

Mouse:    dc.w    $120,0,$122,0
;--------------------------------------------------
tepe_p:    dc.w    $e0,$0,$e2,$0
    dc.w    $e4,$0,$e6,$0
    dc.w    $e8,$0,$ea,$0
    dc.w    $ec,$0,$ee,$0
    dc.w    $180,0
cop_t:    
    dc.w    $182,$0,$184,$0,$186,$0
    dc.w    $188,$0,$18a,$0,$18c,$0,$18e,$0
    dc.w    $190,$0,$192,$0,$194,$0,$196,$0
    dc.w    $198,$0,$19a,$0,$19c,$0,$19e,$0
    dc.w    $4907,$fffe,$0100,$4200
;-------------------------------------------------
    dc.w    $5707,$fffe,$0186,$fe0
    dc.w    $5807,$fffe,$0186,$b03
    dc.w    $5907,$fffe,$0186,$b15
    dc.w    $5a07,$fffe,$0186,$c16
    dc.w    $5b07,$fffe,$0186,$c27
    dc.w    $5c07,$fffe,$0186,$c29
    dc.w    $5d07,$fffe,$0186,$d3d
    dc.w    $5e07,$fffe,$0186,$d3a
    dc.w    $5f07,$fffe,$0186,$d4d
    dc.w    $6007,$fffe,$0186,$e5e
    dc.w    $6107,$fffe,$0186,$d5e
    dc.w    $6207,$fffe,$0186,$d6f
    dc.w    $6307,$fffe,$0186,$d7f
    dc.w    $6407,$fffe,$0186,$d7f
    dc.w    $6507,$fffe,$0186,$d7f
    dc.w    $6607,$fffe,$0186,$d7f
    dc.w    $6707,$fffe,$0186,$d7f
;-------------------------------------------------
    dc.w    $6b07,$fffe
    dc.w    $182,$0,$184,$0,$186,$0
    dc.w    $188,$0,$18a,$0,$18c,$0,$18e,$0
    dc.w    $190,$0,$192,$0,$194,$0,$196,$0
    dc.w    $198,$0,$19a,$0,$19c,$0,$19e,$0

    dc.w    $6d07,$fffe,$0100,$0600
    dc.w    $0100,$0600    ; bit-plane control reg.
    dc.w    $0102,$0000    ; hor-scroll
    dc.w    $0104,$0000    ;$0040     sprite pri
    dc.w    $0106,$1000    ; set color pallette for 16 colors

    dc.w    $0108,$0000    ; modulo (odd)
    dc.w    $010a,$0000    ; modulo (even)
    dc.w    $008e,$2c81    ; screen size
    dc.w    $0090,$2cc1    ; screen size
    dc.w    $0092,$0038    ; h-start
    dc.w    $0094,$00d0    ; h-stop

Plane_d:dc.w    $e0,$0000,$e2,$0000
    dc.w    $e8,$0000,$ea,$0000
    dc.w    $f0,$0000,$f2,$0000
    dc.w    $f8,$0000,$fa,$0000
Plane_u:dc.w    $e4,$0000,$e6,$0000
    dc.w    $ec,$0000,$ee,$0000
    dc.w    $f4,$0000,$f6,$0000
    dc.w    $fc,$0000,$fe,$0000
CoL_u:    dc.w    $0180,$0,$0182,$0,$0184,$0,$0186,$0     ;Plane-up
        dc.w    $0188,$0,$018A,$0,$018C,$0,$018E,$0
    dc.w    $0190,$0,$0192,$0,$0194,$0,$0196,$0
    dc.w    $0198,$0,$019A,$0,$019C,$0,$019E,$0
CoL_d:    dc.w    $01a0,$0,$01a2,$0,$01a4,$0,$01a6,$0     ;plane-Up
    dc.w    $01a8,$0,$01aA,$0,$01aC,$0,$01aE,$0
    dc.w    $01b0,$0,$01b2,$0,$01b4,$0,$01b6,$0
    dc.w    $01b8,$0,$01bA,$0,$01bC,$0,$01bE,$0
    dc.w    $6e07,$fffe,$0100,$0610

    dc.w    $e207,$fffe


CoL_d2:    dc.w    $01a0,$0,$01a2,$0,$01a4,$0,$01a6,$0     ;plane-Up
    dc.w    $01a8,$0,$01aA,$0,$01aC,$0,$01aE,$0
    dc.w    $01b0,$0,$01b2,$0,$01b4,$0,$01b6,$0
    dc.w    $01b8,$0,$01bA,$0,$01bC,$0,$01bE,$0





    dc.l    -2

sprite1:dc.l    0
;-------------------------------------------------
    incdir    dh1:real/raw/
back_ekran:    incbin    kapi_dur.raw
kApI:        incbin    kapi_acil_anim
bwalk:        incbin    pisa-walk.raw
btesti:        incbin    testi.raw
bdrink:        incbin    pisa-suic.raw
btukur:        incbin    pisa-sutukur.raw
bmorf:        incbin    pisa-morph.raw
font:        incbin    'sayilar.raw'
kafa:        incbin    'sadekafa.raw'

        incdir    dh1:real/mask/
mwalk:        incbin    pisa-walk.mask
mtesti:        incbin    testi.mask
mdrink:        incbin    pisa-suic.mask
mtukur:        incbin    pisa-sutukur.mask
mmorf:        incbin    pisa-morph.mask
    incdir    dh1:dino/
pr_data:incbin    mod.level-gecis
        incdir    dh1:real/samples/
sample1:    incbin    kapizili
sample2:    incbin    geyir
sample3:    incbin    skor-artisi
sample4:    incbin    z-tukurme
sample5:    incbin    z-dinazor.vahsi
    section    screens,bss_c
;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
scr1:    ds.b    screen_length*4
scr2:    ds.b    screen_length*4
bosscr:    ds.b    screen_length2*4
scr3:    ds.b    screen_lengthx*4
b_kafa:    ds.b    [32*34]*4
