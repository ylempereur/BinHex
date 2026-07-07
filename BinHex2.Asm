;SAVE"BinHex2.Asm"
*--------------------------------
         LIST    OFF
*--------------------------------
         INCLUDE ":Sources:Library.Asm"
         INCLUDE ":Sources:Equates.Asm"
*--------------------------------
TypTxt   EQU     $54455854
Creat    EQU     $20202020
Good     EQU     0
Copy     EQU     1
fType    EQU     2
vRefNum  EQU     6
version  EQU     8
fName    EQU     10
*--------------------------------
         GLOBAL  9482
;
VARB             DEFS 0
OutBuf           DEFS 8192
DstBuf           DEFS 522
InBuf            DEFS 256
PARABLK          DEFS 80
SFRGet           DEFS 74
SFRPut           DEFS 74
EventRecord      DEFS 0
What             DEFS W
Message          DEFS L
When             DEFS L
Where            DEFS L
Modify           DEFS W
SaveSP           DEFS L
WWindow          DEFS L
Menu             DEFS W
MenuItm          DEFS W
DialPtr          DEFS L
ItmHit           DEFS W
Src.IO           DEFS W
Dst.IO           DEFS W
ResLen           DEFS L
DatLen           DEFS L
Type             DEFS L
Creator          DEFS L
Flags            DEFS W
PutPtr           DEFS L
LEN              DEFS L
CRC              DEFS W
ChkSum           DEFS B
CHR1             DEFS B
CHR4             DEFS L
F.Src            DEFS B
F.Dst            DEFS B
F.filter         DEFS B
F.LF             DEFS B
F.Comp           DEFS B
F.NewF           DEFS B
                 DEFS *&1
;
                 DEFS grafSize
;
         ENDG
*--------------------------------
         TFILE   "Buffer.Bin"
*--------------------------------
         RFILE   "BinHex2",APPL,BNHX,$2000
*================================
         SEG     0,resPurgeable!resPreLoad,Var.Len,32
SEG0
SEG_1    JP      Start,1
END_1
END0
         ENDR
*================================
         SEG     1,resLocked!resPreLoad
*--------------------------------
Start    BSR     CLRVAR
         PEA     -4(A5)
         _InitGraf
         _InitFonts
         _InitWindows
         _InitMenus
         CLR.L   -(SP)
         _InitDialogs
         BSR     SetMenu
         MOVE.L  #$0000FFFF,D0
         _FlushEvents
         MOVE    #2,-(SP)
         _Pack2
         MOVE    #3,-(SP)
         _CouldDialog
         MOVE    #4,-(SP)
         _CouldDialog
         MOVE.B  #1,F.filter(A5)
         MOVE.B  #1,F.NewF(A5)
         _InitCursor
         MOVE.L  A7,SaveSP(A5)
LOOP     _SystemTask
         CLR.B   -(SP)
         MOVE    #-1,-(SP)
         PEA     EventRecord(A5)
         _GetNextEvent
         MOVE.B  (SP)+,D0
         BEQ.S   LOOP
         MOVE    What(A5),D0
         ADD     D0,D0
         MOVE    ETable(PC,D0),D0
         JMP     ETable(PC,D0)
ETable   DATA    /LOOP-ETable    ; null
         DATA    /MSEDWN-ETable  ; mouse down
         DATA    /LOOP-ETable    ; mouse up
         DATA    /KEYDWN-ETable  ; key down
         DATA    /LOOP-ETable    ; key up
         DATA    /LOOP-ETable    ; auto-key
         DATA    /LOOP-ETable    ; update
         DATA    /DSKINS-ETable  ; disk inserted
         DATA    /LOOP-ETable    ; activate
         DATA    /LOOP-ETable    ; abort
         DATA    /LOOP-ETable    ; network
         DATA    /LOOP-ETable    ; I/O driver
KEYDWN   MOVE    Modify(A5),D0
         BTST    #8,D0
         BEQ     LOOP
         CLR.L   -(SP)
         MOVE.L  Message(A5),D0
         MOVE    D0,-(SP)
         _MenuKey
         MOVE.L  (SP)+,D0
         BRA     FUNCTION
MSEDWN   CLR     -(SP)
         MOVE.L  Where(A5),-(SP)
         PEA     WWindow(A5)
         _FindWindow
         MOVE    (SP)+,D0
         ADD     D0,D0
         MOVE    WTable(PC,D0),D0
         JMP     WTable(PC,D0)
WTable   DATA    /LOOP-WTable    ; inDesk
         DATA    /INMENU-WTable  ; inMenuBar
         DATA    /SYSEVN-WTable  ; inSysWindow
         DATA    /LOOP-WTable    ; inContent
         DATA    /LOOP-WTable    ; inDrag
         DATA    /LOOP-WTable    ; inGrow
         DATA    /LOOP-WTable    ; inGoAway
INMENU   CLR.L   -(SP)
         MOVE.L  Where(A5),-(SP)
         _MenuSelect
         MOVE.L  (SP)+,D0
FUNCTION MOVE.L  D0,Menu(A5)
         MOVE    Menu(A5),D0
         ADD     D0,D0
         MOVE    MTable(PC,D0),D0
         JMP     MTable(PC,D0)
MTable   DATA    /MNUOUT-MTable  ; Outside
         DATA    /MNAPLE-MTable  ; Apple
         DATA    /MNFILE-MTable  ; File
MNUOUT   CLR     -(SP)
         _HiliteMenu
         BRA     LOOP
MNAPLE   MOVE    MenuItm(A5),D0
         CMP     #1,D0
         BNE.S   DSKACC
LOGO     CLR.L   -(SP)
         MOVE    #1,-(SP)
         CLR.L   -(SP)
         MOVE.L  #-1,-(SP)
         _GetNewDialog
         MOVE.L  (SP),DialPtr(A5)
         _ShowWindow
.0       CLR.L   -(SP)
         PEA     ItmHit(A5)
         _ModalDialog
         MOVE    ItmHit(A5),D0
         CMP     #1,D0
         BNE.S   .0
         MOVE.L  DialPtr(A5),-(SP)
         _DisposDialog
         BRA     MNUOUT
DSKACC   CLR.L   -(SP)
         MOVE    #1,-(SP)
         _GetMHandle
         MOVE    MenuItm(A5),-(SP)
         PEA     InBuf(A5)
         _GetItem
         CLR     -(SP)
         PEA     InBuf(A5)
         _OpenDeskAcc
         MOVE    (SP)+,D0
         BRA     MNUOUT
MNFILE   MOVE    MenuItm(A5),D0
         ADD     D0,D0
         MOVE    ITable(PC,D0),D0
         JMP     ITable(PC,D0)
ITable   DATA    /MNUOUT-ITable
         DATA    /APPUPL-ITable  ; Appl -> Upl
         DATA    /UPLAPP-ITable  ; Upl -> Appl
         DATA    /MNUOUT-ITable  ; -----------
         DATA    /Filter-ITable  ; TEXT filter
         DATA    /MNUOUT-ITable  ; -----------
         DATA    /Cmprsd-ITable  ; Compressed
         DATA    /LineFd-ITable  ; line feeds
         DATA    /MNUOUT-ITable  ; -----------
         DATA    /QUIT-ITable    ; Quit
Filter   EOR.B   #1,F.filter(A5)
         CLR.L   -(SP)
         MOVE    #2,-(SP)
         _GetMHandle
         MOVE    #4,-(SP)
         MOVE.B  F.filter(A5),-(SP)
         _CheckItem
         BRA     MNUOUT
Cmprsd   EOR.B   #1,F.NewF(A5)
         CLR.L   -(SP)
         MOVE    #2,-(SP)
         _GetMHandle
         MOVE    #6,-(SP)
         MOVE.B  F.NewF(A5),-(SP)
         _CheckItem
         BRA     MNUOUT
LineFd   EOR.B   #1,F.LF(A5)
         CLR.L   -(SP)
         MOVE    #2,-(SP)
         _GetMHandle
         MOVE    #7,-(SP)
         MOVE.B  F.LF(A5),-(SP)
         _CheckItem
         BRA     MNUOUT
QUIT     _ExitToShell
SYSEVN   PEA     EventRecord(A5)
         MOVE.L  WWindow(A5),-(SP)
         _SystemClick
         BRA     LOOP
DSKINS   MOVE    Message(A5),D0
         BEQ     LOOP
         CLR     -(SP)
         MOVE    #100,-(SP)
         MOVE    #100,-(SP)
         MOVE.L  Message(A5),-(SP)
         MOVE    #0,-(SP)
         _Pack2
         MOVE    (SP)+,D0
         BRA     LOOP
*--------------------------------
APPUPL   MOVE    #70,-(SP)
         MOVE    #70,-(SP)
         PEA     NullStr(PC)
         CLR.L   -(SP)
         MOVE    #-1,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         PEA     SFRGet(A5)
         MOVE    #2,-(SP)
         _Pack3
         TST.B   SFRGet+Good(A5)
         BEQ     MNUOUT
         MOVE    #70,-(SP)
         MOVE    #70,-(SP)
         PEA     Prompt(PC)
         PEA     NullStr(PC)
         CLR.L   -(SP)
         PEA     SFRPut(A5)
         MOVE    #1,-(SP)
         _Pack3
         TST.B   SFRPut+Good(A5)
         BEQ     MNUOUT
         LEA     SFRPut(A5),A4
         BSR     DELTF
         BSR     CREATEF
         BSR     GETINFO
         MOVE.L  #TypTxt,32(A0)
         MOVE.L  #Creat,36(A0)
         _SetFileInfo
         MOVE    16(A0),D7
         BNE     DOSERR
         MOVEQ   #2,D0
         LEA     SFRPut(A5),A4
         LEA     DstBuf(A5),A2
         BSR     OPEND
         MOVE    D0,Dst.IO(A5)
         MOVE.B  #1,F.Dst(A5)
         TST     D7
         BNE     DOSERR
         BSR     INIBUF
         LEA     SFRGet(A5),A4
         BSR     GETINFO
         MOVE.L  32(A0),Type(A5)
         MOVE.L  36(A0),Creator(A5)
         MOVE    40(A0),D0
         AND     #$F000,D0
         MOVE    D0,Flags(A5)
         MOVE.L  64(A0),ResLen(A5)
         MOVE.L  54(A0),DatLen(A5)
         BSR     HEADER
         TST.B   F.NewF(A5)
         BEQ.S   .0
         LEA     COMP(PC),A0
         BSR     SAVSTR
.0       BSR     DISP3
         CLR     CRC(A5)
         CLR.B   ChkSum(A5)
.1       MOVE    #10,-(SP)
         MOVE    #70,-(SP)
         _MoveTo
         TST.L   ResLen(A5)
         BEQ.S   .2
         CLR.L   ResLen(A5)
         PEA     SFRPut+fName(A5)
         _DrawString
         PEA     D1L5(PC)
         _DrawString
         LEA     RESF(PC),A0
         BSR     SAVSTR
         MOVEQ   #1,D0
         LEA     SFRGet(A5),A4
         LEA     0,A2
         BSR     OPENR
         BRA.S   .3
.2       TST.L   DatLen(A5)
         BEQ.S   .6
         CLR.L   DatLen(A5)
         PEA     SFRPut+fName(A5)
         _DrawString
         PEA     D1L4(PC)
         _DrawString
         LEA     DATF(PC),A0
         BSR     SAVSTR
         MOVEQ   #1,D0
         LEA     SFRGet(A5),A4
         LEA     0,A2
         BSR     OPEND
.3       MOVE    D0,Src.IO(A5)
         MOVE.B  #1,F.Src(A5)
         TST     D7
         BNE     DOSERR
.4       BSR     RD1BLK
         TST.B   InBuf(A5)
         BEQ.S   .5
         BSR     CONVBH
         BRA.S   .4
.5       LEA     EOD(PC),A0
         BSR     SAVSTR
         LEA     SFRGet(A5),A4
         MOVE    Src.IO(A5),D0
         BSR     CLOSEF
         CLR.B   F.Src(A5)
         BRA     .1
.6       TST.B   F.NewF(A5)
         BNE.S   .7
         LEA     CHECK(PC),A0
         BSR     SAVASC
         MOVE.B  ChkSum(A5),D0
         BSR     SavByte
         BRA.S   .8
.7       LEA     SCRC(PC),A0
         BSR     SAVASC
         MOVE    CRC(A5),D0
         BSR     SavWord
.8       BSR     PutCR
         BSR     SAVBUF
         LEA     SFRPut(A5),A4
         MOVE    Dst.IO(A5),D0
         BSR     CLOSEF
         CLR.B   F.Dst(A5)
         MOVE.L  WWindow(A5),-(SP)
         _DisposWindow
         CLR.L   -(SP)
         MOVE    #3,-(SP)
         CLR.L   -(SP)
         MOVE.L  #-1,-(SP)
         _GetNewDialog
         MOVE.L  (SP),DialPtr(A5)
         _ShowWindow
.9       CLR.L   -(SP)
         PEA     ItmHit(A5)
         _ModalDialog
         MOVE    ItmHit(A5),D0
         CMP     #1,D0
         BNE.S   .9
         MOVE.L  DialPtr(A5),-(SP)
         _DisposDialog
         BRA     MNUOUT
CONVBH   LEA     InBuf(A5),A0
         CLR     D1
         MOVE.B  (A0)+,D1
         TST.B   F.NewF(A5)
         BEQ.S   .2
         CLR.B   D7
         MOVE.B  D1,D0
         BSR     PutCByte
         BRA.S   .2
.0       CLR     D0
         MOVE.B  (A0)+,D0
         ADD.B   D0,ChkSum(A5)
         MOVE    CRC(A5),D2
         ADD     D0,D2
         ROL     #3,D2
         MOVE    D2,CRC(A5)
         TST.B   F.NewF(A5)
         BNE.S   .1
         BSR     SavByte
         BRA.S   .2
.1       BSR     PutCByte
.2       DBRA    D1,.0
         TST.B   F.NewF(A5)
         BEQ.S   .3
         BSR     SavCByte
.3       BRA.S   PutCR
PutCByte MOVEQ   #8-1,D2
.0       CMP.B   #6,D7
         BNE.S   .1
         AND.B   #$3F,D6
         ADD.B   #$20,D6
         EXG     D0,D6
         BSR     PutByte
         EXG     D0,D6
         CLR.B   D7
.1       ROXL.B  #1,D0
         ROXL.B  #1,D6
         ADDQ.B  #1,D7
         DBRA    D2,.0
         RTS
SavCByte TST.B   D7
         BEQ.S   .2
.0       CMP.B   #6,D7
         BEQ.S   .1
         LSL.B   #1,D6
         ADDQ.B  #1,D7
         BRA.S   .0
.1       AND.B   #$3F,D6
         ADD.B   #$20,D6
         MOVE.B  D6,D0
         BSR     PutByte
.2       RTS
SAVSTR   BSR     SAVASC
PutCR    MOVEQ   #$0D,D0
         BSR     PutByte
         TST.B   F.LF(A5)
         BEQ.S   .0
         MOVEQ   #$0A,D0
         BSR     PutByte
.0       RTS
SAVASC   CLR     D1
         MOVE.B  (A0)+,D1
         BRA.S   .1
.0       MOVE.B  (A0)+,D0
         BSR     PutByte
.1       DBRA    D1,.0
         RTS
HEADER   LEA     HDR(PC),A0
         BSR     SAVSTR
         MOVEQ   #'#,D0
         BSR     PutByte
         MOVE.L  Type(A5),D0
         BSR     PUT4C
         MOVE.L  Creator(A5),D0
         BSR     PUT4C
         MOVEQ   #'$,D0
         BSR     PutByte
         MOVE    Flags(A5),D0
         BSR     SavWord
         BRA     PutCR
PUT4C    MOVEQ   #4-1,D1
.0       ROL.L   #8,D0
         BSR     PutByte
         DBRA    D1,.0
         RTS
SavWord  MOVE    D0,-(SP)
         LSR     #8,D0
         BSR     SavByte
         MOVE    (SP)+,D0
SavByte  MOVE.B  D0,-(SP)
         LSR.B   #4,D0
         BSR     SavDigit
         MOVE.B  (SP)+,D0
SavDigit BSR     HEXDGT
         BRA     PutByte
RD1BLK   LEA     PARABLK(A5),A0
         CLR.L   12(A0)
         MOVE    Src.IO(A5),24(A0)
         LEA     InBuf+1(A5),A1
         MOVE.L  A1,32(A0)
         MOVE.L  #32,36(A0)
         CLR     44(A0)
         CLR.L   46(A0)
         _Read
         MOVE    16(A0),D7
         BEQ.S   .0
         CMP     #-39,D7
         BNE     DOSERR
.0       MOVE.B  43(A0),InBuf(A5)
         RTS
*--------------------------------
UPLAPP   MOVE    #70,-(SP)
         MOVE    #70,-(SP)
         PEA     NullStr(PC)
         CLR.L   -(SP)
         TST.B   F.filter(A5)
         BNE.S   .0
         MOVE    #-1,-(SP)
         CLR.L   -(SP)
         BRA.S   .1
.0       MOVE    #1,-(SP)
         PEA     TypeList(PC)
.1       CLR.L   -(SP)
         PEA     SFRGet(A5)
         MOVE    #2,-(SP)
         _Pack3
         TST.B   SFRGet+Good(A5)
         BEQ     MNUOUT
         MOVE    #70,-(SP)
         MOVE    #70,-(SP)
         PEA     Prompt(PC)
         PEA     NullStr(PC)
         CLR.L   -(SP)
         PEA     SFRPut(A5)
         MOVE    #1,-(SP)
         _Pack3
         TST.B   SFRPut+Good(A5)
         BEQ     MNUOUT
         LEA     SFRGet(A5),A4
         BSR     GETINFO
         MOVEQ   #1,D0
         LEA     0,A2
         BSR     OPEND
         MOVE    D0,Src.IO(A5)
         MOVE.B  #1,F.Src(A5)
         TST     D7
         BNE     DOSERR
         CLR.B   F.Comp(A5)
         MOVE.L  #TypTxt,Type(A5)
         MOVE.L  #Creat,Creator(A5)
         CLR     Flags(A5)
         CLR     CRC(A5)
         CLR.B   ChkSum(A5)
.2       BSR     RD1LINE
         CLR     D1
         LEA     InBuf(A5),A0
         MOVE.B  (A0)+,D1
         BEQ     .20
         BRA.S   .4
.3       CMP.B   #'#,(A0)+
         BEQ.S   .5
.4       DBRA    D1,.3
         BRA.S   .2
.5       CMP     #8,D1
         BLO.S   .6
         BSR     GET4C
         MOVE.L  D0,Type(A5)
         BSR     GET4C
         MOVE.L  D0,Creator(A5)
         CMP     #5,D1
         BLO.S   .6
         CMP.B   #'$,(A0)+
         BNE.S   .6
         BSR     GETWORD
         BCS.S   .6
         MOVE    D0,Flags(A5)
.6       BSR     DISP1
         LEA     SFRPut(A5),A4
         BSR     DELTF
         BSR     CREATEF
         BSR     GETINFO
         MOVE.L  Type(A5),32(A0)
         MOVE.L  Creator(A5),36(A0)
         MOVE    Flags(A5),D0
         OR      D0,40(A0)
         _SetFileInfo
         MOVE    16(A0),D7
         BNE     DOSERR
         BSR     RD1LINE
         LEA     COMP(PC),A1
         BSR     COMPARE
         BNE.S   .7
         MOVE.B  #1,F.Comp(A5)
         BSR     RD1LINE
.7       MOVE    #10,-(SP)
         MOVE    #70,-(SP)
         _MoveTo
         PEA     SFRPut+fName(A5)
         _DrawString
         LEA     DATF(PC),A1
         BSR     COMPARE
         BNE.S   .8
         PEA     D1L4(PC)
         _DrawString
         BSR     RD1LINE
         BRA.S   .9
.8       LEA     RESF(PC),A1
         BSR     COMPARE
         BNE.S   .9
         PEA     D1L5(PC)
         _DrawString
         BSR     RD1LINE
         MOVEQ   #2,D0
         LEA     SFRPut(A5),A4
         LEA     DstBuf(A5),A2
         BSR     OPENR
         BRA.S   .10
.9       MOVEQ   #2,D0
         LEA     SFRPut(A5),A4
         LEA     DstBuf(A5),A2
         BSR     OPEND
.10      MOVE    D0,Dst.IO(A5)
         MOVE.B  #1,F.Dst(A5)
         TST     D7
         BNE     DOSERR
         BSR     MoveToEOF
         BSR     INIBUF
         BRA.S   .12
.11      BSR     RD1LINE
.12      TST.B   InBuf(A5)
         BEQ.S   .14
         LEA     STARS(PC),A1
         BSR     COMPARE
         BEQ.S   .13
         BSR     CONVHB
         BRA.S   .11
.13      LEA     EOD(PC),A1
         BSR     COMPARE
         BNE.S   .14
         BSR     RD1LINE
.14      BSR     SAVBUF
         LEA     SFRPut(A5),A4
         MOVE    Dst.IO(A5),D0
         BSR     CLOSEF
         CLR.B   F.Dst(A5)
         LEA     DATF(PC),A1
         BSR     COMPARE
         BEQ     .7
         LEA     RESF(PC),A1
         BSR     COMPARE
         BEQ     .7
         LEA     SFRGet(A5),A4
         MOVE    Src.IO(A5),D0
         BSR     CLOSEF
         CLR.B   F.Src(A5)
         MOVE.L  WWindow(A5),-(SP)
         _DisposWindow
         CLR.L   -(SP)
         MOVE    #4,-(SP)
         CLR.L   -(SP)
         MOVE.L  #-1,-(SP)
         _GetNewDialog
         MOVE.L  (SP)+,DialPtr(A5)
         LEA     CHECK(PC),A1
         BSR     COMPARE
         BNE.S   .15
         LEA     D2L3(PC),A1
         MOVE.B  (A0)+,19(A1)
         MOVE.B  (A0)+,20(A1)
         BRA.S   .17
.15      LEA     SCRC(PC),A1
         BSR     COMPARE
         BNE.S   .16
         LEA     D2L2(PC),A1
         MOVE.B  (A0)+,14(A1)
         MOVE.B  (A0)+,15(A1)
         MOVE.B  (A0)+,16(A1)
         MOVE.B  (A0)+,17(A1)
         LEA     D2L5(PC),A2
         LEA     17(A2),A3
         MOVE    CRC(A5),D0
         BSR     DSPWORD
         BRA.S   .18
.16      LEA     D2L4(PC),A1
.17      LEA     D2L6(PC),A2
         LEA     22(A2),A3
         MOVE.B  ChkSum(A5),D0
         BSR     DSPBYTE
.18      MOVE.L  A1,-(SP)
         MOVE.L  A2,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         _ParamText
         MOVE.L  DialPtr(A5),-(SP)
         _ShowWindow
.19      CLR.L   -(SP)
         PEA     ItmHit(A5)
         _ModalDialog
         MOVE    ItmHit(A5),D0
         CMP     #1,D0
         BNE.S   .19
         MOVE.L  DialPtr(A5),-(SP)
         _DisposDialog
         BRA     MNUOUT
.20      LEA     SFRGet(A5),A4
         MOVE    Src.IO(A5),D0
         BSR     CLOSEF
         CLR.B   F.Src(A5)
         BRA     MNUOUT
CONVHB   BSR     LINSTR
         TST.B   F.Comp(A5)
         BNE.S   .1
.0       CMP.B   #2,D1
         BLO.S   .3
         CLR     D0
         BSR     GETBYTE
         BCS.S   .3
         ADD.B   D0,ChkSum(A5)
         MOVE    CRC(A5),D2
         ADD     D0,D2
         ROL     #3,D2
         MOVE    D2,CRC(A5)
         BSR     PutByte
         BRA.S   .0
.1       CLR.B   D7
         BSR     GetCByte
         BCS.S   .3
         MOVE    D0,D1
         BRA.S   .4
.2       BSR     GetCByte
         BCS.S   .3
         ADD.B   D0,ChkSum(A5)
         MOVE    CRC(A5),D2
         ADD     D0,D2
         ROL     #3,D2
         MOVE    D2,CRC(A5)
         BSR     PutByte
.4       DBRA    D1,.2
.3       RTS
GetCByte MOVEQ   #8-1,D2
.0       TST.B   D7
         BNE.S   .2
         MOVE.B  (A0)+,D6
         SUB.B   #$20,D6
         CMP.B   #$40,D6
         BLO.S   .1
         OR      #1,CCR
         RTS
.1       LSL.B   #2,D6
         MOVEQ   #6,D7
.2       ROXL.B  #1,D6
         ROXL.B  #1,D0
         SUBQ.B  #1,D7
         DBRA    D2,.0
         AND     #$FE,CCR
         RTS
PutByte  MOVE.L  PutPtr(A5),A1
         MOVE.B  D0,(A1)+
         MOVE.L  A1,PutPtr(A5)
         ADDQ.L  #1,LEN(A5)
         CMP.L   #8192,LEN(A5)
         BHS.S   SAVBUF
         RTS
SAVBUF   MOVEM.L D0-D1/D6-D7/A0,-(SP)
         LEA     PARABLK(A5),A0
         CLR.L   12(A0)
         MOVE    Dst.IO(A5),24(A0)
         LEA     OutBuf(A5),A1
         MOVE.L  A1,32(A0)
         MOVE.L  LEN(A5),36(A0)
         CLR     44(A0)
         CLR.L   46(A0)
         _Write
         MOVE    16(A0),D7
         BNE     DOSERR
         MOVEM.L (SP)+,D0-D1/D6-D7/A0
INIBUF   LEA     OutBuf(A5),A1
         MOVE.L  A1,PutPtr(A5)
         CLR.L   LEN(A5)
         RTS
GET4C    MOVEQ   #4-1,D2
.0       LSL.L   #8,D0
         MOVE.B  (A0)+,D0
         SUBQ    #1,D1
         DBRA    D2,.0
         RTS
GETWORD  BSR.L   GETBYTE
GETBYTE  BSR.L   GETDIGIT
GETDIGIT MOVE.B  (A0)+,D2
         SUBQ    #1,D1
         EOR.B   #$30,D2
         CMP.B   #10,D2
         BLO.S   .0
         ADD.B   #$89,D2
         CMP.B   #$FA,D2
         BLO.S   .1
.0       AND.B   #$0F,D2
         LSL     #4,D0
         OR.B    D2,D0
         AND     #$FE,CCR
.1       RTS
DSPWORD  MOVE    D0,-(SP)
         LSR     #8,D0
         BSR.S   DSPBYTE
         MOVE    (SP)+,D0
DSPBYTE  MOVE.B  D0,-(SP)
         LSR.B   #4,D0
         BSR.S   DSPDIGIT
         MOVE.B  (SP)+,D0
DSPDIGIT BSR.S   HEXDGT
         MOVE.B  D0,(A3)+
         RTS
HEXDGT   AND.B   #$0F,D0
         OR.B    #$30,D0
         CMP.B   #$3A,D0
         BLO.S   .0
         ADDQ.B  #7,D0
.0       RTS
LINSTR   LEA     InBuf(A5),A0
         MOVE.B  (A0)+,D1
         BEQ.S   .1
.0       CMP.B   #$0A,(A0)
         BNE.S   .1
         ADDQ.L  #1,A0
         SUBQ.B  #1,D1
         BNE.S   .0
.1       RTS
COMPARE  BSR     LINSTR
         CLR     D2
         MOVE.B  (A1)+,D2
         CMP.B   D2,D1
         BLO.S   .2
         BRA.S   .1
.0       CMP.B   (A0)+,(A1)+
         BNE.S   .2
.1       DBRA    D2,.0
         CLR     D0
.2       RTS
OPNWND   CLR.L   -(SP)
         MOVE    #1,-(SP)
         CLR.L   -(SP)
         MOVE.L  #-1,-(SP)
         _GetNewWindow
         MOVE.L  (SP),WWindow(A5)
         _SetPort
         MOVE    #0,-(SP)
         _TextFont
         MOVE    #12,-(SP)
         _TextSize
         MOVE    #0,-(SP)
         _TextFace
         MOVE    #0,-(SP)
         _TextMode
         RTS
DISP1    BSR     OPNWND
         MOVE    #10,-(SP)
         MOVE    #22,-(SP)
         _MoveTo
         PEA     D1L1(PC)
         _DrawString
         MOVE.B  #4,CHR1(A5)
         MOVE.L  Type(A5),CHR4(A5)
         PEA     CHR1(A5)
         _DrawString
         MOVE    #10,-(SP)
         MOVE    #38,-(SP)
         _MoveTo
         PEA     D1L2(PC)
         _DrawString
         MOVE.L  Creator(A5),CHR4(A5)
         PEA     CHR1(A5)
         _DrawString
         MOVE    #10,-(SP)
         MOVE    #102,-(SP)
         _MoveTo
         PEA     D1L3(PC)
         _DrawString
         RTS
DISP3    BSR     OPNWND
         MOVE    #10,-(SP)
         MOVE    #22,-(SP)
         _MoveTo
         PEA     D3L1(PC)
         _DrawString
         MOVE.B  #4,CHR1(A5)
         MOVE.L  Type(A5),CHR4(A5)
         PEA     CHR1(A5)
         _DrawString
         MOVE    #10,-(SP)
         MOVE    #38,-(SP)
         _MoveTo
         PEA     D3L2(PC)
         _DrawString
         MOVE.L  Creator(A5),CHR4(A5)
         PEA     CHR1(A5)
         _DrawString
         MOVE    #10,-(SP)
         MOVE    #102,-(SP)
         _MoveTo
         PEA     D1L3(PC)
         _DrawString
         RTS
*--------------------------------
SETPAR   LEA     PARABLK(A5),A0
         CLR.L   12(A0)
         LEA     fName(A4),A1
         MOVE.L  A1,18(A0)
         MOVE    vRefNum(A4),22(A0)
         MOVE.B  version+1(A4),26(A0)
         RTS
OPEND    BSR     SETPAR
         MOVE.B  D0,27(A0)
         MOVE.L  A2,28(A0)
         _Open
         MOVE    24(A0),D0
         MOVE    16(A0),D7
         RTS
OPENR    BSR     SETPAR
         MOVE.B  D0,27(A0)
         MOVE.L  A2,28(A0)
         _OpenRF
         MOVE    24(A0),D0
         MOVE    16(A0),D7
         RTS
CLOSEF   LEA     PARABLK(A5),A0
         CLR.L   12(A0)
         MOVE    D0,24(A0)
         _Close
         MOVE    16(A0),D7
         BNE     DOSERR
         CLR.L   18(A0)
         MOVE    vRefNum(A4),22(A0)
         _FlushVol
         MOVE    16(A0),D7
         BNE     DOSERR
         RTS
CREATEF  BSR     SETPAR
         _Create
         MOVE    16(A0),D7
         BNE     DOSERR
         RTS
DELTF    BSR     SETPAR
         CLR     28(A0)
         _GetFileInfo
         MOVE    16(A0),D7
         BEQ.S   .0
         CMP     #-43,D7
         BEQ.S   .1
         BRA     DOSERR
.0       MOVE    #-45,D7
         BTST    #7,40(A0)
         BNE     DOSERR
         _Delete
         MOVE    16(A0),D7
         BNE     DOSERR
.1       RTS
GETINFO  BSR     SETPAR
         CLR     28(A0)
         _GetFileInfo
         MOVE    16(A0),D7
         BNE     DOSERR
         RTS
MoveToEOF
         LEA     PARABLK(A5),A0
         CLR.L   12(A0)
         MOVE    Dst.IO(A5),22(A0)
         MOVE    #2,44(A0)
         CLR.L   46(A0)
         _SetFPos
         MOVE    16(A0),D7
         BNE     DOSERR
         RTS
CLOSFILE TST.B   F.Src(A5)
         BEQ.S   .0
         CLR.B   F.Src(A5)
         LEA     SFRGet(A5),A4
         MOVE    Src.IO(A5),D0
         BSR     CLOSEF
.0       TST.B   F.Dst(A5)
         BEQ.S   .1
         CLR.B   F.Dst(A5)
         LEA     SFRPut(A5),A4
         MOVE    Dst.IO(A5),D0
         BSR     CLOSEF
.1       RTS
RD1LINE  LEA     PARABLK(A5),A0
         CLR.L   12(A0)
         MOVE    Src.IO(A5),24(A0)
         LEA     InBuf+1(A5),A1
         MOVE.L  A1,32(A0)
         MOVE.L  #255,36(A0)
         MOVE    #$0D80,44(A0)
         CLR.L   46(A0)
         _Read
         MOVE    16(A0),D7
         BEQ.S   .0
         CMP     #-39,D7
         BNE     DOSERR
.0       MOVE.B  43(A0),InBuf(A5)
         RTS
DOSERR   MOVE    D7,-(SP)
         BSR     CLOSFILE
         CLR.L   -(SP)
         _FrontWindow
         MOVE.L  (SP)+,D0
         BEQ.S   .1
         CMP.L   WWindow(A5),D0
         BNE.S   .1
         MOVE.L  D0,-(SP)
         _DisposWindow
.1       CLR.L   -(SP)
         MOVE    #2,-(SP)
         CLR.L   -(SP)
         MOVE.L  #-1,-(SP)
         _GetNewDialog
         MOVE.L  (SP)+,DialPtr(A5)
         MOVE    (SP)+,D7
         BSR     INIERR
         MOVE.L  DialPtr(A5),-(SP)
         _ShowWindow
         MOVE    #4,-(SP)
         _SysBeep
.0       CLR.L   -(SP)
         PEA     ItmHit(A5)
         _ModalDialog
         MOVE    ItmHit(A5),D0
         CMP     #1,D0
         BNE.S   .0
         MOVE.L  DialPtr(A5),-(SP)
         _DisposDialog
         MOVE.L  SaveSP(A5),A7
         BRA     MNUOUT
INIERR   LEA     TERR(PC),A0
         CLR     D0
.0       MOVE.B  (A0)+,D0
         BEQ.S   .1
         CMP.B   D0,D7
         BEQ.S   .1
         MOVE.B  (A0)+,D0
         ADD     D0,A0
         BRA.S   .0
.1       MOVE.L  A0,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         _ParamText
         RTS
*--------------------------------
SetMenu  CLR.L   -(SP)
         MOVE    #1,-(SP)
         _GetRMenu
         MOVE.L  (SP),-(SP)
         CLR     -(SP)
         _InsertMenu
         MOVE.L  #$44525652,-(SP)
         _AddResMenu
         CLR.L   -(SP)
         MOVE    #2,-(SP)
         _GetRMenu
         CLR     -(SP)
         _InsertMenu
         _DrawMenuBar
         RTS
*--------------------------------
* Clear Variable Area
*--------------------------------
CLRVAR   LEA     VARB(A5),A0
         MOVE.W  #VAR.RLN,D0
         BRA.S   .1
.0       CLR.B   (A0)+
.1       DBRA    D0,.0
         RTS
*--------------------------------
TypeList ASC     "TEXT"
NullStr  STR     ""
HDR      STR     "(This file must be converted with BinHex.Hex)"
STARS    STR     "***"
COMP     STR     "***COMPRESSED"
RESF     STR     "***RESOURCE FORK"
DATF     STR     "***DATA FORK"
EOD      STR     "***END OF DATA"
SCRC     STR     "***CRC:"
CHECK    STR     "***CHECKSUM:"
D1L1     STR     "TYPE of new file is................: "
D1L2     STR     "CREATOR of new file is..........: "
D1L3     STR     "Conversion in process - Please stand by…"
D1L4     STR     " : Data Fork"
D1L5     STR     " : Resource Fork"
D2L2     STR     "CRC in file: 0000"
D2L3     STR     "Checksum in file: 00"
D2L4     STR     "No checksum present in file…"
D2L5     STR     "Calculated CRC: 0000"
D2L6     STR     "Calculated Checksum: 00"
D3L1     STR     "TYPE of Application document is: "
D3L2     STR     "CREATOR of Application document is: "
Prompt   STR     "Save document as:"
*--------------------------------
ESTR     MACRO
         DATA    #]1
         STR     "]2"
         ENDM
*--------------------------------
TERR     ESTR    -33,"Directory full"
         ESTR    -34,"Disk full"
         ESTR    -36,"I/O"
         ESTR    -44,"Write protected diskette"
         ESTR    -45,"File locked"
         ESTR    -46,"Volume locked"
         ESTR      0,"File system"
         ADJST
*--------------------------------
         ENDR
*================================
         RSRC    MENU,1,resPreLoad
         DATA    /1              ; Menu ID
         DATA    /0,/0
         DATA    /0              ; Menu Def.
         DATA    /0
         DATA    $FFFFFFFB       ; Enable Flags
         HEX     0114            ; Title
         STR     "About BinHex…"
         DATA    #0,#0,#0,#0     ; Icon,Keyboard,Mark,Style
         STR     "-"
         DATA    #0,#0,#0,#0
         STR     ""
         ENDR
*--------------------------------
         RSRC    MENU,2,resPreLoad
         DATA    /2
         DATA    /0,/0
         DATA    /0
         DATA    /0
         DATA    $FFFFFED7
         STR     "File"
         STR     "Application -> Upload"
         DATA    #0,#0,#0,#0
         STR     "Upload -> Application"
         DATA    #0,#0,#0,#0
         STR     "-"
         DATA    #0,#0,#0,#0
         STR     "TEXT filter"
         DATA    #0,#0,#$12,#0
         STR     "-"
         DATA    #0,#0,#0,#0
         STR     "Compressed"
         DATA    #0,#0,#$12,#0
         STR     "Send line feeds"
         DATA    #0,#0,#0,#0
         STR     "-"
         DATA    #0,#0,#0,#0
         STR     "Quit"
         DATA    #0,#'Q,#0,#0
         STR     ""
         ENDR
*--------------------------------
         RSRC    DLOG,1,resPreLoad
         DATA    /100,/50,/200,/460      ; Bounds
         DATA    /1                      ; Wind ID
         DATA    #0,#0                   ; Visible
         DATA    #0,#0                   ; NoGoAway
         DATA    0                       ; refCon
         DATA    /1                      ; Item ID
         STR     ""                      ; Title
         ENDR
*--------------------------------
         RSRC    DITL,1,resPreLoad
DITL1    DATA    /5-1                    ; Number of Item
         DATA    0
         DATA    /70,/340,/90,/400       ; Disp Rect
         DATA    #4                      ; Type
         STR     "OK"                    ; Content
         DATA    0
         DATA    /10,/10,/26,/400
         DATA    #8+128
         DATA    #.1-.0
.0       ASC     "BinHex 2.0,  written by "
         ASC     "Yves Lempereur {CIS 74016,1741} "
.1       DATA    0
         DATA    /26,/10,/42,/400
         DATA    #8+128
         DATA    #.3-.2
.2       ASC     "with MacASM™, an Editor/Assembler "
         ASC     "for the Macintosh."
.3       DATA    0
         DATA    /58,/10,/74,/300
         DATA    #8+128
         STR     "For further information contact Mainstay, "
         DATA    0
         DATA    /74,/10,/90,/300
         DATA    #8+128
         STR     "{CIS 70765,734} or (818) 991-6540."
         ENDR
*--------------------------------
         RSRC    DLOG,2,resPreLoad
         DATA    /100,/100,/190,/400
         DATA    /1
         DATA    #0,#0
         DATA    #0,#0
         DATA    0
         DATA    /2
         STR     ""
         ENDR
*--------------------------------
         RSRC    DITL,2,resPreLoad
         DATA    /2-1
         DATA    0
         DATA    /60,/230,/80,/290
         DATA    #4
         STR     "OK"
         DATA    0
         DATA    /20,/20,/59,/280
         DATA    #8+128
         STR     "^0 error. "
         ENDR
*--------------------------------
         RSRC    DLOG,3,resPreLoad
         DATA    /100,/100,/190,/400
         DATA    /1
         DATA    #0,#0
         DATA    #0,#0
         DATA    0
         DATA    /3
         STR     ""
         ENDR
*--------------------------------
         RSRC    DITL,3,resPreLoad
DITL3    DATA    /2-1
         DATA    0
         DATA    /60,/230,/80,/290
         DATA    #4
         STR     "OK"
         DATA    0
         DATA    /10,/10,/58,/290
         DATA    #8+128
         DATA    #.1-.0
.0       ASC     "Conversion of Application document to an "
         ASC     "Upload format document has been completed! "
.1
         ENDR
*--------------------------------
         RSRC    DLOG,4,resPreLoad
         DATA    /100,/100,/184,/410
         DATA    /1
         DATA    #0,#0
         DATA    #0,#0
         DATA    0
         DATA    /4
         STR     ""
         ENDR
*--------------------------------
         RSRC    DITL,4,resPreLoad
DITL4    DATA    /4-1
         DATA    0
         DATA    /54,/240,/74,/300
         DATA    #4
         STR     "OK"
         DATA    0
         DATA    /10,/10,/42,/300
         DATA    #8+128
         DATA    #.1-.0
.0       ASC     "Conversion of Upload format document to "
         ASC     "Application document has been completed!"
.1
         DATA    0
         DATA    /42,/10,/58,/230
         DATA    #8+128
         STR     "^0"
         DATA    0
         DATA    /58,/10,/74,/230
         DATA    #8+128
         STR     "^1"
         ENDR
*--------------------------------
         RSRC    WIND,1,resPreLoad
         DATA    /100,/100,/216,/405
         DATA    /1
         DATA    #1,#0
         DATA    #0,#0
         DATA    0
         STR     ""
         ENDR
*--------------------------------
         RSRC    BNHX,0,resPurgeable
         STR     "BinHex V2.0 -- 10/29/84"
         ENDR
*--------------------------------
         RSRC    ICN#,128,resPurgeable
         HEX     0FFFFE00.08000300.08000280.08004240
         HEX     08006220.087FF210.087FFBF8.087FF008
         HEX     08706008.08704008.08700008.08700008
         HEX     08700008.08700008.08703F08.09FC4088
         HEX     08F88048.08713028.0821C818.080E7F0F
         HEX     04023007.02010007.01008007.00806007
         HEX     00401FE7.0020021F.00100407.00080800
         HEX     00041000.00022000.00014000.00008000
*
         HEX     0FFFFE00.0FFFFF00.0FFFFF80.0FFFFFC0
         HEX     0FFFFFE0.0FFFFFF0.0FFFFFF8.0FFFFFF8
         HEX     0FFFFFF8.0FFFFFF8.0FFFFFF8.0FFFFFF8
         HEX     0FFFFFF8.0FFFFFF8.0FFFFFF8.0FFFFFF8
         HEX     0FFFFFF8.0FFFFFF8.0FFFFFF8.0FFFFFFF
         HEX     07FFFFFF.03FFFFFF.01FFFFFF.00FFFFFF
         HEX     007FFFFF.003FFE1F.001FFC07.000FF800
         HEX     0007F000.0003E000.0001C000.00008000
         ENDR
*--------------------------------
         RSRC    FREF,128,resPurgeable
         ASC     "APPL"
         DATA    /0
         STR     ""
         ENDR
*--------------------------------
         RSRC    BNDL,128,resPurgeable
         ASC     "BNHX"
         DATA    /0
         DATA    /2-1
         ASC     "ICN#"
         DATA    /1-1
         DATA    /0,/128
         ASC     "FREF"
         DATA    /1-1
         DATA    /0,/128
         ENDR
*================================
         END
