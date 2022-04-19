/-  *zink
/+  *zink-pedersen, *zink-json, *mip
|%
::
+$  body  (unit *)
+$  cache  (map * phash)
+$  appendix  [cax=cache hit=hints bud=@]
+$  book  (pair body appendix)
::
++  zink
  =|  appendix
  =*  app  -
  |=  [s=* f=*]
  ::  TODO: must return trace on crash
  |^
  =|  trace=(list [@ta *])
  ?~  formula-cost=(cost f bud)
    `[cax hit 0]
  ?:  (lth bud u.formula-cost)  `[cax hit 0]
  =.  bud  (sub bud u.formula-cost)
  |^  ^-  book
  ?+    f
    ~&  f
    !!
  ::  formula is a cell; do distribution
  ::
      [^ *]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    =^  hed=body  app
      $(f -.f)
    ?~  hed  `app
    =^  tal=body  app
      $(f +.f)
    ?~  tal  `app
    =^  hhed  cax  (hash -.f)
    =^  htal  cax  (hash +.f)
    =.  app  (put-hint [%cons hhed htal])
    [~ u.hed^u.tal]^app
  ::
      [%0 axis=@]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    =^  part  bud
      (frag axis.f s bud)
    ?~  part  `app
    ?~  u.part  !!  ::  TODO: safety
    =^  hpart  cax  (hash u.u.part)
    =^  hsibs  cax  (merk-sibs s axis.f)
    =.  app  (put-hint [%0 axis.f hpart hsibs])
    [~ u.u.part]^app
  ::
      [%1 const=*]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    =^  hres  cax  (hash const.f)
    =.  app  (put-hint [%1 hres])
    [~ const.f]^app
  ::
      [%2 sub=* for=*]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    =^  hsub  cax  (hash sub.f)
    =^  hfor  cax  (hash for.f)
    =^  subject=body  app
      $(f sub.f)
    ?~  subject  `app
    ::  TODO: need to add a check to ensure no crash
    =^  formula=body  app
      $(f for.f)
    ?~  formula  `app
    ::  TODO: need to add a check to ensure no crash
    =.  app  (put-hint [%2 hsub hfor])
    $(s u.subject, f u.formula)
  ::
      [%3 arg=*]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    =^  argument=body  app
      $(f arg.f)
    ?~  argument  `app
    =^  harg  cax  (hash arg.f)
    ?@  u.argument
      =.  app  (put-hint [%3 harg %atom u.argument])
      [~ %.n]^app
    =^  hhash  cax  (hash -.u.argument)
    =^  thash  cax  (hash +.u.argument)
    =.  app  (put-hint [%3 harg %cell hhash thash])
    [~ %.y]^app
  ::
      [%4 arg=*]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    =^  argument=body  app
      $(f arg.f)
    =^  harg  cax  (hash arg.f)
    ?~  argument  `app
    ?>  ?=(@ u.argument)  ::  TODO: safely return trace
    =.  app  (put-hint [%4 harg u.argument])
    [~ .+(u.argument)]^app
  ::
      [%5 a=* b=*]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    =^  ha  cax  (hash a.f)
    =^  hb  cax  (hash b.f)
    =^  a=body  app
      $(f a.f)
    ?~  a  `app
    =^  b=body  app
      $(f b.f)
    ?~  b  `app
    =.  app  (put-hint [%5 ha hb])
    [~ =(u.a u.b)]^app
  ::
      [%6 test=* yes=* no=*]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    =^  htest  cax  (hash test.f)
    =^  hyes   cax  (hash yes.f)
    =^  hno    cax  (hash no.f)
    =^  result=(unit *)  app
      $(f test.f)
    ?~  result  `app
    =.  app  (put-hint [%6 htest hyes hno])
    ?+  u.result  !!  ::  TODO: safely do trace
      %&  $(f yes.f)
      %|  $(f no.f)
    ==
  ::
      [%7 subj=* next=*]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    =^  hsubj  cax  (hash subj.f)
    =^  hnext  cax  (hash next.f)
    =^  subject=body  app
      $(f subj.f)
    ?~  subject  `app
    ::  TODO: check if crash here and do trace
    =.  app  (put-hint [%7 hsubj hnext])
    %=  $
      s  u.subject
      f  next.f
    ==
  ::
      [%8 head=* next=*]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    =^  jax  app  (jet head.f next.f)
    ?^  jax  jax^app
    =^  hhead  cax  (hash head.f)
    =^  hnext  cax  (hash next.f)
    =^  head=body  app
      $(f head.f)
    ?~  head  `app
    ::  TODO: check if head crashes
    =.  app  (put-hint [%8 hhead hnext])
    %=  $
      s  [u.head s]
      f  next.f
    ==
  ::
      [%9 axis=@ core=*]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    =^  hcore  cax  (hash core.f)
    =^  core=body  app
      $(f core.f)
    ?~  core  `app
    ::  TODO: check if core crashed
    =^  arm  bud
      (frag axis.f u.core bud)
    ?~  arm  `app
    ::  TODO: check if arm crashed
    ?~  u.arm  !!
    =^  harm  cax  (hash u.u.arm)
    =^  sibs  cax  (merk-sibs u.core axis.f)
    =.  app  (put-hint [%9 axis.f hcore harm sibs])
    %=  $
      s  u.core
      f  u.u.arm
    ==
  ::
      [%10 [axis=@ value=*] target=*]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    =^  hval  cax  (hash value.f)
    =^  htar  cax  (hash target.f)
    ?:  =(0 axis.f)  !!  ::  TODO: safety!
    =^  target=body  app
      $(f target.f)
    ?~  target  `app
    ::  TODO: safety!
    =^  value=body  app
      $(f value.f)
    ?~  value  `app
    ::  TODO: safety!
    =^  mutant=(unit (unit *))  bud
      (edit axis.f u.target u.value bud)
    ?~  mutant  `app
    ?~  u.mutant  !!  ::  TODO: SAFETY!
    =^  oldleaf  bud
      (frag axis.f u.target bud)
    ?~  oldleaf  `app
    ?~  u.oldleaf  !!  ::  TODO: SAFETY
    =^  holdleaf  cax  (hash u.u.oldleaf)
    =^  sibs  cax  (merk-sibs u.target axis.f)
    =.  app  (put-hint [%10 axis.f hval htar holdleaf sibs])
    [~ u.u.mutant]^app
  ==
  :: Check if we are calling an arm in a core and if so lookup the axis
  :: in the jet map
  :: Calling convention is
  :: [8 [9 JET-AXIS 0 CORE-AXIS] 9 2 10 [6 MAKE-SAMPLE] 0 2]
  :: If we match this then look up JET-AXIS in the jet map to see if we're
  :: calling a jetted arm.
  ::
  :: Note that this arm should only be called on an 8
  :: TODO Figure out what CORE-AXIS should be
  +$  jax  [nam=@tas arm-axis=@ core-axis=@ sam=* arg=*]
  ++  jet
    |=  [head=* next=*]
    ^-  book
    =^  mj  app  (match-jet head next)
    ?~  mj  `app
    =^  jar=(unit [res=* arg=json])  app
      (run-jet nam.u.mj arg.u.mj)
    ?~  jar  `app
    =^  hhead  cax  (hash head)
    =^  hnext  cax  (hash next)
    =^  hsam  cax  (hash sam.u.mj)
    =.  app
    %-  put-hint
    :*  %jet
        hhead
        hnext
        arm-axis.u.mj
        core-axis.u.mj
        hsam
        arg.u.jar
    ==
    (some res.u.jar)^app
  ::
  ++  match-jet
    |=  [head=* next=*]
    ^-  [(unit jax) appendix]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    ?.  ?=([%9 arm-axis=@ %0 core-axis=@] head)  `app
    ?.  ?=([%9 %2 %10 [%6 sam=*] %0 %2] next)  `app
    ?~  mjet=(~(get by jets) arm-axis.head)  `app
    =^  sub=body  app
      ^$(f head)
    ?~  sub  `app
    =^  arg=body  app
      ^$(s u.sub^s, f sam.next)
    =^  h  cax  (hash u.sub^s)
    =^  hsub  cax  (hash u.sub)
    =^  hs  cax  (hash s)
    :_  app
    %+  bind  (both mjet arg)
    |=  [j=@tas a=*]
    [j arm-axis.head core-axis.head sam.next a]
  ::
  ++  run-jet
    |=  [arm=@tas sam=*]
    ^-  [(unit [* json]) appendix]
    ?+  arm  ~^app
    ::
        %dec
      ?:  (lth bud 1)  ~^app
      =.  bud  (sub bud 1)
      ?.  ?=(@ sam)  ~^app
      :_  app
      %-  some
      :-  (dec sam)
      %-  pairs:enjs:format
      ~[['arg1' s+(num:enjs sam)]]
    ::
        %add
      ?:  (lth bud 1)  ~^app
      =.  bud  (sub bud 1)
      ?.  ?=([x=@ud y=@ud] sam)  ~^app
      :_  app
      %-  some
      :-  (add x.sam y.sam)
      %-  pairs:enjs:format
      :~  ['arg1' s+(num:enjs x.sam)]
          ['arg2' s+(num:enjs y.sam)]
      ==
    ::
        %mul
      ?:  (lth bud 1)  ~^app
      =.  bud  (sub bud 1)
      ?.  ?=([x=@ud y=@ud] sam)  ~^app
      :_  app
      %-  some
      :-  (mul x.sam y.sam)
      %-  pairs:enjs:format
      :~  ['arg1' s+(num:enjs x.sam)]
          ['arg2' s+(num:enjs y.sam)]
      ==
    ::
        %double
      ?:  (lth bud 1)  ~^app
      =.  bud  (sub bud 1)
      ?.  ?=(@ sam)  ~^app
      :_  app
      %-  some
      :-  (mul 2 sam)
      %-  pairs:enjs:format
      ~[['arg1' s+(num:enjs sam)]]
    ==
  ::
  ++  put-hint
    |=  hin=cairo-hint
    ^-  appendix
    =^  sroot  cax  (hash s)
    =^  froot  cax  (hash f)
    =.  hit  (~(put bi hit) sroot froot hin)
    app
  --
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
    ^-  [phash cache]
    (^hash n cax)
  ::
  ++  cost                                              ::  gas cost of noun
    |^
    |=  [a=* bud=@ud]
    ^-  (unit @ud)
    ?@(a `(pat a) (ket a bud))
    ++  pat  |=(a=@ (max 1 (met 5 a)))
    ++  ket
      |=  [a=^ bud=@ud]
      ?:  (lth bud 1)  ~
      =.  bud  (dec bud)
      ?~  lef=(^$ -.a bud)  ~
      ?:  (lth bud u.lef)  ~
      =.  bud  (sub bud u.lef)
      ?~  rig=(^$ +.a bud)  ~
      `+((add u.lef u.rig))
    --
  ::  +merk-sibs from bottom to top
  ::
  ++  merk-sibs
    |=  [s=* axis=@]
    =|  path=(list phash)
    |-  ^-  [(list phash) (map * phash)]
    ?:  =(1 axis)
      [path cax]
    ?~  axis  !!
    ?@  s  !!
    =/  pick  (cap axis)
    =^  sibling=phash  cax
      %-  hash
      ?-(pick %2 +.s, %3 -.s)
    =/  child  ?-(pick %2 -.s, %3 +.s)
    %=  $
      s     child
      axis  (mas axis)
      path  [sibling path]
    ==
  --
::
::  eval-noun: evaluate nock with zink
::
++  eval-noun
  |=  [n=(pair) bud=@]
  ^-  book
  %.  n
  %*  .  zink
    app  [~ ~ bud]
  ==
::
::  eval-noun: evaluate nock with zink
::
++  eval-noun-with-cache
  |=  [n=(pair) bud=@ cax=cache]
  ^-  book
  %.  n
  %*  .  zink
    app  [cax ~ bud]
  ==
::
::  eval-hoon-with-hints: eval hoon and return result w/hints as json
::
++  eval-hoon-with-hints
  |=  [file=path gen=hoon bud=@]
  ^-  [(unit *) json]
  =/  src  .^(@t %cx file)
  =/  gun  (slap !>(~) (ream src))
  =/  han  (~(mint ut p.gun) %noun gen)
  =-  [p (create-hints [q.gun q.han] hit.q ~)]
  (eval-noun [q.gun q.han] bud)
::  eval-hoon: compile a hoon file and evaluate it with zink
::
++  eval-hoon
  |=  [file=path lib=(unit path) gen=hoon bud=@]
  ^-  book
  =/  clib
    ?~  lib  !>(~)
    =/  libsrc  .^(@t %cx u.lib)
    (slap !>(~) (ream libsrc))
  =/  src  .^(@t %cx file)
  =/  gun  (slap clib (ream src))
  =/  han  (~(mint ut p.gun) %noun gen)
  (eval-noun [q.gun q.han] bud)
::  eval-hoon-with-cache: compile a hoon file and evaluate it with zink
::
++  eval-hoon-with-cache
  |=  [file=path lib=(unit path) gen=hoon bud=@ cax=cache]
  ^-  book
  =/  clib
    ?~  lib  !>(~)
    =/  libsrc  .^(@t %cx u.lib)
    (slap !>(~) (ream libsrc))
  =/  src  .^(@t %cx file)
  =/  gun  (slap clib (ream src))
  =/  han  (~(mint ut p.gun) %noun gen)
  (eval-noun-with-cache [q.gun q.han] bud cax)
::
::  eval-hoon-with-cache-and-hints: eval hoon and return result w/ hints
::  as json and with cache
++  eval-hoon-with-cache-and-hints
  |=  [file=path lib=(unit path) gen=hoon bud=@ cax=cache]
  ^-  [book @t]
  =/  clib
    ?~  lib  !>(~)
    =/  libsrc  .^(@t %cx u.lib)
    (slap !>(~) (ream libsrc))
  =/  src  .^(@t %cx file)
  =/  gun  (slap clib (ream src))
  =/  han  (~(mint ut p.gun) %noun gen)
  =/  bok  (eval-noun-with-cache [q.gun q.han] bud cax)
  =/  js  (create-hints [q.gun q.han] hit.q.bok cax)
  bok^(crip (en-json:html js))
::  create-hints: create full hint json
::
++  create-hints
  |=  [n=^ h=hints cax=cache]
  ^-  json
  =^  hs  cax  (hash -.n cax)
  =^  hf  cax  (hash +.n cax)
  %-  pairs:enjs:format
  :~  ['subject' s+(num:enjs hs)]
      ['formula' s+(num:enjs hf)]
      ['hints' (all:enjs h)]
  ==
::
::  hash:
::  if x is an atom then hash(x)=h(x, 0)
::  else hash([x y])=h(hash(x), hash(y))
::  where h = pedersen hash
++  hash
  |=  [n=* cax=cache]
  ^-  [phash cache]
  =/  mh  (~(get by cax) n)
  ?^  mh  [u.mh cax]
  ?@  n
    =/  h  (hash:pedersen n 0)
    [h (~(put by cax) n h)]
  =^  hh  cax  $(n -.n)
  =^  ht  cax  $(n +.n)
  =/  h  (hash:pedersen hh ht)
  [h (~(put by cax) n h)]
--
