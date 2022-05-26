::  Tests for fungible.hoon (token contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/+  *test, cont=zig-contracts-fungible, *zig-sys-smart
=>  ::  test data
    |%
    ++  metadata-1  ^-  grain
      :*  `@ux`'simple'
          `@ux`'fungible'
          `@ux`'holder'
          1  ::  town-id
          :+  %&  `@`'salt'
          :*  name='Simple Token'
              symbol='ST'
              decimals=0
              supply=100
              cap=~
              mintable=%.n
              minters=~
              deployer=0x0
              salt=`@`'salt'
      ==  ==
    ::
    ++  account-1  ^-  grain
      :*  0x1.beef
          `@ux`'fungible'
          0xbeef
          1
          [%& `@`'salt' [50 ~ `@ux`'simple']]
      ==
    ++  owner-1  ^-  account
      [0xbeef 0 0x1234.5678]
    ::
    ++  account-2  ^-  grain
      :*  0x1.dead
          `@ux`'fungible'
          0xdead
          1
          [%& `@`'salt' [30 ~ `@ux`'simple']]
      ==
    ++  owner-2  ^-  account
      [0xdead 0 0x1234.5678]
    ::
    ++  account-3  ^-  grain
      :*  0x1.cafe
          `@ux`'fungible'
          0xcafe
          1
          [%& `@`'salt' [20 ~ `@ux`'simple']]
      ==
    ++  owner-3  ^-  account
      [0xcafe 0 0x1234.5678]
    ::
    ++  account-4  ^-  grain
      :*  0x1.face
          `@ux`'fungible'
          0xface
          1
          [%& `@`'diff' [20 ~ `@ux`'different!']]
      ==
    --
::  testing arms
|%
++  test-matches-type  ^-  tang
  =/  valid  (mule |.(;;(contract cont)))
  (expect-eq !>(%.y) !>(-.valid))
::
::  tests for %give
::
++  test-give-known-receiver  ^-  tang
  =/  =zygote
    :+  owner-1
      `[%give 0xdead `0x1.dead 30]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [~ `@ux`'fungible' 0 1 (malt ~[[id:`grain`account-2 account-2]])]
  =/  updated-1
    :*  0x1.beef
        `@ux`'fungible'
        0xbeef
        1
        [%& `@`'salt' [20 ~ `@ux`'simple']]
    ==
  =/  updated-2
    :*  0x1.dead
        `@ux`'fungible'
        0xdead
        1
        [%& `@`'salt' [60 ~ `@ux`'simple']]
    ==
  =/  res=chick
    (~(write cont cart) zygote)
  =/  correct=chick
    [%& (malt ~[[id:`grain`updated-1 updated-1] [id:`grain`updated-2 updated-2]]) ~ ~]
  (expect-eq !>(res) !>(correct))
::
++  test-give-unknown-receiver  ^-  tang
  =/  =zygote
    :+  owner-1
      `[%give 0xffff ~ 30]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [~ `@ux`'fungible' 0 1 ~]
  =/  new-id  (fry-rice 0xffff `@ux`'fungible' 1 `@`'salt')
  =/  new
    :*  new-id
        `@ux`'fungible'
        0xffff
        1
        [%& `@`'salt' [0 ~ `@ux`'simple']]
    ==
  =/  res=chick
    (~(write cont cart) zygote)
  =/  correct=chick
    :^  %|  ~
      :+  me.cart  town-id.cart
      [owner-1 `[%give 0xffff `new-id 30] (silt ~[0x1.beef]) (silt ~[new-id])]
    [~ (malt ~[[new-id new]]) ~]
  (expect-eq !>(res) !>(correct))
::
++  test-give-not-enough  ^-  tang
  =/  =zygote
    :+  owner-1
      `[%give 0xdead `0x1.dead 51]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [~ `@ux`'fungible' 0 1 (malt ~[[id:`grain`account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) zygote)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-metadata-mismatch  ^-  tang
  =/  =zygote
    :+  owner-1
      `[%give 0xface `0x1.face 10]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [~ `@ux`'fungible' 0 1 (malt ~[[id:`grain`account-4 account-4]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) zygote)))
  (expect-eq !>(%.n) !>(-.res))
::
::  tests for %take
::

::
::  tests for %set-allowance
::

::
::  tests for %mint
::

::
::  tests for %deploy
::
--