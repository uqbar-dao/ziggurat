::  ziggurat [uqbar-dao]
::
::  TODO need to make sure this design is acceptable in terms of
::  data availability and censorship. last validator in epoch is random,
::  but there's still only 1 per epoch and they could censor. since
::  the set of possible transactions in the town contract is so narrow,
::  possibly we can show that no logic can result in unwanted secret
::  manipulation
::
/-  indexer
/+  *ziggurat, default-agent, dbug, verb
/*  smart-lib  %noun  /lib/zig/compiled/smart-lib/noun
=,  util
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      mode=?(%indexer %validator %none)
      address=(unit id:smart)
      =epochs
      queue=(map slot-num=@ud chunks)
      =basket           ::  accept town mgmt txs from stars
      globe=town:smart  ::  store town hall info; update end of each epoch
      =height
  ==
+$  inflated-state-0  [state-0 =mil]
+$  mil  $_  ~(mill mill 0)
--
::
=|  inflated-state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  `this(state [[%0 %none ~ ~ ~ ~ [~ ~] 0] ~(mill mill +:(cue q.q.smart-lib))])
::
++  on-save  !>(-.state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  =+  ~(mill mill +:(cue q.q.smart-lib))
  `this(state [!<(state-0 old-vase) -])
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  ~|("%ziggurat: error: got erroneous %watch" !!)
      [%validator ?([%epoch-catchup @ ~] [%updates ~])]
    ?:  =(mode %none)  ~|("%ziggurat: error: got %watch when not active" !!)
    ~|  "%ziggurat: error: only stars can listen to block production!"
    ?>  (allowed-participant [src our now]:bowl)
    ?-    i.t.path
        %updates
      ::  do nothing here, but send all new blocks and epochs on this path
      `this
    ::
        %epoch-catchup
      ~|  "%ziggurat: error: we must be a validator to be listened to on this path"
      ?>  =(mode %validator)
      ::  TODO: figure out whether to use this number or not
      ::  =/  start=(unit @ud)
      ::  =-  ?:(=(- 0) ~ `(dec -))
      ::  (slav %ud i.t.t.path)
      ~&  "%ziggurat: got a watch on %epoch-catchup, sharing epochs"
      :_  this
      :+  [%give %fact ~ %zig-update !>([%epochs-catchup epochs])]
        [%give %kick ~ ~]
      ~
    ==
  ::
      [%sequencer %updates ~]
    ~|  "%ziggurat: error: only {<our.bowl>} can listen here"
    ?>  =(src.bowl our.bowl)
    ::  send next-producer on this path for our sequencer agent
    `this
  ::
      [%indexer %updates ~]
    ::  ~|  "comets and moons may not be indexers, tiny dos protection"
    ::  ?>  (lte (met 3 src.bowl) 4)
    ::  do nothing here, but send all new blocks and epochs on this path
    `this
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  ~|("%ziggurat: error: got erroneous %poke" !!)
      %zig-chain-poke
    =^  cards  state
      (poke-chain !<(chain-poke vase))
    [cards this]
    ::
      %zig-weave-poke
    =^  cards  state
      (poke-basket !<(weave-poke vase))
    [cards this]
    ::
      %noun
    ~|  "%ziggurat: error: {<src.bowl>} not welcome here"
    ?>  (allowed-participant [src our now]:bowl)
    ~|  "%ziggurat: error: invalid history"
    ?>  (validate-history our.bowl epochs)
    `this
  ==
  ::
  ++  poke-chain
    |=  act=chain-poke
    ^-  (quip card _state)
    ?-    -.act
        %set-addr
      ?>  =(src.bowl our.bowl)
      `state(address `id.act)
    ::
        %start
      ?>  =(src.bowl our.bowl)
      ~|  "ziggurat must be run on a star or star-moon"
      ?>  (allowed-participant our.bowl our.bowl now.bowl)
      ?~  address.state
        ~|("ziggurat requires an associated public key" !!)
      ~|  "we have already started in this mode"
      ?<  =(mode mode.act)
      =?  epochs  ?=(^ history.act)
        history.act
      ?:  ?=(%indexer mode.act)
        :_  state(mode %indexer)
        (subscriptions-cleanup wex.bowl sup.bowl)
      ::  become a validator
      ?>  ?|(?=(^ epochs) ?=(^ validators.act))
      ?~  others=~(tap in (~(del in validators.act) our.bowl))
        ::  single-validator new chain
        ~&  >  "initializing new blockchain"
        :_  state(mode %validator, globe starting-state.act)
        %-  zing
        :~  (subscriptions-cleanup wex.bowl sup.bowl)
            ?~  epochs  ~
            (new-epoch-timers +:(need (pry:poc epochs)) our.bowl)
        ==
      ::  joining the existing blockchain
      ::  give ourselves a dummy epoch, but immediately start
      ::  %epoch-catchup from one of the other known validators
      ~&  >  "%ziggurat: attempting to join relay chain"
      =+  sig=become-validator+(sign:zig-sig our.bowl now.bowl 'attestation')
      ::  ask the indexer for current set of validators on-chain
      ::  so we can subscribe to them all
      ~|  "%ziggurat: error: can't find validators on-chain"
      =/  capitol-search
        .^(update:indexer %gx /(scot %p our.bowl)/indexer/(scot %da now.bowl)/grain/(scot %ux 'ziggurat')/noun)
      ?>  ?=(%grain -.capitol-search)
      =/  capitol-grain=grain:smart  +.+.-:~(tap by grains.capitol-search)
      ?>  ?=(%& -.germ.capitol-grain)
      =/  validators  ~(key by (hole:mill (map ship *) data.p.germ.capitol-grain))
      ::
      =+  (gas:poc ~ [0 [0 *@da ~(tap in validators) ~]]^~)
      :_  state(mode %validator, epochs -)
      ::  make tx to add ourselves, send to another validator
      %-  zing
      :~  (subscriptions-cleanup wex.bowl sup.bowl)
          (watch-updates validators)
          :~  :*  %pass  /set-node
                  %agent  [our.bowl %wallet]
                  %poke  %zig-wallet-poke
                  !>([%set-node relay-town-id i.others])
              ==
              (start-epoch-catchup i.others 0)
              (poke-capitol our.bowl u.address.state [1 100.000] sig)
          ==
      ==
    ::
        %stop
      ?>  =(src.bowl our.bowl)
      ?~  address.state
        ~|("%ziggurat: error: requires an associated public key" !!)
      =+  stop-validating+(sign:zig-sig our.bowl now.bowl 'attestation')
      :_  state
      ~[(poke-capitol our.bowl u.address.state [rate.gas.act bud.gas.act] -)]
    ::
        %new-epoch
      ?>  =(src.bowl our.bowl)
      =/  cur=epoch          +:(need (pry:poc epochs))
      =/  last-slot=slot     +:(need (pry:sot slots.cur))
      =/  last-slot-num=@ud  num.p.last-slot
      ?~  validator-set=(get-on-chain-validator-set p.globe.state)
        ::  haven't received global state yet, sit tight
        ~&  >>>  "%ziggurat: waiting to receive relay state"
        `state
      ::  if we're no longer in validator set, leave the chain
      ?.  (~(has in u.validator-set) our.bowl)
        :-  (subscriptions-cleanup wex.bowl sup.bowl)
        state(mode %none, epochs ~, queue ~, basket ~, globe [~ ~], height 0)
      =/  new-epoch=epoch
        :^    +(num.cur)
            (deadline start-time.cur (dec (lent order.cur)))
          ::  ~&  >>>  `@ux`(epoch-seed last-slot-num epochs cur)
          ::  ~&  >>>  (shuffle u.validator-set (epoch-seed last-slot-num epochs cur))
          (shuffle u.validator-set (epoch-seed last-slot-num epochs cur))
        ~
      =/  validators=(list ship)
        ~(tap in (~(del in u.validator-set) our.bowl))
      ?:  ?&  ?=(^ validators)
              %+  lth  start-time.new-epoch
              (sub now.bowl (mul +((lent order.new-epoch)) epoch-interval))
          ==
        ::  this epoch has already started
        ~&  >>>  "%ziggurat: attempting to catch up with known validators"
        :_  state
        (start-epoch-catchup i.validators num.cur)^~
      ::  either on-time to start epoch, or solo validator
      ::  set our timers for all the slots in this epoch,
      ::  subscribe to all the other validator ships,
      ::  and alert subscribing sequencers of the next block producer
      ~&  epoch+num.new-epoch^u.validator-set^`@ux`(end [3 2] (sham epochs))
      =/  [next-producer=ship next-slot=@ud]
        ?~  +.order.new-epoch
          [-.order.new-epoch 0]
        [-.+.order.new-epoch 1]
      :_  %=  state
            epochs  (put:poc epochs num.new-epoch new-epoch)
            queue   (malt ~[[relay-town-id (~(gut by queue) relay-town-id ~)]])
            height  ?~(q.last-slot height height.u.q.last-slot)
          ==
      =+  %-  hall-update-card
          .^((unit @ud) %gx /(scot %p our.bowl)/sequencer/(scot %da now.bowl)/town-id/noun)
      %-  zing
      :~  [(notify-sequencer next-slot next-producer) ?~(- ~ [u.- ~])]
          (watch-updates (silt (murn order.new-epoch filter-by-wex)))
          (new-epoch-timers new-epoch our.bowl)
      ==
    ::
        %receive-chunk
      ?>  (allowed-participant [src our now]:bowl)
      ~&  >  "ziggurat: received chunk town={<town-id.act>} for slot={<for-slot.act>} from {<src.bowl>}"
      ::  only accept chunks from sequencers in on-chain council
      =/  found  (~(got by p.globe.state) `@ux`'world')
      ?.  ?=(%& -.germ.found)
        ~|("ziggurat: error: couldn't find that town on chain" !!)
      =+  (hole:mill ,(map @ud (map ship [@ux [@ux @p life]])) data.p.germ.found)
      ?~  hall=(~(get by -) town-id.act)
        ~|("ziggurat: error: couldn't find that town on chain" !!)
      ?.  (~(has by u.hall) src.bowl)
        ~|("ziggurat: error: only registered sequencers are allowed to submit a chunk" !!)
      =/  cur=epoch  +:(need (pry:poc epochs))
      =/  slot=(unit [key=@ud val=slot])  (pry:sot slots.cur)
      ?.  .=  our.bowl
          ?~  slot
            ?~(+.order.cur -.order.cur -.+.order.cur)
          ::  ~&  >>  `@ux`(sham p.val.u.slot)
          +:(next-block-producer num.p.val.u.slot order.cur p.val.u.slot)
        ~&  >>>  "ziggurat: rejecting chunk, we're not next block producer"
        !!
      =+  (~(gut by queue.state) for-slot.act ~)
      ?:  (~(has by -) town-id.act)
        ~&  >>>  "ziggurat: rejecting chunk, we already have one for that town in that slot!"
        !!
      `state(queue (~(put by queue.state) for-slot.act (~(put by -) town-id.act chunk.act)))
    ==
  ::
  ++  poke-basket
    |=  act=weave-poke
    ^-  (quip card _state)
    ~|  "ziggurat: rejected relay chain transaction"
    ?>  (allowed-participant [src our now]:bowl)
    =/  cur=epoch  +:(need (pry:poc epochs))
    ?-    -.act
        %forward
      ::  only accepts transactions from possible validators/sequencers
      =.  eggs.act  (filter eggs.act |=(=egg:smart =(relay-town-id town-id.p.egg)))
      ::  TODO FIX: if transaction is submitted after this ship has made their block,
      ::  the transaction gets stuck in limbo. Can fix by having ziggurats forward their basket
      ::  at beginning of epoch if it isn't empty.
      =+  final-producer=(get-second-to-last order.cur)
      ?:  =(our.bowl final-producer)
        `state(basket (~(uni in basket) eggs.act))
      ::  clear our basket and forward to final producer in epoch
      :_  state(basket ~)
      :_  ~
      :*  %pass  /basket-gossip
          %agent  [final-producer %ziggurat]
          %poke  %zig-weave-poke
          !>([%receive (~(uni in eggs.act) basket.state)])
      ==
    ::
        %receive
      ?~  (find [src.bowl]~ order.cur)
        ~|("ziggurat: can only receive eggs from known validators" !!)
      ~|  "ziggurat: rejected basket: we're not the final validator for this epoch"
      ?>  =(our.bowl (get-second-to-last order.cur))
      `state(basket (~(uni in basket) eggs.act))
    ==
  ::
  ++  watch-updates
    |=  validators=(set ship)
    ^-  (list card)
    =.  validators  (~(del in validators) our.bowl)
    %+  turn  ~(tap in validators)
    |=  s=ship
    ^-  card
    =/  =^wire  /validator/updates/(scot %p s)
    [%pass wire %agent [s %ziggurat] %watch /validator/updates]
  ::
  ++  filter-by-wex
    |=  shp=ship
    ^-  (unit ship)
    ?:  %-  ~(any in ~(key by wex.bowl))
        |=([* =ship *] =(shp ship))
      ~
    `shp
  ::
  ::  +hall-update: give sequencer updated hall for their town at start of new epoch
  ::
  ++  hall-update-card
    |=  town-id=(unit @ud)
    ^-  (unit card)
    ?~  town-id  ~
    ::  grab on-chain data for that hall in this epoch
    ?~  found=(~(get by p.globe.state) `@ux`'world')  ~
    ?.  ?=(%& -.germ.u.found)                         ~
    =+  (hole:mill ,(map @ud (map ship [@ux [@ux @p life]])) data.p.germ.u.found)
    ?~  hall=(~(get by -) u.town-id)                  ~
    `[%give %fact ~[/sequencer/updates] %sequencer-update !>([%new-hall u.hall])]
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  |^
  ?+    wire  (on-agent:def wire sign)
      [%validator ?([%epoch-catchup @ @ ~] [%updates @ ~])]
    ~|  "can only receive validator updates when we are a validator!"
    ?>  =(mode %validator)
    ?-    i.t.wire
        %updates
      ?<  ?=(%poke-ack -.sign)
      ?:  ?=(%watch-ack -.sign)
        ?~  p.sign
          `this
        ~&  u.p.sign
        `this
      ?:  ?=(%kick -.sign)
        ::  resubscribe to validators for updates if kicked
        ::
        :_  this
        [%pass wire %agent [src.bowl %ziggurat] %watch (snip `path`wire)]~
      =^  cards  state
        (update-fact !<(update q.cage.sign))
      [cards this]
    ::
        %epoch-catchup
      ?<  ?=(%poke-ack -.sign)
      ?:  ?=(%kick -.sign)  `this
      ?:  ?=(%watch-ack -.sign)  `this
        ::  ?.  ?=(^ p.sign)    `this
        ::  =/  cur=epoch  +:(need (pry:poc epochs))
        ::  =/  validators=(list ship)
        ::    ?:  =(2 (lent order.cur))
        ::      ~(tap in (~(del in (silt order.cur)) our.bowl))
        ::    ~(tap in (~(del in (~(del in (silt order.cur)) our.bowl)) src.bowl))
        ::  ?~  validators  !!
        ::  :_  this
        ::  (start-epoch-catchup i.validators num.cur)^~
      ?>  ?=(%fact -.sign)
      =^  cards  state
        (epoch-catchup !<(update q.cage.sign))
      [cards this]
    ==
  ::
      [%indexer %updates ~]
    ~|  "can only receive indexer updates when we are an indexer!"
    ?>  =(%indexer mode)
    `this
  ==
  ::
  ++  update-fact
    |=  =update
    ^-  (quip card _state)
    =/  cur=epoch  +:(need (pry:poc epochs))
    =/  next-slot-num
      ?~(p=(bind (pry:sot slots.cur) head) 0 +(u.p))
    =/  prev-hash
      (got-hed-hash next-slot-num epochs cur)
    ?+    -.update  !!
        %new-block
      ~&  "received a block from {<src.bowl>}"
      ?:  (lth epoch-num.update num.cur)
        ~&  >>>  "%ziggurat: ignoring an old block from a prior epoch"
        `state
      ?:  (gth epoch-num.update num.cur)
        ::  the new block is from an epoch beyond what we have as current,
        ::  determine who and whether to try and catch up
        =/  validators=(list ship)
          ?:  =(2 (lent order.cur))
            ~(tap in (~(del in (silt order.cur)) our.bowl))
          ~(tap in (~(del in (~(del in (silt order.cur)) our.bowl)) src.bowl))
        ?.  ?=(^ validators)
          ::  if we believe we're the only validator, just ignore old block
          `state
        ::  otherwise try to catch up
        :_  state
        (start-epoch-catchup i.validators num.cur)^~
      ::  incorporate block into our epoch
      ::
      =^  cards  cur
        %-  ~(their-block epo cur prev-hash [our now src]:bowl)
        [header `block]:update
      ::  updating globe state on every block -- can limit this to
      ::  only on block where we make changes (currently second-to-last)
      ::  for efficiency's sake
      :-  cards
      %=  state
        height  height.block.update
        epochs  (put:poc epochs num.cur cur)
        globe   +:(~(got by chunks.block.update) relay-town-id)
      ==
    ::
        %saw-block
      :_  state
      %+  ~(see-block epo cur prev-hash [our now src]:bowl)
        epoch-num.update
      header.update
    ==
  ::
  ++  epoch-catchup
    |=  =update
    ^-  (quip card _state)
    ?>  ?=(%epochs-catchup -.update)
    ~&  "%ziggurat: catching up to {<src.bowl>}"
    =/  a=(list (pair @ud epoch))  (bap:poc epochs.update)
    =/  b=(list (pair @ud epoch))  (bap:poc epochs)
    ?~  epochs.update
      ~&  %picked-our-history^": no competitor"
      `state
    ~|  "invalid history"
    ?>  (validate-history our.bowl epochs.update)
    ?~  epochs
      ~&  %picked-their-history^": we had none"
      `state(epochs epochs.update)
    |-  ^-  (quip card _state)
    ?~  b
      ::  if we pick their history, clear old timers if any exist
      ::  and set new ones based on latest epoch
      ::  set global state to match last block in acquired history
      ::  TODO set block height based on theirs
      ~&  %picked-their-history^": longer blockchain"
      =/  [n=@ud =epoch]  (need (pry:poc epochs.update))
      =/  =slot
        ?~  latest=(pry:sot slots.epoch)
          ::  look in previous epoch
          =/  prev=^epoch  (got:poc epochs.update (dec n))
          +:(need (pry:sot slots.prev))
        +.u.latest
      =+  +:(~(got by chunks:(need q.slot)) relay-town-id)
      :_  state(epochs epochs.update, globe -)
      (new-epoch-timers epoch our.bowl)
    ?~  a
      ~&  %picked-our-history^": longer blockchain"
      `state
    ?:  =(i.a i.b)
      $(a t.a, b t.b)
    =/  a-s=(list (pair @ud slot))  (tap:sot slots.q.i.a)
    =/  b-s=(list (pair @ud slot))  (tap:sot slots.q.i.b)
    |-  ^-  (quip card _state)
    ?~  a-s        ^$(a t.a, b t.b)
    ?~  b-s        ^$(a t.a, b t.b)
    ?~  q.q.i.b-s
      ~&  %picked-their-history^": more slots"
      =/  [n=@ud =epoch]  (need (pry:poc epochs.update))
      =/  =slot
        ?~  latest=(pry:sot slots.epoch)
          ::  look in previous epoch
          =/  prev=^epoch  (got:poc epochs.update (dec n))
          +:(need (pry:sot slots.prev))
        +.u.latest
      =+  +:(~(got by chunks:(need q.slot)) relay-town-id)
      :_  state(epochs epochs.update, globe -)
      (new-epoch-timers epoch our.bowl)
    ?~  q.q.i.a-s
      ~&  %picked-our-history^": more slots"
      `state
    $(a-s t.a-s, b-s t.b-s)
  --
::
++  on-arvo
  |=  [=wire =sign-arvo:agent:gall]
  |^  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%timers ?([%slot @ @ ~] [%epoch-catchup @ @ ~])]
    ~|  "ziggurat: error: these timers are only relevant for validators!"
    ?>  =(%validator mode)
    ?:  ?=(%epoch-catchup i.t.wire)
      `this
    =/  epoch-num  (slav %ud i.t.t.wire)
    =/  slot-num  (slav %ud i.t.t.t.wire)
    ?>  ?=([%behn %wake *] sign-arvo)
    ?^  error.sign-arvo
      ~&  error.sign-arvo
      `this
    =^  cards  state
      (slot-timer epoch-num slot-num)
    [cards this]
  ==
  ::
  ++  slot-timer
    |=  [epoch-num=@ud slot-num=@ud]
    ^-  (quip card _state)
    =/  cur=epoch  +:(need (pry:poc epochs))
    ?.  =(num.cur epoch-num)
      ::  timer is from an epoch that we don't view as current, ignore
      `state
    =/  next-slot-num
      ?~(p=(bind (pry:sot slots.cur) head) 0 +(u.p))
    ::  see which ship is responsible for this slot
    =/  =ship  (snag slot-num order.cur)
    ?.  =(next-slot-num slot-num)
      ::  timer does not match slot we view as currently open, ignore
      ?.  =(ship our.bowl)  `state
      ~|("%ziggurat: error: we can only produce the next block, not past or future blocks" !!)
    =/  prev-hash
      (got-hed-hash slot-num epochs cur)
    ?:  =(ship our.bowl)
      ::  we are responsible for producing a block in this slot
      ::
      ::  TODO: check what chunks we received and see if any were missing
      ::
      =+  second-to-last=(get-second-to-last order.cur)
      ?.  =(our.bowl second-to-last)
        ::  normal block
        =+  :_  height.state
            %+  ~(put by (~(gut by queue.state) slot-num ~))
            relay-town-id  [~ globe.state]
        =^  cards  cur
          (~(our-block epo cur prev-hash [our now src]:bowl) -)
        :-  cards
        %=  state
          height  +(height)
          queue   (~(del by queue) slot-num)
          epochs  (put:poc epochs num.cur cur)
        ==
      ::  if this is the SECOND TO LAST block in the epoch,
      ::  perform global-level transactions
      ::  insert transaction to advance
      =+  /(scot %p our.bowl)/wallet/(scot %da now.bowl)/account/(scot %ux (need address.state))/(scot %ud relay-town-id)/noun
      =+  .^(account:smart %gx -)
      =/  globe-chunk
        (~(mill-all mil - relay-town-id height.state) globe.state ~(tap in basket.state))
      =+  :_  height.state
          %+  ~(put by (~(gut by queue.state) slot-num ~))
          relay-town-id  globe-chunk
      =^  cards  cur
        (~(our-block epo cur prev-hash [our now src]:bowl) -)
      :-  cards
      %=  state
        basket  ~
        height  +(height)
        globe   +.globe-chunk
        queue   (~(del by queue) slot-num)
        epochs  (put:poc epochs num.cur cur)
      ==
    ::  someone else was responsible for producing this block,
    ::  but they have not done so
    =^  cards  cur
      ~(skip-block epo cur prev-hash [our now src]:bowl)
    ~&  skip-block+[num.cur slot-num]
    [cards state(epochs (put:poc epochs num.cur cur))]
  --
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ::  scries for sequencer agent
  ::
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%active ~]
    ``noun+!>(`?`=(%validator mode.state))
  ::
      [%block-height ~]
    ``noun+!>(height.state)
  ::
      [%address ~]
    ``noun+!>(`(unit id:smart)`address.state)
  ::
      [%epoch ~]
    =/  cur=epoch  +:(need (pry:poc epochs))
    ``noun+!>(`@ud`num.cur)
  ::
      [%slot ~]
    =/  cur=epoch  +:(need (pry:poc epochs))
    ``noun+!>(`@ud`?~(p=(bind (pry:sot slots.cur) head) 0 +(u.p)))
  ::  scries for contracts
  ::
      [%rice @ ~]
    (read-rice t.path height.state relay-town-id p.globe.state)
  ::
      [%wheat @ @tas @ta ^]  :: grain id, %noun/%json, argument @ta, then any associated rice IDs
    (read-wheat t.path height.state relay-town-id p.globe.state)
  ::
      [%sizeof @ ~]
    ::  give size of item in global granary
    =/  id  (slav %ux i.t.t.path)
    ?~  res=(~(get by p.globe.state) id)  ``noun+!>(~)
    ``noun+!>(`(met 3 (jam res)))
  ::
      [%chain-size ~]
    ::  give size of full chain state
    ``noun+!>((met 3 (jam epochs.state)))
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
