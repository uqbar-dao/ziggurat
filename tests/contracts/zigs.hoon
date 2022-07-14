::  Tests for fungible.hoon (token contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/+  *test, cont=zig-contracts-zigs, *zig-sys-smart
=>  ::  test data
    |%
    ++  init-now  *@da
    ++  town-id   0x123
    ++  salt      `@`'zigs'
    ::
    ++  holder-1  0xbeef
    ++  holder-2  0xdead
    ++  holder-3  0xcafe
    ++  holder-4  0xface
    ::
    ++  metadata-grain  ^-  grain
      :*  zigs-wheat-id
          zigs-wheat-id
          zigs-wheat-id
          town-id
          :^  %&  salt  %metadata
          :*  name='Zigs: UQ| Tokens'
              symbol='ZIG'
              decimals=18
              supply=1.000.000
              cap=~
              mintable=%.n
              minters=~
              deployer=0x0
              salt=salt
      ==  ==
    ::
    ++  account-1  ^-  grain
      :*  0x1.beef
          zigs-wheat-id
          holder-1
          town-id
          [%& salt %account [50 (malt ~[[holder-2 1.000]]) zigs-wheat-id]]
      ==
    ::
    ++  account-2  ^-  grain
      :*  0x1.dead
          zigs-wheat-id
          holder-2
          town-id
          [%& salt %account [30 (malt ~[[holder-1 10]]) zigs-wheat-id]]
      ==
    ::
    ++  account-3  ^-  grain
      :*  0x1.cafe
          zigs-wheat-id
          holder-3
          town-id
          [%& salt %account [20 (malt ~[[holder-1 10] [holder-2 20]]) zigs-wheat-id]]
      ==
    ::
    ++  account-4  ^-  grain
      :*  0x1.face
          `@ux`'fungible'
          holder-4
          town-id
          [%& `@`'diff' %account [20 (malt ~[[holder-1 10]]) `@ux`'different!']]
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
    :-  [%give 10 holder-2 30]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-2 account-2]])]
  =/  updated-1=grain
    :*  0x1.beef
        zigs-wheat-id
        holder-1
        town-id
        [%& salt %account [20 (malt ~[[holder-2 1.000]]) zigs-wheat-id]]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        zigs-wheat-id
        holder-2
        town-id
        [%& salt %account [60 (malt ~[[holder-1 10]]) zigs-wheat-id]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    (result ~[updated-1 updated-2] ~ ~ ~)
  (expect-eq !>(correct) !>(res))
::
++  test-give-unknown-receiver  ^-  tang
  =/  =embryo
    :-  [%give 10 0xffff 30]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id ~]
  =/  new-id  (fry-rice zigs-wheat-id 0xffff town-id salt)
  =/  new=grain
    :*  new-id
        zigs-wheat-id
        0xffff
        town-id
        [%& salt %account [0 ~ zigs-wheat-id]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    %+  continuation
      ~[(call me.cart town-id.cart [%give 0xffff 30] ~[0x1.beef] ~[new-id])]
    (result ~ [new ~] ~ ~)
  (expect-eq !>(correct) !>(res))
::
++  test-give-not-enough  ^-  tang
  =/  =embryo
    :-  [%give 10 holder-2 51]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-high-budget  ^-  tang
  =/  =embryo
    :-  [%give 31 holder-2 20]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-exact-budget  ^-  tang
  =/  =embryo
    :-  [%give 30 holder-2 20]
    (malt ~[[id:account-1 account-1]])
  =/  updated-1=grain
    :*  0x1.beef
        zigs-wheat-id
        holder-1
        town-id
        [%& salt %account [30 (malt ~[[holder-2 1.000]]) zigs-wheat-id]]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        zigs-wheat-id
        holder-2
        town-id
        [%& salt %account [50 (malt ~[[holder-1 10]]) zigs-wheat-id]]
    ==
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-2 account-2]])]
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    (result [updated-1 updated-2 ~] ~ ~ ~)
  (expect-eq !>(correct) !>(res))
::
++  test-give-metadata-mismatch  ^-  tang
  =/  =embryo
    :-  [%give 10 holder-4 10]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-4 account-4]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-wrong-giver-grain  ^-  tang
  =/  bad-account=grain
    :*  0x1.beef
        zigs-wheat-id
        0x8888
        town-id
        [%& salt %account [50 ~ zigs-wheat-id]]
    ==
  =/  =embryo
    :-  [%give 10 holder-4 10]
    (malt ~[[id:account-1 bad-account]])
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-4 account-4]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-wrong-giver-grain-2  ^-  tang
  =/  =embryo
    :-  [%give 10 holder-4 10]
    (malt ~[[id:metadata-grain metadata-grain]])
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-4 account-4]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-wrong-receiver-grain  ^-  tang
  =/  =embryo
    :-  [%give 10 holder-2 10]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-3 account-3]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-wrong-receiver-grain-2  ^-  tang
  =/  =embryo
    :-  [%give 10 holder-2 10]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-3 account-3]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
::  tests for %take
::
++  test-take-simple
  =/  =embryo
    :-  [%take holder-1 `0x1.beef 0x1.dead 10]
    ~
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-1 account-1] [id:account-2 account-2]])]
  =/  updated-1=grain
    :*  0x1.beef
        zigs-wheat-id
        holder-1
        town-id
        [%& salt %account [60 (malt ~[[holder-2 1.000]]) zigs-wheat-id]]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        zigs-wheat-id
        holder-2
        town-id
        [%& salt %account [20 (malt ~[[holder-1 0]]) zigs-wheat-id]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    (result [updated-1 updated-2 ~] ~ ~ ~)
  (expect-eq !>(correct) !>(res))
::
++  test-take-send-third
  =/  =embryo
    :-  [%take holder-3 `0x1.cafe 0x1.dead 10]
    ~
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-3 account-3] [id:account-2 account-2]])]
  =/  updated-3=grain
    :*  0x1.cafe
        zigs-wheat-id
        holder-3
        town-id
        [%& salt %account [30 (malt ~[[holder-1 10] [holder-2 20]]) zigs-wheat-id]]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        zigs-wheat-id
        holder-2
        town-id
        [%& salt %account [20 (malt ~[[holder-1 0]]) zigs-wheat-id]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    (result [updated-3 updated-2 ~] ~ ~ ~)
  (expect-eq !>(correct) !>(res))
::
++  test-take-send-mismatching-account
  =/  =embryo
    :-  [%take holder-1 `0x1.cafe 0x1.dead 10]
    ~
  =/  =cart
    [zigs-wheat-id [holder-3 0] init-now town-id (malt ~[[id:account-3 account-3] [id:account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-take-send-new-account
  =/  =embryo
    :-  [%take 0xffff ~ 0x1.dead 10]
    ~
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-2 account-2]])]
  =/  new-id  (fry-rice zigs-wheat-id 0xffff town-id salt)
  =/  new=grain
    :*  new-id
        zigs-wheat-id
        0xffff
        town-id
        [%& salt %account [0 ~ zigs-wheat-id]]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        zigs-wheat-id
        holder-2
        town-id
        [%& salt %account [20 (malt ~[[holder-1 0]]) zigs-wheat-id]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    %+  continuation
      ~[(call me.cart town-id.cart [%take 0xffff `new-id 0x1.dead 10] ~ ~[new-id 0x1.dead])]
    (result ~ [new ~] ~ ~)
  (expect-eq !>(res) !>(correct))
::
++  test-take-over-allowance
  =/  =embryo
    :-  [%take holder-1 `0x1.beef 0x1.dead 20]
    ~
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-3 account-3] [id:account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-take-over-balance
  =/  =embryo
    :-  [%take holder-2 `0x1.dead 0x1.beef 60]
    ~
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-1 account-1] [id:account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-take-no-allowance
  =/  =embryo
    :-  [%take holder-2 `0x1.dead 0x1.beef 60]
    ~
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id (malt ~[[id:account-1 account-1] [id:account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
::  tests for %set-allowance
::
++  test-set-allowance-simple
  =/  =embryo
    :-  [%set-allowance holder-3 100]
    (malt ~[[id:account-1 account-1]])
  =/  updated-1=grain
    :*  0x1.beef
        zigs-wheat-id
        holder-1
        town-id
        [%& salt %account [50 (malt ~[[holder-2 1.000] [holder-3 100]]) zigs-wheat-id]]
    ==
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id ~]
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    (result [updated-1 ~] ~ ~ ~)
  (expect-eq !>(correct) !>(res))
::
++  test-set-allowance-again
  =/  =embryo
    :-  [%set-allowance holder-2 100]
    (malt ~[[id:account-1 account-1]])
  =/  updated-1=grain
    :*  0x1.beef
        zigs-wheat-id
        holder-1
        town-id
        [%& salt %account [50 (malt ~[[holder-2 100]]) zigs-wheat-id]]
    ==
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id ~]
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    (result [updated-1 ~] ~ ~ ~)
  (expect-eq !>(correct) !>(res))
::
++  test-set-allowance-zero
  =/  =embryo
    :-  [%set-allowance holder-2 0]
    (malt ~[[id:account-1 account-1]])
  =/  updated-1=grain
    :*  0x1.beef
        zigs-wheat-id
        holder-1
        town-id
        [%& salt %account [50 (malt ~[[holder-2 0]]) zigs-wheat-id]]
    ==
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id ~]
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    (result [updated-1 ~] ~ ~ ~)
  (expect-eq !>(correct) !>(res))
::
++  test-set-allowance-self
  =/  =embryo
    :-  [%set-allowance holder-1 100]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [zigs-wheat-id [holder-1 1] init-now town-id ~]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
--