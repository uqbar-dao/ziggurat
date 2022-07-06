::  rollup [UQ| DAO]
::
::  Agent that simulates a rollup contract on another chain.
::  Receives state transitions (moves) for towns, verifies them,
::  and allows sequencer ships to continue processing batches.
::
/+  *sequencer, *rollup, mill=zig-mill, default-agent, dbug, verb
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      =capitol
      status=?(%available %off)
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
++  on-init  `this(state [%0 ~ %off])
++  on-save  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  `this(state !<(state-0 old-vase))
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?.  =(%available status.state)
    ~|("%rollup: error: got watch while not active" !!)
  ?>  (allowed-participant [src our now]:bowl)
  ::  give new subscibing sequencer recent root from every town
  ::
  ?+    path  !!
      [%capitol-updates ~]
    :_  this
    =-  [%give %fact ~ -]~
    [%sequencer-rollup-update !>(`capitol-update`[%new-capitol capitol])]
  ::
      [%peer-root-updates ~]
    :_  this
    %+  turn  ~(tap by capitol)
    |=  [=id:smart =hall:sequencer]
    ^-  card
    =-  [%give %fact ~ -]
    [%sequencer-rollup-update !>(`town-update`[%new-peer-root id (rear roots.hall) now.bowl])]
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?.  ?=(%rollup-action mark)
    ~|("%rollup: error: got erroneous %poke" !!)
  ?>  (allowed-participant [src our now]:bowl)
  =^  cards  state
    (handle-poke !<(action vase))
  [cards this]
  ::
  ++  handle-poke
    |=  act=action
    ^-  (quip card _state)
    ?-    -.act
        %activate
      `state(status %available)
    ::
        %launch-town
      ::  create new hall
      ?<  (~(has by capitol) town-id.hall.act)
      ::  TODO remove starting-state from init and populate new towns via
      ::  assets from other towns
      =+  (~(put by capitol) town-id.hall.act hall.act)
      :_  state(capitol -)
      :~  =-  [%give %fact ~[/peer-root-updates] %sequencer-rollup-update -]
          !>(`town-update`[%new-peer-root town-id.hall.act (rear roots.hall.act) now.bowl])
      ::
          =-  [%give %fact ~[/capitol-updates] %sequencer-rollup-update -]
          !>(`capitol-update`[%new-capitol -])
      ==
    ::
        %bridge-assets
      ::  for simulation purposes
      ?~  hall=(~(get by capitol.state) town-id.act)  !!
      :_  state
      =+  [%town-action !>([%receive-assets assets.act])]
      [%pass /bridge %agent [q.sequencer.u.hall %sequencer] %poke -]~
    ::
        %receive-batch
      ?~  hall=(~(get by capitol.state) town-id.act)
        ~|("%rollup: rejecting batch; town not found" !!)
      ?.  =([from.act src.bowl] sequencer.u.hall)
        ~|("%rollup: rejecting batch; sequencer doesn't match town" !!)
      ?.  (verify-sig:mill from.act new-root.act sig.act %.y)
        ~|("%rollup: rejecting batch; sequencer signature not valid" !!)
      ?.  =(diff-hash.act (sham state-diffs.act))
        ~|("%rollup: rejecting batch; diff hash not valid" !!)
      ::  check that other town state roots are up-to-date
      ::  recent-enough is a variable here that can be adjusted
      =/  recent-enough  2
      ?.  %+  levy
            %+  turn  ~(tap by peer-roots.act)
            |=  [=id:smart root=@ux]
            ?~  hall=(~(get by capitol.state) id)  %.n
            =+  ?:  (lte (lent roots.u.hall) recent-enough)
                  roots.u.hall
                (slag recent-enough roots.u.hall)
            ?~  (find [root]~ -)
              %.n
            %.y
          |=(a=? a)
        ~|("%rollup: rejecting batch; peer roots not recent enough" !!)
      ?:  ?=(%committee -.mode.act)
        ::  handle DAC, TODO
        ::
        !!
      ::  handle full-publish mode
      ::
      =+  %=  u.hall
            latest-diff-hash  diff-hash.act
            roots  (snoc roots.u.hall new-root.act)
          ==
      =+  (~(put by capitol) town-id.act -)
      :_  state(capitol -)
      :~  =-  [%give %fact ~[/peer-root-updates] %sequencer-rollup-update -]
          !>(`town-update`[%new-peer-root town-id.act new-root.act now.bowl])
      ::
          =-  [%give %fact ~[/capitol-updates] %sequencer-rollup-update -]
          !>(`capitol-update`[%new-capitol -])
      ==
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  (on-agent:def wire sign)
::
++  on-arvo
  |=  [=wire =sign-arvo:agent:gall]
  ^-  (quip card _this)
  (on-arvo:def wire sign-arvo)
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ::  all scrys return a unit
  ::
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%status ~]
    ``noun+!>(status.state)
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
