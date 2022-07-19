::  Test suite for multisig.hoon
::
/+  *test, cont=zig-contracts-multisig, *zig-sys-smart
/=  lib  /lib/zig/contracts/lib/multisig
=,  lib
=>  ::  test data
    |%
    ++  init-now  ~2022.6.20..17.54.07..7d8d
    ++  town-id    0x1
    ::
    ++  owner-1
      ^-  account
      [id=0xbeef nonce=0 zigs=0x1234.5678]
    ++  owner-2
      ^-  account
      [0xdead 0 0x1234.5678]
    ++  owner-3
      ^-  account
      [0xcafe 0 0x1234.5678]
    ::
    ++  multisig-wheat-id  0x2222.2222
    ++  egg-add-member
      =|  =egg
      =.  p.egg
        %=  p.egg
          from     multisig-wheat-id
          to       multisig-wheat-id
          rate     10
          budget   100.000
          town-id  town-id
        ==
      =.  q.egg
        %=  q.egg
          action       `[%add-member id:owner-2]
          cont-grains  (silt ~[multisig-grain-id])
        ==
      egg
    ++  egg-add-member-hash
      (sham-egg [egg-add-member [id nonce]:owner-1 (add init-now ~s1)])
    ++  egg-remove-member
      =|  =egg
      =.  p.egg
        %=  p.egg
          from     multisig-wheat-id
          to       multisig-wheat-id
          rate     10
          budget   100.000
          town-id  town-id
        ==
      =.  q.egg
        %=  q.egg
          action       `[%remove-member id:owner-1]
          cont-grains  (silt ~[multisig-grain-id])
        ==
      egg
    ++  egg-remove-member-hash
      (sham-egg [egg-add-member [id nonce]:owner-2 (add init-now ~s5)])
    ::
    ++  multisig-state-1
      ::  base state
      ^-  multisig-state
      [members=(silt ~[id:owner-1]) threshold=1 pending=~]
    ++  multisig-state-2
      ^-  multisig-state
      :*  members:multisig-state-1
          threshold:multisig-state-1
          pending=(malt ~[[egg-add-member-hash [egg-add-member votes=~]]])
      ==
    ++  multisig-state-3
      ^-  multisig-state
      :*  members:multisig-state-2
          threshold:multisig-state-2
          pending=~  :: tx has passed
      ==
    ++  multisig-state-4
      ^-  multisig-state
      :*  (~(put in members:multisig-state-3) id:owner-2)
          threshold:multisig-state-3
          pending:multisig-state-3
      ==
    ++  multisig-state-5
      ^-  multisig-state
      :*  members:multisig-state-4
          threshold=2
          pending:multisig-state-4
      ==
    ::
    :: for our specific case, id and salt were simply pre-calculated by calling the contract
    ++  multisig-grain-id    0x5a0e.c09d.57d9.4bda.7524.50a3.ddbb.2248
    ++  multisig-salt        0x96be.233c.46b2.2eea.4f01.2490.8a36.3041  
    ++  multisig-grain-1
      ^-  grain
      :*  id=multisig-grain-id
          lord=multisig-wheat-id
          holder=multisig-wheat-id
          town-id
          germ=[%& salt=multisig-salt %multisig data=multisig-state-1]
      ==
    ++  multisig-grain-2
      ^-  grain
      :*  id:multisig-grain-1
          lord:multisig-grain-1
          holder:multisig-grain-1
          town-id:multisig-grain-1
          germ=[%& salt=multisig-salt %multisig data=multisig-state-2]
      ==
    ++  multisig-grain-3
      ^-  grain
      :*  id:multisig-grain-1
          lord:multisig-grain-1
          holder:multisig-grain-1
          town-id:multisig-grain-1
          germ=[%& salt=multisig-salt %multisig data=multisig-state-3]
      ==
    ++  multisig-grain-4
      ^-  grain
      :*  id:multisig-grain-1
          lord:multisig-grain-1
          holder:multisig-grain-1
          town-id:multisig-grain-1
          germ=[%& salt=multisig-salt %multisig data=multisig-state-4]
      ==
    ++  multisig-grain-5
      ^-  grain
      :*  id:multisig-grain-1
          lord:multisig-grain-1
          holder:multisig-grain-1
          town-id:multisig-grain-1
          germ=[%& salt=multisig-salt %multisig data=multisig-state-5]
      ==
    --
::  testing arms
|%
++  test-contract-typechecks  ^-  tang
  =/  valid  (mule |.(;;(contract cont)))
  (expect-eq !>(%.y) !>(-.valid))
::
++  test-create-multisig
  ^-  tang
  =/  =embryo
    :*  action=`[%create-multisig threshold=1 members=(silt ~[id:owner-1])]
        grains=~
    ==
  =/  =cart  [multisig-wheat-id from=[id:owner-1 0] (add init-now ~s0) town-id owns=~]
  =/  res=chick  (~(write cont cart) embryo)
  =*  expected-grain  multisig-grain-1
  =/  grain  ?>(?=(%.y -.res) (snag 0 ~(val by issued.p.res)))
  (expect-eq !>(expected-grain) !>(grain))
::
++  test-submit-tx
  ^-  tang
  ::  setting up the tx to propose
  ::  creating the execution context by hand
  =/  =embryo
    :*  action=`[%submit-tx egg-add-member]
        grains=~
    ==
  =/  =cart  [me=multisig-wheat-id from=[id:owner-1 0] (add init-now ~s1) town-id owns=(malt ~[[id:multisig-grain-1 multisig-grain-1]])]
  ::  executing the contract call with the context
  =/  res=chick  (~(write cont cart) embryo)
  ::
  =*  expected-grain  multisig-grain-2
  =/  grain  ?>(?=(%.y -.res) (snag 0 ~(val by changed.p.res)))
  (expect-eq !>(expected-grain) !>(grain))
++  test-vote-1
  ^-  tang
  =/  =embryo
    :*  action=`[%vote egg-add-member-hash]
        grains=~
    ==
  =/  =cart  [me=multisig-wheat-id from=[id:owner-1 0] (add init-now ~s2) town-id owns=(malt ~[[id:multisig-grain-2 multisig-grain-2]])]
  ::
  =/  res=chick  (~(write cont cart) embryo)
  ::
  =*  expected-grain  multisig-grain-3
  =/  [=grain next-list=_next:*hen]
    ?>  ?=(%.n -.res)
    [(snag 0 ~(val by changed.rooster.p.res)) next.p.res]
  ::
  =/  next  (snag 0 next-list)
  ;:  weld
    (expect-eq !>(expected-grain) !>(grain))
    ::
    ::  elementwise comparison of next and submitted egg
    (expect-eq !>(to.next) !>(to.p:egg-add-member))
    (expect-eq !>(town-id.next) !>(town-id.p:egg-add-member))
    (expect-eq !>(action.yolk.next) !>(action.q:egg-add-member))
    (expect-eq !>(cont-grains.yolk.next) !>(cont-grains.q:egg-add-member))
  ==
++  test-add-member
  ^-  tang
  =/  =embryo
    :*  action.q:egg-add-member
        grains=~
    ==
  =/  =cart  [me=multisig-wheat-id [multisig-wheat-id 0] (add init-now ~s3) town-id owns=(malt ~[[id:multisig-grain-3 multisig-grain-3]])]
  =/  res=chick  (~(write cont cart) embryo)
  ::
  =*  expected-grain  multisig-grain-4
  =/  grain  ?>(?=(%.y -.res) (snag 0 ~(val by changed.p.res)))
  (expect-eq !>(expected-grain) !>(grain))
++  test-set-threshold
  ^-  tang
  ::  skips the %vote tx for this, assumes it already happened
  =/  =embryo
    :*  action=`[%set-threshold 2]
        grains=~
    ==
  ::  TODO does this make sense?? this is approximating a continuation call and isn't exact anyways
  =/  =cart  [me=multisig-wheat-id from=[multisig-wheat-id 0] (add init-now ~s4) town-id owns=(malt ~[[id:multisig-grain-4 multisig-grain-4]])]
  =/  res=chick  (~(write cont cart) embryo)
  =*  expected-grain  multisig-grain-5
  =/  grain  ?>(?=(%.y -.res) (snag 0 ~(val by changed.p.res)))
  (expect-eq !>(expected-grain) !>(grain))
++  test-vote-2-of-2-remove-member
  ^-  tang
  =|  test-output=tang
  |^
  ::  TX 1 - %submit-tx to remove owner-1 from multisig
  ::
  =/  =embryo
    :*  action=`[%submit-tx egg-remove-member]
        grains=~
    ==
  =/  =cart      [me=multisig-wheat-id [id:owner-2 0] (add init-now ~s5) town-id owns=(malt ~[[id:multisig-grain-5 multisig-grain-5]])]
  =/  res=chick  (~(write cont cart) embryo)
  =/  grain-submit-tx  ?>(?=(%.y -.res) (snag 0 ~(val by changed.p.res)))
  =.  test-output  (weld test-output (expect-eq !>(expected-grain-submit-tx) !>(grain-submit-tx)))
  ::  TX 2 - %vote by owner-2  
  ::
  =.  embryo
    :*  action=`[%vote egg-remove-member-hash]
        grains=~
    ==
  =.  cart  [me=multisig-wheat-id from=[id:owner-2 0] (add init-now ~s6) town-id owns=(malt ~[[id:expected-grain-submit-tx expected-grain-submit-tx]])]  
  =.  res   (~(write cont cart) embryo)
  =/  grain-vote-tx-1  ?>(?=(%.y -.res) (snag 0 ~(val by changed.p.res)))
  =.  test-output  (weld test-output (expect-eq !>(expected-grain-vote-tx-1) !>(grain-vote-tx-1)))
  ::  TX 3 - %vote by owner-1, removes owner-1
  ::
  =.  embryo
    :*  action=`[%vote egg-remove-member-hash]
        grains=~
    ==
  =.  cart  [me=multisig-wheat-id from=[id:owner-1 0] (add init-now ~s7) town-id owns=(malt ~[[id:expected-grain-vote-tx-1 expected-grain-vote-tx-1]])]  
  =.  res   (~(write cont cart) embryo)
  =/  [grain-vote-tx-2=grain next-list=_next:*hen]
    ?>  ?=(%.n -.res)
    [(snag 0 ~(val by changed.rooster.p.res)) next.p.res]
  =/  next  (snag 0 next-list)
  =.  test-output
    ;:  weld
      (expect-eq !>(expected-grain-vote-tx-2) !>(grain-vote-tx-2))
      ::
      (expect-eq !>(to.next) !>(to.p:egg-remove-member))
      (expect-eq !>(town-id.next) !>(town-id.p:egg-remove-member))
      (expect-eq !>(action.yolk.next) !>(action.q:egg-remove-member))
      (expect-eq !>(cont-grains.yolk.next) !>(cont-grains.q:egg-remove-member))
    ==
  ::  TX 4 - apply %remove-member
  ::
  =.  embryo
    :*  action.q:egg-remove-member
        grains=~
    ==
  =.  cart  [me=multisig-wheat-id [multisig-wheat-id 0] (add init-now ~s8) town-id owns=(malt ~[[id:expected-grain-vote-tx-2 expected-grain-vote-tx-2]])]  
  =.  res   (~(write cont cart) embryo)
  =/  grain-remove-member  ?>(?=(%.y -.res) (snag 0 ~(val by changed.p.res)))
  =.  test-output  (weld test-output (expect-eq !>(expected-grain-remove-member) !>(grain-remove-member)))
  test-output
  ::
  ++  expected-state-submit-tx
    ^-  multisig-state
    :*  members:multisig-state-5
        threshold:multisig-state-5
        ::  tx is submitted
        (~(put by pending:multisig-state-4) egg-remove-member-hash [egg-remove-member votes=~])
    ==
  ++  expected-grain-submit-tx
    ^-  grain
    :*  id:multisig-grain-1
        lord:multisig-grain-1
        holder:multisig-grain-1
        town-id:multisig-grain-1
        germ=[%& salt=multisig-salt %multisig data=expected-state-submit-tx]
    ==
  ::
  ++  expected-state-vote-tx-1
    ^-  multisig-state
    :*  members:expected-state-submit-tx
        threshold:expected-state-submit-tx
        ::  tx 1 vote recorded
        (~(put by pending:expected-state-submit-tx) egg-remove-member-hash [egg-remove-member votes=(silt ~[id:owner-2])])
    ==
  ++  expected-grain-vote-tx-1
    ^-  grain
    :*  id:multisig-grain-1
        lord:multisig-grain-1
        holder:multisig-grain-1
        town-id:multisig-grain-1
        germ=[%& salt=multisig-salt %multisig data=expected-state-vote-tx-1]
    ==
  ::
  ++  expected-state-vote-tx-2
    ^-  multisig-state
    :*  members:expected-state-vote-tx-1
        threshold:expected-state-vote-tx-1
        pending=~  ::  vote passed so tx is cleared
    ==
  ++  expected-grain-vote-tx-2
    ^-  grain
    :*  id:multisig-grain-1
        lord:multisig-grain-1
        holder:multisig-grain-1
        town-id:multisig-grain-1
        germ=[%& salt=multisig-salt %multisig data=expected-state-vote-tx-2]
    ==
  ++  expected-state-remove-member
    ^-  multisig-state
    :*  (~(del in members:expected-state-vote-tx-2) id:owner-1)  ::  member is removed
        threshold:expected-state-vote-tx-2
        pending:expected-state-vote-tx-2
    ==
  ++  expected-grain-remove-member
    ^-  grain
    :*  id:multisig-grain-1
        lord:multisig-grain-1
        holder:multisig-grain-1
        town-id:multisig-grain-1
        germ=[%& salt=multisig-salt %multisig data=expected-state-remove-member]
    ==
  --
--