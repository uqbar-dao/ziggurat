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
::  tests for %set-allowance
::
++  test-set-allowance  ^-  tang
  =/  =embryo
    :+  owner-1
      `[%set-allowance 0xcafe 10]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' 0 1 (malt ~[[id:account-3 account-3]])]
  =/  updated-1=grain
    :*  id:account-1
        `@ux`'fungible'
        0xbeef
        0x1
        [%& `@`'salt' [50 (silt ~[[0xdead 10] [0xcafe 10]]) `@ux`'simple']]
    ==
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1]]) ~ ~]
  =/  res=chick
    (~(write cont cart) embryo)
  (expect-eq !>(res) !>(correct))
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
  =/  account  `0x1.dead  :: a rice of account-2  :: TODO: something is really fishy here. the account rice should have to be signed but this is fucked
  =/  from-rice  0x1.beef  :: from account-1's rice
  =/  amount  30
  =/  nonce  0
  =/  deadline  (add *@da 1)
  =/  =typed-message  :-  (fry-rice pub-1 `@ux`'fungible' 0x1 `@`'salt')
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
  =/  =typed-message  :-  (fry-rice pub-1 `@ux`'fungible' 0x1 `@`'salt')
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
++  test-take-send-new-account  ^-  tang
  =/  =embryo
    :+  owner-1
      `[%take 0xffff ~ 0x1.dead 10]
    ~
  =/  =cart
    [`@ux`'fungible' 0 1 (malt ~[[id:account-2 account-2]])]
  =/  new-id  (fry-rice 0xffff `@ux`'fungible' 1 `@ux`'salt')
  =/  new
    :*  new-id
        `@ux`'fungible'
        0xffff
        1
        [%& `@`'salt' [10 ~ `@ux`'simple']]
    ==
  =/  correct=chick
    :+  %|
      :+  me.cart  town-id.cart
      [owner-1 `[%take 0xffff `new-id 0x1.dead 10] ~ (silt ~[0x1.dead new-id])]
    [~ (malt ~[[new-id new]]) ~]
  =/  res=chick
    (~(write cont cart) embryo)
  (expect-eq !>(res) !>(correct))
::
::  tests for %mint
::
++  test-mint-known-receivers  ^-  tang
  =/  =embryo
    :+  owner-1
      `[%mint `@ux`'simple' (silt ~[[0xdead `0x1.dead 50] [0xcafe `0x1.cafe 10]])]
    ~
  =/  =cart
    [`@ux`'fungible' 0 1 (malt ~[[id:metadata-2 metadata-2] [id:account-2 account-2] [id:account-3 account-3]])]
  =/  updated-1=grain
    :*  `@ux`'simple'
        `@ux`'fungible'
        `@ux`'holder'
        1  ::  town-id
        :+  %&  `@`'salt'
        :*  name='Simple Token'
            symbol='ST'
            decimals=0
            supply=160
            cap=`1.000
            mintable=%.n
            minters=(silt ~[0xbeef])
            deployer=0x0
            salt=`@`'salt'
    ==  ==
  =/  updated-2=grain
    :*  0x1.dead
        `@ux`'fungible'
        0xdead
        1
        [%& `@`'salt' [80 (malt ~[[0xbeef 10]]) `@ux`'simple']]
    ==
  =/  updated-3=grain
    :*  0x1.cafe
        `@ux`'fungible'
        0xcafe
        1
        [%& `@`'salt' [30 ~ `@ux`'simple']]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1] [id:updated-2 updated-2] [id:updated-3 updated-3]]) ~ ~]
  (expect-eq !>(res) !>(correct))
::
++  test-mint-unknown-receiver  ^-  tang
  =/  =embryo
    :+  owner-1
      `[%mint `@ux`'simple' (silt ~[[0xffff ~ 50]])]
    ~
  =/  =cart
    [`@ux`'fungible' 0 1 (malt ~[[id:metadata-2 metadata-2]])]
  =/  new-id  (fry-rice 0xffff `@ux`'fungible' 1 `@`'salt')
  =/  new=grain
    :*  new-id
      `@ux`'fungible'
      0xffff
      1
      [%& `@`'salt' [0 ~ `@ux`'simple']]
    ==
  =/  issued-rice=(map id grain)
    (malt ~[[new-id new]])
  =/  next-mints=(set mint:sur)
    (silt ~[[0xffff `new-id 50]])
  =/  updated-1=grain
    :*  `@ux`'simple'
        `@ux`'fungible'
        `@ux`'holder'
        1  ::  town-id
        :+  %&  `@`'salt'
        :*  name='Simple Token'
            symbol='ST'
            decimals=0
            supply=150
            cap=`1.000
            mintable=%.n
            minters=(silt ~[0xbeef])
            deployer=0x0
            salt=`@`'salt'
    ==  ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    :+  %|
      :+  me.cart  town-id.cart
      [owner-1 `[%mint `@ux`'simple' next-mints] ~ ~(key by `(map id grain)`issued-rice)]
    [(malt ~[[id:updated-1 updated-1]]) issued-rice ~]
  (expect-eq !>(res) !>(correct))
::
::  tests for %deploy
::
++  test-deploy  ^-  tang
  =/  token-salt
    (sham (cat 3 0xbeef 'TC'))
  =/  account-rice
    (fry-rice 0xdead `@ux`'fungible' 1 token-salt)
  =/  new-token-metadata=grain
    :*  (fry-rice `@ux`'fungible' `@ux`'fungible' 1 token-salt)
        `@ux`'fungible'
        `@ux`'fungible'
        1
        :+  %&  token-salt
        :*  'Test Coin'
            'TC'
            0
            900
            `1.000
            %.y
            (silt ~[0xdead])
            0xbeef
            token-salt
    ==  ==
  =/  updated-account=grain
    :*  account-rice
        `@ux`'fungible'
        0xdead
        1
        :+  %&  token-salt
        :*  900
            ~
            id.new-token-metadata
    ==  ==
  =/  =embryo
    :+  owner-1
      `[%deploy (silt ~[[0xdead 900]]) (silt ~[0xdead]) 'Test Coin' 'TC' 0 1.000 %.y]
    ~
  =/  cart
    [`@ux`'fungible' 0 1 ~]
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& ~ (malt ~[[account-rice updated-account] [[[id.new-token-metadata new-token-metadata]]]]) ~]
  (expect-eq !>(res) !>(correct))
--
