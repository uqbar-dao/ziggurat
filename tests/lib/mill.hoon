::
::  Tests for lib/zig/mill.hoon
::  Basic goal: construct a simple town / helix state
::  and manipulate it with some calls to our zigs contract.
::  Mill should handle clearing a mempool populated by
::  calls and return an updated town. The zigs contract
::  should manage transactions properly so this is testing
::  the arms of that contract as well.
::
::  Tests here should cover:
::  (all calls to exclusively zigs contract)
::
::  * executing a single call with +mill
::  * executing same call unsuccessfully -- not enough gas
::  * unsuccessfully -- some constraint in contract unfulfilled
::  * (test all constraints in contract: balance, gas, +give, etc)
::  * executing multiple calls with +mill-all
::
/-  zink
/+  *test, mill=zig-mill, *zig-sys-smart, *sequencer
/*  smart-lib-noun  %noun  /lib/zig/compiled/smart-lib/noun
/*  zink-cax-noun   %noun  /lib/zig/compiled/hash-cache/noun
/*  zigs-contract   %noun  /lib/zig/compiled/zigs/noun
/*  triv-contract   %noun  /lib/zig/compiled/trivial/noun
|%
++  init-now  *@da
::
++  mil
  %~  mill  mill
  :-  ;;(vase (cue q.q.smart-lib-noun))
  ;;((map * @) (cue q.q.zink-cax-noun))
::
++  zigs
  |%
  +$  account-mold
    $:  balance=@ud
        allowances=(map sender=id @ud)
    ==
  ++  town-id    0x0
  ++  set-fee    7  :: arbitrary replacement for +bull calculations
  ++  beef-zigs-grain
    ^-  grain
    :*  0x1.beef
        zigs-wheat-id
        0xbeef
        0x0
        [%& `@`'zigs' [300.000 ~ `@ux`'zigs-metadata']]
    ==
  ++  dead-zigs-grain
    ^-  grain
    :*  0x1.dead
        zigs-wheat-id
        0xdead
        0x0
        [%& `@`'zigs' [200.000 ~ `@ux`'zigs-metadata']]
    ==
  ++  cafe-zigs-grain
    ^-  grain
    :*  0x1.cafe
        zigs-wheat-id
        0xcafe
        0x0
        [%& `@`'zigs' [100.000 ~ `@ux`'zigs-metadata']]
    ==
  ++  wheat-grain
    ^-  grain
    =/  =wheat  ;;(wheat (cue q.q.zigs-contract))
    :*  zigs-wheat-id  ::  id
        zigs-wheat-id  ::  lord
        zigs-wheat-id  ::  holders
        town-id              ::  town-id
        [%| wheat(owns (silt ~[0x1.beef 0x1.dead 0x1.cafe]))]
    ==
  ++  triv-wheat-grain
    ^-  grain
    =/  =wheat  ;;(wheat (cue q.q.triv-contract))
    :*  0xdada.dada  ::  id
        0xdada.dada  ::  lord
        0xdada.dada  ::  holders
        town-id      ::  town-id
        [%| wheat]
    ==
  ++  fake-granary
    ^-  granary
    =/  grains=(list (pair id grain))
      :~  [zigs-wheat-id wheat-grain]
          [0xdada.dada triv-wheat-grain]
          [0x1.beef beef-zigs-grain]
          [0x1.dead dead-zigs-grain]
          [0x1.cafe cafe-zigs-grain]
      ==
    (~(gas by *(map id grain)) grains)
  ++  fake-populace
    ^-  populace
    %-  %~  gas  by  *(map id @ud)
    ~[[0xbeef 0] [0xdead 0] [0xcafe 0]]
  ++  fake-town
    ^-  land
    [fake-granary fake-populace]
  --
::
::  ++  test-trivial-fail
::    =*  mil     mil:zigs
::    =/  caller  [0xbeef 1 0x1.beef]
::    =/  yok=yolk
::      [caller `[%init ~] ~ ~]
::    =/  shel=shell
::      [caller [0 0 0] ~ zigs-wheat-id 1 333 0x0 0]
::    =/  egg  [shel yok]
::    =/  [=land fee=@ud =errorcode hits=(list hints:zink) =crow]
::      %+  ~(mill mil [0xdead 1 0x1.dead] 0x0 init-now:zigs)
::        fake-town:zigs
::      egg
::    %+  expect-eq
::      !>(%6)
::    !>(errorcode)
::
++  test-trivial-pass
  =/  caller  [0xbeef 1 0x1.beef]
  =/  yok=yolk
    [caller ~ ~ ~]
  =/  shel=shell
    [caller [0 0 0] ~ 0xdada.dada 1 5.000 0x0 0]
  =/  egg  [shel yok]
  =/  [=land fee=@ud =errorcode hits=(list hints:zink) =crow]
    %+  ~(mill mil [0xcafe 1 0x1.cafe] 0x0 init-now)
      fake-town:zigs
    egg
  ~&  >>>  "budget spent: {<fee>}"
  ~&  >>  hits
  %+  expect-eq
    !>(%0)
  !>(errorcode)
::
++  test-zigs-give
  =/  caller  [0xbeef 1 0x1.beef]
  =/  yok=yolk
    [caller `[%give 0xdead `0x1.dead 777 50.000] (silt ~[0x1.beef]) (silt ~[0x1.dead])]
  =/  shel=shell
    [caller [0 0 0] ~ zigs-wheat-id 1 50.000 0x0 0]
  =/  egg  [shel yok]
  =/  [=land fee=@ud =errorcode hits=(list hints:zink) =crow]
    %+  ~(mill mil [0xcafe 1 0x1.cafe] 0x0 init-now)
      fake-town:zigs
    egg
  ~&  >>>  "budget spent: {<fee>}"
  =/  correct  dead-zigs-grain:zigs
  =.  germ.correct  [%& `@`'zigs' [200.777 ~ `@ux`'zigs-metadata']]
  %+  expect-eq
    !>(correct)
  !>((~(got by p.land) 0x1.dead))
::
::  ++  test-single-c-call
::    =*  mil     mil:zigs
::    =/  caller  [0xbeef 1 0x1.beef]
::    =/  yok=yolk
::      [caller `[%give 0x1234 ~ 777 333] (silt ~[0x1.beef]) ~]
::    =/  shel=shell
::      [caller [0 0 0] ~ zigs-wheat-id 1 500 0x0 0]
::    =/  egg  [shel yok]
::    =/  [=land fee=@ud =errorcode hits=(list hints:zink) =crow]
::      %+  ~(mill mil [0xcafe 1 0x1.cafe] 0x0 init-now:zigs)
::        fake-town:zigs
::      egg
::    ::  ?>  =(fee (mul 2 set-fee:zigs))
::    ::  ?>  =(errorcode %0)
::    =/  correct-id  (fry-rice 0x1234 zigs-wheat-id 0x0 `@`'zigs')
::    =/  correct
::      ^-  grain
::      :*  correct-id
::          zigs-wheat-id
::          0x1234
::          0x0
::          [%& `@`'zigs' [777 ~ `@ux`'zigs-metadata']]
::      ==
::    %+  expect-eq
::      !>(correct)
::    !>((~(got by p.land) correct-id))
--