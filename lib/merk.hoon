|%
+$  hash  @ux
++  merk
  |$  [key value]                                       ::  table
  $|  (tree (pair key (pair hash value)))
  |=  a=(tree (pair key (pair hash value)))
  ?:(=(~ a) & (apt:(bi key value) a))
::
++  shag                                                ::  256bit noun hash
  |=  yux=*  ^-  hash  ^-  @
  ?@  yux
    (shas %gash yux)
  (shas %shag (jam yux))
::
::  +sore: single sha-256 hash in ascending order, uses +dor as
::  fallback
::
++  sore
  |=  [a=* b=*]
  ^-  ?
  =+  [c=(shag a) d=(shag b)]
  ?:  =(c d)
    (dor a b)
  (lth c d)
::
::  +sure: double sha-256 hash in ascending order, uses +dor as
::  fallback
::
++  sure
  |=  [a=* b=*]
  ^-  ?
  =+  [c=(shag (shag a)) d=(shag (shag b))]
  ?:  =(c d)
    (dor a b)
  (lth c d)
::
++  bi                                                  ::  merk engine
  |*  [key=mold val=mold]
  =>  |%
      +$  mert  (tree (pair key (pair hash val)))
      --
  |%
  ++  bif                                               ::  splits a by b
    |=  [a=mert b=key c=val]
    ^+  [l=a r=a]
    =<  +
    |-  ^+  a
    ?~  a
      [[b (mer a b c) c] ~ ~]
    ?:  =(b p.n.a)
      ?:  =(c q.q.n.a)
        a
      a(n [b (mer a b c) c])
    ?:  (sore b p.n.a)
      =/  d  $(a l.a)
      ?>  ?=(^ d)
      d(r a(l r.d, p.q.n (mer a(l r.d) [p q.q]:n.a)))
    =/  d  $(a r.a)
    ?>  ?=(^ d)
    d(l a(r l.d, p.q.n (mer a(r l.d) [p q.q]:n.a)))
  ::
  ++  del                                               ::  delete at key b
    |=  [a=mert b=key]
    |-  ^+  a
    ?~  a
      ~
    ?.  =(b p.n.a)
      ?:  (sore b p.n.a)
        =.  l.a  $(a l.a)
        a(n [p.n.a (mer a [p q.q]:n.a) q.q.n.a])
      =.  r.a  $(a r.a)
      a(n [p.n.a (mer a [p q.q]:n.a) q.q.n.a])
    |-  ^-  [$?(~ _a)]
    ?~  l.a  r.a
    ?~  r.a  l.a
    ?:  (sure p.n.l.a p.n.r.a)
      =.  r.l.a  $(l.a r.l.a)
      l.a(n [p.n.l.a (mer l.a [p q.q]:n.l.a) q.q.n.l.a])
    =.  l.r.a  $(r.a l.r.a)
    r.a(n [p.n.r.a (mer r.a [p q.q]:n.r.a) q.q.n.r.a])
  ::
  ++  dif                                               ::  difference
    |=  [a=mert b=mert]
    |-  ^+  a
    ?~  b
      a
    =/  c  (bif a p.n.b q.q.n.b)
    ?>  ?=(^ c)
    =/  d  $(a l.c, b l.b)
    =/  e  $(a r.c, b r.b)
    |-  ^-  [$?(~ _a)]
    ?~  d  e
    ?~  e  d
    ?:  (sure p.n.d p.n.e)
      =/  dr  $(d r.d)
      d(r dr, p.q.n (mer d(r dr) [p q.q]:n.d))
    =/  el  $(e l.e)
    e(l el, p.q.n (mer e(l el) [p q.q]:n.e))
  ::
  ++  apt                                               ::  check correctness
    |=  a=mert
    =|  [l=(unit) r=(unit)]
    |-  ^-  ?
    ?~  a   &
    ?&  ?~(l & &((sore p.n.a u.l) !=(p.n.a u.l)))
        ?~(r & &((sore u.r p.n.a) !=(u.r p.n.a)))
        ?~  l.a   &
        &((sure p.n.a p.n.l.a) !=(p.n.a p.n.l.a) $(a l.a, l `p.n.a))
        ?~  r.a   &
        &((sure p.n.a p.n.r.a) !=(p.n.a p.n.r.a) $(a r.a, r `p.n.a))
        =(p.q.n.a (mer a [p q.q]:n.a))
    ==
  ::
  ++  gas                                               ::  concatenate
    |=  [a=mert b=(list [p=key q=val])]
    ^+  a
    ?~  b  a
    $(b t.b, a (put a i.b))
  ::
  ++  mek                                               ::  merkle hashes for key
    |=  [a=mert b=key]
    ^-  (list hash)
    =|  =(list hash)
    |-
    ?~  a
      ~
    ?:  =(b p.n.a)
      (flop [p.q.n.a list])
    ?:  (sore b p.n.a)
      $(a l.a, list [p.q.n.a list])
    $(a r.a, list [p.q.n.a list])
  ::
  ++  mer                                               ::  generate merkle hash
    |=  [a=mert b=(pair key val)]
    ^-  hash
    ?~  a  (shag [b ~ ~])
    %-  shag
    :+  b
      ?~(l.a ~ p.q.n.l.a)
    ?~(r.a ~ p.q.n.r.a)
  ::
  ++  get                                               ::  grab value by key
    |=  [a=mert b=key]
    ^-  (unit val)
    |-
    ?~  a
      ~
    ?:  =(b p.n.a)
      (some q.q.n.a)
    ?:  (sore b p.n.a)
      $(a l.a)
    $(a r.a)
  ::
  ++  got                                               ::  need value by key
    |=  [a=mert b=key]
    ^-  val
    (need (get a b))
  ::
  ++  gut                                               ::  fall value by key
    |=  [a=mert b=key c=val]
    ^-  val
    (fall (get a b) c)
  ::
  ++  has                                               ::  key existence check
    |=  [a=mert b=key]
    !=(~ (get a b))
  ::
  ++  int                                               ::  intersection
    |=  [a=mert b=mert]
    ?:  =(a b)  a
    ::  mor ->  sure
    ::  gor ->  sore
    |-  ^+  a
    ?~  b
      ~
    ?~  a
      ~
    ?:  (sure p.n.a p.n.b)
      ?:  =(p.n.b p.n.a)
        =:  l.a  $(a l.a, b l.b)
            r.a  $(a r.a, b r.b)
        ==
        b(p.q.n (mer a [p q.q]:n.a))
      ?:  (sore p.n.b p.n.a)
        ::
        !!
      ::
      !!
    ?:  =(p.n.a p.n.b)
      ::
      !!
    ?:  (sore p.n.a p.n.b)
      ::
      !!
    ::
    !!
  ::
  ++  put                                               ::  adds key-value pair
    |=  [a=mert b=key c=val]
    ^+  a
    ?~  a
      [[b (mer a b c) c] ~ ~]
    ?:  =(b p.n.a)
      ?:  =(c q.q.n.a)
        a
      a(n [b (mer a b c) c])
    ?:  (sore b p.n.a)
      =/  d  $(a l.a)
      ?>  ?=(^ d)
      =.  a
        ?:  (sure p.n.a p.n.d)
          a(l d)
        d(r a(l r.d, p.q.n (mer a(l r.d) [p q.q]:n.a)))
      a(p.q.n (mer a [p q.q]:n.a))
    =/  d  $(a r.a)
    ?>  ?=(^ d)
    =.  a
      ?:  (sure p.n.a p.n.d)
        a(r d)
      d(l a(r l.d, p.q.n (mer a(r l.d) [p q.q]:n.a)))
    a(p.q.n (mer a [p q.q]:n.a))
  ::
  ++  uni
    |=  [a=mert b=mert]
    ?:  =(a b)  a
    |-  ^+  a
    ?~  b
      a
    ?~  a
      b
    ?:  =(p.n.b p.n.a)
      =:  l.a  $(a l.a, b l.b)
          r.a  $(a r.a, b r.b)
      ==
      a(p.q.n (mer a [p q.q]:n.a))
    ?:  (sure p.n.a p.n.b)
      ?:  (sore p.n.b p.n.a)
        =.  l.a  $(a l.a, r.b ~, p.q.n.b (mer b(r ~) [p q.q]:n.b))
        $(b r.b, p.q.n.a (mer a [p q.q]:n.a))
      =.  r.a  $(a r.a, l.b ~, p.q.n.b (mer b(l ~) [p q.q]:n.b))
      $(b l.b, p.q.n.a (mer a [p q.q]:n.a))
    ?:  (sore p.n.a p.n.b)
      =.  l.b  $(b l.b, r.a ~, p.q.n.a (mer a(r ~) [p q.q]:n.a))
      $(a r.a, p.q.n.b (mer b [p q.q]:n.b))
    =.  r.b  $(b r.b, l.a ~, p.q.n.a (mer a(l ~) [p q.q]:n.a))
    $(a l.a, p.q.n.b (mer b [p q.q]:n.b))
  --
--
