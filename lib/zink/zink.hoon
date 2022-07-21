/-  *zink
/+  *zink-pedersen, *zink-json
=>  |%
    +$  good      (unit (pair * hints))
    +$  fail      (list [@ta *])
    +$  body      (each good fail)
    +$  cache     (map * phash)
    +$  appendix  [cax=cache bud=@]
    +$  book      (pair body appendix)
    --
|%
++  zebra                                                 ::  bounded zk +mule
  |=  [bud=@ud cax=cache [s=* f=*]]
  ^-  book
  %.  [s f]
  %*  .  zink
    app  [cax bud]
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
++  create-hints
  |=  [n=^ h=hints cax=cache]
  ^-  json
  =/  hs  (hash -.n cax)
  =/  hf  (hash +.n cax)
  %-  pairs:enjs:format
  :~  hints+(hints:enjs h)
      subject+s+(num:enjs hs)
      formula+s+(num:enjs hf)
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
  ::~&  >  f
  ?+    f
    ~&  f
    [%|^trace app]
  ::
      [^ *]
    ~&  >  "%cons"
    =^  hed=body  app
      $(f -.f)
    ?:  ?=(%| -.hed)  ~&  61  [%|^trace app]
    ?~  p.hed  [%&^~ app]
    =^  tal=body  app
      $(f +.f)
    ?:  ?=(%| -.tal)  ~&  65  [%|^trace app]
    ?~  p.tal  [%&^~ app]
    =^  hhed=(unit phash)  app  (hash -.f)
    ?~  hhed  [%&^~ app]
    =^  htal=(unit phash)  app  (hash +.f)
    ?~  htal  [%&^~ app]
    =/  hit  [%cons u.hhed u.htal]^(welp q.u.p.hed q.u.p.tal)
    :-  [%& ~ [p.u.p.hed p.u.p.tal] hit]
    app
  ::
      [%0 axis=@]
      ~&  >  "%0"
    =^  part  bud
      (frag axis.f s bud)
    ?~  part  [%&^~ app]
    ?~  u.part  ~&  78  [%|^trace app]
    =^  hpart=(unit phash)         app  (hash u.u.part)
    ?~  hpart  [%&^~ app]
    =^  hsibs=(unit (list phash))  app  (merk-sibs s axis.f)
    ?~  hsibs  [%&^~ app]
    :-  [%& ~ u.u.part ~[[%0 axis.f u.hpart u.hsibs]]]
    app
  ::
      [%1 const=*]
      ~&  >  "%1"
    =^  hres=(unit phash)  app  (hash const.f)
    ?~  hres  [%&^~ app]
    :-  [%& ~ const.f ~[[%1 u.hres]]]
    app
  ::
      [%2 sub=* for=*]
      ~&  >  "%2"
    =^  hsub=(unit phash)  app  (hash sub.f)
    ?~  hsub  [%&^~ app]
    =^  hfor=(unit phash)  app  (hash for.f)
    ?~  hfor  [%&^~ app]
    =^  subject=body  app
      $(f sub.f)
    ?:  ?=(%| -.subject)  ~&  99  [%|^trace app]
    ?~  p.subject  [%&^~ app]
    =^  formula=body  app
      $(f for.f)
    ?:  ?=(%| -.formula)  ~&  103  [%|^trace app]
    ?~  p.formula  [%&^~ app]
    =/  res
      %_  $
        s    p.u.p.subject
        f    p.u.p.formula
    ==
   (append-hints res [%2 u.hsub u.hfor]^(welp q.u.p.subject q.u.p.formula))
  ::
      [%3 arg=*]
      ~&  >  "%3"
    =^  argument=body  app
      $(f arg.f)
    ?:  ?=(%| -.argument)  ~&  114  [%|^trace app]
    ?~  p.argument  [%&^~ app]
    =^  harg=(unit phash)  app  (hash arg.f)
    ?~  harg  [%&^~ app]
    ?@  p.u.p.argument
      :-  [%& ~ %.n [%3 u.harg %atom p.u.p.argument]^q.u.p.argument]
      app
    =^  hhash=(unit phash)  app  (hash -.p.u.p.argument)
    ?~  hhash  [%&^~ app]
    =^  thash=(unit phash)  app  (hash +.p.u.p.argument)
    ?~  thash  [%&^~ app]
    :-  [%& ~ %.y [%3 u.harg %cell u.hhash u.thash]^q.u.p.argument]
    app
  ::
      [%4 arg=*]
      ~&  >  "%4"
    =^  argument=body  app
      $(f arg.f)
    ?:  ?=(%| -.argument)  ~&  131  [%|^trace app]
    =^  harg=(unit phash)  app  (hash arg.f)
    ?~  harg  [%&^~ app]
    ?~  p.argument  [%&^~ app]
    ?^  p.u.p.argument  ~&  135  [%|^trace app]
    :-  [%& ~ .+(p.u.p.argument) [%4 u.harg p.u.p.argument]^q.u.p.argument]
    app
  ::
      [%5 a=* b=*]
      ~&  >  "%5"
    =^  ha=(unit phash)  app  (hash a.f)
    ?~  ha  [%&^~ app]
    =^  hb=(unit phash)  app  (hash b.f)
    ?~  hb  [%&^~ app]
    =^  a=body  app
      $(f a.f)
    ?:  ?=(%| -.a)  ~&  146  [%|^trace app]
    ?~  p.a  [%&^~ app]
    =^  b=body  app
      $(f b.f)
    ?:  ?=(%| -.b)  ~&  150  [%|^trace app]
    ?~  p.b  [%&^~ app]
    :-  [%& ~ =(p.u.p.a p.u.p.b) [%5 u.ha u.hb]^(welp q.u.p.a q.u.p.b)]
    app
  ::
      [%6 test=* yes=* no=*]
      ~&  >  "%6"
    =^  htest=(unit phash)  app  (hash test.f)
    ?~  htest  [%&^~ app]
    =^  hyes=(unit phash)   app  (hash yes.f)
    ?~  hyes  [%&^~ app]
    =^  hno=(unit phash)    app  (hash no.f)
    ?~  hno  [%&^~ app]
    =^  result=body  app
      $(f test.f)
    ?:  ?=(%| -.result)  ~&  164  [%|^trace app]
    ?~  p.result  [%&^~ app]
    =/  res  ?+  p.u.p.result  ~&  167  [%|^trace app]
      %&  $(f yes.f)
      %|  $(f no.f)
    ==
    (append-hints res [%6 u.htest u.hyes u.hno]^q.u.p.result)
  ::
      [%7 subj=* next=*]
      ~&  >  "%7"
    =^  hsubj=(unit phash)  app  (hash subj.f)
    ?~  hsubj  [%&^~ app]
    =^  hnext=(unit phash)  app  (hash next.f)
    ?~  hnext  [%&^~ app]
    =^  subject=body  app
      $(f subj.f)
    ?:  ?=(%| -.subject)  ~&  179  [%|^trace app]
    ?~  p.subject  [%&^~ app]
    =/  res  %_  $
      s    p.u.p.subject
      f    next.f
    ==
    (append-hints res [%7 u.hsubj u.hnext]^q.u.p.subject)
  ::
      [%8 head=* next=*]
      ~&  >  "%8"
   :: =^  jax=body  app
    ::  (jet head.f next.f)
    ::?:  ?=(%| -.jax)  ~&  190  [%|^trace app]
    ::?^  p.jax  [%& p.jax]^app
    =^  hhead=(unit phash)  app  (hash head.f)
    ?~  hhead  [%&^~ app]
    =^  hnext=(unit phash)  app  (hash next.f)
    ?~  hnext  [%&^~ app]
    =^  head=body  app
      $(f head.f)
    ?:  ?=(%| -.head)  ~&  198  [%|^trace app]
    ?~  p.head  [%&^~ app]
    =/  res  %_  $
      s    [p.u.p.head s]
      f    next.f
    ==
    (append-hints res [%8 u.hhead u.hnext]^q.u.p.head)
  ::
      [%9 axis=@ core=*]
      ~&  >  "%9"
    =^  hcore=(unit phash)  app  (hash core.f)
    ?~  hcore  [%&^~ app]
    =^  core=body  app
      $(f core.f)
    ?:  ?=(%| -.core)  ~&  211  [%|^trace app]
    ?~  p.core  [%&^~ app]
    =^  arm  bud
      (frag axis.f p.u.p.core bud)
    ?~  arm  [%&^~ app]
    ?~  u.arm  ~&  216  [%|^trace app]
    =^  harm=(unit phash)  app  (hash u.u.arm)
    ?~  harm  [%&^~ app]
    =^  hsibs=(unit (list phash))  app  (merk-sibs p.u.p.core axis.f)
    ?~  hsibs  [%&^~ app]
    =/  res  %_  $
      s    p.u.p.core
      f    u.u.arm
    ==
    (append-hints res [%9 axis.f u.hcore u.harm u.hsibs]^q.u.p.core)
  ::
      [%10 [axis=@ value=*] target=*]
      ~&  >  "%10"
    =^  hval=(unit phash)  app  (hash value.f)
    ?~  hval  [%&^~ app]
    =^  htar=(unit phash)  app  (hash target.f)
    ?~  htar  [%&^~ app]
    ?:  =(0 axis.f)  ~&  232  [%|^trace app]
    =^  target=body  app
      $(f target.f)
    ?:  ?=(%| -.target)  ~&  235  [%|^trace app]
    ?~  p.target  [%&^~ app]
    =^  value=body  app
      $(f value.f)
    ?:  ?=(%| -.value)  ~&  239  [%|^trace app]
    ?~  p.value  [%&^~ app]
    =^  mutant=(unit (unit *))  bud
      (edit axis.f p.u.p.target p.u.p.value bud)
    ?~  mutant  [%&^~ app]
    ?~  u.mutant  ~&  244  [%|^trace app]
    =^  oldleaf  bud
      (frag axis.f p.u.p.target bud)
    ?~  oldleaf  [%&^~ app]
    ?~  u.oldleaf  ~&  248  [%|^trace app]
    =^  holdleaf=(unit phash)  app  (hash u.u.oldleaf)
    ?~  holdleaf  [%&^~ app]
    =^  hsibs=(unit (list phash))  app  (merk-sibs p.u.p.target axis.f)
    ?~  hsibs  [%&^~ app]
    :-
    [%& ~ u.u.mutant [%10 axis.f u.hval u.htar u.holdleaf u.hsibs]^(welp q.u.p.target q.u.p.value)]
    app
    ::app(hit [%10 axis.f u.hval u.htar u.holdleaf u.hsibs]^(welp hit1 hit2))
  ::
       [%11 tag=@ next=*]
       ~&  >  "%11"
    =^  next=body  app
      $(f next.f)
    :_  app
    ?:  ?=(%| -.next)  ~&  260  %|^trace
    ?~  p.next  %&^~
    :^  %&  ~
    .*  s
    [11 tag.f 1 -.u.p.next]
    ~  :: Do we need hints?
  ::
     [%11 [tag=@ clue=*] next=*]
    =^  clue=body  app
      $(f clue.f)
    ?:  ?=(%| -.clue)  ~&  269  [%|^trace app]
    ?~  p.clue  [%&^~ app]
    =^  next=body  app
      =?    trace
          ?=(?(%hunk %hand %lose %mean %spot) tag.f)
        [[tag.f u.p.clue] trace]
      $(f next.f)
    :_  app
    ?:  ?=(%| -.next)  ~&  277  %|^trace
    ?~  p.next  %&^~
    :^  %&  ~
    .*  s
    [11 [tag.f 1 -.u.p.clue] 1 -.u.p.next]
    ~  :: Do we need hints?
  ==
  ++  append-hints
    |=  [[bod=body app=appendix] hin=hints]
    ^-  book
    ::?.  ?=([[%& ~ * bit=hints] *] b)  b
    ?:  ?=(%| -.bod)  bod^app
    ?~  +.bod  bod^app
    ::=/  h  -.u.p.bod
    [%& ~ p.u.p.bod (welp hin q.u.p.bod)]^app
    ::bod^app
    ::?:  |(?=(%| -<.b) ?=(~ p.-<.b))  b
    ::=/  h  q.u.p.p.b
    ::b(q.u.p.p.b hin^q.u.p.p.b)
    ::b(hit hin^hit.b)


::?:  ?=(%| -.hed)  ~&  61  [%|^trace app]
::?~  p.hed  [%&^~ app]
  :: Check if we are calling an arm in a core and if so lookup the axis
  :: in the jet map
  :: Calling convention is
  :: [8 [9 JET-AXIS 0 CORE-AXIS] 9 2 10 [6 MAKE-SAMPLE] 0 2]
  :: If we match this then look up JET-AXIS in the jet map to see if we're
  :: calling a jetted arm.
  ::
  :: Note that this arm should only be called on an 8
  :: TODO Figure out what CORE-AXIS should be
  ::++  jet
    ::|=  [head=* next=*]
    ::^-  book
    ::=^  mj  app  (match-jet head next)
    ::?~  mj  [%&^~ app]
    ::(run-jet u.mj)^app
  ::
  ::++  match-jet
    ::|=  [head=* next=*]
    ::^-  [(unit [@tas *]) appendix]
    ::?:  (lth bud 1)  `app
    ::=.  bud  (sub bud 1)
    ::?.  ?=([%9 arm-axis=@ %0 core-axis=@] head)  `app
    ::?.  ?=([%9 %2 %10 [%6 sam=*] %0 %2] next)  `app
    ::?~  mjet=(~(get by jets) arm-axis.head)  `app
    ::=^  sub=body  app
      ::^$(f head, hit ~)
    ::?:  ?=(%| -.sub)  `app
    ::?~  p.sub  `app
    ::=^  arg=body  app
      ::^$(s sub^s, f sam.next)
    ::?:  ?=(%| -.arg)  `app
    ::?~  p.arg  `app
    ::[~ u.mjet u.p.arg]^app
  ::
  ::++  run-jet
    ::|=  [arm=@tas sam=*]
    ::^-  body
    ::~&  arm
    ::?+    arm  %|^trace
        ::%dec
      ::?:  (lth bud 1)  %&^~
      ::=.  bud  (sub bud 1)
      ::?.  ?=(@ sam)  %|^trace
      ::  TODO: probably unsustainable to need to include assertions to
      ::  make all jets crash safe
      ::?.  (gth sam 0)  %|^trace
      ::%&^(some (dec sam))
    ::==
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
