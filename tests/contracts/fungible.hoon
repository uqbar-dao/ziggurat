::  Tests for fungible.hoon (token contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/+  *test, cont=zig-contracts-fungible, *zig-sys-smart, ethereum
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
    ::
    ::  for signatures
    ::
    +$  approve  $:  from=id
                     to=id
                     amount=@ud
                     nonce=@ud
                     deadline=@da
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
  ::  send from 2 (dead) to 1 (beef)
  =/  to  pub-1
  =/  account  `0x1.beef
  =/  from-rice  0x1.dead
  =/  amount  30
  =/  nonce  0
  =/  deadline  (add *@da 1)
  =/  =typed-message  :-  (fry-rice pub-2 `@ux`'fungible' 0x1 0)
                        (sham ;;(approve [pub-2 to amount nonce deadline]))
  =/  sig  %+  ecdsa-raw-sign:secp256k1:secp:crypto
             (sham typed-message)
           priv-2
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
        pub-2
        0x1
        [%& `@`'salt' [60 ~ `@ux`'simple' 1]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-2 updated-2]]) ~ ~] :: [id:updated-1 updated-1]
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