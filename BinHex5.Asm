;SAVE"BinHex5.Asm"
*--------------------------------
; BinHex version 5.0 (MacBinary)
;
; Still understands the old formats
; but won't create them.
*--------------------------------
         LIST    OFF
*--------------------------------
         INCLUDE ":Sources:Library.Asm"
         INCLUDE ":Sources:Equates.Asm"
*--------------------------------
TypTxt           EQU  $54455854  ; TEXT
Creatr           EQU  $426E4871  ; BnHq
DLE              EQU  $90
;
What             EQU  0
Message          EQU  2
When             EQU  6
Where            EQU  10
Modify           EQU  14
;
Good             EQU  0
Copy             EQU  1
fType            EQU  2
vRefNum          EQU  6
version          EQU  8
fName            EQU  10
RefNum           EQU  74         ; Not standard
;
systemFont       EQU  0
fontSize9        EQU  9
fontSize12       EQU  12
;
teJustLeft       EQU  0
teJustCenter     EQU  1
*--------------------------------
         GLOBAL  9694
;
OutBuf           DEFS 8192
DstBuf           DEFS 522
InBuf            DEFS 256
TblDcd           DEFS 128
ParaBlk          DEFS 80
SFRGet           DEFS 74+2
SFRPut           DEFS 74+2
NewName          DEFS 64
EventRecord      DEFS 16
;
WWindow          DEFS L
Menu             DEFS W
MenuItm          DEFS W
ItmHit           DEFS W
;
Type             DEFS L          ; Keep this order
Creator          DEFS L
Flags            DEFS W
Location         DEFS L
Folder           DEFS W
Locked           DEFS W
DataLen          DEFS L
RsrcLen          DEFS L
FlCrDat          DEFS L
FlMdDat          DEFS L
;
RptCnt           DEFS W
CRC              DEFS W
;
BitBuf           DEFS W
ChrCnt           DEFS W
LinePtr          DEFS L
;
BufPtr           DEFS L
BufLen           DEFS L
;
Length           DEFS L
Window1          DEFS L
;
Flag.Logo        DEFS B
Flag.Filter      DEFS B
Flag.Comp        DEFS B
RptChr           DEFS B
ChkSum           DEFS B
                 DEFS *&1
;
                 DEFS grafSize
;
         ENDG
*--------------------------------
         TFILE   "Buffer.Bin"
*--------------------------------
         RFILE   "BinHex5",APPL,BnHq,$2000
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
Start    PEA     -4(A5)
         _InitGraf
         _InitFonts
         _InitWindows
         _InitMenus
         _TEInit
         CLR.L   -(SP)
         _InitDialogs
         BSR     SetMenu
         MOVE.L  #$0000FFFF,D0
         _FlushEvents
         MOVE    #2,-(SP)
         _Pack2
         CLR.L   -(SP)
         MOVE.L  #$5041434B,-(SP)
         MOVE    #7,-(SP)
         _GetResource
         MOVE.L  (SP)+,A0
         _HNoPurge
         CLR.L   -(SP)
         MOVE.L  #$464F4E54,-(SP)
         MOVE    #(128*geneva)+fontSize12,-(SP)
         _GetResource
         MOVE.L  (SP)+,A0
         _HNoPurge
         CLR.L   -(SP)
         MOVE.L  #$464F4E54,-(SP)
         MOVE    #(128*monaco)+fontSize9,-(SP)
         _GetResource
         MOVE.L  (SP)+,A0
         _HNoPurge
         MOVE.B  #1,Flag.Filter(A5)
         BSR     ProcLogo
         MOVEQ   #0,D0
         BSR     Cursor
Loop     _SystemTask
         CLR.B   -(SP)
         MOVE    #$0FFF,-(SP)
         PEA     EventRecord(A5)
         _GetNextEvent
         TST.B   (SP)+
         BEQ.S   Loop
         MOVE    EventRecord+What(A5),D0
         ADD     D0,D0
         MOVE    .0(PC,D0),D0
         JMP     .0(PC,D0)
.0       DATA    /Loop-.0        ; null
         DATA    /MseDwn-.0      ; mouse down
         DATA    /Loop-.0        ; mouse up
         DATA    /KeyDwn-.0      ; key down
         DATA    /Loop-.0        ; key up
         DATA    /Loop-.0        ; auto-key
         DATA    /Loop-.0        ; update
         DATA    /DskIns-.0      ; disk inserted
         DATA    /Loop-.0        ; activate
         DATA    /Loop-.0        ;
         DATA    /Loop-.0        ; network
         DATA    /Loop-.0        ; device driver
KeyDwn   BSR     ClosLogo
         MOVE    EventRecord+Modify(A5),D0
         BTST    #8,D0
         BEQ     Loop
         CLR.L   -(SP)
         MOVE.L  EventRecord+Message(A5),D0
         MOVE    D0,-(SP)
         _MenuKey
         BRA     Function
MseDwn   BSR     ClosLogo
         CLR     -(SP)
         MOVE.L  EventRecord+Where(A5),-(SP)
         PEA     WWindow(A5)
         _FindWindow
         MOVE    (SP)+,D0
         ADD     D0,D0
         MOVE    .0(PC,D0),D0
         JMP     .0(PC,D0)
.0       DATA    /Loop-.0        ; inDesk
         DATA    /InMenu-.0      ; inMenuBar
         DATA    /SysEvn-.0      ; inSysWindow
         DATA    /Loop-.0        ; inContent
         DATA    /Loop-.0        ; inDrag
         DATA    /Loop-.0        ; inGrow
         DATA    /Loop-.0        ; inGoAway
InMenu   CLR.L   -(SP)
         MOVE.L  EventRecord+Where(A5),-(SP)
         _MenuSelect
Function MOVE.L  (SP)+,Menu(A5)
         MOVE    Menu(A5),D0
         ADD     D0,D0
         MOVE    .0(PC,D0),D0
         JMP     .0(PC,D0)
.0       DATA    /MnuOut-.0      ; Outside
         DATA    /MnAple-.0      ; Apple
         DATA    /MnFile-.0      ; File
         DATA    /MnEdit-.0      ; Edit
MnuOut   CLR     -(SP)
         _HiliteMenu
         MOVEQ   #0,D0
         BSR     Cursor
         BRA     Loop
MnAple   MOVE    MenuItm(A5),D0
         CMP     #1,D0
         BNE.S   DskAcc
About    CLR.L   -(SP)
         MOVE    #1,-(SP)
         CLR.L   -(SP)
         MOVE.L  #-1,-(SP)
         _GetNewDialog
         MOVE.L  (SP),Window1(A5)
         _ShowWindow
.0       CLR.L   -(SP)
         PEA     ItmHit(A5)
         _ModalDialog
         MOVE    ItmHit(A5),D0
         CMP     #1,D0
         BNE.S   .0
         MOVE.L  Window1(A5),-(SP)
         _DisposDialog
         BRA     MnuOut
DskAcc   CLR.L   -(SP)
         MOVE    #1,-(SP)
         _GetMHandle
         MOVE    MenuItm(A5),-(SP)
         PEA     NewName(A5)
         _GetItem
         CLR     -(SP)
         PEA     NewName(A5)
         _OpenDeskAcc
         TST     (SP)+
         BRA     MnuOut
MnFile   MOVE    MenuItm(A5),D0
         ADD     D0,D0
         MOVE    .0(PC,D0),D0
         JMP     .0(PC,D0)
.0       DATA    /MnuOut-.0
         DATA    /AppUpl-.0      ; Appl -> Upl
         DATA    /UplApp-.0      ; Upl -> Appl
         DATA    /MnuOut-.0      ; -----------
         DATA    /Filter-.0      ; TEXT filter
         DATA    /MnuOut-.0      ; -----------
         DATA    /Quit-.0        ; Quit
Filter   EOR.B   #1,Flag.Filter(A5)
         CLR.L   -(SP)
         MOVE    #2,-(SP)
         _GetMHandle
         MOVE    #4,-(SP)
         MOVE.B  Flag.Filter(A5),-(SP)
         _CheckItem
         BRA     MnuOut
Quit     _ExitToShell
MnEdit   MOVE    MenuItm(A5),D0
         BEQ     MnuOut
         SUBQ    #1,D0
         CLR.B   -(SP)
         MOVE    D0,-(SP)
         _SysEdit
         TST.B   (SP)+
         BRA     MnuOut
SysEvn   PEA     EventRecord(A5)
         MOVE.L  WWindow(A5),-(SP)
         _SystemClick
         BRA     Loop
DskIns   BSR     ClosLogo
         MOVE    EventRecord+Message(A5),D0
         BEQ     Loop
         CLR     -(SP)
         MOVE    #100,-(SP)
         MOVE    #100,-(SP)
         MOVE.L  EventRecord+Message(A5),-(SP)
         MOVE    #0,-(SP)
         _Pack2
         TST     (SP)+
         BRA     Loop
*--------------------------------
AppUpl   MOVE    #70,-(SP)
         MOVE    #70,-(SP)
         PEA     NullStr(PC)
         CLR.L   -(SP)
         MOVE    #-1,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         PEA     SFRGet(A5)
         MOVE    #SFGetFile,-(SP)
         _Pack3
         TST.B   SFRGet+Good(A5)
         BEQ     MnuOut
         BSR     AddExt
         MOVE    #100,-(SP)
         MOVE    #70,-(SP)
         PEA     Prompt(PC)
         PEA     NewName(A5)
         CLR.L   -(SP)
         PEA     SFRPut(A5)
         MOVE    #SFPutFile,-(SP)
         _Pack3
         TST.B   SFRPut+Good(A5)
         BEQ     MnuOut
         MOVEQ   #4,D0
         BSR     Cursor
         LEA     SFRGet(A5),A4
         BSR     GetInfo
         BNE     Err
         MOVE.L  32(A0),Type(A5)
         MOVE.L  36(A0),Creator(A5)
         MOVE    40(A0),Flags(A5)
         AND     #$FF00,Flags(A5)
         MOVE.L  42(A0),Location(A5)
         MOVE    46(A0),Folder(A5)
         MOVE    30(A0),Locked(A5)
         AND     #$0100,Locked(A5)
         MOVE.L  54(A0),DataLen(A5)
         MOVE.L  64(A0),RsrcLen(A5)
         MOVE.L  72(A0),FlCrDat(A5)
         MOVE.L  76(A0),FlMdDat(A5)
         BSR     Disp1
         LEA     SFRPut(A5),A4
         BSR     DeleteF
         BNE     AErr0
         BSR     CreateF
         BNE     AErr1
         BSR     GetInfo
         BNE     AErr1
         MOVE.L  #TypTxt,32(A0)
         MOVE.L  #Creatr,36(A0)
         _SetFileInfo
         MOVE    16(A0),D7
         BNE     AErr1
         MOVEQ   #fsWrPerm,D0
         LEA     DstBuf(A5),A2
         LEA     SFRPut(A5),A4
         BSR     OpenData
         BNE     AErr2
         BSR     InitB
         BSR     SvHdr
         BNE     AErr2
         MOVEQ   #fsRdPerm,D0
         LEA     0,A2
         LEA     SFRGet(A5),A4
         BSR     OpenData
         BNE     AErr3
         MOVE.L  DataLen(A5),Length(A5)
         BSR     PutBlk
         BNE     AErr3
         LEA     SFRGet(A5),A4
         BSR     CloseF
         BNE     AErr3
         MOVEQ   #fsRdPerm,D0
         LEA     0,A2
         LEA     SFRGet(A5),A4
         BSR     OpenRsrc
         BNE     AErr3
         MOVE.L  RsrcLen(A5),Length(A5)
         BSR     PutBlk
         BNE     AErr3
         LEA     SFRGet(A5),A4
         BSR     CloseF
         BNE     AErr3
         BSR     FlshB
         BNE     AErr2
         LEA     SFRPut(A5),A4
         BSR     CloseF
         BNE     AErr2
         BSR     CloseWind
         BSR     Complete
         BRA     MnuOut
*--------------------------------
UplApp   MOVE    #70,-(SP)
         MOVE    #70,-(SP)
         PEA     NullStr(PC)
         CLR.L   -(SP)
         TST.B   Flag.Filter(A5)
         BNE.S   .0
         MOVE    #-1,-(SP)
         CLR.L   -(SP)
         BRA.S   .1
.0       MOVE    #1,-(SP)
         PEA     TypeList(PC)
.1       CLR.L   -(SP)
         PEA     SFRGet(A5)
         MOVE    #SFGetFile,-(SP)
         _Pack3
         TST.B   SFRGet+Good(A5)
         BEQ     MnuOut
         MOVEQ   #fsRdPerm,D0
         LEA     0,A2
         LEA     SFRGet(A5),A4
         BSR     OpenData
         BNE     UErr0
         BSR     Rd1Blk
         BNE     Old
         LEA     InBuf(A5),A0
         TST.B   0(A0)
         BNE     Old
         TST.B   74(A0)
         BNE     Old
         TST.B   82(A0)
         BNE     Old
         BSR     LdHdr
         BNE     UErr0
         MOVE    #100,-(SP)
         MOVE    #70,-(SP)
         PEA     Prompt(PC)
         PEA     NewName(A5)
         CLR.L   -(SP)
         PEA     SFRPut(A5)
         MOVE    #SFPutFile,-(SP)
         _Pack3
         TST.B   SFRPut+Good(A5)
         BEQ     .6
         MOVEQ   #4,D0
         BSR     Cursor
         BSR     Disp2
         LEA     SFRPut(A5),A4
         BSR     DeleteF
         BNE     UErr1
         BSR     CreateF
         BNE     UErr2
         MOVE.L  Type(A5),32(A0)
         MOVE.L  Creator(A5),36(A0)
         MOVE    Flags(A5),40(A0)
         AND     #$F800,40(A0)
         MOVE.L  Location(A5),42(A0)
         MOVE    Folder(A5),46(A0)
         MOVE.L  FlCrDat(A5),72(A0)
         MOVE.L  FlMdDat(A5),76(A0)
         _SetFileInfo
         MOVE    16(A0),D7
         BNE     UErr2
         MOVEQ   #fsWrPerm,D0
         LEA     DstBuf(A5),A2
         LEA     SFRPut(A5),A4
         BSR     OpenData
         BNE     UErr3
         MOVE.L  DataLen(A5),Length(A5)
         BSR     GetBlk
         BNE     UErr3
         LEA     SFRPut(A5),A4
         BSR     CloseF
         BNE     UErr3
         MOVEQ   #fsWrPerm,D0
         LEA     DstBuf(A5),A2
         LEA     SFRPut(A5),A4
         BSR     OpenRsrc
         BNE     UErr3
         MOVE.L  RsrcLen(A5),Length(A5)
         BSR     GetBlk
         BNE     UErr3
         LEA     SFRPut(A5),A4
         BSR     CloseF
         BNE     UErr3
         MOVE.B  Locked(A5),D0
         AND.B   #$01,D0
         BEQ.S   .2
         LEA     SFRPut(A5),A4
         BSR     SetLock
         BNE     UErr2
.2       LEA     SFRGet(A5),A4
         BSR     CloseF
         BNE     UErr1
         BSR     CloseWind
         BSR     Complete
         BRA     MnuOut
.6       LEA     SFRGet(A5),A4
         BSR     CloseF
         BNE     UErr0
         BRA     MnuOut
Old      LEA     SFRGet(A5),A4
         BSR     MovToSTR
         BNE     UErr0
.2       BSR     Rd1Line
         BNE     UErr0
         MOVE    #-39,D7
         TST     D1
         BEQ     UErr0
         LEA     InBuf(A5),A0
.25      SUBQ    #1,D1
         BMI.S   .2
         MOVE.B  (A0)+,D0
         CMP.B   #32,D0
         BLO.S   .25
         CMP.B   #':,D0
         BEQ.S   .5
         BRA.S   .35
.3       MOVE.B  (A0)+,D0
.35      CMP.B   #'#,D0
         BEQ     .7
.4       DBRA    D1,.3
         BRA.S   .2
.5       MOVE.L  A0,LinePtr(A5)
         MOVE    D1,ChrCnt(A5)
         BSR     InitDcmp
         BNE     UErr0
         BSR     LoadHdr
         BNE     UErr0
         MOVE    #100,-(SP)
         MOVE    #70,-(SP)
         PEA     Prompt(PC)
         PEA     NewName(A5)
         CLR.L   -(SP)
         PEA     SFRPut(A5)
         MOVE    #SFPutFile,-(SP)
         _Pack3
         TST.B   SFRPut+Good(A5)
         BEQ     .6
         MOVEQ   #4,D0
         BSR     Cursor
         BSR     Disp2
         LEA     SFRPut(A5),A4
         BSR     DeleteF
         BNE     UErr1
         BSR     CreateF
         BNE     UErr2
         BSR     GetInfo
         BNE     UErr2
         MOVE.L  Type(A5),32(A0)
         MOVE.L  Creator(A5),36(A0)
         MOVE    Flags(A5),D0
         OR      D0,40(A0)
         _SetFileInfo
         MOVE    16(A0),D7
         BNE     UErr2
         MOVEQ   #fsWrPerm,D0
         LEA     DstBuf(A5),A2
         LEA     SFRPut(A5),A4
         BSR     OpenData
         BNE     UErr3
         MOVE.L  DataLen(A5),Length(A5)
         BSR     DcmpBlk
         BNE     UErr3
         LEA     SFRPut(A5),A4
         BSR     CloseF
         BNE     UErr3
         MOVEQ   #fsWrPerm,D0
         LEA     DstBuf(A5),A2
         LEA     SFRPut(A5),A4
         BSR     OpenRsrc
         BNE     UErr3
         MOVE.L  RsrcLen(A5),Length(A5)
         BSR     DcmpBlk
         BNE     UErr3
         LEA     SFRPut(A5),A4
         BSR     CloseF
         BNE     UErr3
         LEA     SFRGet(A5),A4
         BSR     CloseF
         BNE     UErr1
         BSR     CloseWind
         BSR     Complete
         BRA     MnuOut
.6       LEA     SFRGet(A5),A4
         BSR     CloseF
         BNE     UErr0
         BRA     MnuOut
.7       MOVE.L  #TypTxt,Type(A5)
         MOVE.L  #Creatr,Creator(A5)
         CLR     Flags(A5)
         CMP     #8,D1
         BLO.S   .8
         BSR     Get4C
         MOVE.L  D0,Type(A5)
         BSR     Get4C
         MOVE.L  D0,Creator(A5)
.8       CMP     #5,D1
         BLO.S   .9
         CMP.B   #'$,(A0)+
         BNE.S   .9
         BSR     GetWord
         BCS.S   .9
         MOVE    D0,Flags(A5)
.9       BSR     RmvExt
         MOVE    #100,-(SP)
         MOVE    #70,-(SP)
         PEA     Prompt(PC)
         PEA     NewName(A5)
         CLR.L   -(SP)
         PEA     SFRPut(A5)
         MOVE    #SFPutFile,-(SP)
         _Pack3
         TST.B   SFRPut+Good(A5)
         BEQ.S   .6
         MOVEQ   #4,D0
         BSR     Cursor
         BSR     Disp3
         LEA     SFRPut(A5),A4
         BSR     DeleteF
         BNE     UErr1
         BSR     CreateF
         BNE     UErr2
         BSR     GetInfo
         BNE     UErr2
         MOVE.L  Type(A5),32(A0)
         MOVE.L  Creator(A5),36(A0)
         MOVE    Flags(A5),D0
         OR      D0,40(A0)
         _SetFileInfo
         MOVE    16(A0),D7
         BNE     UErr2
         CLR.B   Flag.Comp(A5)
         CLR.B   ChkSum(A5)
         CLR     CRC(A5)
         BSR     Rd1Str
         BNE     UErr2
         LEA     Comp(PC),A1
         BSR     Compare
         BNE.S   .10
         MOVE.B  #1,Flag.Comp(A5)
         BSR     Rd1Str
         BNE     UErr2
.10      LEA     DatF(PC),A1
         BSR     Compare
         BNE.S   .11
.105     BSR     Disp4
         BSR     Rd1Str
         BNE     UErr2
         BRA.S   .12
.11      LEA     ResF(PC),A1
         BSR     Compare
         BNE.S   .12
.115     BSR     Disp5
         BSR     Rd1Str
         BNE     UErr2
         MOVEQ   #fsWrPerm,D0
         LEA     DstBuf(A5),A2
         LEA     SFRPut(A5),A4
         BSR     OpenRsrc
         BNE     UErr3
         BRA.S   .13
.12      MOVEQ   #fsWrPerm,D0
         LEA     DstBuf(A5),A2
         LEA     SFRPut(A5),A4
         BSR     OpenData
         BNE     UErr3
.13      BSR     MovToEOF
         BNE     UErr3
         BSR     InitB
         BRA.S   .15
.14      BSR     Rd1Str
         BNE     UErr3
.15      TST.B   InBuf(A5)
         BEQ.S   .17
         LEA     Stars(PC),A1
         BSR     Compare
         BEQ.S   .16
         BSR     ConvHB
         BNE     UErr3
         BRA.S   .14
.16      LEA     EOD(PC),A1
         BSR     Compare
         BNE.S   .17
         BSR     Rd1Str
         BNE     UErr3
.17      BSR     FlshB
         BNE     UErr3
         LEA     SFRPut(A5),A4
         BSR     CloseF
         BNE     UErr3
         LEA     DatF(PC),A1
         BSR     Compare
         BEQ     .105
         LEA     ResF(PC),A1
         BSR     Compare
         BEQ     .115
         LEA     SFRGet(A5),A4
         BSR     CloseF
         BNE     UErr1
         BSR     CloseWind
         LEA     Check(PC),A1
         BSR     Compare
         BNE.S   .18
         BSR     GetByte
         BCS.S   .19
         CMP.B   Chksum(A5),D0
         BEQ.S   .20
         LEA     TChk(PC),A0
         MOVE.B  Chksum(A5),D0
         BSR     DspByte
         MOVEQ   #2,D7
         BRA     Err
.18      LEA     SCRC(PC),A1
         BSR     Compare
         BNE.S   .19
         BSR     GetWord
         BCS.S   .19
         CMP     CRC(A5),D0
         BEQ.S   .20
         LEA     TCRC(PC),A0
         MOVE    CRC(A5),D0
         BSR     DspWord
         MOVEQ   #1,D7
         BRA     Err
.19      MOVEQ   #3,D7
         BRA     Err
.20      BSR     Complete
         BRA     MnuOut
TypeList ASC     "TEXT"
Stars    STR     "***"
Comp     STR     "***COMPRESSED"
DatF     STR     "***DATA FORK"
ResF     STR     "***RESOURCE FORK"
EOD      STR     "***END OF DATA"
Check    STR     "***CHECKSUM:"
SCRC     STR     "***CRC:"
         ADJST
*--------------------------------
SvHdr    BSR     ClrBuf
;        CLR.B   InBuf+0(A5)
         LEA     SFRGet+fName(A5),A0
         LEA     InBuf+1(A5),A1
         CLR     D1
         MOVE.B  (A0),D1
.0       MOVE.B  (A0)+,(A1)+
         DBRA    D1,.0
         LEA     Type(A5),A0
         LEA     InBuf+65(A5),A1
         MOVEQ   #34-1,D1
.1       MOVE.B  (A0)+,(A1)+
         DBRA    D1,.1
         MOVE.L  #128,D1
         BRA     WriteBk
*--------------------------------
LdHdr    LEA     InBuf+1(A5),A0
         CLR     D1
         MOVE.B  (A0),D1
         MOVEQ   #4,D7
         CMP     #63,D1
         BHI.S   .2
         LEA     NewName(A5),A1
.0       MOVE.B  (A0)+,(A1)+
         DBRA    D1,.0
         LEA     InBuf+65(A5),A0
         LEA     Type(A5),A1
         MOVEQ   #34-1,D1
.1       MOVE.B  (A0)+,(A1)+
         DBRA    D1,.1
         CLR     D7
.2       RTS
*--------------------------------
PutBlk   TST.L   Length(A5)
         BEQ.S   .0
         BSR     ClrBuf
         BSR     Rd1Bk
         BNE.S   .0
         SUB.L   D1,Length(A5)
         MOVE.L  #128,D1
         BSR     WriteBk
         BEQ.S   PutBlk
.0       RTS
*--------------------------------
GetBlk   BSR     InitB
.0       TST.L   Length(A5)
         BEQ.S   .3
.1       BSR     Rd1Blk
         BNE.S   .4
         MOVE.L  #128,D1
         CMP.L   Length(A5),D1
         BLS.S   .2
         MOVE.L  Length(A5),D1
.2       BSR     WriteBk
         BNE.S   .4
         SUB.L   D1,Length(A5)
         BNE.S   .1
.3       BSR     FlshB
.4       RTS
*--------------------------------
ConvHB   BSR     LinStr
         TST.B   Flag.Comp(A5)
         BNE.S   .1
.0       CMP.B   #2,D1
         BLO.S   .4
         BSR     GetByte
         BCS.S   .4
         ADD.B   D0,ChkSum(A5)
         BSR     .6
         BEQ.S   .0
         BRA.S   .5
.1       MOVE    #$80,D6
         CLR     D0
         BSR     GetCByte
         MOVE    D0,D2
         BRA.S   .3
.2       BSR     GetCByte
         MOVE    CRC(A5),D3
         ADD     D0,D3
         ROL     #3,D3
         MOVE    D3,CRC(A5)
         BSR     .6
         BNE.S   .5
.3       DBRA    D2,.2
.4       CLR     D7
.5       RTS
.6       MOVEM.L D0/A0,-(SP)
         BSR     WriteB
         MOVEM.L (SP)+,D0/A0
         RTS
GetCByte MOVEQ   #8-1,D3
.0       CMP.B   #$80,D6
         BNE.S   .3
.1       CLR     D6
         TST     D1
         BEQ.S   .2
         SUBQ    #1,D1
         MOVE.B  (A0)+,D6
         SUB.B   #$20,D6
         CMP.B   #$40,D6
         BHS.S   .1
         LSL.B   #2,D6
.2       OR.B    #$02,D6
.3       LSL.B   #1,D6
         ROXL.B  #1,D0
         DBRA    D3,.0
         RTS
Get4C    MOVEQ   #4-1,D2
.0       LSL.L   #8,D0
         MOVE.B  (A0)+,D0
         SUBQ    #1,D1
         DBRA    D2,.0
         RTS
GetWord  BSR.L   GetByte
GetByte  BSR.L   GetDigit
GetDigit MOVE.B  (A0)+,D2
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
DspWord  MOVE    D0,-(SP)
         LSR     #8,D0
         BSR.S   DspByte
         MOVE    (SP)+,D0
DspByte  MOVE.B  D0,-(SP)
         LSR.B   #4,D0
         BSR.S   DspDigit
         MOVE.B  (SP)+,D0
DspDigit AND.B   #$0F,D0
         OR.B    #$30,D0
         CMP.B   #$3A,D0
         BLO.S   .0
         ADDQ.B  #7,D0
.0       MOVE.B  D0,(A0)+
         RTS
LinStr   LEA     InBuf(A5),A0
         CLR     D1
         MOVE.B  (A0)+,D1
         BEQ.S   .1
.0       CMP.B   #$0A,(A0)
         BNE.S   .1
         ADDQ.L  #1,A0
         SUBQ    #1,D1
         BNE.S   .0
.1       RTS
Compare  BSR     LinStr
         CLR     D2
         MOVE.B  (A1)+,D2
         CMP     D2,D1
         BLO.S   .2
         BRA.S   .1
.0       CMP.B   (A0)+,(A1)+
         BNE.S   .2
.1       DBRA    D2,.0
         CLR     D0
.2       RTS
*--------------------------------
LoadHdr  CLR     CRC(A5)
         BSR     DcmpByte
         BNE.S   .3
         MOVEQ   #4,D7
         CMP.B   #63,D0
         BHI.S   .3
         CLR     D1
         MOVE.B  D0,D1
         LEA     NewName(A5),A1
         BRA.S   .1
.0       BSR     DcmpByte
         BNE.S   .3
.1       MOVE.B  D0,(A1)+
         DBRA    D1,.0
         BSR     DcmpByte
         BNE.S   .3
         LEA     Type(A5),A1
         MOVEQ   #10-1,D1
.2       BSR     DcmpByte
         BNE.S   .3
         MOVE.B  D0,(A1)+
         DBRA    D1,.2
         LEA     DataLen(A5),A1
         MOVEQ   #8-1,D1
.4       BSR     DcmpByte
         BNE.S   .3
         MOVE.B  D0,(A1)+
         DBRA    D1,.4
         BSR     DcmpCRC
.3       RTS
*--------------------------------
DcmpBlk  BSR     InitB
         CLR     CRC(A5)
.0       TST.L   Length(A5)
         BEQ.S   .2
.1       BSR     DcmpByte
         BNE.S   .3
         BSR     WriteB
         BNE.S   .3
         SUBQ.L  #1,Length(A5)
         BNE.S   .1
.2       BSR     DcmpCRC
         BNE.S   .3
         BSR     FlshB
.3       RTS
*--------------------------------
InitDcmp CLR     RptCnt(A5)
         BRA     InitDcod
DcmpCRC  BSR     DcmpByte
         BNE.S   .0
         BSR     DcmpByte
         BNE.S   .0
         TST     CRC(A5)
         BEQ.S   .0
         LEA     TCRC(PC),A0
         MOVE    CRC(A5),D0
         BSR     DspWord
         MOVEQ   #1,D7
.0       RTS
DcmpByte TST     RptCnt(A5)
         BNE.S   .0
         BSR     DcodByte
         BNE.S   .4
         CMP.B   #DLE,D0
         BNE.S   .2
         BSR     DcodByte
         BNE.S   .4
         TST.B   D0
         BEQ.S   .1
         SUBQ.B  #1,D0
         AND     #$00FF,D0
         MOVE    D0,RptCnt(A5)
.0       SUBQ    #1,RptCnt(A5)
         MOVE.B  RptChr(A5),D0
         BRA.S   .3
.1       MOVE.B  #DLE,D0
.2       MOVE.B  D0,RptChr(A5)
.3       BSR     CRCUpd
         CLR     D7
.4       RTS
CRCUpd   MOVEM.L D0-D2,-(SP)
         MOVE    CRC(A5),D2
         MOVEQ   #8-1,D1
.0       LSL.B   #1,D0
         ROXL    #1,D2
         BCC.S   .1
         EOR     #$1021,D2
.1       DBRA    D1,.0
         MOVE    D2,CRC(A5)
         MOVEM.L (SP)+,D0-D2
         RTS
*--------------------------------
InitDcod LEA     TblDcd(A5),A0
         MOVEQ   #128-1,D0
.0       MOVE.B  #$80,(A0)+
         DBRA    D0,.0
         LEA     TblCod(PC),A0
         LEA     TblDcd(A5),A1
         CLR     D1
         MOVEQ   #64-1,D0
.1       MOVE.B  0(A0,D0),D1
         MOVE.B  D0,0(A1,D1)
         DBRA    D0,.1
         MOVE    #$80,BitBuf(A5)
         CLR     D7
         RTS
DcodByte MOVEM.L D1-D2,-(SP)
         MOVE    BitBuf(A5),D2
         MOVEQ   #8-1,D1
.0       CMP.B   #$80,D2
         BNE.S   .3
.1       TST     ChrCnt(A5)
         BNE.S   .2
         BSR.S   .5
         BNE.S   .4
.2       MOVE.L  LinePtr(A5),A0
         ADDQ.L  #1,LinePtr(A5)
         SUBQ    #1,ChrCnt(A5)
         CLR     D2
         MOVE.B  (A0),D2
         BMI.S   .1
         LEA     TblDcd(A5),A0
         MOVE.B  0(A0,D2),D2
         BMI.S   .1
         LSL.B   #2,D2
         OR.B    #$02,D2
.3       LSL.B   #1,D2
         ROXL.B  #1,D0
         DBRA    D1,.0
         MOVE    D2,BitBuf(A5)
         CLR     D7
.4       MOVEM.L (SP)+,D1-D2
         RTS
.5       MOVEM.L D0-D1,-(SP)
         BSR     Rd1Line
         BNE.S   .6
         TST     D1
         BEQ.S   .7
         LEA     InBuf(A5),A0
         MOVE.L  A0,LinePtr(A5)
         MOVE    D1,ChrCnt(A5)
         CLR     D7
.6       MOVEM.L (SP)+,D0-D1
         RTS
.7       MOVE    #-39,D7
         BRA.S   .6
*--------------------------------
TblCod   ASC     :!"#$%&'()*+,-012345689@ABCDEFGHI:
         ASC     :JKLMNPQRSTUVXYZ[`abcdefhijklmpqr:
*--------------------------------
ClrBuf   LEA     InBuf(A5),A0
         MOVEQ   #128/4-1,D1
.0       CLR.L   (A0)+
         DBRA    D1,.0
         RTS
WriteBk  LEA     InBuf(A5),A0
         MOVE.L  BufPtr(A5),A1
         MOVE.L  D1,D0
         BRA.S   .1
.0       MOVE.B  (A0)+,(A1)+
.1       DBRA    D0,.0
         MOVE.L  A1,BufPtr(A5)
         ADD.L   D1,BufLen(A5)
         MOVE.L  #8192,D0
         SUB.L   BufLen(A5),D0
         CMP.L   #128,D0
         BLO.S   FlshB
         CLR     D7
         RTS
WriteB   MOVE.L  BufPtr(A5),A0
         MOVE.B  D0,(A0)
         ADDQ.L  #1,BufPtr(A5)
         ADDQ.L  #1,BufLen(A5)
         CMP.L   #8192,BufLen(A5)
         BHS.S   FlshB
         CLR     D7
         RTS
FlshB    LEA     ParaBlk(A5),A0
         CLR.L   12(A0)
         MOVE    SFRPut+RefNum(A5),24(A0)
         PEA     OutBuf(A5)
         MOVE.L  (SP)+,32(A0)
         MOVE.L  BufLen(A5),36(A0)
         CLR     44(A0)
         CLR.L   46(A0)
         _Write
         MOVE    16(A0),D7
InitB    PEA     OutBuf(A5)
         MOVE.L  (SP)+,BufPtr(A5)
         CLR.L   BufLen(A5)
         TST     D7
         RTS
*--------------------------------
Rd1Blk   LEA     ParaBlk(A5),A0
         CLR.L   12(A0)
         MOVE    SFRGet+RefNum(A5),24(A0)
         PEA     InBuf(A5)
         MOVE.L  (SP)+,32(A0)
         MOVE.L  #128,36(A0)
         CLR     44(A0)
         CLR.L   46(A0)
         _Read
         MOVE    16(A0),D7
         BNE.S   .0
         MOVE    #-39,D7
         CMP.L   #128,40(A0)
.0       RTS
*--------------------------------
Rd1Bk    LEA     ParaBlk(A5),A0
         CLR.L   12(A0)
         MOVE    SFRGet+RefNum(A5),24(A0)
         PEA     InBuf(A5)
         MOVE.L  (SP)+,32(A0)
         MOVE.L  #128,36(A0)
         CLR     44(A0)
         CLR.L   46(A0)
         _Read
         MOVE.L  40(A0),D1
         MOVE    16(A0),D7
         BEQ.S   .0
         CMP     #-39,D7
.0       RTS
*--------------------------------
Rd1Line  LEA     ParaBlk(A5),A0
         CLR.L   12(A0)
         MOVE    SFRGet+RefNum(A5),24(A0)
         PEA     InBuf(A5)
         MOVE.L  (SP)+,32(A0)
         MOVE.L  #256,36(A0)
         MOVE    #$0D80,44(A0)
         CLR.L   46(A0)
         _Read
         MOVE.L  40(A0),D1
         MOVE    16(A0),D7
         BEQ.S   .0
         CMP     #-39,D7
.0       RTS
*--------------------------------
Rd1Str   LEA     ParaBlk(A5),A0
         CLR.L   12(A0)
         MOVE    SFRGet+RefNum(A5),24(A0)
         PEA     InBuf+1(A5)
         MOVE.L  (SP)+,32(A0)
         MOVE.L  #255,36(A0)
         MOVE    #$0D80,44(A0)
         CLR.L   46(A0)
         _Read
         MOVE.B  43(A0),InBuf(A5)
         MOVE    16(A0),D7
         BEQ.S   .0
         CMP     #-39,D7
.0       RTS
*--------------------------------
* Append ".Bin" to the Name.
*--------------------------------
AddExt   LEA     SFRGet+fName(A5),A0
         LEA     NewName(A5),A1
         CLR     D0
         MOVE.B  (A0)+,D0
         CMP     #59,D0
         BLS.S   .0
         MOVEQ   #59,D0
.0       MOVE.B  D0,(A1)+
         BRA.S   .2
.1       MOVE.B  (A0)+,(A1)+
.2       DBRA    D0,.1
         LEA     StrBin(PC),A0
         MOVEQ   #4-1,D0
.3       MOVE.B  (A0)+,(A1)+
         DBRA    D0,.3
         ADDQ.B  #4,NewName(A5)
         RTS
StrBin   ASC     ".Bin"
*--------------------------------
* Remove ".H?X" from the Name.
*--------------------------------
RmvExt   LEA     SFRGet+fName(A5),A0
         LEA     NewName(A5),A1
         CLR     D1
         MOVE.B  (A0),D1
.0       MOVE.B  (A0)+,(A1)+
         CMP     #4,D1
         BNE.S   .1
         MOVE.B  (A0),D0
         CMP.B   #'.,D0
         BNE.S   .1
         MOVE.B  1(A0),D0
         BSR     lcUC
         CMP.B   #'H,D0
         BNE.S   .1
         MOVE.B  3(A0),D0
         BSR     lcUC
         CMP.B   #'X,D0
         BNE.S   .1
         SUBQ.B  #4,NewName(A5)
         BRA.S   .2
.1       DBRA    D1,.0
.2       RTS
lcUC     CMP.B   #'z,D0
         BHI.S   .0
         CMP.B   #'a,D0
         BLO.S   .0
         AND.B   #$5F,D0
.0       RTS
*--------------------------------
Cursor   TST     D0
         BNE.S   .0
         _InitCursor
         BRA.S   .1
.0       CLR.L   -(SP)
         MOVE    D0,-(SP)
         _GetCursor
         MOVE.L  (SP)+,A0
         MOVE.L  (A0),-(SP)
         _SetCursor
.1       RTS
*--------------------------------
OpenWind CLR.L   -(SP)
         MOVE    #1,-(SP)
         CLR.L   -(SP)
         MOVE.L  #-1,-(SP)
         _GetNewWindow
         MOVE.L  (SP),Window1(A5)
         _SetPort
         MOVE    #geneva,-(SP)
         _TextFont
         MOVE    #fontSize12,-(SP)
         _TextSize
         CLR     -(SP)
         _TextFace
         MOVE    #1,-(SP)
         _TextMode
         RTS
CloseWind
         MOVE.L  Window1(A5),-(SP)
         _DisposWindow
         RTS
*--------------------------------
Disp1    BSR     OpenWind
         BSR     DispGet
         BSR     DispDfrk
         BSR     DispRfrk
         BRA     DispTC
Disp2    BSR     OpenWind
         BSR     DispPut
         BSR     DispDfrk
         BSR     DispRfrk
         BRA     DispTC
Disp3    BSR     OpenWind
         BSR     DispPut
         BRA     DispTC
Disp4    MOVE    #20,-(SP)
         MOVE    #48,-(SP)
         _MoveTo
         LEA     D2L2(PC),A2
         BRA     DrawBold
Disp5    MOVE    #20,-(SP)
         MOVE    #64,-(SP)
         _MoveTo
         LEA     D2L3(PC),A2
         BRA     DrawBold
DispGet  MOVE    #20,-(SP)
         MOVE    #32,-(SP)
         _MoveTo
         PEA     D1L1S(PC)
         _DrawString
         LEA     SFRGet+fName(A5),A2
         BSR     DrawBold
         PEA     D1L1E(PC)
         _DrawString
         RTS
DispPut  MOVE    #20,-(SP)
         MOVE    #32,-(SP)
         _MoveTo
         PEA     D1L1S(PC)
         _DrawString
         LEA     SFRPut+fName(A5),A2
         BSR     DrawBold
         PEA     D1L1E(PC)
         _DrawString
         RTS
DispDfrk MOVE    #20,-(SP)
         MOVE    #48,-(SP)
         _MoveTo
         PEA     D1L2S(PC)
         _DrawString
         MOVE.L  DataLen(A5),D0
         BSR     DrawNum
         PEA     D1L2E(PC)
         _DrawString
         RTS
DispRfrk MOVE    #20,-(SP)
         MOVE    #64,-(SP)
         _MoveTo
         PEA     D1L3S(PC)
         _DrawString
         MOVE.L  RsrcLen(A5),D0
         BSR     DrawNum
         PEA     D1L2E(PC)
         _DrawString
         RTS
DispTC   MOVE    #20,-(SP)
         MOVE    #80,-(SP)
         _MoveTo
         PEA     D1L4S(PC)
         _DrawString
         MOVE.B  #4,InBuf+1(A5)
         MOVE.L  Type(A5),InBuf+2(A5)
         LEA     InBuf+1(A5),A2
         BSR     DrawBold
         PEA     D1L1E(PC)
         _DrawString
         MOVE    #20,-(SP)
         MOVE    #96,-(SP)
         _MoveTo
         PEA     D1L5S(PC)
         _DrawString
         MOVE.B  #4,InBuf+1(A5)
         MOVE.L  Creator(A5),InBuf+2(A5)
         LEA     InBuf+1(A5),A2
         BSR     DrawBold
         PEA     D1L1E(PC)
         _DrawString
         RTS
D1L1S    STR     "Converting the file """
D1L1E    STR     """."
D1L2S    STR     "Data fork size is "
D1L2E    STR     " bytes."
D1L3S    STR     "Resource fork size is "
D1L4S    STR     "Type is """
D1L5S    STR     "Creator is """
D2L2     STR     "Data fork!"
D2L3     STR     "Resource fork!"
         ADJST
*--------------------------------
DrawNum  LEA     InBuf(A5),A0
         MOVE    #NumToString,-(SP)
         _Pack7
DrawStr  LEA     InBuf(A5),A2
DrawBold MOVE    #systemFont,-(SP)
         _TextFont
         MOVE.L  A2,-(SP)
         _DrawString
         MOVE    #geneva,-(SP)
         _TextFont
         RTS
*--------------------------------
* File manager routines
* A4 = SFR Pointer
* EQ : No error
* NE : D7=error code
*--------------------------------
SetPar   LEA     ParaBlk(A5),A0
         CLR.L   12(A0)
         PEA     fName(A4)
         MOVE.L  (SP)+,18(A0)
         MOVE    vRefNum(A4),22(A0)
         MOVE.B  version+1(A4),26(A0)
         RTS
*--------------------------------
* Open routines
* D0 = ioPermssn
* A2 = Buffer or NIL
*--------------------------------
OpenData BSR     SetPar
         MOVE.B  D0,27(A0)
         MOVE.L  A2,28(A0)
         _Open
         MOVE    24(A0),RefNum(A4)
         MOVE    16(A0),D7
         RTS
OpenRsrc BSR     SetPar
         MOVE.B  D0,27(A0)
         MOVE.L  A2,28(A0)
         _OpenRF
         MOVE    24(A0),RefNum(A4)
         MOVE    16(A0),D7
         RTS
*--------------------------------
CloseF   LEA     ParaBlk(A5),A0
         CLR.L   12(A0)
         MOVE    RefNum(A4),24(A0)
         _Close
         MOVE    16(A0),D7
         BNE.S   .0
         CLR.L   18(A0)
         MOVE    vRefNum(A4),22(A0)
         _FlushVol
         MOVE    16(A0),D7
.0       RTS
*--------------------------------
CreateF  BSR     SetPar
         _Create
         MOVE    16(A0),D7
         RTS
*--------------------------------
DeleteF  BSR     SetPar
         CLR     28(A0)
         _GetFileInfo
         MOVE    16(A0),D7
         BEQ.S   .0
         CMP     #-43,D7
         BRA.S   .1
.0       MOVE    #-45,D7
         BTST    #7,40(A0)
         BNE.S   .1
         _Delete
         MOVE    16(A0),D7
.1       RTS
*--------------------------------
GetInfo  BSR     SetPar
         CLR     28(A0)
         _GetFileInfo
         MOVE    16(A0),D7
         RTS
*--------------------------------
MovToEOF LEA     ParaBlk(A5),A0
         CLR.L   12(A0)
         MOVE    RefNum(A4),22(A0)
         MOVE    #2,44(A0)
         CLR.L   46(A0)
         _SetFPos
         MOVE    16(A0),D7
         RTS
MovToSTR LEA     ParaBlk(A5),A0
         CLR.L   12(A0)
         MOVE    RefNum(A4),22(A0)
         MOVE    #1,44(A0)
         CLR.L   46(A0)
         _SetFPos
         MOVE    16(A0),D7
         RTS
*--------------------------------
SetLock  BSR     SetPar
         _SetFilLock
         MOVE    16(A0),D7
         RTS
*--------------------------------
UErr3    MOVE    D7,-(SP)
         LEA     SFRPut(A5),A4
         BSR     CloseF
         MOVE    (SP)+,D7
UErr2    MOVE    D7,-(SP)
         LEA     SFRPut(A5),A4
         BSR     DeleteF
         MOVE    (SP)+,D7
UErr1    BSR     CloseWind
UErr0    MOVE    D7,-(SP)
         LEA     SFRGet(A5),A4
         BSR     CloseF
         MOVE    (SP)+,D7
         BRA.S   Err
AErr3    MOVE    D7,-(SP)
         LEA     SFRGet(A5),A4
         BSR     CloseF
         MOVE    (SP)+,D7
AErr2    MOVE    D7,-(SP)
         LEA     SFRPut(A5),A4
         BSR     CloseF
         MOVE    (SP)+,D7
AErr1    MOVE    D7,-(SP)
         LEA     SFRPut(A5),A4
         BSR     DeleteF
         MOVE    (SP)+,D7
AErr0    BSR     CloseWind
Err      LEA     TErr(PC),A0
.0       MOVE.B  (A0)+,D0
         BEQ.S   .1
         EXT     D0
         CMP     D0,D7
         BEQ.S   .1
         CLR     D0
         MOVE.B  (A0)+,D0
         ADD     D0,A0
         BRA.S   .0
.1       MOVE.L  A0,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         _ParamText
         MOVEQ   #0,D0
         BSR     Cursor
         CLR     -(SP)
         MOVE    #9,-(SP)
         CLR.L   -(SP)
         _StopAlert
         TST     (SP)+
         BRA     MnuOut
*--------------------------------
ESTR     MACRO
         DATA    #]1
         STR     "]2"
         ENDM
*--------------------------------
TErr     ESTR    -33,"Directory full"
         ESTR    -34,"Disk full"
         ESTR    -36,"Disk I/O"
         ESTR    -39,"End of file"
         ESTR    -44,"Write protected diskette"
         ESTR    -45,"File locked"
         ESTR    -46,"Volume locked"
         ESTR    -47,"File busy"
         ESTR      4,"Bad name"
         ESTR      3,"No checksum"
TChk     EQU     *+13
         ESTR      2,"Checksum ($00)"
TCRC     EQU     *+8
         ESTR      1,"CRC ($0000)"
         ESTR      0,"File system"
         ADJST
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
         CLR.L   -(SP)
         MOVE    #3,-(SP)
         _GetRMenu
         CLR     -(SP)
         _InsertMenu
         _DrawMenuBar
         RTS
*--------------------------------
ProcLogo CLR.L   -(SP)
         MOVE    #2,-(SP)
         CLR.L   -(SP)
         MOVE.L  #-1,-(SP)
         _GetNewWindow
         MOVE.L  (SP),Window1(A5)
         _SetPort
         MOVE    #SystemFont,-(SP)
         _TextFont
         MOVE    #fontSize12,-(SP)
         _TextSize
         MOVE    #1,-(SP)
         _TextFace
         MOVE    #1,-(SP)
         _TextMode
         PEA     Blk1(PC)
         MOVE.L  #Blk1Len,-(SP)
         PEA     Blk1Rect(PC)
         MOVE    #teJustCenter,-(SP)
         _TextBox
         MOVE    #geneva,-(SP)
         _TextFont
         CLR     -(SP)
         _TextFace
         PEA     Blk2(PC)
         MOVE.L  #Blk2Len,-(SP)
         PEA     Blk2Rect(PC)
         MOVE    #teJustCenter,-(SP)
         _TextBox
         MOVE    #monaco,-(SP)
         _TextFont
         MOVE    #fontSize9,-(SP)
         _TextSize
         PEA     Blk3(PC)
         MOVE.L  #Blk3Len,-(SP)
         PEA     Blk3Rect(PC)
         MOVE    #teJustLeft,-(SP)
         _TextBox
;        MOVE    #1,-(SP)
;        _TextFace
         PEA     Blk4(PC)
         MOVE.L  #Blk4Len,-(SP)
         PEA     Blk4Rect(PC)
         MOVE    #teJustCenter,-(SP)
         _TextBox
         MOVE.B  #1,Flag.Logo(A5)
         RTS
Complete CLR.L   -(SP)
         MOVE    #3,-(SP)
         CLR.L   -(SP)
         MOVE.L  #-1,-(SP)
         _GetNewWindow
         MOVE.L  (SP),Window1(A5)
         _SetPort
         MOVE    #SystemFont,-(SP)
         _TextFont
         MOVE    #fontSize12,-(SP)
         _TextSize
         CLR     -(SP)
         _TextFace
         MOVE    #1,-(SP)
         _TextMode
         MOVE    #10,-(SP)
         MOVE    #22,-(SP)
         _MoveTo
         PEA     CStr(PC)
         _DrawString
         MOVE.B  #1,Flag.Logo(A5)
         RTS
ClosLogo TST.B   Flag.Logo(A5)
         BEQ.S   .0
         MOVE.L  Window1(A5),-(SP)
         _DisposWindow
         CLR.B   Flag.Logo(A5)
.0       RTS
*--------------------------------
Blk1Rect DATA    /10,/10,/26,/462
Blk2Rect DATA    /26,/10,/58,/462
Blk3Rect DATA    /74,/10,/184,/462
Blk4Rect DATA    /184,/10,/228,/462
NullStr  STR     ""
Prompt   STR     "Save document as:"
CStr     STR     "File conversion successfully completed!"
Blk1     ASC     "BinHex v5.0"
Blk1Len  EQU     *-Blk1
Blk2     ASC     "by"
         HEX     0D
         ASC     "Yves Lempereur"
Blk2Len  EQU     *-Blk2
Blk3     ASC     "This new and improved version of BinHex is offered "
         ASC     "to you as shareware. Although a copyrighted program, "
         ASC     "you are encouraged to offer a copy of it "
         ASC     "to anyone who wants it. You may not modify or sell "
         ASC     "this program without express written permission of "
         ASC     "the author."
         HEX     0D0D
         ASC     "If you decide to keep and use this program, please "
         ASC     "send $10.00 to the author. Include your name and "
         ASC     "address to be advised on future developments. Your "
         ASC     "support will assure other high quality shareware "
         ASC     "utilities. Thank you."
Blk3Len  EQU     *-Blk3
Blk4     ASC     "Yves Lempereur"
         HEX     0D
         ASC     "28611B Canwood St."
         HEX     0D
         ASC     "Agoura Hills, CA 91301"
         HEX     0D
         ASC     "(818) 991-6540"
Blk4Len  EQU     *-Blk4
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
         DATA    $FFFFFFD7
         STR     "File"
         STR     "Application -> Upload"
         DATA    #0,#'U,#0,#0
         STR     "Download -> Application"
         DATA    #0,#'D,#0,#0
         STR     "-"
         DATA    #0,#0,#0,#0
         STR     "TEXT filter"
         DATA    #0,#0,#$12,#0
         STR     "-"
         DATA    #0,#0,#0,#0
         STR     "Quit"
         DATA    #0,#'Q,#0,#0
         STR     ""
         ENDR
*--------------------------------
         RSRC    MENU,3,resPreLoad
         DATA    /3
         DATA    /0,/0
         DATA    /0
         DATA    /0
         DATA    $FFFFFFFB
         STR     "Edit"
         STR     "Undo"
         DATA    #0,#'Z,#0,#0
         STR     "-"
         DATA    #0,#0,#0,#0
         STR     "Cut"
         DATA    #0,#'X,#0,#0
         STR     "Copy"
         DATA    #0,#'C,#0,#0
         STR     "Paste"
         DATA    #0,#'V,#0,#0
         STR     "Clear"
         DATA    #0,#0,#0,#0
         STR     ""
         ENDR
*--------------------------------
         RSRC    DLOG,1,resPreLoad
         DATA    /70,/100,/174,/400      ; Bounds
         DATA    /1                      ; Wind ID
         DATA    #0,#0                   ; Visible
         DATA    #0,#0                   ; NoGoAway
         DATA    0                       ; refCon
         DATA    /1                      ; Item ID
         STR     ""                      ; Title
         ENDR
*--------------------------------
         RSRC    DITL,1,resPreLoad
         DATA    /5-1                    ; Number of Item
         DATA    0
         DATA    /64,/230,/84,/290       ; Disp Rect
         DATA    #4                      ; Type
         STR     "OK"                    ; Content
         DATA    0
         DATA    /20,/244,/52,/276
         DATA    #32+128
         DATA    #2,/128
         DATA    0
         DATA    /20,/10,/36,/200
         DATA    #8+128
         STR     "BinHex v5.0  (MacBinary)"
         DATA    0
         DATA    /44,/10,/60,/200
         DATA    #8+128
         STR     "written by Yves Lempereur"
         HEX     00
         DATA    0
         DATA    /68,/10,/84,/200
         DATA    #8+128
         STR     "Copyright 1985 by Mainstay"
         ENDR
*--------------------------------
         RSRC    ALRT,9,resPreLoad
         DATA    /100,/100,/190,/400
         DATA    /9
         DATA    /$5555
         ENDR
*--------------------------------
         RSRC    DITL,9,resPreLoad
         DATA    /2-1
         DATA    0
         DATA    /60,/230,/80,/290
         DATA    #4
         STR     "OK"
         DATA    0
         DATA    /27,/72,/43,/280
         DATA    #8+128
         STR     "^0 error."
         HEX     00
         ENDR
*--------------------------------
         RSRC    WIND,1,resPreLoad
         DATA    /70,/100,/186,/400
         DATA    /1
         DATA    #1,#0
         DATA    #0,#0
         DATA    0
         STR     ""
         ENDR
*--------------------------------
         RSRC    WIND,2,resPreLoad
         DATA    /40,/20,/280,/492
         DATA    /1
         DATA    #1,#0
         DATA    #0,#0
         DATA    0
         STR     ""
         ENDR
*--------------------------------
         RSRC    WIND,3,resPreLoad
         DATA    /70,/105,/105,/390
         DATA    /1
         DATA    #1,#0
         DATA    #0,#0
         DATA    0
         STR     ""
         ENDR
*--------------------------------
         RSRC    ICON,128,resPreLoad
         HEX     00000000000F00000009800000094000
         HEX     0009E000000820000008200000082000
         HEX     007FFC0000200800007FFC0000400400
         HEX     005014000040040001C0078000400480
         HEX     004004800050148000400480007FFC9E
         HEX     002008FE007FFC1E0002800000044000
         HEX     0008700000108B00002167000013FB00
         HEX     00096300000583000002FF0000010300
         ENDR
*--------------------------------
         RSRC    BnHq,0,resPurgeable
         STR     "BinHex v5.0 -- 04/19/85"
         ENDR
*--------------------------------
         RSRC    ICN#,128,resPurgeable
         HEX     0FFFFE00080003000800028008004240
         HEX     08006220087FF210087FFBF8087FF008
         HEX     08706008087040080870000808700008
         HEX     087000080870000808703F0809FC4088
         HEX     08F88048087130280821C818080E7F0F
         HEX     04023007020100070100800700806007
         HEX     00401FE70020021F0010040700080800
         HEX     00041000000220000001400000008000
*
         HEX     0FFFFE000FFFFF000FFFFF800FFFFFC0
         HEX     0FFFFFE00FFFFFF00FFFFFF80FFFFFF8
         HEX     0FFFFFF80FFFFFF80FFFFFF80FFFFFF8
         HEX     0FFFFFF80FFFFFF80FFFFFF80FFFFFF8
         HEX     0FFFFFF80FFFFFF80FFFFFF80FFFFFFF
         HEX     07FFFFFF03FFFFFF01FFFFFF00FFFFFF
         HEX     007FFFFF003FFE1F001FFC07000FF800
         HEX     0007F0000003E0000001C00000008000
         ENDR
*--------------------------------
         RSRC    ICN#,129,resPurgeable
         HEX     0FFFFE00080003000A48028009500240
         HEX     080002200B180210080003F809500008
         HEX     0A480008080000080800000808000008
         HEX     08000008080080080801400808022008
         HEX     08043808080845880810B3880809FD88
         HEX     0804B1880802C18808017F8808008188
         HEX     08000008080000080800000808000008
         HEX     0800000808000008080000080FFFFFF8
*
         HEX     0FFFFE000FFFFF000FFFFF800FFFFFC0
         HEX     0FFFFFE00FFFFFF00FFFFFF80FFFFFF8
         HEX     0FFFFFF80FFFFFF80FFFFFF80FFFFFF8
         HEX     0FFFFFF80FFFFFF80FFFFFF80FFFFFF8
         HEX     0FFFFFF80FFFFFF80FFFFFF80FFFFFF8
         HEX     0FFFFFF80FFFFFF80FFFFFF80FFFFFF8
         HEX     0FFFFFF80FFFFFF80FFFFFF80FFFFFF8
         HEX     0FFFFFF80FFFFFF80FFFFFF80FFFFFF8
         ENDR
*--------------------------------
         RSRC    FREF,128,resPurgeable
         ASC     "APPL"
         DATA    /0
         STR     ""
         ENDR
*--------------------------------
         RSRC    FREF,129,resPurgeable
         ASC     "TEXT"
         DATA    /1
         STR     ""
         ENDR
*--------------------------------
         RSRC    BNDL,128,resPurgeable
         ASC     "BnHq"
         DATA    /0
         DATA    /2-1
         ASC     "ICN#"
         DATA    /2-1
         DATA    /0,/128
         DATA    /1,/129
         ASC     "FREF"
         DATA    /2-1
         DATA    /0,/128
         DATA    /1,/129
         ENDR
*================================
         END
