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
/=  zigsur          /lib/zig/contracts/lib/zigs
/*  smart-lib-noun  %noun  /lib/zig/compiled/smart-lib/noun
/*  zink-cax-noun   %noun  /lib/zig/compiled/hash-cache/noun
/*  zigs-contract   %noun  /lib/zig/compiled/zigs/noun
/*  triv-contract   %noun  /lib/zig/compiled/trivial/noun
|%
::
::  constants / dummy info for mill
::
++  init-now  *@da
++  town-id    0x0
++  set-fee    7
++  fake-sig   [0 0 0]
++  mil
  %~  mill  mill
  :+    ;;(vase (cue q.q.smart-lib-noun))
    ;;((map * @) (cue q.q.zink-cax-noun))
  %.n
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
    :*  0x1.1512.3341
        zigs-wheat-id
        0x1512.3341
        town-id
        [%& `@`'zigs' [1.000.000 ~ `@ux`'zigs-metadata']]
    ==
  ++  beef-account
    ^-  grain
    :*  0x1.beef
        zigs-wheat-id
        holder-1
        town-id
        [%& `@`'zigs' [300.000 ~ `@ux`'zigs-metadata']]
    ==
  ++  dead-account
    ^-  grain
    :*  0x1.dead
        zigs-wheat-id
        0xdead
        town-id
        [%& `@`'zigs' [200.000 ~ `@ux`'zigs-metadata']]
    ==
  ++  cafe-account
    ^-  grain
    :*  0x1.cafe
        zigs-wheat-id
        0xcafe
        town-id
        [%& `@`'zigs' [100.000 ~ `@ux`'zigs-metadata']]
    ==
  ++  wheat-grain
    ^-  grain
    =/  =wheat  ;;(wheat (cue q.q.zigs-contract))
    :*  zigs-wheat-id
        zigs-wheat-id
        zigs-wheat-id
        town-id
        [%| wheat(owns (silt ~[0x1.beef 0x1.dead 0x1.cafe]))]
    ==
  --
::
++  triv-wheat
  ^-  grain
  =/  =wheat  ;;(wheat (cue q.q.triv-contract))
  :*  0xdada.dada  ::  id
      0xdada.dada  ::  lord
      0xdada.dada  ::  holders
      town-id
      [%| wheat]
  ==
::
++  empty-wheat
  ^-  grain
  :*  0xffff.ffff  ::  id
      0xffff.ffff  ::  lord
      0xffff.ffff  ::  holders
      town-id
      [%| ~ ~]
  ==
::
++  fake-granary
  ^-  granary
  =/  grains=(list [id grain])
    :~  [zigs-wheat-id wheat-grain:zigs]
        [id:triv-wheat triv-wheat]
        [id:empty-wheat empty-wheat]
        [id:miller-account:zigs miller-account:zigs]
        [id:beef-account:zigs beef-account:zigs]
        [id:dead-account:zigs dead-account:zigs]
        [id:cafe-account:zigs cafe-account:zigs]
    ==
  (~(gas by *(map id grain)) grains)
++  fake-populace
  ^-  populace
  %-  %~  gas  by  *(map id @ud)
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
++  test-mill-bad-account
  =/  yok=yolk
    [`[%random-command ~] ~ ~]
  =/  shel=shell
    [0xbeef fake-sig ~ id:triv-wheat 1 333 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id init-now)
    fake-land  [shel yok]
  ::
  ;:  weld
  ::  assert that our call failed
    %+  expect-eq
    !>(%1)  !>(errorcode.res)
  ::  assert no burns created
    %+  expect-eq
    !>(~)  !>(burned.res)
  ::  assert no fee
    %+  expect-eq
    !>(0)  !>(fee.res)
  ::  assert no crow created
    %+  expect-eq
    !>(~)  !>(crow.res)
  ::  assert that diff is correct
    %+  expect-eq
    !>(~)  !>(p.land.res)
  ==
::
++  test-mill-high-nonce
  =/  yok=yolk
    [`[%random-command ~] ~ ~]
  =/  shel=shell
    [[0xbeef 2 0x1.beef] fake-sig ~ id:triv-wheat 1 333 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id init-now)
    fake-land  [shel yok]
  ::
  ;:  weld
  ::  assert that our call failed
    %+  expect-eq
    !>(%3)  !>(errorcode.res)
  ::  assert no burns created
    %+  expect-eq
    !>(~)  !>(burned.res)
  ::  assert no fee
    %+  expect-eq
    !>(0)  !>(fee.res)
  ::  assert no crow created
    %+  expect-eq
    !>(~)  !>(crow.res)
  ::  assert that diff is correct
    %+  expect-eq
    !>(~)  !>(p.land.res)
  ==
::
++  test-mill-low-nonce
  =/  yok=yolk
    [`[%random-command ~] ~ ~]
  =/  shel=shell
    [[0xbeef 0 0x1.beef] fake-sig ~ id:triv-wheat 1 333 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id init-now)
    fake-land  [shel yok]
  ::
  ;:  weld
  ::  assert that our call failed
    %+  expect-eq
    !>(%3)  !>(errorcode.res)
  ::  assert no burns created
    %+  expect-eq
    !>(~)  !>(burned.res)
  ::  assert no fee
    %+  expect-eq
    !>(0)  !>(fee.res)
  ::  assert no crow created
    %+  expect-eq
    !>(~)  !>(crow.res)
  ::  assert that diff is correct
    %+  expect-eq
    !>(~)  !>(p.land.res)
  ==
::
++  test-mill-missing-account-grain
  =/  yok=yolk
    [`[%random-command ~] ~ ~]
  =/  shel=shell
    [[0xbeef 1 0x2.beef] fake-sig ~ id:triv-wheat 1 333 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id init-now)
    fake-land  [shel yok]
  ::
  ;:  weld
  ::  assert that our call failed
    %+  expect-eq
    !>(%4)  !>(errorcode.res)
  ::  assert no burns created
    %+  expect-eq
    !>(~)  !>(burned.res)
  ::  assert no fee
    %+  expect-eq
    !>(0)  !>(fee.res)
  ::  assert no crow created
    %+  expect-eq
    !>(~)  !>(crow.res)
  ::  assert that diff is correct
    %+  expect-eq
    !>(~)  !>(p.land.res)
  ==
::
++  test-mill-wrong-account-grain
  =/  yok=yolk
    [`[%random-command ~] ~ ~]
  =/  shel=shell
    [[0xbeef 1 0x1.dead] fake-sig ~ id:triv-wheat 1 333 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id init-now)
    fake-land  [shel yok]
  ::
  ;:  weld
  ::  assert that our call failed
    %+  expect-eq
    !>(%4)  !>(errorcode.res)
  ::  assert no burns created
    %+  expect-eq
    !>(~)  !>(burned.res)
  ::  assert no fee
    %+  expect-eq
    !>(0)  !>(fee.res)
  ::  assert no crow created
    %+  expect-eq
    !>(~)  !>(crow.res)
  ::  assert that diff is correct
    %+  expect-eq
    !>(~)  !>(p.land.res)
  ==
::
++  test-mill-low-budget
  =/  yok=yolk
    [`[%random-command ~] ~ ~]
  =/  hash=@ux  `@ux`(sham yok)
  =/  shel=shell
    [caller-1 fake-sig ~ id:triv-wheat 1 300.001 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id init-now)
    fake-land  [shel yok]
  ::
  ;:  weld
  ::  assert that our call failed with correct errorcode
    %+  expect-eq
    !>(%4)  !>(errorcode.res)
  ::  assert no burns created
    %+  expect-eq
    !>(~)  !>(burned.res)
  ::  assert no fee
    %+  expect-eq
    !>(0)  !>(fee.res)
  ::  assert no crow created
    %+  expect-eq
    !>(~)  !>(crow.res)
  ::  assert that diff is correct
    %+  expect-eq
    !>(~)  !>(p.land.res)
  ==
::
++  test-mill-missing-contract
  =/  yok=yolk
    [`[%random-command ~] ~ ~]
  =/  hash=@ux  `@ux`(sham yok)
  =/  shel=shell
    [caller-1 fake-sig ~ 0x27.3708.9341 1 333 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id init-now)
    fake-land  [shel yok]
  ::
  ;:  weld
  ::  assert that our call failed with correct errorcode
    %+  expect-eq
    !>(%5)  !>(errorcode.res)
  ::  assert no burns created
    %+  expect-eq
    !>(~)  !>(burned.res)
  ::  assert no fee
    %+  expect-eq
    !>(0)  !>(fee.res)
  ::  assert no crow created
    %+  expect-eq
    !>(~)  !>(crow.res)
  ::  assert that diff is correct
    %+  expect-eq
    !>(~)  !>(p.land.res)
  ==
::
++  test-mill-contract-not-wheat
  =/  yok=yolk
    [`[%random-command ~] ~ ~]
  =/  hash=@ux  `@ux`(sham yok)
  =/  shel=shell
    [caller-1 fake-sig ~ id:dead-account:zigs 1 333 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id init-now)
    fake-land  [shel yok]
  ::
  ;:  weld
  ::  assert that our call failed with correct errorcode
    %+  expect-eq
    !>(%5)  !>(errorcode.res)
  ::  assert no burns created
    %+  expect-eq
    !>(~)  !>(burned.res)
  ::  assert no fee
    %+  expect-eq
    !>(0)  !>(fee.res)
  ::  assert no crow created
    %+  expect-eq
    !>(~)  !>(crow.res)
  ::  assert that diff is correct
    %+  expect-eq
    !>(~)  !>(p.land.res)
  ==
::
++  test-mill-contract-is-empty
  =/  yok=yolk
    [`[%random-command ~] ~ ~]
  =/  hash=@ux  `@ux`(sham yok)
  =/  shel=shell
    [caller-1 fake-sig ~ id:empty-wheat 1 333 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id init-now)
    fake-land  [shel yok]
  ::
  ;:  weld
  ::  assert that our call failed with correct errorcode
    %+  expect-eq
    !>(%5)  !>(errorcode.res)
  ::  assert no burns created
    %+  expect-eq
    !>(~)  !>(burned.res)
  ::  assert no fee
    %+  expect-eq
    !>(0)  !>(fee.res)
  ::  assert no crow created
    %+  expect-eq
    !>(~)  !>(crow.res)
  ::  assert that diff is correct
    %+  expect-eq
    !>(~)  !>(p.land.res)
  ==
::
++  test-mill-germinate-only-take-lorded-grains  !!
::
++  test-mill-fertilize-only-take-held-grains  !!
::
++  test-mill-trivial-pass
  =/  yok=yolk
    [`[%random-command ~] ~ ~]
  =/  shel=shell
    [caller-1 fake-sig ~ id:triv-wheat 1 333 town-id 0]
  =/  res=mill-result
    %+  ~(mill mil miller town-id init-now)
    fake-land  [shel yok]
  ::
  ;:  weld
  ::  assert that our call failed
    %+  expect-eq
    !>(%0)  !>(errorcode.res)
  ::  assert no burns created
    %+  expect-eq
    !>(~)  !>(burned.res)
  ::  assert fee is full
    %+  expect-eq
    !>(set-fee)  !>(fee.res)
  ::  assert we get trivial crow
    %+  expect-eq
    !>([[%hello ~] ~])  !>(crow.res)
  ::  assert that fee paid correctly
    %+  expect-eq
     !>(299.993)
    =+  (~(got by p.land.res) id:beef-account:zigs)
    ?>  ?=(%& -.germ.-)
    !>(-.data.p.germ.-)
  ==
::
::  tests for harvest (validation checks on contract outputs)
::
::  tests for 'changed' grains
::
++  test-harvest-changed-grain-exists  !!
::
++  test-harvest-changed-grain-type-doesnt-change  !!
::
++  test-harvest-changed-grain-id-changes  !!
::
++  test-harvest-rice-salt-change  !!
::
++  test-harvest-changed-issued-overlap  !!
::
++  test-harvest-changed-without-provenance  !!
::
::  tests for 'issued' grains
::
++  test-harvest-issued-ids-not-matching  !!
::
++  test-harvest-issued-ids-bad-rice-hash  !!
::
++  test-harvest-issued-ids-bad-wheat-hash  !!
::
++  test-harvest-issued-without-provenance  !!
::
++  test-harvest-issued-already-exists  !!
::
::
::  tests for 'burned' grains
::
++  test-harvest-burned-grain-doesnt-exist  !!
::
++  test-harvest-burned-ids-not-matching  !!
::
++  test-harvest-burned-overlap-with-changed  !!
::
++  test-harvest-burned-overlap-with-issued  !!
::
++  test-harvest-burned-without-provenance  !!
::
++  test-harvest-burned-gas-payment-account  !!
::
::  tests for +mill-all
::
++  test-mill-all-trivial-gas-fail-audit
  =/  yok=yolk
    [`[%random-command ~] ~ ~]
  =/  hash=@ux  `@ux`(sham yok)
  =/  shel=shell
    [caller-1 fake-sig ~ id:triv-wheat 1 300.001 town-id 0]
  =/  res=state-transition
    %^  ~(mill-all mil miller town-id init-now)
    fake-land  ~[[hash [shel yok]]]  1
  ;:  weld
  ::  assert that our call failed with correct errorcode
    %+  expect-eq
      !>(%4)
    !>(status.p.+.-.processed.res)
  ::  assert that miller gets no reward
    %+  expect-eq
      !>(`grain`miller-account:zigs)
    !>(`grain`(~(got by p.land.res) id:miller-account:zigs))
  ==
::
++  test-mill-all-trivial-pass
  =/  yok=yolk
    [`[%random-command ~] ~ ~]
  =/  hash=@ux  `@ux`(sham yok)
  =/  shel=shell
    [caller-1 fake-sig ~ id:triv-wheat 1 333 town-id 0]
  =/  res=state-transition
    %^  ~(mill-all mil miller town-id init-now)
    fake-land  ~[[hash [shel yok]]]  1
  ;:  weld
  ::  assert that our call went through
    %+  expect-eq
      !>(%0)
    !>(status.p.+.-.processed.res)
  ::  assert fee paid
    %+  expect-eq
     !>(299.993)
    =+  (~(got by p.land.res) id:beef-account:zigs)
    ?>  ?=(%& -.germ.-)
    !>(-.data.p.germ.-)
  ::  assert fee received correctly
    %+  expect-eq
     !>(1.000.007)
    =+  (~(got by p.land.res) id:miller-account:zigs)
    ?>  ?=(%& -.germ.-)
    !>(-.data.p.germ.-)
  ==
--