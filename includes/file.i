oldopenlibrary  = -408
closelibrary    = -414
open            = -30
close           = -36
read            = -42
write           = -48
mode_old        = 1005
mode_new        = 1006

ld_load:macro
                move.l 4,a6
                lea _dosname(pc),a1
                jsr oldopenlibrary(a6)
                lea _dosbase(pc),a0
                move.l d0,(a0)
                move.l d0,a6
                move.l #filename1,d1
                move.l #mode_old,d2
                jsr open(a6)
                tst.l d0
                beq.b ld_closelib
                move.l _dosbase(pc),a6
                move.l d0,ds_filehandler
                move.l d0,d1
                move.l #ds_buffer,d2
                move.l #8,d3
                jsr read(a6)
                move.l _dosbase(pc),a6
                move.l ds_filehandler(pc),d1
                jsr close(a6)
ld_closelib
                move.l _dosbase(pc),a1
                jsr closelibrary(a6)
                move.l #0,d0
                rts
endm

ld_save:macro
                move.l 4,a6
                lea _dosname(pc),a1
                jsr oldopenlibrary(a6)
                lea _dosbase(pc),a0
                move.l d0,(a0)
                move.l d0,a6
                move.l #filename1,d1
                move.l #mode_new,d2
                jsr open(a6)
                tst.l d0
                beq.b ld_closelib2
                move.l _dosbase(pc),a6
                move.l d0,ds_filehandler
                move.l d0,d1
                move.l #ds_buffer,d2
                move.l #8,d3
                jsr    write(a6)
                move.l _dosbase(pc),a6
                move.l ds_filehandler(pc),d1
                jsr close(a6)
ld_closelib2
                move.l _dosbase(pc),a1
                jsr closelibrary(a6)
                move.l #0,d0
                rts
endm


ld_data:macro
    _dosbase:       dc.l 0
    _dosname:       dc.b 'dos.library',0
    ds_filehandler: dc.l 0            ;reserved
    filename:       dc.l filename1    ;filename pointer
    ds_buffer:      dc.l 0,0
    filename1:      dc.b 's:DINO-II.data',0,0
endm
