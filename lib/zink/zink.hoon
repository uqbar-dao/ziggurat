/-  *zink
/+  *zink-pedersen
=>  |%
    +$  good      (unit *)
    +$  fail      (list [@ta *])
    +$  body      (each good fail)
    +$  cache     (map * phash)
    +$  appendix  [cax=cache hit=hints bud=@ tep=@]
    +$  book      (pair body appendix)
    --
|%
++  zebra                                                 ::  bounded zk +mule
  |=  [bud=@ud cax=cache [s=* f=*]]
  ^-  book
  %.  [s f]
  %*  .  zink
    app  [cax ~ bud 0]
  ==
::
++  hash
  |=  [n=* cax=(map * phash)]
  ^-  phash
  ?@  n
    ?:  (lte n 12)
      =/  ch  (~(get by cax) n)
      ?^  ch  u.ch
      (hash:pedersen n 0)
    (hash:pedersen n 0)
  ?^  ch=(~(get by cax) n)
    u.ch
  =/  hh  $(n -.n)
  =/  ht  $(n +.n)
  (hash:pedersen hh ht)
::
++  trace-to-matrix
  |=  hit=hints
  ^-  (list (list @x))
  =|  lis=(list (list @x))
  |-
  ?~  hit  lis
  ?~  i.hit  $(hit t.hit)
  %_    $
    hit  t.hit
  ::
      lis
    ?-    +<.i.hit
        %0  (snoc lis [sh `@x`+< `@x`axis leaf path]:i.hit)
    ::
        %1  (snoc lis [sh `@x`+< res ~]:i.hit)
    ::
        %2
      =/  f1rows  (trace-to-matrix f1.i.hit)
      =/  f2rows  (trace-to-matrix f2.i.hit)
      %+  weld
        %+  weld
          %+  snoc  lis
          [sh `@x`+< f1h f2h p1h p2h hres `@x`f1step `@x`f2step ~]:i.hit
        f1rows
      f2rows
    ::
        %cons
      =/  f1rows  (trace-to-matrix f1.i.hit)
      =/  f2rows  (trace-to-matrix f2.i.hit)
      %+  weld
        %+  weld
          %+  snoc  lis
          [sh `@x`+< f1h f2h p1h p2h `@x`f1step `@x`f2step ~]:i.hit
        f1rows
      f2rows
    ==
  ==
::
++  matrix-to-csv
  |=  lis=(list (list @x))
  ^-  cord
  =|  cords=(list cord)
  |-
  ?~  lis
    (rap 3 (join '\0a' (flop cords)))
  %_  $
    lis  t.lis
  ::
      cords
    =/  len  (lent i.lis)
    :_  cords
    =<  c
    %+  roll  i.lis
    |=  [h=@x [c=@t i=@]]
    =+  (scot %x h)
    :_  +(i)
    %^  cat  3  c
    ?:  =(+(i) len)  -
    (cat 3 - ', ')
  ==
::
++  constrain
  |=  hit=hints
  ^-  ?
  =/  i  0
  |^
  =/  b=?  %.y
  |-
  ?~  hit
    b
  ?.  b  b
  =^  res  b
    (deep i.hit)
  ?.  b  b
  =.  b
    (broad res)
  ?.  b  b
  $(hit t.hit, i +(i))
  ::
  ::  +broad: verify constraints across instructions in the list
  ++  broad
    |=  hin=(unit thee-hint)
    ^-  ?
    ?~  hin
      %.y
    ?-    +<.u.hin
      ?(%0 %1 %cons)  %.n
    ::
        %2
      ?~  hit    %.n
      ?~  t.hit  %.n
      ?&  (ver-s-hash p1h.u.hin i.t.hit)
          (ver-f-hash p2h.u.hin i.t.hit)
      ==
    ==
  ::
  ::  +deep: verify constraints recursively in the tree
  ++  deep
    |=  the=thee
    ^-  [(unit thee-hint) ?]
    ?~  the
      [~ %.y]
    ?-    +<.the
        %0
      :-  ~
      ?:  =(0 axis.the)  %.n
      ::  TODO: assert formula hash = hash(0 (hash axis))  ???
      =/  leaf  leaf.the
      =/  root  *phash
      |-
      ?:  =(1 axis.the)  =(sh.the leaf)
      ?~  path.the       %.n
      =*  sib  i.path.the
      ?:  =(2 axis.the)
        =.  root  (hash:pedersen leaf sib)
        =(sh.the root)
      ?:  =(3 axis.the)
        =.  root  (hash:pedersen sib leaf)
        =(sh.the root)
      ?:  =((mod axis.the 2) 0)
        $(axis.the (div axis.the 2), leaf (hash:pedersen leaf sib), path.the t.path.the)
      $(axis.the (div (dec axis.the) 2), leaf (hash:pedersen sib leaf), path.the t.path.the)
    ::
        %1
      [~ %.y]
    ::
        %2
      =/  f1d  (constrain f1.the)
      ?.  f1d  [~ %.n]
      =/  f2d  (constrain f2.the)
      ?.  f2d  [~ %.n]
      :-  `the
      ?&  (ver-f-hash f1h.the -.f1.the)
          (ver-f-hash f2h.the -.f2.the)
          (ver-p-hash p1h.the (rear f1.the))
          (ver-p-hash p2h.the (rear f2.the))
          =(f1step.the (roll f1.the add-step))
          =(f2step.the (roll f2.the add-step))
      ==
    ::
        %cons
      =/  f1d  (constrain f1.the)
      ?.  f1d  [~ %.n]
      =/  f2d  (constrain f2.the)
      ?.  f2d  [~ %.n]
      :-  ~
      ?&  (ver-f-hash f1h.the -.f1.the)
          (ver-f-hash f2h.the -.f2.the)
          (ver-p-hash p1h.the (rear f1.the))
          (ver-p-hash p2h.the (rear f2.the))
          =(f1step.the (roll f1.the add-step))
          =(f2step.the (roll f2.the add-step))
      ==
    ==
  ::
  ++  add-step
    |=  [t=thee b=@]
    ^-  @
    ?~  t  0
    ?-    +<.t
      ?(%0 %1)  1
      %2        (add [f1step f2step]:t)
      %cons     (add [f1step f2step]:t)
    ==
  ::
  ++  ver-f-hash
    |=  [fh=phash t=thee]
    ^-  ?
    ?~  t  %.n
    .=  fh
    %-  hash:pedersen
    ?-    +<.t
      %0     [(hash:pedersen 0 0) (hash:pedersen axis.t 0)]
      %1     [(hash:pedersen 1 0) res.t]
      %2     [(hash:pedersen 2 0) (hash:pedersen [f1h f2h]:t)]
      %cons  [f1h f2h]:t
    ==
  ::
  ++  ver-p-hash
    |=  [ph=phash t=thee]
    ^-  ?
    ?~  t  %.n
    .=  ph
    ?-    +<.t
      %0     leaf.t
      %1     res.t
      %2     hres.t
      %cons  (hash:pedersen [p1h p2h]:t)
    ==
  ::
  ++  ver-s-hash
    |=  [sh=phash t=thee]
    ^-  ?
    ?~  t  %.n
    =(sh sh.t)
  --
::
++  pedometer
  |=  [tep=@ hin=thee-hint]
  ^-  @
  .+
  ?-    +<.hin
    ?(%0 %1)  tep
  ::
      %2
    %+  add  tep
    %+  add  f1step.hin
    f2step.hin
  ::
      %cons
    %+  add  tep
    %+  add  f1step.hin
    f2step.hin
  ==
::
++  zink
  =|  appendix
  =*  app  -
  =|  trace=fail
  |=  [s=* f=*]
  ^-  book
  |^
  |-
  =^  sh=(unit phash)  app  (hash s)
  ?~  sh
    [%&^~ app]
  ?+    f
    ~&  f
    [%|^trace app]
  ::
      [^ *]
    =/  old-hit  hit
    =/  old-tep  tep
    =^  hed=body  app
      $(f -.f, hit ~)
    ?:  ?=(%| -.hed)  [%|^trace app]
    ?~  p.hed  [%&^~ app]
    =^  hedp=(unit phash)  app  (hash u.p.hed)
    ?~  hedp  [%&^~ app]
    =/  hed-hit  hit
    =/  hed-tep  tep
    =^  tal=body  app
      $(f +.f, hit ~)
    ?:  ?=(%| -.tal)  [%|^trace app]
    ?~  p.tal  [%&^~ app]
    =^  talp=(unit phash)  app  (hash u.p.tal)
    ?~  talp  [%&^~ app]
    =*  tal-hit  hit
    =*  tal-tep  tep
    =^  hhed=(unit phash)  app  (hash -.f)
    ?~  hhed  [%&^~ app]
    =^  htal=(unit phash)  app  (hash +.f)
    ?~  htal  [%&^~ app]
    :-  [%& ~ u.p.hed^u.p.tal]
    =+  u.sh^[%cons u.hhed u.htal u.hedp u.talp hed-hit tal-hit hed-tep tal-tep]
    %_    app
      hit  (snoc old-hit -)
      tep  (pedometer old-tep -)
    ==
  ::
      [%0 axis=@]
    =^  part  bud
      (frag axis.f s bud)
    ?~  part  [%&^~ app]
    ?~  u.part  [%|^trace app]
    =^  hpart=(unit phash)         app  (hash u.u.part)
    ?~  hpart  [%&^~ app]
    =^  hsibs=(unit (list phash))  app  (merk-sibs s axis.f)
    ?~  hsibs  [%&^~ app]
    :-  [%& ~ u.u.part]
    =+  u.sh^[%0 axis.f u.hpart u.hsibs]
    app(hit (snoc hit -), tep 1)
  ::
      [%1 const=*]
    =^  hres=(unit phash)  app  (hash const.f)
    ?~  hres  [%&^~ app]
    :-  [%& ~ const.f]
    =+  u.sh^[%1 u.hres]
    app(hit (snoc hit -), tep 1)
  ::
      [%2 sub=* for=*]
    =^  hsub=(unit phash)  app  (hash sub.f)
    ?~  hsub  [%&^~ app]
    =^  hfor=(unit phash)  app  (hash for.f)
    ?~  hfor  [%&^~ app]
    =/  old-hit  hit
    =/  old-tep  tep
    =^  subject=body  app
      $(f sub.f, hit ~)
    ?:  ?=(%| -.subject)  [%|^trace app]
    ?~  p.subject  [%&^~ app]
    =^  hsubp=(unit phash)  app  (hash u.p.subject)
    ?~  hsubp  [%&^~ app]
    =/  sub-hit  hit
    =/  sub-tep  tep
    =^  formula=body  app
      $(f for.f, hit ~)
    ?:  ?=(%| -.formula)  [%|^trace app]
    ?~  p.formula  [%&^~ app]
    =*  for-hit  hit
    =*  for-tep  tep
    =^  hforp=(unit phash)  app  (hash u.p.formula)
    ?~  hforp  [%&^~ app]
    =^  hres=(unit phash)  app  (hash [u.p.subject u.p.formula])
    ?~  hres  [%&^~ app]
    =+  :-  u.sh
        :*  %2  u.hsub  u.hfor  u.hsubp  u.hforp  u.hres
            sub-hit   for-hit   sub-tep   for-tep
        ==
    %_  $
      s    u.p.subject
      f    u.p.formula
      hit  (snoc old-hit -)
      tep  (pedometer old-tep -)
    ==
  ==
  ::
  ++  frag
    |=  [axis=@ noun=* bud=@ud]
    ^-  [(unit (unit)) @ud]
    ?:  =(0 axis)  [`~ bud]
    |-  ^-  [(unit (unit)) @ud]
    ?:  =(0 bud)  [~ bud]
    ?:  =(1 axis)  [``noun (dec bud)]
    ?@  noun  [`~ (dec bud)]
    =/  pick  (cap axis)
    %=  $
      axis  (mas axis)
      noun  ?-(pick %2 -.noun, %3 +.noun)
      bud   (dec bud)
    ==
  ::
  ++  edit
    |=  [axis=@ target=* value=* bud=@ud]
    ^-  [(unit (unit)) @ud]
    ?:  =(1 axis)  [``value bud]
    ?@  target  [`~ bud]
    ?:  =(0 bud)  [~ bud]
    =/  pick  (cap axis)
    =^  mutant  bud
      %=  $
        axis    (mas axis)
        target  ?-(pick %2 -.target, %3 +.target)
        bud     (dec bud)
      ==
    ?~  mutant  [~ bud]
    ?~  u.mutant  [`~ bud]
    ?-  pick
      %2  [``[u.u.mutant +.target] bud]
      %3  [``[-.target u.u.mutant] bud]
    ==
  ::
  ++  hash
    |=  n=*
    ^-  [(unit phash) appendix]
    =/  mh  (~(get by cax) n)
    ?^  mh
      ?:  =(bud 0)  [~ app]
      [mh app(bud (dec bud))]
    ?@  n
      ?:  =(bud 0)  [~ app]
      =/  h  (hash:pedersen n 0)
      :-  `h
      app(cax (~(put by cax) n h), bud (dec bud))
    =^  hh=(unit phash)  app  $(n -.n)
    ?~  hh  [~ app]
    =^  ht=(unit phash)  app  $(n +.n)
    ?~  ht  [~ app]
    =/  h  (hash:pedersen u.hh u.ht)
    ?:  =(bud 0)  [~ app]
    :-  `h
    app(cax (~(put by cax) n h), bud (dec bud))
  ::
  ++  merk-sibs
    |=  [s=* axis=@]
    =|  path=(list phash)
    |-  ^-  [(unit (list phash)) appendix]
    ?:  =(1 axis)
      [`path app]
    ?~  axis  !!
    ?@  s  !!
    =/  pick  (cap axis)
    =^  sibling=(unit phash)  app
      %-  hash
      ?-(pick %2 +.s, %3 -.s)
    ?~  sibling  [~ app]
    =/  child  ?-(pick %2 -.s, %3 +.s)
    %=  $
      s     child
      axis  (mas axis)
      path  [u.sibling path]
    ==
  --
--
