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
          :^  %&  `@`'salt'  %metadata
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
      ++  metadata-mintable  ^-  grain
      :*  `@ux`'simple'
          `@ux`'fungible'
          `@ux`'holder'
          town-id=0x1
          :^  %&  `@`'salt'  %metadata
          :*  name='Simple Token'
              symbol='ST'
              decimals=0
              supply=100
              cap=`1.000
              mintable=%.y
              minters=(silt ~[pub-1])
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
          [%& `@`'salt' %account [50 ~ `@ux`'simple' 0]]
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
          [%& `@`'salt' %account [30 ~ `@ux`'simple' 0]]
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
          [%& `@`'salt' %account [20 (malt ~[[0xffff 100]]) `@ux`'simple' 0]]
      ==
    ::
    ++  account-4  ^-  grain
      :*  0x1.face
          `@ux`'fungible'
          0xface
          0x1
          [%& `@`'diff' %account [20 ~ `@ux`'different!' 0]]
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
    :-  [%set-allowance 0xcafe 10]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' [pub-1 0] init-now 0x1 (malt ~[[id:account-3 account-3]])]
  =/  updated-1=grain
    :*  id:account-1
        `@ux`'fungible'
        pub-1
        0x1
        [%& `@`'salt' %account [50 (silt ~[[0xcafe 10]]) `@ux`'simple' ~]]
    ==
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1]]) ~ ~ ~]
  =/  res=chick
    (~(write cont cart) embryo)
  (expect-eq !>(res) !>(correct))
::
::  tests for %give
::
++  test-give-known-receiver  ^-  tang
  =/  =embryo
    :-  [%give pub-2 30]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' [pub-2 0] init-now 0x1 (malt ~[[id:`grain`account-2 account-2]])]
  =/  updated-1=grain
    :*  0x1.beef
        `@ux`'fungible'
        pub-1
        0x1
        [%& `@`'salt' %account [20 ~ `@ux`'simple' 0]]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        `@ux`'fungible'
        pub-2
        0x1
        [%& `@`'salt' %account [60 ~ `@ux`'simple' 0]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1] [id:updated-2 updated-2]]) ~ ~ ~]
  (expect-eq !>(res) !>(correct))
++  test-give-unknown-receiver  ^-  tang
  =/  =embryo
    :-  [%give 0xffff 30]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' [pub-1 0] init-now 0x1 ~]
  =/  new-id  (fry-rice `@ux`'fungible' 0xffff 0x1 `@`'salt')
  =/  new=grain
    :*  new-id
        `@ux`'fungible'
        0xffff
        0x1
        [%& `@`'salt' %account [0 ~ `@ux`'simple' 0]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    :+  %|
      :~  :+  me.cart  town-id.cart
        [`[%give 0xffff 30] (silt ~[0x1.beef]) (silt ~[new-id])]
       ==
    [~ (malt ~[[new-id new]]) ~ ~]
  (expect-eq !>(res) !>(correct))
::
++  test-give-not-enough  ^-  tang
  =/  =embryo
    :-  `[%give 0xdead `0x1.dead 51]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' [pub-1 0] init-now 0x1 (malt ~[[id:`grain`account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-metadata-mismatch  ^-  tang
  =/  =embryo
    :-  `[%give 0xface `0x1.face 10]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' [pub-1 0] init-now 0x1 (malt ~[[id:`grain`account-4 account-4]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
::  tests for %take
::
++  test-take-send-new-account  ^-  tang
  =/  =embryo
    :-  [%take 0xffff ~ 0x1.cafe 10]
    ~
  =/  =cart
    [`@ux`'fungible' [0xffff 0] init-now 0x1 (malt ~[[id:account-3 account-3]])]
  =/  new-id=id  (fry-rice `@ux`'fungible' 0xffff 0x1 `@ux`'salt')
  =/  new=grain
    :*  new-id
        `@ux`'fungible'
        0xffff
        0x1
        [%& `@`'salt' %account [0 ~ `@ux`'simple' 0]]
    ==
  =/  correct=chick
    :+  %|
      :~  :+  me.cart
            town-id.cart
          [`[%take 0xffff `new-id 0x1.cafe 10] ~ (silt ~[0x1.cafe new-id])]
      ==
    [~ (malt ~[[new-id new]]) ~ ~]
  =/  res=chick
    (~(write cont cart) embryo)
  (expect-eq !>(res) !>(correct))
::
::  tests for %take-with-sig
::
++  test-take-with-sig-known-reciever  ^-  tang
  ::  owner-1 is giving owner-2 the ability to take 30
  =/  to  pub-2
  =/  account  `0x1.dead  :: a rice of account-2  :: TODO: something is really fishy here. the account rice should have to be signed but this is fucked
  =/  from-account  0x1.beef  :: from account-1's rice
  =/  amount  30
  =/  nonce  0
  =/  deadline  (add *@da 1)
  =/  =typed-message  :-  (fry-rice `@ux`'fungible' pub-1 0x1 `@`'salt')
                        (sham [pub-1 to amount nonce deadline])
  =/  sig  %+  ecdsa-raw-sign:secp256k1:secp:crypto-non-zuse
             (sham typed-message)
           priv-1
  =/  =embryo
    :-  [%take-with-sig to account from-account amount nonce deadline sig]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' [pub-2 0] init-now 0x1 (malt ~[[id:`grain`account-1 account-1] [id:`grain`account-2 account-2]])]
  =/  updated-1=grain
    :*  0x1.beef
        `@ux`'fungible'
        pub-1
        0x1
        [%& `@`'salt' %account [20 ~ `@ux`'simple' 1]]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        `@ux`'fungible'
        pub-2
        0x1
        [%& `@`'salt' %account [60 ~ `@ux`'simple' 0]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& [(malt ~[[id:updated-1 updated-1] [id:updated-2 updated-2]]) ~ ~ ~]]
  (expect-eq !>(res) !>(correct))

++  test-take-with-sig-unknown-reciever  ^-  tang
  ::  owner-1 is giving owner-2 the ability to take 30
  =/  to  pub-2
  =/  account  ~  :: unkown account this time
  =/  from-account  0x1.beef
  =/  amount  30
  =/  nonce  0
  =/  deadline  (add *@da 1)
  =/  =typed-message  :-  (fry-rice `@ux`'fungible' pub-1 0x1 `@`'salt')
                      (sham [pub-1 to amount nonce deadline])
  =/  sig  %+  ecdsa-raw-sign:secp256k1:secp:crypto-non-zuse
             (sham typed-message)
           priv-1
  =/  =embryo
    :-  [%take-with-sig to account from-account amount nonce deadline sig]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'fungible' [pub-2 0] init-now 0x1 (malt ~[[id:`grain`account-1 account-1]])] :: cart no longer knows account-2' rice
  =/  updated-1=grain
    :*  0x1.beef
        `@ux`'fungible'
        pub-1
        0x1
        [%& `@`'salt' %account [20 ~ `@ux`'simple' 1]]
    ==
  =/  new-id  (fry-rice pub-2 `@ux`'fungible' 0x1 `@`'salt')
  =/  new=grain
    :*  new-id
        `@ux`'fungible'
        pub-2
        0x1
        [%& `@`'salt' %account [30 ~ `@ux`'simple' 0]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    :+  %|
      :~  :+  me.cart
            town-id.cart
          [`[%take-with-sig pub-2 `new-id 0x1.beef amount nonce deadline sig] ~ (silt ~[0x1.beef new-id])]
      ==
    [~ (malt ~[[new-id new]]) ~ ~]
  (expect-eq !>(res) !>(correct))
::
::  tests for %mint
::
++  test-mint-known-receivers  ^-  tang
  =/  =embryo
    :-  [%mint `@ux`'simple' (silt ~[[pub-1 `0x1.dead 50] [pub-2 `0x1.cafe 10]])]
    ~
  =/  =cart
    :*  `@ux`'fungible'
        [pub-1 0]
        init-now
        0x1
        (malt ~[[id:metadata-mintable metadata-mintable] [id:account-2 account-2] [id:account-3 account-3]])
    ==
  =/  updated-1=grain
    :*  `@ux`'simple'
        `@ux`'fungible'
        `@ux`'holder'
        0x1
        :^  %&  `@`'salt'  %metadata
        :*  name='Simple Token'
            symbol='ST'
            decimals=0
            supply=160
            cap=`1.000
            mintable=%.n
            minters=(silt ~[pub-1])
            deployer=0x0
            salt=`@`'salt'
    ==  ==
  =/  updated-2=grain
    :*  0x1.dead
        `@ux`'fungible'
        pub-2
        0x1
        [%& `@`'salt' %account [80 ~ `@ux`'simple' 0]]
    ==
  =/  updated-3=grain
    :*  0x1.cafe
        `@ux`'fungible'
        pub-3
        0x1
        [%& `@`'salt' %account [30 (malt ~[[0xffff 100]]) `@ux`'simple' 0]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1] [id:updated-2 updated-2] [id:updated-3 updated-3]]) ~ ~ ~]
  (expect-eq !>(res) !>(correct))
::
++  test-mint-unknown-receiver  ^-  tang
  =/  =embryo
    :-  [%mint `@ux`'simple' (silt ~[[pub-1 ~ 50]])]
    ~
  =/  =cart
    [`@ux`'fungible' [pub-1 0] init-now 0x1 (malt ~[[id:metadata-mintable metadata-mintable]])]
  =/  new-id  (fry-rice `@ux`'fungible' pub-1 0x1 `@`'salt')
  =/  new=grain
    :*  new-id
      `@ux`'fungible'
      pub-1
      0x1
      [%& `@`'salt' %account [0 ~ `@ux`'simple' 0]]
    ==
  =/  issued-rice=(map id grain)
    (malt ~[[new-id new]])
  =/  next-mints=(set mint:sur:cont-lib)
    (silt ~[[pub-1 `new-id 50]])
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    :+  %|
      :~  :+  me.cart  town-id.cart
        [`[%mint `@ux`'simple' next-mints] ~ ~(key by `(map id grain)`issued-rice)]
      ==
    [~ issued-rice ~ ~]
  (expect-eq !>(res) !>(correct))
::
::  tests for %deploy
::
++  test-deploy  ^-  tang
  =/  token-salt
    (sham (cat 3 pub-1 'TC'))
  =/  account-rice
    (fry-rice `@ux`'fungible' pub-1 0x1 token-salt)
  =/  new-token-metadata=grain
    :*  (fry-rice `@ux`'fungible' `@ux`'fungible' 0x1 token-salt)
        `@ux`'fungible'
        `@ux`'fungible'
        0x1
        :^  %&  token-salt  %metadata
        :*  'Test Coin'
            'TC'
            0
            900
            `1.000
            %.y
            (silt ~[pub-1])
            pub-1
            token-salt
    ==  ==
  =/  updated-account=grain
    :*  account-rice
        `@ux`'fungible'
        pub-1
        0x1
        :^  %&  token-salt  %account
        :*  900
            ~
            id.new-token-metadata
            0
    ==  ==
  =/  =embryo
    :-  [%deploy (silt ~[[pub-1 900]]) (silt ~[pub-1]) 'Test Coin' 'TC' 0 1.000 %.y]
    ~
  =/  cart
    [`@ux`'fungible' [pub-1 0] init-now 0x1 ~]
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& ~ (malt ~[[account-rice updated-account] [id.new-token-metadata new-token-metadata]]) ~ ~]
  (expect-eq !>(res) !>(correct))
--