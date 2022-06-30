::  Tests for fungible.hoon (token contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/+  *test, cont=zig-contracts-fungible, *zig-sys-smart
=>  ::  test data
    |%
    ++  init-now  *@da
    ++  metadata-1  ^-  grain
      :*  `@ux`'simple'
          `@ux`'fungible'
          `@ux`'holder'
          town-id=0x1
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
          0x1
          [%& `@`'salt' [50 ~ `@ux`'simple' 0]]
      ==
    ++  owner-1  ^-  account
      [0xbeef 0 0x1234.5678]
    ::
    ++  account-2  ^-  grain
      :*  0x1.dead
          `@ux`'fungible'
          0xdead
          0x1
          [%& `@`'salt' [30 ~ `@ux`'simple' 0]]
      ==
    ++  owner-2  ^-  account
      [0xdead 0 0x1234.5678]
    ::
    ++  account-3  ^-  grain
      :*  0x1.cafe
          `@ux`'fungible'
          0xcafe
          0x1
          [%& `@`'salt' [20 ~ `@ux`'simple' 0]]
      ==
    ++  owner-3  ^-  account
      [0xcafe 0 0x1234.5678]
    ::
    ++  account-4  ^-  grain
      :*  0x1.face
          `@ux`'fungible'
          0xface
          0x1
          [%& `@`'diff' [20 ~ `@ux`'different!' 0]]
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
  =/  =embryo
    :+  owner-1
      `[%give 0xdead `0x1.dead 30]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' init-now 0x1 (malt ~[[id:`grain`account-2 account-2]])]
  =/  updated-1=grain
    :*  0x1.beef
        `@ux`'fungible'
        0xbeef
        0x1
        [%& `@`'salt' [20 ~ `@ux`'simple' 0]]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        `@ux`'fungible'
        0xdead
        0x1
        [%& `@`'salt' [60 ~ `@ux`'simple' 0]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1] [id:updated-2 updated-2]]) ~ ~]
  (expect-eq !>(res) !>(correct))
::
++  test-give-unknown-receiver  ^-  tang
  =/  =embryo
    :+  owner-1
      `[%give 0xffff ~ 30]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' init-now 0x1 ~]
  =/  new-id  (fry-rice 0xffff `@ux`'fungible' 0x1 `@`'salt')
  =/  new=grain
    :*  new-id
        `@ux`'fungible'
        0xffff
        0x1
        [%& `@`'salt' [0 ~ `@ux`'simple' 0]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    :+  %|
      :+  me.cart  town-id.cart
      [owner-1 `[%give 0xffff `new-id 30] (silt ~[0x1.beef]) (silt ~[new-id])]
    [~ (malt ~[[new-id new]]) ~]
  (expect-eq !>(res) !>(correct))
::
++  test-give-not-enough  ^-  tang
  =/  =embryo
    :+  owner-1
      `[%give 0xdead `0x1.dead 51]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' init-now 0x1 (malt ~[[id:`grain`account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-metadata-mismatch  ^-  tang
  =/  =embryo
    :+  owner-1
      `[%give 0xface `0x1.face 10]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' init-now 0x1 (malt ~[[id:`grain`account-4 account-4]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
::  tests for %take
::

::
::  tests for %take-with-sig
::
++  test-take-with-sig-known-reciever  ^-  tang
  =/  to  0xdead
  =/  account  `0x1.beef
  =/  from-rice  0x1.dead :: id.account-1
  =/  amount  30
  =/  nonce  0
  =/  deadline  (add *@da 1)
  :: =/  =typed-message  :-  `@ux`'fungible'
  ::                       :*  
  ::                       ==
  :: =/  sig  %+  ecdsa-raw-sign:secp256k1:secp:crypto
  ::            typed-message
  ::          0
  
  =/  sig  [v=0 r=25.248.332.491.586.708.363.601.973.388.309.628.628.733.012.561.401.931.610.399.476.835.572.499.426.335 s=27.365.559.960.048.330.724.580.333.546.865.253.643.265.405.962.229.511.435.455.789.175.130.621.227.585]
  =/  =embryo
    :+  owner-1
      `[%take-with-sig to account from-rice amount nonce deadline sig]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' init-now 0x1 (malt ~[[id:`grain`account-2 account-2]])]
  =/  updated-1=grain
    :*  0x1.beef
        `@ux`'fungible'
        0xbeef
        0x1
        [%& `@`'salt' [20 ~ `@ux`'simple' 0]]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        `@ux`'fungible'
        0xdead
        0x1
        [%& `@`'salt' [60 ~ `@ux`'simple' 1]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1] [id:updated-2 updated-2]]) ~ ~]
  (expect-eq !>(res) !>(correct))
::
++  test-take-with-sig-unknown-reciever  ^-  tang
  ~

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