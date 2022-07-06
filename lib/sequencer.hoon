/-  *sequencer
/+  mill=zig-mill
|%
++  transition-state
  |=  [old=(unit town) proposed=[=basket =land diff-hash=@ux root=@ux]]
  ^-  (unit town)
  ?~  old  old
  :-  ~
  %=  u.old
    land  land.proposed
    latest-diff-hash.hall  diff-hash.proposed
    roots.hall  (snoc roots.hall.u.old root.proposed)
  ==
::
++  read-grain
  |=  [=path =granary]
  ^-  (unit (unit cage))
  ?>  ?=([%grain @ ~] path)
  =/  id  (slav %ux i.t.path)
  ``noun+!>((~(get by granary) id))
::
++  read-wheat
  |=  [=path now=time town-id=id:smart =granary library=vase]
  |^  ^-  (unit (unit cage))
  ?>  ?=([%read @ @tas @ta @ ^] path)
  =/  id  (slav %ux i.t.path)
  =/  read-type  (slav %tas i.t.t.path)  ::  %json or %noun
  =/  arg=^path
    ?:  =('~' i.t.t.t.t.path)
      [i.t.t.t.path ~]
    [i.t.t.t.path i.t.t.t.t.path ~]
  =/  contract-rice=(list @ux)  ::  TODO need to figure this out
    %+  murn  t.t.t.t.t.path
    |=  addr=@
    ?:  =('~' addr)  ~
    `(slav %ux addr)
  ?~  res=(~(get by granary) id)  ``noun+!>(~)
  ?.  ?=(%| -.germ.u.res)         ``noun+!>(~)
  ?~  cont.p.germ.u.res           ``noun+!>(~)
  =*  cont  u.cont.p.germ.u.res
  =/  owns
    %-  ~(gas by *(map id:smart grain:smart))
    %+  murn  contract-rice
    |=  find=id:smart
    ?~  found=(~(get by granary) find)  ~
    ?.  ?=(%& -.germ.u.found)           ~
    ?.  =(lord.u.found id)              ~
    `[find u.found]
  ::  this isn't an ideal method but okay for now
  ::  goal is to return ~ if some rice weren't found
  ?.  =(~(wyt by owns) (lent contract-rice))
    ``noun+!>(~)
  ::  TODO swap this with +zebra when able?
  =/  cart     [id from=[0x0 0] now town-id owns]
  =/  payload  .*(q.library pay.cont)
  =/  battery  .*([q.library payload] bat.cont)
  =/  dor      [-:!>(*contract:smart) battery]
  ?+  read-type  [~ ~]
    %noun  ``noun+!>(`q:(read-shut dor %read !>(cart) !>(arg) %noun))
    %json  ``json+!>(;;(json q:(read-shut dor %read !>(cart) !>(arg) %json)))
  ==
  ::
  ++  read-shut                                               ::  slam a door
    |=  [dor=vase arm=@tas dor-sam=vase arm-sam=vase arm-arm=?(%noun %json)]
    ^-  vase
    %+  slap
      (slop dor (slop dor-sam arm-sam))
    ^-  hoon
    :-  %cnsg
    :^    [arm-arm ~]
        [%cnsg [arm ~] [%$ 2] [%$ 6] ~]  ::  replace sample
      [%$ 7]
    ~
  --
--
