::  Tests for fungible.hoon (token contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/+  *test, cont=zig-contracts-fungible, cont-lib=zig-contracts-lib-fungible, *zig-sys-smart, ethereum
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
    ++  priv-1  0xbeef.beef.beef.beef.beef.beef.beef.beef.beef.beef
    ++  pub-1  (address-from-prv:key:ethereum priv-1)
    ++  owner-1  ^-  account
      [pub-1 0 0x1234.5678]
    ++  account-1  ^-  grain
      :*  0x1.beef         ::  id
          `@ux`'fungible'  ::  lord
          pub-1            ::  holder
          0x1              ::  town
          [%& `@`'salt' [50 ~ `@ux`'simple' 0]]
      ==
    ::
    ++  priv-2  0xdead.dead.dead.dead.dead.dead.dead.dead.dead.dead
    ++  pub-2  (address-from-prv:key:ethereum priv-2)
    ++  owner-2  ^-  account
      [pub-2 0 0x1234.5678]
    ++  account-2  ^-  grain
      :*  0x1.dead
          `@ux`'fungible'
          pub-2
          0x1
          [%& `@`'salt' [30 ~ `@ux`'simple' 0]]
      ==
    ::
    ++  priv-3  0xcafe.cafe.cafe.cafe.cafe.cafe.cafe.cafe.cafe.cafe
    ++  pub-3  (address-from-prv:key:ethereum priv-3)
    ++  owner-3  ^-  account
      [pub-3 0 0x1234.5678]
    ++  account-3  ^-  grain
      :*  0x1.cafe
          `@ux`'fungible'
          pub-3
          0x1
          [%& `@`'salt' [20 ~ `@ux`'simple' 0]]
      ==
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
        pub-1
        0x1
        [%& `@`'salt' [20 ~ `@ux`'simple' 0]]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        `@ux`'fungible'
        pub-2
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
  ::  owner-1 is giving owner-2 the ability to take 30
  =/  to  pub-2
  =/  account  `0x1.dead  :: a rice of account-2
  =/  from-rice  0x1.beef  :: from account-1's rice
  =/  amount  30
  =/  nonce  0
  =/  deadline  (add *@da 1)
  =/  =typed-message  :-  (fry-rice pub-1 `@ux`'fungible' 0x1 0)
                        (sham ;;(approve:sur:cont-lib [pub-1 to amount nonce deadline]))
  =/  sig  %+  ecdsa-raw-sign:secp256k1:secp:crypto
             (sham typed-message)
           priv-1
  =/  =embryo
    :+  owner-2  ::  is calling take-with-sig
      `[%take-with-sig to account from-rice amount nonce deadline sig]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' init-now 0x1 (malt ~[[id:`grain`account-1 account-1] [id:`grain`account-2 account-2]])]
  =/  updated-1=grain
    :*  0x1.beef
        `@ux`'fungible'
        pub-1
        0x1
        [%& `@`'salt' [20 ~ `@ux`'simple' 1]]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        `@ux`'fungible'
        pub-2
        0x1
        [%& `@`'salt' [60 ~ `@ux`'simple' 0]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1] [id:updated-2 updated-2]]) ~ ~]
  (expect-eq !>(res) !>(correct))
::
++  test-take-with-sig-unknown-reciever  ^-  tang
  ::  owner-1 is giving owner-2 the ability to take 30
  =/  to  pub-2
  =/  account  ~  :: unkown account this time
  =/  from-rice  0x1.beef
  =/  amount  30
  =/  nonce  0
  =/  deadline  (add *@da 1)
  =/  =typed-message  :-  (fry-rice pub-1 `@ux`'fungible' 0x1 0)
                        (sham ;;(approve:sur:cont-lib [pub-1 to amount nonce deadline]))
  =/  sig  %+  ecdsa-raw-sign:secp256k1:secp:crypto
             (sham typed-message)
           priv-1
  =/  =embryo
    :+  owner-2  ::  is calling take-with-sig
      `[%take-with-sig to account from-rice amount nonce deadline sig]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' init-now 0x1 (malt ~[[id:`grain`account-1 account-1]])] :: cart no longer knows account-2' rice
  =/  updated-1=grain
    :*  0x1.beef
        `@ux`'fungible'
        pub-1
        0x1
        [%& `@`'salt' [20 ~ `@ux`'simple' 1]]
    ==
  =/  new-id  (fry-rice pub-2 `@ux`'fungible' 0x1 `@`'salt')
  =/  new=grain
    :*  new-id
        `@ux`'fungible'
        pub-2
        0x1
        [%& `@`'salt' [30 ~ `@ux`'simple' 0]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    :+  %|
      :+  me.cart  town-id.cart
      [owner-2 `[%take-with-sig pub-2 `new-id 0x1.beef amount nonce deadline sig] ~ (silt ~[0x1.beef new-id])]
    [~ (malt ~[[new-id new]]) ~]
  (expect-eq !>(res) !>(correct))

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