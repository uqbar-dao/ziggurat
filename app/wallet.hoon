::  wallet [uqbar-dao]
::
::  Uqbar wallet agent. Stores private key and facilitates signing
::  transactions, holding nonce values, and keeping track of owned data.
::
/+  *ziggurat, default-agent, dbug, verb
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      keys=(map pub=@ [=acru:ames seed=@])  ::  private key-store
      nodes=(map town=@ud =ship)  ::  the sequencer you submit txs to for each town
      nonces=(map pub=@ (map town=@ud nonce=@ud))
      books=(map pub=@ book)  ::  "address book" of rice for each key
      ::  TODO add block explorer hookup here, can subscribe for changes
      ::  potential to do cool stuff with %pals integration here
  ==
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init  `this(state [%0 ~ ~ ~ ~])
::
++  on-save  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  =/  old-state  !<(state-0 old-vase)
  `this(state old-state)
::
++  on-watch  on-watch:def
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  !!
      %zig-wallet-poke
    =^  cards  state
      (poke-wallet !<(wallet-poke vase))
    [cards this]
  ==
  ::
  ++  poke-wallet
    |=  act=wallet-poke
    ^-  (quip card _state)
    ?>  =(src.bowl our.bowl)
    ?-    -.act
    ::
        %import
      =/  new-keys  (pit:nu:crub:crypto 256 seed.act)
      `state(keys (~(put by keys) pub:ex:new-keys [new-keys seed.act]))
    ::
        %create
      =/  new-keys  (pit:nu:crub:crypto 256 eny.bowl)
      `state(keys (~(put by keys) pub:ex:new-keys [new-keys eny.bowl]))
    ::
        %delete
      ::  will irreversibly lose seed...
      :-  ~  %=  state
        keys    (~(del by keys) address.act)
        nonces  (~(del by nonces) address.act)
        books   (~(del by books) address.act)
      ==
    ::
        %set-node
      `state(nodes (~(put by nodes) town.act ship.act))
    ::
        %set-nonce  ::  mostly for testing
      =+  acc=(~(got by nonces.state) address.act)
      `state(nonces (~(put by nonces) address.act (~(put by acc) town.act new.act)))
    ::
        %populate
      ::  populate wallet with fake data for testing
      ::  will WIPE previous wallet state!!
      =/  new-keys  (pit:nu:crub:crypto 256 eny.bowl)
      =/  pub  pub:ex:new-keys
      =/  fake-1
        :-  [1 0x0 'zigs']
        :*  (fry-rice:smart pub 0x0 1 `@`'zigs')
            0x0  pub  1
            [%& `@`'zigs' [100.000.000 ~]]
        ==
      =/  fake-2
        :-  [1 `@ux`'fake-token' 'wETH']
        :*  (fry-rice:smart pub `@ux`'fake-token' 1 `@`'wETH')
            `@ux`'fake-token'  pub  1
            [%& `@`'wETH' [173.000 ~]]
        ==
      :-  ~
      %=  state
        keys  (malt ~[[pub [new-keys eny.bowl]]])
        nodes  (malt ~[[0 ~zod] [1 ~bus] [2 ~nec]])
        nonces  (malt ~[[pub (malt ~[[0 0] [1 0] [2 0]])]])
        books  (malt ~[[pub (malt ~[[fake-1] [fake-2]])]])
      ==        
    ::
        %submit
      ::  submit a transaction
      ::  create an egg and sign it, then poke a sequencer
      ::
      ::  things to expose on frontend:
      ::  'from' address, contract 'to' address, town select, 
      ::  gas (rate & budget), transaction type (acquired from ABI..?)
      ::  
      =/  our-nonces     (~(gut by nonces.state) from.act ~)
      =/  nonce=@ud      (~(gut by our-nonces) town.act 0)
      =/  =caller:smart  [from.act +(nonce) (fry-rice:smart from.act 0x0 town.act 'zigs')]
      =/  =yolk:smart    [caller args.act my-grains.act cont-grains.act]
      =/  sig=@          (sign:as:acru:(~(got by keys.state) from.act) (sham (jam yolk)))
      =/  =egg:smart     [[caller sig to.act rate.gas.act bud.gas.act town.act] yolk]
      =/  node=ship      ?~(sequencer.act (~(got by nodes.state) town.act) u.sequencer.act)
      :_  state(nonces (~(put by nonces) from.act (~(put by our-nonces) town.act +(nonce))))
      :~  :*  %pass  /submit-tx
              %agent  [node ?:(=(0 town.act) %ziggurat %sequencer)]
              %poke  %zig-weave-poke
              !>([%forward (silt ~[egg])])
      ==  ==
    ==
  --
::
++  on-agent
  ::  TODO provide subscribe paths for frontend,
  ::  and update it on changes to wallet state.
  ::  Changes will be provided by connecting to an indexer
  on-agent:def
::
++  on-arvo  on-arvo:def
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?.  =(%x -.path)  ~
  ::  TODO move JSON parsing stuff into a helper lib
  ?+    +.path  (on-peek:def path)
      [%accounts ~]
    =;  =json  ``json+!>(json)
    =,  enjs:format
    %-  pairs
    %+  turn  ~(tap by keys.state)
    |=  [pub=@ux [hold=acru:ames seed=@]]
    :-  (scot %ux pub)
    %-  pairs
    :~  ['address' (tape (scow %ux pub))]
        ['seed' (tape (scow %ux seed))]
        :-  'nonces'
        %-  pairs
        %+  turn  ~(tap by (~(gut by nonces.state) pub ~))
        |=  [town=@ud nonce=@ud]
        [(crip (scow %ud town)) (numb nonce)]
    ==
  ::
      [%account @ @ ~]
    ::  returns our account for the pubkey and town-id given
    ::  for validator & sequencer use, to execute mill
    =/  pub  (slav %ux i.t.t.path)
    =/  town-id  (slav %ud i.t.t.t.path)
    =/  nonce  (~(gut by (~(got by nonces.state) pub)) town-id 0)
    =/  zigs=id:smart
      (fry-rice:smart pub 0x0 town-id 'zigs')
    ``noun+!>(`account:smart`[pub nonce zigs])
  ::
      [%book ~]
    ::  return entire book map for wallet frontend
    =;  =json  ``json+!>(json)
    =,  enjs:format
    %-  pairs
    %+  turn  ~(tap by books.state)
    |=  [pub=@ux =book]
    :-  (scot %ux pub)
    %-  pairs
    %+  turn  ~(tap by book)
    |=  [* =grain:smart]
    =/  bal=@ud
      ?.  ?=(%& -.germ.grain)  0
      ;;(@ud -.data.p.germ.grain)
    :-  (scot %ux id.grain)
    %-  pairs
    :~  ['id' (tape (scow %ux id.grain))]
        ['lord' (tape (scow %ux lord.grain))]
        ['holder' (tape (scow %ux holder.grain))]
        ['town' (numb town-id.grain)]
        ::  note: need to use 'token standard' here
        ::  to guarantee properly parsed data
        ['data' (frond 'balance' (numb bal))]
    ==
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
