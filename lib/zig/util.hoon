/-  *ziggurat, wallet
=>  |%
    +$  card  card:agent:gall
    --
|_  library=vase
::
::  +allowed-participant: grades whether a ship is permitted to participate
::  in Uqbar validation. currently using hardcoded whitelist
::
++  allowed-participant
  |=  [=ship our=ship now=@da]
  ^-  ?
  (~(has in whitelist) ship)
++  whitelist
  ^-  (set ship)
  %-  ~(gas in *(set ship))
  :~  ::  fakeships for localhost testnets
      ~zod  ~bus  ~nec  ~wet  ~rys
      ::  hodzod's testing moons
      ~watryp-loplyd-dozzod-bacrys
      ::  hosted's testing moons
      ~ricmun-lasfer-hosted-fornet
      ::  ~littel-wolfur's
      ~harden-ripped-littel-wolfur
      ~mipber
      ::  ~roslug-fampet's testing moons
      ~hosdex-hodsud-roslug-fampet
  ==
::  Potential future gating function:
::
::  ?|  =(%king (clan:title ship))
::      =(%czar (clan:title ship))  ::  this is really for fakezod testing
::      ?&  =(%earl (clan:title ship))
::          =(%king (clan:title (sein:title our now ship)))
::      ==
::  ==
::
++  new-epoch-timers
  |=  [=epoch our=ship]
  ^-  (list card)
  =/  order  order.epoch
  =/  i  0
  =|  cards=(list card)
  |-  ^-  (list card)
  ?~  order  cards
  %_    $
    i      +(i)
    order  t.order
  ::
      cards
    :_  cards
    (wait num.epoch i start-time.epoch =(our i.order))
  ==
::
++  give-on-updates
  |=  [=update epoch-start-time=time blk=(unit block)]
  ^-  (list card)
  ::  sends either a 'new-block' or 'saw-block' to fellow validators,
  ::  and sends an 'indexer-block' to indexers.
  =+  ?:  ?=(%new-block -.update)
        !>(`^update`[%indexer-block epoch-num.update epoch-start-time header.update blk])
      ?:  ?=(%saw-block -.update)
        !>(`^update`[%indexer-block epoch-num.update epoch-start-time header.update blk])
      !!
  :~  [%give %fact ~[/validator/updates] %zig-update !>(update)]
      [%give %fact ~[/indexer/updates] %zig-update -]
  ==
::
++  forward-basket
  |=  [=ship =basket]
  ^-  card
  :*  %pass  /basket-gossip
      %agent  [ship %ziggurat]
      %poke  %zig-weave-poke
      !>([%receive basket])
  ==
::
++  notify-sequencer
  |=  [slot-num=@ud =ship]
  ^-  card
  :-  %give
  :^  %fact  ~[/sequencer/updates]
      %sequencer-update  !>([%next-producer slot-num ship])
::
::  +subscriptions-cleanup: close subscriptions of our various watchers
::
++  subscriptions-cleanup
  |=  [wex=boat:gall sup=bitt:gall]
  ^-  (list card)
  %+  weld
    %+  murn  ~(tap by wex)
    |=  [[=wire =ship =term] *]
    ^-  (unit card)
    ?.  ?|  ?=([%validator %updates *] wire)
            ?=([%sequencer %updates *] wire)
            ?=([%indexer %updates *] wire)
        ==
      ~
    `[%pass wire %agent [ship term] %leave ~]
  %+  murn  ~(tap by sup)
  |=  [* [p=ship q=path]]
  ^-  (unit card)
  ?.  ?=([%validator *] q)  ~
  `[%give %kick q^~ `p]
::
::  +wait: create %behn timer cards for a given epoch-slot
::
++  wait
  |=  [epoch-num=@ud slot-num=@ud epoch-start=@da our-block=?]
  ^-  card
  =/  =time
    ::  if we're the block producer for this slot,
    ::  make our timer pop early so we don't miss the deadline
    ::  otherwise, just set timer for slot deadline
    =-  ?.(our-block - (sub - (mul 8 (div epoch-interval 10))))
    (deadline epoch-start slot-num)
  ~&  timer+[[%our our-block] epoch-num slot-num time]
  =-  [%pass - %arvo %b %wait time]
  /timers/slot/(scot %ud epoch-num)/(scot %ud slot-num)
::
++  deadline
  |=  [start-time=@da num=@ud]
  ^-  @da
  %+  add  start-time
  (mul +(num) epoch-interval)
::
++  get-last-slot
  |=  =slots
  ^-  [@ud (unit slot)]
  ?~  p=(pry:sot slots)
    [0 ~]
  [-.u.p `+.u.p]
::
++  start-epoch-catchup
  |=  [src=ship epoch-num=@ud]
  ^-  card
  ~&  >  "starting epoch catchup"  ::  printout
  =/  =wire  /validator/epoch-catchup/(scot %ud epoch-num)
  [%pass (snoc wire (scot %p src)) %agent [src %ziggurat] %watch wire]
::
++  poke-new-epoch
  |=  [our=ship epoch-num=@ud]
  ^-  card
  =-  [%pass /new-epoch/(scot %ud epoch-num) %agent [our %ziggurat] %poke -]
  zig-chain-poke+!>(`chain-poke`[%new-epoch ~])
::
++  shuffle
  |=  [set=(set ship) eny=@]
  ^-  (list ship)
  =/  lis=(list ship)  ~(tap in set)
  =/  len  (lent lis)
  =/  rng  ~(. og eny)
  =|  shuffled=(list ship)
  |-
  ?~  lis
    shuffled
  =^  num  rng
    (rads:rng len)
  %_  $
    shuffled  [(snag num `(list ship)`lis) shuffled]
    len       (dec len)
    lis       (oust [num 1] `(list ship)`lis)
  ==
::
++  get-on-chain-validator-set
  |=  =granary:smart
  ^-  (unit (set ship))
  ?~  found=(~(get by granary) `@ux`'ziggurat')  ~
  ?.  ?=(%& -.germ.u.found)                      ~
  :-  ~
  %~  key  by
  !<(,(map ship [@ux @p life]) [-:!>(*,(map ship [@ux @p life])) data.p.germ.u.found])
::
++  next-block-producer
  |=  [slot=@ud order=(list ship) hed=block-header]
  ^-  [@ud ship]
  ::  ~&  >>>  "slot: {<slot>} order: {<order>} hed-hash: {<`@ux`(sham head)>}"
  =+  (add slot 2)
  ?:  (gth (lent order) -)
    [- (snag - order)]
  [0 -:(shuffle (silt order) (sham hed))]
::
++  get-second-to-last
  |=  ord=(list ship)
  =+  (lent ord)
  ?:  =(- 1)
    (rear ord)
  (snag (sub - 2) ord)
::  +filter: filters a set with boolean gate
++  filter
  |*  [a=(tree) b=gate]
  =+  c=`(set _?>(?=(^ a) n.a))`~
  |-  ?~  a  c
  =.  c
    ?:  (b n.a)
      (~(put in c) n.a)
    c
  =.  c  $(a l.a, c c)
  $(a r.a, c c)
::
++  sequencer-sub-card
  |=  our=ship
  ^-  card
  :*  %pass   /sequencer/updates
      %agent  [our %ziggurat]
      %watch  /sequencer/updates
  ==
::
++  poke-capitol
  |=  [our=ship address=id:smart [rate=@ud bud=@ud] args=supported-args:wallet]
  ^-  card
  ::  only dealing on relay chain (town 0)
  ::  with capitol contract
  :*  %pass  /submit-tx
      %agent  [our %wallet]
      %poke  %zig-wallet-poke
      !>([%submit address `@ux`'capitol' relay-town-id [rate bud] args])
  ==
::
++  read-rice
  |=  [=path blocknum=@ud town-id=@ud =granary:smart]
  ^-  (unit (unit cage))
  ?>  ?=([%rice @ ~] path)
  =/  id  (slav %ux i.t.path)
  ?~  res=(~(get by granary) id)
    ``noun+!>(~)
  ?.  ?=(%& -.germ.u.res)
    ``noun+!>(~)
  ``noun+!>(``rice:smart`p.germ.u.res)
::
++  read-wheat
  |=  [=path blocknum=@ud town-id=@ud =granary:smart]
  |^  ^-  (unit (unit cage))
  ?>  ?=([%wheat @ @tas @ta ^] path)
  =/  id  (slav %ux i.t.path)
  =/  read-type  (slav %tas i.t.t.path)
  =/  arg=^path
    ?:  =('~' i.t.t.t.t.path)
      [i.t.t.t.path ~]
    [i.t.t.t.path i.t.t.t.t.path ~]
  =/  contract-rice=(list @ux)
    %+  murn  t.t.t.t.t.path
    |=  addr=@
    ?:  =('~' addr)  ~
    `(slav %ux addr)
  ?~  res=(~(get by granary) id)  ``noun+!>(~)
  ?.  ?=(%| -.germ.u.res)         ``noun+!>(~)
  ?~  cont.p.germ.u.res           ``noun+!>(~)
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
  =/  payload  .*(q.library pay.u.cont.p.germ.u.res)
  =/  battery  .*([q.library payload] bat.u.cont.p.germ.u.res)
  =/  dor      [-:!>(*contract:smart) battery]
  =/  cart  [id blocknum town-id owns]
  ?+  read-type  ``noun+!>(~)
    :: %noun  ``noun+!>(~(noun ~(read cont cart) arg))
    %json  ``json+!>(;;(json q:(json-read-shut dor %read !>(cart) !>(arg))))
  ==
  ::
  ++  json-read-shut                                               ::  slam a door
    |=  [dor=vase arm=@tas dor-sam=vase arm-sam=vase]
    ^-  vase
    %+  slap
      (slop dor (slop dor-sam arm-sam))
    ^-  hoon
    :-  %cnsg
    :^    [%json ~]
        [%cnsg [arm ~] [%$ 2] [%$ 6] ~]  ::  replace sample
      [%$ 7]
    ~
  ::
  --
--
