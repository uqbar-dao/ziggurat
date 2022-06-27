::  Tests for nft.hoon (non-fungible token contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/+  *test, cont=zig-contracts-publish, *zig-sys-smart
=>  ::  test data
    |%
    ++  init-now  *@da
    ++  owner-1  ^-  account
      [0xbeef 0 0x1234.5678]
    ++  trivial-nok  ^-  *
      [[8 [1 0] [1 1 0] 0 1] 8 [1 0 0 0] [1 8 [8 [9 2.398 0 4.095] 9 2 10 [6 7 [0 3] 1 100] 0 2] 1 0 0 0] 0 1]
    ++  trivial-nok-upgrade  ^-  *
      [[8 [1 0] [1 1 0] 0 1] 8 [1 0 0 0] [1 8 [8 [9 2.398 0 4.095] 9 2 10 [6 7 [0 3] 1 1.000] 0 2] 1 0 0 0] 0 1]
    --
::  testing arms
|%
++  test-matches-type  ^-  tang
  =/  valid  (mule |.(;;(contract cont)))
  (expect-eq !>(%.y) !>(-.valid))
::
::  tests for %deploy
::
++  test-trivial-deploy  ^-  tang
  =/  =embryo
    [owner-1 `[%deploy %.y [trivial-nok ~] ~] ~]
  =/  =cart
    [`@ux`'publish' init-now 0x1 ~]
  =/  new-id  (fry-contract `@ux`'publish' 0x1 trivial-nok)
  =/  new-grain  ^-  grain
    :*  new-id
        `@ux`'publish'
        0xbeef
        0x1
        [%| `[trivial-nok ~] ~]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& ~ (malt ~[[id.new-grain new-grain]]) ~]
  (expect-eq !>(correct) !>(res))
::
::  tests for %upgrade
::
++  test-trivial-upgrade  ^-  tang
  =/  cont-grain  ^-  grain
    :*  0xabcd
        `@ux`'publish'
        0xbeef
        0x1
        [%| `[trivial-nok ~] ~]
    ==
  =/  =embryo
    [owner-1 `[%upgrade 0xabcd [trivial-nok-upgrade ~]] ~]
  =/  =cart
    [`@ux`'publish' init-now 0x1 (malt ~[[id.cont-grain cont-grain]])]
  =/  new-grain  ^-  grain
    :*  0xabcd
        `@ux`'publish'
        0xbeef
        0x1
        [%| `[trivial-nok-upgrade ~] ~]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id.new-grain new-grain]]) ~ ~]
  (expect-eq !>(correct) !>(res))
--