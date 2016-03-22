
extensions [ table sock2 ]

;------------------------------------
; globals
;------------------------------------

globals
[
  patch.pixels     ; effectively patch-size

  railTop-height      ; rail ycor
  railBottom-height   ; rail ycor
  railLeft-width      ; rail xcor

  ;working table
  tableTop.height
  tableBottom.height
  tableLeft.width


  floor.height

  col.count        ; no. horizontal columns
  row.count        ; no. vertical columns

  col.pixels
  col.size         ; size of a column - width & other uses
  row.size


  cmd-stack        ; stack (kinda) of commands for execution
  cmd-rules        ; rules for cmd expansion & execution
  shapes-map       ; a map of shrdlu shapes to NL shapes

  arm0
  arm1
  arm2

  arm.pixels
  arm.size
  arm.retracted?
  arm.holds



  top-arm.base-height
  bottom-arm.base-height
  left-arm.base-width


  ratchet0
  ratchet1
  ratchet2

  rail.color
  lines0            ; this one is a set
  lines1
  lines2

  riggings0
  riggings1
  riggings2

  output-indent
]

to globals.setup
  set patch.pixels 10
  set col.count 10
  set row.count 10
  set col.pixels 60

  set arm.pixels 18
  set rail.color blue

  set col.size (col.pixels / patch.pixels )
  set arm.size (arm.pixels / patch.pixels )

  set railTop-height      max-pycor - 2
  set railBottom-height   min-pycor + 2
  set railLeft-width      min-pxcor + 2

  set tableTop.height     max-pycor - 6
  set tableBottom.height  min-pycor + 6
  set tableLeft.width     min-pxcor + 6

  set floor.height 10

  set cmd-stack ""


  let #expandTR (gen "Tr" col.size)
  let #expandTL (gen "Tl" col.size)

  let #expandBR (gen "Br" col.size)
  let #expandBL (gen "Bl" col.size)

  let #expandLR (gen "Lr" col.size)
  let #expandLL (gen "Ll" col.size)

  let #expandL (gen "l" col.size)

  set cmd-rules table:from-list
  (list

    (list "TR" (task [cmd-stack.push #expandTR]) )
    (list "TL" (task [cmd-stack.push #expandTL]) )


    (list "BR" (task [cmd-stack.push #expandBR]) )
    (list "BL" (task [cmd-stack.push #expandBL]) )

    (list "LR" (task [cmd-stack.push #expandLR]) )
    (list "LL" (task [cmd-stack.push #expandLL]) )


    (list "TD" (task [cmd-stack.push (gen "Td" arm.dist-to-top-of-col)]) )
    (list "BD" (task [cmd-stack.push (gen "Bd" arm.dist-to-bottom-of-col)]) )
    (list "LD" (task [cmd-stack.push (gen "Ld" arm.dist-to-left-of-col)]) )



;    (list "U" (task [arm.retract])  )
    (list "TU" (task [Top.arm.retract])  )
    (list "BU" (task [Bottom.arm.retract])  )
    (list "LU" (task [Left.arm.retract])  )
;

    ;; bbot controls
    (list "Tr" (task [top.arm.cmd-right]) )
    (list "Tl" (task [top.arm.cmd-left]) )
    (list "Td" (task [top.arm.cmd-down]) )
    (list "Tu" (task [top.arm.cmd-up]) )

    (list "Br" (task [bottom.arm.cmd-right]) )
    (list "Bl" (task [bottom.arm.cmd-left]) )
    (list "Bd" (task [bottom.arm.cmd-down]) )
    (list "Bu" (task [bottom.arm.cmd-up]) )

    (list "Lr" (task [left.arm.cmd-right]) )
    (list "Ll" (task [left.arm.cmd-left]) )
    (list "Ld" (task [left.arm.cmd-down]) )
    (list "Lu" (task [left.arm.cmd-up]) )



;    (list "d" (task [top.arm.cmd-down ]) )
;    (list "u" (task [top.arm.cmd-up   ]) )

    )

end


;------------------------------------
; startup & setup
;------------------------------------


to startup
  globals.setup
  world.set-size
  setup
end


to setup
  clear-all
  globals.setup
  patches.setup
  rail.setup
  reset-ticks
end


;------------------------------------
; patches
;------------------------------------

to patches.setup
  ask patches [ set pcolor grey]

  ; table patches

  ask patches with [pycor = tableTop.height  and pxcor > tableLeft.width ]
  [ set pcolor 2 ]

  ask patches with [pycor = tableBottom.height and pxcor > tableLeft.width]
  [ set pcolor 2 ]

  ask patches with [pxcor = tableLeft.width and pycor < tableTop.height + 1 and pycor > tableBottom.height - 1]
  [ set pcolor 2 ]

  ;;numbers

  ask patches with [(pycor = tableBottom.height - 2) and (pxcor mod col.size) = 2]
  [ set plabel (floor (pxcor / (col.size ) ))
    set plabel-color 1
  ]

  ask patches with [(pycor mod col.size) = 2 and (pxcor = tableLeft.width - 2)]
  [ set plabel (floor (pycor / (col.size ) ))
    set plabel-color 1
  ]


;  ask patches with [(pycor = tableTop.height + 2) and (pxcor mod col.size) = 2]
;  [ set plabel (floor (pxcor / col.size))
;    set plabel-color 1
;  ]
;
;  ask patches with [(pxcor = tableLeft.width - 2) and (pycor mod col.size) = 2]
;  [ set plabel (floor (pycor / col.size))
;    set plabel-color 1
;  ]
;

;  let #i 0
;  repeat col.count
;  [ crt 1
;    [ setxy (#i * col.size + 4) (floor.height - 2)
;      set size 0
;      set label floor (pxcor / col.size)
;      set #i (#i + 1)
;    ]
;  ]
end



;------------------------------------
; world control
;------------------------------------


to world.set-size
  let #min-px   0
  let #max-px   col.count * col.size     ;;
  let #min-py   0
  let #max-py   col.count * col.size     ;;

  set-patch-size 10
  resize-world  #min-px #max-px #min-py #max-py
end



;------------------------------------
; rail
;------------------------------------

breed [rail-bars rail-bar]
breed [rail-lines rail-line]
breed [arms arm]


to rail.setup
  ;; draw Top horizontal rail
  ask patches with [pycor = railTop-height ]  ;; and pxcor mod 2 = 0
  [ ;set pcolor 41
    sprout-rail-bars 1
    [ set shape "rail3"
      set color black
      set size 1
    ]
  ]

  ;; draw Bottom horizontal rail
  ask patches with [pycor = railBottom-height ]
  [
   sprout-rail-bars 1
   [
     set shape "rail3"
     set color black
     set size 1
   ]
  ]

  ;; draw left vertial rail
  ask patches with [pxcor = railLeft-width ]
  [
   sprout-rail-bars 1
   [
    set shape "rail-line"
    set color black
    set size 1
   ]
  ]

  ;; draw the top ratchet
  let #half-col int (col.size / 2) + 5
  crt 1 ;; the ratchet
  [ setxy #half-col (railTop-height)
    set color rail.color
    set size 3
    set shape "rail-star"
    set heading 0
    set ratchet0 self
  ]

  ;; draw the bottom ratchet


  crt 1
  [
    setxy (#half-col) (railBottom-height)
    set color rail.color
    set size 3
    set shape "rail-star"
    set heading 37
    set ratchet1 self
  ]


  ;; draw the left ratchet

  crt 1
  [
   setxy (railLeft-width ) (#half-col)
   set color rail.color
   set size 3
   set shape "rail-star"
   set heading 37
   set ratchet2 self
  ]

  ;; draw 2 elements between ratchet & arm for Top
  set lines0 (turtle-set nobody)
  foreach [1 2]
  [ create-rail-lines 1
    [ setxy #half-col (railTop-height - ?)
      init-rail-horizontal-line-agent
      set lines0 (turtle-set lines0 self)
    ]
  ]

  ;; draw 2 elements between ratchet & arm for bottom
  set lines1 (turtle-set nobody)
  foreach [-1 -2]
  [ create-rail-lines 1
    [
      setxy #half-col (railBottom-height - ? )
      init-rail-horizontal-line-agent
      set lines1 (turtle-set lines1 self)
    ]
  ]

  ;; draw 2 elements between ratchet & arm for left
  set lines2 (turtle-set nobody)
  foreach [-1 -2]
  [ create-rail-lines 1
    [
      setxy (railLeft-width - ? ) #half-col
      init-rail-vertical-line-agent
      set lines2 (turtle-set lines2 self)
    ]
  ]


  ;; draw the top arm
  set top-arm.base-height (railTop-height - 3)
  create-arms 1
  [ setxy #half-col top-arm.base-height
    set color black
    set size  3
    set heading 0
    set shape "pusher"
    rt 90


    set arm0 self
    set arm.retracted? true
    set arm.holds nobody
  ]

  ;; draw the bottom arm
  set bottom-arm.base-height (railBottom-height + 3)
  create-arms 1
  [
   setxy #half-col bottom-arm.base-height
   set color black
   set size 3
   set heading 0
   set shape "pusher"
   rt 270
   set arm1 self
   set arm.retracted? true
   set arm.holds nobody
  ]

  ;; draw the left arm

  set left-arm.base-width (railLeft-width + 3)
  create-arms 1
  [
   setxy left-arm.base-width #half-col
   set color black
   set size 3
   set heading 0
   set shape "pusher"
   set arm2 self
   set arm.retracted? true
   set arm.holds nobody
  ]

  ;; arm + ratchet, etc are grouped as riggings
  ;; for coordinated horizontal movements
  set riggings0 (turtle-set arm0 lines0 ratchet0)

  set riggings1 (turtle-set arm1 lines1 ratchet1)

  set riggings2 (turtle-set arm2 lines2 ratchet2)
end


to init-rail-horizontal-line-agent
  set color rail.color
  set size 1
  set shape "rail-line"
end

to init-rail-vertical-line-agent
  set color rail.color
  set size 1
  set shape "rail3"
end



;------------------------------------
; arm procedures
;------------------------------------


;; moving Left and Right

;;Right
to top.arm.cmd-right
  arm.move-horiz riggings0 1 ratchet0
end

to bottom.arm.cmd-right
  arm.move-horiz riggings1 1 ratchet1
end

to left.arm.cmd-right
  arm.move-vertical 1
end

;;Left
to top.arm.cmd-left
  arm.move-horiz riggings0 -1 ratchet0
end

to bottom.arm.cmd-left
  arm.move-horiz riggings1 -1 ratchet1
end

to left.arm.cmd-left
  arm.move-vertical -1
end


;; Horizontal
to arm.move-horiz [#pos #dx #rat]
  ask (turtle-set #pos arm.holds)
  [ setxy (xcor + #dx) ycor ]
  ask #rat [ rt 30 ]
end

;;vertical
to arm.move-vertical [#dx]
  ask (turtle-set riggings2 arm.holds)
  [ setxy xcor ( ycor + #dx ) ]
    ask ratchet2 [ rt 30 ]
end


;; vertical up
to top.arm.cmd-down
  arm.vertical.cmd-down ratchet0 arm0 1
end

to bottom.arm.cmd-down
  arm.vertical.cmd-down ratchet1 arm1 -1
end

to arm.vertical.cmd-down [#rat #arm #dy]
  ask #rat [ set color red ]
  ask #arm
  [ hatch-rail-lines 1 [init-rail-horizontal-line-agent]
    setxy xcor (ycor - #dy)
  ]
  ask (turtle-set arm.holds)
  [setxy xcor (ycor - #dy) ]
end

;; vertical down

to top.arm.cmd-up
  arm.cmd-up ratchet0 arm0 1
end

to bottom.arm.cmd-up
  arm.cmd-up ratchet1 arm1 -1
end

to arm.cmd-up [#rat #arm #dy]
  ask #rat [set color blue ]
  ask #arm
  [
   setxy xcor (ycor + #dy)
   ask rail-lines-here [die]
  ]
  ask (turtle-set arm.holds)
  [
     setxy xcor (ycor + #dy)
  ]
end

;; Horizontal up

to left.arm.cmd-down
  ask ratchet2 [set color red ]
  ask arm2
  [
    hatch-rail-lines 1 [init-rail-vertical-line-agent]
    setxy (xcor + 1) ycor
  ]

  ;;moving arm
  ask (turtle-set arm.holds)
  [setxy (xcor + 1) ycor ]
end

to left.arm.cmd-up
  ask ratchet2 [set color blue ]
  ask arm2
  [
   setxy (xcor - 1) ycor
   ask rail-lines-here [die]
  ]

  ;;moving block
  ask (turtle-set arm.holds)
  [
   setxy (xcor - 1) ycor
  ]
end

to exec.move-to [#d #col]
  assert (#col >= 0 and #col < col.count) "trying to move to a column that dosn't exist"
 ; inform 1 (list "moving to" #col)

 let #c 0

  ifelse (#d = "B")
  [set #c (#col - Bottom.arm.col )]
  [
     ifelse (#d = "T")
  [set #c (#col - Top.arm.col )]
  ;;if not top or bottom assume left
  [set #c (#col - Left.arm.col )]

    ]


  ifelse (#c >= 0)
  [ cmd-stack.queue (gen (word #d "R") #c) ]
  [ cmd-stack.queue (gen (word #d "L") (abs #c)) ]
  cmd-stack.run
 ; inform -1 ["-moving complete"]
end


;



;=============================================================================================================================================================================================
; Reporting distance for Down Method
;=============================================================================================================================================================================================


to-report arm.dist-to-top-of-col
  let #block block.at-top-of Top.arm.col
  let #dist [ycor] of arm0

  ifelse (#block = nobody)
  [ set #dist (#dist - floor.height) ]
  [ set #dist (#dist - ([ycor] of #block) - ([size] of #block) / 2) ]                                                    ;;stop when tuching



  set #dist (#dist - (arm.size / 2) + 1)
  report #dist
end

to-report arm.dist-to-bottom-of-col
  let #block block.at-bottom-of Bottom.arm.col
  let #dist [ycor] of arm1

  ifelse (#block = nobody)
  [ set #dist (#dist + ( [ycor] of arm0 - floor.height)) ]
  [ set #dist ([ycor] of #block - [size] of #block / 2) - #dist   ]

  set #dist (#dist - (arm.size / 2) + 1)
  report #dist
end

;;
;; Left
to-report arm.dist-to-left-of-col
  let #block block.at-left-of Left.arm.col
  let #dist [xcor] of arm2

  ifelse (#block = nobody)
  [ set #dist (#dist + ( col.pixels - floor.height))]
  [ set #dist ([xcor] of #block - [size] of #block / 2) - #dist   ]


  set #dist (#dist - (arm.size / 2) + 1)
  report #dist

end

;=============================================================================================================================================================================================
; Arm Retracting
;=============================================================================================================================================================================================


to Top.arm.retract

  let #dist top-arm.base-height - ([ycor] of arm0)
  cmd-stack.queue (gen "Tu" #dist)
  cmd-stack.run
  ask ratchet0 [ set color black ]
end

to Bottom.arm.retract

  let #dist [ycor] of arm1 - bottom-arm.base-height
  cmd-stack.queue (gen "Bu" #dist)
  cmd-stack.run
  ask ratchet1 [ set color Yellow ]
end

to Left.arm.retract

  let #dist [xcor] of arm2 - left-arm.base-width
  cmd-stack.queue (gen "Lu" #dist)
  cmd-stack.run
  ask ratchet2 [ set color black ]
end

;=============================================================================================================================================================================================
; Reporting arm colum
;=============================================================================================================================================================================================

to-report Top.arm.col
    report int (([xcor] of arm0) / col.size)
end

to-report Bottom.arm.col
    report int (([xcor] of arm1) / col.size)
end

to-report Left.arm.col
    report int (([ycor] of arm2) / col.size)
end

;======================================================
; CMD-STACK manipulation
;======================================================


to-report cmd-stack.pop
  let #dat1 (first  cmd-stack)
  set cmd-stack (but-first cmd-stack)
  let #dat2 (first  cmd-stack)
  set cmd-stack (but-first cmd-stack)
  let #dat3 word #dat1 #dat2
  report #dat3
end

to-report cmd-stack.pop2
  let #dat (filter [? != 0] firstn 2 cmd-stack)
    set cmd-stack (but-first cmd-stack)
    report #dat
  end

;; to take first n of a stack
to-report firstn [#n #stack]
  report sublist #stack 0 min list #n (length #stack)
end

to cmd-stack.push [#dat]
  set cmd-stack (word #dat cmd-stack )
end


to cmd-stack.queue [#dat]
  set cmd-stack (word cmd-stack #dat)
end

to cmd-stack.run
  while [not empty? cmd-stack]
  [ cmd-stack.run1 ]
end

to cmd-stack.run1
  let #m cmd-stack.pop

  ifelse (table:has-key? cmd-rules #m)
  [ run (table:get cmd-rules #m) ]
  [
    print (word "unknown command: " #m)
  ]
  tick
end

to-report gen [#str #n]

  set #n (int #n)
  ifelse (#n = 0)
  [ report "" ]
  [ report reduce word n-values #n [#str] ]
end


;================================================================================================================================================================
; Repl
;================================================================================================================================================================
to exec.repl
  let cmd-str sock2:read
  output-print (word "received: " cmd-str)
  run cmd-str
  tick
end

to finrepl [#num]
  loop [
   if (#num = 0) [stop]
   exec.repl
  ]
end


;======================================================
; Shapes making
;======================================================

breed [blocks block]
breed [banners banner]

blocks-own
[block-name shape-name color-name]


to exec.make [#name #clr]

  let #shape (first #name)
  ifelse (#shape = "T")
  [set #shape "blk-triangl"]
  [ifelse (#shape = "C")
    [set #shape "blk-cube"]
    [set #shape "blk-circle"]
    ]


  show  #name
  show #shape
  show 5
  show #clr
  exec.make1 #name #shape 5 #clr
end


to exec.make1 [#name #shape #size #color]
  ;; it will appear in the hand
  ;; assumptions
  ;     (i)  hand is empty
  ;     (ii) hand is retracted
;  inform 1 (list "making" #name #color #shape "- size" #size)

  assert (arm.retracted? = true) "trying to make a block but arm is not retracted"
  assert (arm.holds = nobody) "trying to make a block but arm is holding a block"
  assert (#size <= col.size)  "trying to make a block but size is too big"

  let #b 0
  create-blocks 1
  [ set block-name #name

    set size  #size
    set shape-name #shape
    set color-name #color

    set shape #shape    set color (runresult #color)

    setxy ([xcor] of arm1) ([ycor] of arm2)
   ; arm.hold self
    set #b self  ;; for animation below

    hatch-banners 1
    [ set size  0
      set shape "circle"
      set color (runresult #color)
      set label #name
      set label-color black
      create-link-from myself
      [ tie
        hide-link
      ]
    ]
  ]
;  inform 0 (list "new block is" #b)
  block-flash #b
 ; inform -1 ["-making complete"]
  ask #b [st]
end

;================================================================================================================================================================
; Shapes movement
;================================================================================================================================================================
to pushshapeTwo [#col #to #fr]
  let #num (#to - #fr)

  ifelse (#num < 0)
  [pushshape "T" #col turn-pos #num]
  [pushshape "B" #col #num]

end

to pushshapeOne [#arm  #col #to #fr]
   let #num (#to - #fr)
   pushshape #arm #col #num
end
to pushshape [#arm #col #num]

  let #block block.at-top-of #col

  exec.move-to #arm #col

  cmd-stack.queue (word #arm "D")
  cmd-stack.run

  arm.hold  convert.arm #arm convert.arm2 #arm #col


  cmd-stack.queue (gen (word #arm "d" ) (#num * col.size))

  cmd-stack.run

  arm.unhold convert.arm #arm

  cmd-stack.queue (word #arm "U")
  cmd-stack.run


end

to-report convert.arm [#arm]

  let #myarm "A"

  ifelse (#arm = "T")
  [set #myarm arm0    ]
  [ifelse (#arm = "B")
    [set #myarm arm1]
    [set #myarm arm2 ]
  ]
   report #myarm
end


to-report convert.arm2 [#arm #col]

  let #myblock "A"

  ifelse (#arm = "T")
  [set #myblock block.at-top-of #col]
  [ifelse (#arm = "B")
    [set #myblock block.at-bottom-of #col]
    [set #myblock block.at-left-of #col ]
  ]
   report #myblock
end

to arm.hold [#arm #block]
  ask #arm
  [
  set arm.holds #block
  ]
end


to arm.unhold [#arm]
  ask #arm
  [
  set arm.holds nobody
  ]
end


;================================================================================================================================================================
; Extra
;================================================================================================================================================================

to-report block.at-top-of [#col]
  report max-one-of (blocks with [ xcor = (col.xcor #col)])
  [ycor]
end

to-report block.at-bottom-of [#col]
  report min-one-of (blocks with [ xcor = (col.xcor #col)])
  [ycor]
end

to-report block.at-left-of [#col]
  report min-one-of (blocks with [ ycor = (col.xcor #col)])
  [xcor]
end


to-report col.xcor [#col]
  report (#col * col.size) + (int (col.size / 2)) - 1
end


;

to assert [#x #str]
  if not #x
  [ error (word "assert fails: " #str) ]
end

  ;;block flashing when being maid
to block-flash [#b]
  repeat 5
  [ tick
    ask #b [ ht ]
    tick
    ask #b [ st ]
  ]
end


to-report turn-pos [#num]
  report (#num * -1)
end

to setUpShapes
  ;; making the triangles
  exec.move-to "L" 1
  exec.move-to "B" 2
  exec.make1 "t1" "blk-triangl" 5 "blue"
  exec.move-to "B" 3
  exec.make1 "t2" "blk-triangl" 5 "green"
  exec.move-to "B" 4
  exec.make1 "t3" "blk-triangl" 5 "yellow"
  exec.move-to "B" 5
  exec.make1 "t4" "blk-triangl" 5 "red"

  exec.move-to "B" 1
  exec.move-to "L" 2

  ;; making the circles
  exec.make1 "c1" "blk-circle" 5 "blue"
  exec.move-to "L" 3
  exec.make1 "c2" "blk-circle" 5 "green"
  exec.move-to "L" 4
  exec.make1 "C3" "blk-circle" 5 "yellow"
  exec.move-to "L" 5
  exec.make1 "C4" "blk-circle" 5 "red"

  ;; making the Sqares
  exec.move-to "L" 8
  exec.move-to "B" 2
  exec.make1 "S1" "blk-cube" 5 "blue"
  exec.move-to "B" 3
  exec.make1 "S2" "blk-cube" 5 "green"
  exec.move-to "B" 4
  exec.make1 "S3" "blk-cube" 5 "yellow"
  exec.move-to "B" 5
  exec.make1 "S4" "blk-cube" 5 "red"

end
@#$#@#$#@
GRAPHICS-WINDOW
3
10
623
651
-1
-1
10.0
1
10
1
1
1
0
1
1
1
0
60
0
60
1
1
1
ticks
30.0

BUTTON
632
10
710
46
NIL
startup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
19
665
613
710
NIL
cmd-stack
17
1
11

TEXTBOX
744
158
1006
214
different cmds\nexec.move-to \"T\" 4\nexec.make1 \"cube\" \"blk-cube\" 5 \"blue\"\npushshape \"T\" 3 3
11
0.0
1

INPUTBOX
630
60
714
120
port-num
2222
1
0
Number

BUTTON
632
133
707
166
connect
print (word \"connecting on \" port-num)\nsock2:connect-local port-num\nprint \"socket connected\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
630
183
713
216
NIL
exec.repl
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
655
233
1031
680
12

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

blk-circle
false
0
Circle -16777216 true false 0 0 300
Circle -7500403 true true 15 15 270

blk-cube
false
0
Rectangle -16777216 true false 0 0 300 300
Rectangle -7500403 true true 15 15 285 285

blk-triangl
false
0
Polygon -16777216 true false 150 0 300 300 0 300
Polygon -7500403 true true 150 30 30 285 270 285

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

pusher
true
0
Polygon -5825686 true false 150 15 195 15 195 285 150 285 150 225 120 225 120 180 45 180 45 120 120 120 120 75 150 75 150 15 165 15

rail-line
false
1
Rectangle -7500403 false false 60 0 210 300
Rectangle -2674135 true true 210 0 240 300
Rectangle -2674135 true true 45 0 75 300
Rectangle -2674135 true true 75 0 210 75
Rectangle -2674135 true true 75 150 210 225

rail-star
true
0
Polygon -16777216 true false 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108
Circle -7500403 true true 118 118 62

rail-v
true
1
Polygon -2674135 true true 45 300 45 0 270 0 270 300 240 300 240 75 75 75 75 300 45 300 75 300
Rectangle -2674135 true true 75 150 240 240

rail3
false
1
Rectangle -7500403 false false 0 90 300 240
Rectangle -2674135 true true 0 60 300 90
Rectangle -2674135 true true 0 225 300 255
Rectangle -2674135 true true 0 90 75 225
Rectangle -2674135 true true 150 90 225 225

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
