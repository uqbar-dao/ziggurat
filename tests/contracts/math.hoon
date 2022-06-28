::  Test suite for math.hoon
::
/-  sequencer
/+  *test, cont=zig-contracts-math, mill=zig-mill, *zig-sys-smart
/*  smart-lib-noun  %noun  /lib/zig/compiled/smart-lib/noun
/*  zink-cax-noun   %noun  /lib/zig/compiled/hash-cache/noun
/*  math-contract   %noun  /lib/zig/compiled/math/noun
=>  |%
    +$  variable  number=@ud
    +$  action
      $%  [%make-variable initial=@ud]
          [%add amount=@ud]
          [%sub amount=@ud]
          [%giv who=id]
      ==
    ::
    ++  grainz
      |=  grz=(list grain)
      %-  ~(gas by *(map id grain))
      %+  turn  grz
      |=  [=grain]
      [id.grain grain]
    ++  make-cart
      |=  [owns=(map id grain)]
      ^-  cart
      [me=math-wheat-id init-now town-id owns]
    ++  fake-granary
      |=  [grains=(list grain)]
      ^-  granary:sequencer
      (~(put by (grainz grains)) math-wheat-id math-wheat-grain)
    ::
    ++  init-now  *@da
    ++  town-id    0x1
    ++  mil
      %~  mill  mill
      :-  ;;(vase (cue q.q.smart-lib-noun))
      ;;((map * @) (cue q.q.zink-cax-noun))
    ++  owner-1
      ^-  account
      [id=0xbeef nonce=0 zigs=0x1234.5678]
    ++  owner-2
      ^-  account
      [0xdead 0 0x1234.5678]
    ::
    ++  math-wheat-id  0xadd
    ++  math-salt      `@`'math'
    ++  math-wheat-grain
      ^-  grain
      =/  =wheat  ;;(wheat (cue q.q.math-contract))
      :*  math-wheat-id
          math-wheat-id
          math-wheat-id
          town-id
          [%| wheat]
      ==
    ++  make-grain
      |=  [holder=id =variable]
      ^-  grain
      :*  id=(fry-rice holder math-wheat-id town-id math-salt)
          lord=math-wheat-id
          holder
          town-id
          germ=[%& math-salt data=variable]
      ==
    ++  math-grain-1  ^-(grain (make-grain id:owner-1 [number=100]))
    ++  math-grain-2  ^-(grain (make-grain id:owner-1 [number=120]))
    ++  math-grain-3  ^-(grain (make-grain id:owner-1 [number=117]))
    ++  math-grain-4
      ::  holder changes but original id remains the same (even though holder changed)
      ^-  grain
      :*  id:math-grain-3
          lord:math-grain-3
          holder=id:owner-2
          town-id:math-grain-3
          germ:math-grain-3
      ==
    --
|%
++  test-contract-typechecks  ^-  tang
  =/  valid  (mule |.(;;(contract cont)))
  (expect-eq !>(%.y) !>(-.valid))
::
++  test-create-variable
  ^-  tang
  =/  =embryo
    :*  caller=owner-1
        args=`[%make-variable 100]
        grains=~
    ==
  =/  =cart  (make-cart ~)
  =/  res=chick  (~(write cont cart) embryo)
  =*  expected-grain  math-grain-1
  =/  grain  ?>(?=(%.y -.res) (snag 0 ~(val by issued.p.res)))
  (expect-eq !>(expected-grain) !>(grain))
::
++  test-add-variable
  ^-  tang
  ::  setting up the tx to propose
  ::  creating the execution context by hand
  =/  =embryo
    :*  caller=owner-1
        args=`[%add 20]
        grains=~
    ==
  =/  =cart  (make-cart (grainz ~[math-grain-1]))
  ::  executing the contract call with the context
  =/  res=chick  (~(write cont cart) embryo)
  ::
  =*  expected-grain  math-grain-2
  =/  grain  ?>(?=(%.y -.res) (snag 0 ~(val by changed.p.res)))
  (expect-eq !>(expected-grain) !>(grain))
::++  test-sub-variable
::  ^-  tang
::  =/  shel=shell
::    [owner-1 [0 0 0] ~ math-wheat-id 1 999 town-id %0]
::  ::  i'm the yoker
::  =/  yok=yolk
::    [owner-1 `[%sub 3] ~ (silt ~[id:math-grain-2])]
::  =/  egg  [shel yok]
::  ::  so many goddam doors
::  =/  le-farm  ~(farm mil owner-1 town-id init-now)
::  =/  [* * nary=(unit granary:sequencer) * =errorcode]
::    :: doesn't work yet because work doesn't like the hen call
::    (~(work le-farm (fake-granary ~[math-grain-2])) egg)
::  ::  executing the contract call with the context
::  =*  expected-grain  math-grain-3
::  =/  grain  (~(got by (need nary)) id:math-grain-3)
::  (expect-eq !>(expected-grain) !>(grain))
++  test-giv-variable
  ^-  tang
  ::  setting up the tx to propose
  ::  creating the execution context by hand
  =/  =embryo
    :*  caller=owner-1
        args=`[%giv who=id:owner-2]
        grains=~
    ==
  =/  =cart  (make-cart (grainz ~[math-grain-3]))
  ::  executing the contract call with the context
  =/  res=chick  (~(write cont cart) embryo)
  ::
  =*  expected-grain  math-grain-4
  =/  grain  ?>(?=(%.y -.res) (snag 0 ~(val by changed.p.res)))
  (expect-eq !>(expected-grain) !>(grain))
--