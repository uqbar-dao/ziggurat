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
/*  triv-contract   %noun  /lib/zig/compiled/trivial/noun
|%
::
::  constants / dummy info for mill
::
++  town-id    0x0
++  set-fee    7
++  fake-sig   [0 0 0]
++  mil
  %~  mill  mill
  :+    ;;(vase (cue q.q.smart-lib-noun))
    ;;((map * @) (cue q.q.zink-cax-noun))
  %.y
::
+$  mill-result
  [fee=@ud =land burned=granary =errorcode hits=(list hints:zink) =crow]
::
::  fake data
::
++  miller    ^-  account  [0x1512.3341 1 0x1.1512.3341]
++  caller-1  ^-  account  [0xbeef 1 0x1.beef]
++  caller-2  ^-  account  [0xdead 1 0x1.dead]
++  caller-3  ^-  account  [0xcafe 1 0x1.cafe]
::
++  zigs
  |%
  ++  holder-1  0xbeef
  ++  holder-2  0xdead
  ++  holder-3  0xcafe
  ++  miller-account
    ^-  grain
    :*  %&
        `@`'zigs'
        %account
        [1.000.000 ~ `@ux`'zigs-metadata']
        0x1.1512.3341
        zigs-wheat-id
        0x1512.3341
        town-id
    ==
  ++  beef-account
    ^-  grain
    :*  %&
        `@`'zigs'
        %account
        [300.000 ~ `@ux`'zigs-metadata']
        0x1.beef
        zigs-wheat-id
        holder-1
        town-id
    ==
  ++  dead-account
    ^-  grain
    :*  %&
        `@`'zigs'
        %account
        [200.000 ~ `@ux`'zigs-metadata']
        0x1.dead
        zigs-wheat-id
        holder-2
        town-id
    ==
  ++  cafe-account
    ^-  grain
    :*  %&
        `@`'zigs'
        %account
        [100.000 ~ `@ux`'zigs-metadata']
        0x1.cafe
        zigs-wheat-id
        holder-3
        town-id
    ==
  --
::
++  triv-wheat
  ^-  grain
  =/  cont  ;;([bat=* pay=*] (cue q.q.triv-contract))
  =/  interface=lumps
    %-  ~(gas by *lumps)
    :~  %give^[%give [%pair [%amount [%ud *@ud]] [%my-account [%grain *@ux]]]]
    ==
  =/  types=lumps
    %-  ~(gas by *lumps)
    :~  %account^[%account [%pair [%balance [%ud *@ud]] [%metadata [%grain *@ux]]]]
    ==
  :*  %|
      `cont
      interface
      types
      0xdada.dada  ::  id
      0xdada.dada  ::  lord
      0xdada.dada  ::  holder
      town-id
  ==
::
++  fake-granary
  ^-  granary
  %-  ~(gas by *(map id grain))
  :~  [id.p:triv-wheat triv-wheat]
      [id.p:beef-account:zigs beef-account:zigs]
      [id.p:miller-account:zigs miller-account:zigs]
  ==
++  fake-populace
  ^-  populace
  %-  ~(gas by *(map id @ud))
  ~[[holder-1:zigs 0] [holder-2:zigs 0] [holder-3:zigs 0]]
++  fake-land
  ^-  land
  [fake-granary fake-populace]
::
::  begin tests
::
::
::  tests for +mill
::
++  test-mill-all-trivial-pass
  ::  tag your @ux with %grain-id if you want it to be carried in cart
  =/  =action  [%give 100 [%grain 0x1.beef]]
  =/  hash=@ux  `@ux`(sham action)
  =/  shel=shell
    [caller-1 fake-sig ~ id.p:triv-wheat 1 1.000 town-id 0]
  =/  [res=state-transition rej=carton]
    %^  ~(mill-all mil miller town-id 1)  ::  batch-num
    fake-land  (silt ~[[hash [shel action]]])  1.024
  ~&  >>>  crows.res
  ;:  weld
  ::  assert that our call went through
    %+  expect-eq
      !>(%0)
    !>(status.p.+.-.processed.res)
  ::  assert fee paid
    %+  expect-eq
      !>(299.993)
    =+  (~(got by p.land.res) id.p:beef-account:zigs)
    ?>  ?=(%& -.-)
    !>(-.data.p.-)
  ::  assert fee received correctly
    %+  expect-eq
     !>(1.000.007)
    =+  (~(got by p.land.res) id.p:miller-account:zigs)
    ?>  ?=(%& -.-)
    !>(-.data.p.-)
  ==
--