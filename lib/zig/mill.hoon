/+  *zig-fink, std=zig-sys-std
|_  [validator-id=@ux =land:std now=time]
::
::  +mill-all: mills all calls in mempool
::
++  mill-all
  |=  [helix-id=@ud =town:std mempool=(list call:std)]
  =/  pending
    %+  sort  mempool
    |=  [a=call:std b=call:std]
    (gth rate.a rate.b)
  =|  result=(list [@ux call:std])
          ::  'chunk' def
  |-  ^-  [(list [@ux call:std]) town:std]
  ?~  pending
    [result town]
  %_  $
    pending  t.pending
    result   [[`@ux`(shax (jam i.pending)) i.pending] result]
    town  (mill helix-id town i.pending)
  ==
::  +mill: processes a single call and returns updated town
::
++  mill
  |=  [town-id=@ud =town:std =call:std]
  ^-  town:std
  ?.  ?=(user:std from.call)  town
  ?~  curr-nonce=(~(get by q.town) id.from.call)
    town  ::  missing user
  ?.  =(nonce.from.call +(u.curr-nonce))
    town  ::  bad nonce
  ?.  (~(audit tax p.town) call)
    town  ::  can't afford gas
  ~&  >  "finished audit"
  =+  [gan rem]=(~(work farm p.town) call)
  ~&  >  "finished work"
  =/  fee=@ud   (sub budget.call rem)
  ::~&  >>  town
  :-  ?~  gan  (~(pay tax p.town) id.from.call fee)
      (~(pay tax u.gan) id.from.call fee)
  ~&  >  "done paying taxes"
  (~(put by q.town) id.from.call nonce.from.call)
::
::  +tax: manage payment for contract execution in zigs
::
++  tax
  |_  =granary:std
  +$  zigs-mold
    $:  ~
        total=@ud
        balances=(map id:std @ud)
        allowances=(map:std [owner=id:std sender=id:std] @ud)
        coinbase-rate=@ud
    ==
  ::  +audit: evaluate whether a caller can afford gas
  ++  audit
    |=  =call:std
    ^-  ?
    ?~  zigs=(~(get by granary) zigs-rice-id:std)   %.n
    ?.  ?=(%& -.germ.u.zigs)                        %.n
    =/  data  (hole:std zigs-mold data.p.germ.u.zigs)
    ~&  >>  balances.data
    ?.  ?=(user:std from.call)                      %.n
    ?~  bal=(~(get by balances.data) id.from.call)  %.n
    (gth u.bal (mul rate.call budget.call))
  ::  +pay: extract gas fee from caller's zigs balance
  ++  pay
    |=  [payee=id:std fee=@ud]
    ^-  granary:std
    ~&  >  "paying taxes"
    ?~  zigs=(~(get by granary) zigs-rice-id:std)  granary
    ?.  ?=(%& -.germ.u.zigs)                       granary
    =/  data  (hole:std zigs-mold data.p.germ.u.zigs)
    =.  balances.data
      %+  %~  jab  by
          ?.  (~(has by balances.data) validator-id)
            ::  make account if none in balances
            (~(put by balances.data) validator-id fee)
          ::  otherwise add to existing balance
          %+  ~(jab by balances.data)
            validator-id
          |=(bal=@ud (add bal fee))
        payee
      |=(bal=@ud (sub bal fee))
    =.  data.p.germ.u.zigs  data
    ~&  >>  balances.data
    (~(put by granary) zigs-rice-id:std u.zigs)
  --
::
::  +farm: execute a call to a contract within a wheat
::
++  farm
  |_  =granary:std
  ::
  ++  work
    |=  =call:std
    ^-  [(unit granary:std) @ud]
    ~&  >  "work-ing"
    =/  crop  (plant call(budget (div budget.call rate.call)))
    ~&  >  crop
    ~&  >  "loch4?"
    :_  +.crop
    ?~  -.crop  ~
    ~&  >  "loch5?"
    (harvest u.-.crop to.call from.call)
  ::
  ++  plant
    |=  =call:std
    ^-  [(unit contract-result:std) @ud]
    ~&  >  "plant-ing"
    |^
    =/  args  (incubate args.call)
    ?~  con=(germinate to.call)
      `budget.call
    (grow u.con args call)
    ::
    ++  incubate
      |=  arg=call-args:std
      ^-  contract-args:std
      ?.  ?=(user:std from.call)  !!
      =*  inp  +.arg
      :-  -.arg
      :+  caller.inp
        args.inp
      %-  ~(gas by *contract-input-rice:std)
      %+  murn  ~(tap in rice-ids.inp)
      |=  =id:std
      ?~  res=(~(get by granary) id)  ~
      ?.  ?=(%& -.germ.u.res)  ~
      ::  check that caller holds all input rice
      ?.  =(id.from.call -.+.germ.u.res)  ~
      `[id u.res]
    ::
    ++  germinate
      |=  find=id:std
      ^-  (unit contract:std)
      ?~  gra=(~(get by granary) find)  ~
      ?.  ?=(%| -.germ.u.gra)  ~
      ?~  p.germ.u.gra  ~
      `!<(contract:std [-:!>(*contract:std) u.p.germ.u.gra])
    --
  ::
  ++  grow
    |=  [cont=contract:std args=contract-args:std =call:std]
    ^-  [(unit contract-result:std) @ud]
    ~&  >  "grow-ing"
    |^
    =+  [bran rem]=(weed cont to.call args ~ budget.call)
    ~&  >  "1st weeding successful"
    ?:  ?=(%& -.bran)
      ~&  >  "loch"
      p.bran^rem
    |-
    =*  next  next.p.bran
    =*  mem   mem.p.bran
    =^  crop  rem
      ~&  >  "loch2"
      (plant call(from to.call, to to.next, budget rem, args args.next))
    ?~  crop  `rem
    =/  gan  (harvest u.crop to.call from.call)
    ~&  >  "loch3"
    ?~  gan  `rem
    =.  granary  u.gan
    =^  eve  rem
      (weed cont to.call [%event u.crop] mem rem)
    ~&  >  "weeding successful"
    ?:  ?=(%& -.eve)
      p.eve^rem
    %_  $
      next.p.bran  next.p.eve
      mem.p.bran   mem.p.eve
    ==
    ::
    ++  weed
      |=  [cont=contract:std to=id:std args=contract-args:std mem=(unit vase) budget=@ud]
      ^-  [(each (unit contract-result:std) continuation:std) @ud]
      ~&  >  "weed-ing"
      =+  [res bud]=(barn cont to args ~ budget)
      ~&  >>>  res
      ~&  >  "barning successful"
      ?~  res            
        ~&  >  "bloach" 
        [%& ~]^bud
      ?:  ?=(%| -.u.res)
        %-  head
        :-  [%& ~]^bud
        %+  turn
           `(list tank)`+.u.res
        |=  in=tank
        ~&  ~(ram re in)
        ~&  >  "aloach"
        ~
        
      ~&  >  "barning successful"
      ?:  ?=(%result -.p.u.res)
        ?.  ?|  &(?=(%read -.p.p.u.res) ?=(%read -.args))
                &(?=(%write -.p.p.u.res) ?=(%write -.args))
            ==
          [%& ~]^bud
        [%& `p.p.u.res]^bud
      ~&  >  "barning successful"
      [%| p.p.u.res]^bud
      
    ::
    ::  +barn: run contract formula with arguments and memory, bounded by bud
    ::  (takes yolk and runs write)
    ++  barn
      |_   [=contract:std to=id:std mem=(unit vase) bud=@ud]
      ++  write
        |=  =scramble
        ^-  [(unit (each chick (list tank))) @ud]
        :_  bud
        :-  ~
        %-  mule
          ?-  -.args
            %read   |.((~(read contract mem to) +.args))
            %write  |.(;;(male:std (~(write contract mem to) +.args)))
            %event  |.(;;(sex:std (~(event contract mem to) +.args)))
          ==
      ++  read
        |=  =path
        ^-  [(unit (each * (list tank))) @ud]
        ::  scry
        0
      ++  event
        |=  =male
        ^-  [(unit (each chick (list tank))) @ud]
        *chick
      --
  ::
  ++  harvest
    |=  [res=contract-result:std lord=id:std from=caller:std]
    ^-  (unit granary:std)
    ~&  >  "harvest-ing"
    ?:  ?=(%read -.res)  `granary
    =-  ?.  -  ~
        `(~(uni by granary) (~(uni by changed.res) issued.res))
    ?&  %-  ~(all in changed.res)
        |=  [=id:std =grain:std]
        ::  id in changed map must be equal to id in grain AND
        ::  all changed grains must already exist AND
        ::  no changed grains may also have been issued at same time AND
        ::  only grains that proclaim us lord may be changed
        ?&  =(id id.grain)
            (~(has by granary) id.grain)
            !(~(has by issued.res) id.grain)
            =(lord lord:(~(got by granary) id))
        ==
      ::
        %-  ~(all in issued.res)
        |=  [=id:std =grain:std]
        ::  id in issued map must be equal to id in grain AND
        ::  all newly issued grains must have properly-hashed id AND
        ::  lord of grain must be contract issuing it
        ?&  =(id id.grain)
            =((fry:std lord.grain town-id.grain germ.grain) id.grain)
            =(lord lord.grain)
    ==  ==
  --
--
