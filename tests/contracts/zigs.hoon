::  Tests for fungible.hoon (token contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/+  *test, cont=zig-contracts-zigs, *zig-sys-smart
=>  ::  test data
    |%
    ++  init-now  *@da
    ++  metadata-1  ^-  grain
      :*  `@ux`'zigs'
          `@ux`'zigs'
          `@ux`'zigs'
          0x1  ::  town-id
          :+  %&  `@`'zigs'
          :*  name='Zigs: UQ| Tokens'
              symbol='ZIG'
              decimals=18
              supply=100
              cap=~
              mintable=%.n
              minters=~
              deployer=0x0
              salt=`@`'zigs'
      ==  ==
    ::
    ++  account-1  ^-  grain
      :*  0x1.beef
          `@ux`'zigs'
          0xbeef
          0x1
          [%& `@`'zigs' [50 (malt ~[[0xdead 1.000]]) `@ux`'zigs']]
      ==
    ++  owner-1  ^-  account
      [0xbeef 0 0x1234.5678]
    ::
    ++  account-2  ^-  grain
      :*  0x1.dead
          `@ux`'zigs'
          0xdead
          0x1
          [%& `@`'zigs' [30 (malt ~[[0xbeef 10]]) `@ux`'zigs']]
      ==
    ++  owner-2  ^-  account
      [0xdead 0 0x1234.5678]
    ::
    ++  account-3  ^-  grain
      :*  0x1.cafe
          `@ux`'zigs'
          0xcafe
          0x1
          [%& `@`'zigs' [20 (malt ~[[0xbeef 10] [0xdead 20]]) `@ux`'zigs']]
      ==
    ++  owner-3  ^-  account
      [0xcafe 0 0x1234.5678]
    ::
    ++  account-4  ^-  grain
      :*  0x1.face
          `@ux`'fungible'
          0xface
          0x1
          [%& `@`'diff' [20 (malt ~[[0xbeef 10]]) `@ux`'different!']]
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
    :-  `[%give 0xdead `0x1.dead 30 10]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-2 account-2]])]
  =/  updated-1=grain
    :*  0x1.beef
        `@ux`'zigs'
        0xbeef
        0x1
        [%& `@`'zigs' [20 (malt ~[[0xdead 1.000]]) `@ux`'zigs']]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        `@ux`'zigs'
        0xdead
        0x1
        [%& `@`'zigs' [60 (malt ~[[0xbeef 10]]) `@ux`'zigs']]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1] [id:updated-2 updated-2]]) ~ ~]
  (expect-eq !>(correct) !>(res))
::
++  test-give-unknown-receiver  ^-  tang
  =/  =embryo
    :-  `[%give 0xffff ~ 30 10]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 ~]
  =/  new-id  (fry-rice 0xffff `@ux`'zigs' 0x1 `@`'zigs')
  =/  new=grain
    :*  new-id
        `@ux`'zigs'
        0xffff
        0x1
        [%& `@`'zigs' [0 ~ `@ux`'zigs']]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    :+  %|
      :_  ~
      :+  me.cart  town-id.cart
      [`[%give 0xffff `new-id 30 10] (silt ~[0x1.beef]) (silt ~[new-id])]
    [~ (malt ~[[new-id new]]) ~]
  (expect-eq !>(correct) !>(res))
::
++  test-give-not-enough  ^-  tang
  =/  =embryo
    :-  `[%give 0xdead `0x1.dead 51 10]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-high-budget  ^-  tang
  =/  =embryo
    :-  `[%give 0xdead `0x1.dead 20 31]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-exact-budget  ^-  tang
  =/  =embryo
    :-  `[%give 0xdead `0x1.dead 20 30]
    (malt ~[[id:account-1 account-1]])
  =/  updated-1=grain
    :*  0x1.beef
        `@ux`'zigs'
        0xbeef
        0x1
        [%& `@`'zigs' [30 (malt ~[[0xdead 1.000]]) `@ux`'zigs']]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        `@ux`'zigs'
        0xdead
        0x1
        [%& `@`'zigs' [50 (malt ~[[0xbeef 10]]) `@ux`'zigs']]
    ==
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-2 account-2]])]
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1] [id:updated-2 updated-2]]) ~ ~]
  (expect-eq !>(correct) !>(res))
::
++  test-give-metadata-mismatch  ^-  tang
  =/  =embryo
    :-  `[%give 0xface `0x1.face 10 10]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-4 account-4]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-wrong-giver-grain  ^-  tang
  =/  bad-account=grain
    :*  0x1.beef
        `@ux`'zigs'
        0x8888
        0x1
        [%& `@`'zigs' [50 ~ `@ux`'zigs']]
    ==
  =/  =embryo
    :-  `[%give 0xface `0x1.face 10 10]
    (malt ~[[id:account-1 bad-account]])
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-4 account-4]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-wrong-giver-grain-2  ^-  tang
  =/  =embryo
    :-  `[%give 0xface `0x1.face 10 10]
    (malt ~[[id:metadata-1 metadata-1]])
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-4 account-4]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-wrong-receiver-grain  ^-  tang
  =/  =embryo
    :-  `[%give 0xdead `0x1.dead 10 10]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-3 account-3]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-give-wrong-receiver-grain-2  ^-  tang
  =/  =embryo
    :-  `[%give 0xdead `0x1.cafe 10 10]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-3 account-3]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
::  tests for %take
::
++  test-take-simple
  =/  =embryo
    :-  `[%take 0xbeef `0x1.beef 0x1.dead 10]
    ~
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-1 account-1] [id:account-2 account-2]])]
  =/  updated-1=grain
    :*  0x1.beef
        `@ux`'zigs'
        0xbeef
        0x1
        [%& `@`'zigs' [60 (malt ~[[0xdead 1.000]]) `@ux`'zigs']]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        `@ux`'zigs'
        0xdead
        0x1
        [%& `@`'zigs' [20 (malt ~[[0xbeef 0]]) `@ux`'zigs']]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1] [id:updated-2 updated-2]]) ~ ~]
  (expect-eq !>(correct) !>(res))
::
++  test-take-send-third
  =/  =embryo
    :-  `[%take 0xcafe `0x1.cafe 0x1.dead 10]
    ~
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-3 account-3] [id:account-2 account-2]])]
  =/  updated-3=grain
    :*  0x1.cafe
        `@ux`'zigs'
        0xcafe
        0x1
        [%& `@`'zigs' [30 (malt ~[[0xbeef 10] [0xdead 20]]) `@ux`'zigs']]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        `@ux`'zigs'
        0xdead
        0x1
        [%& `@`'zigs' [20 (malt ~[[0xbeef 0]]) `@ux`'zigs']]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-3 updated-3] [id:updated-2 updated-2]]) ~ ~]
  (expect-eq !>(correct) !>(res))
::
++  test-take-send-mismatching-account
  =/  =embryo
    :-  `[%take 0xbeef `0x1.cafe 0x1.dead 10]
    ~
  =/  =cart
    [`@ux`'zigs' 0xcafe init-now 0x1 (malt ~[[id:account-3 account-3] [id:account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-take-send-new-account
  =/  =embryo
    :-  `[%take 0xffff ~ 0x1.dead 10]
    ~
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-2 account-2]])]
  =/  new-id  (fry-rice 0xffff `@ux`'zigs' 0x1 `@`'zigs')
  =/  new=grain
    :*  new-id
        `@ux`'zigs'
        0xffff
        0x1
        [%& `@`'zigs' [0 ~ `@ux`'zigs']]
    ==
  =/  updated-2=grain
    :*  0x1.dead
        `@ux`'zigs'
        0xdead
        0x1
        [%& `@`'zigs' [20 (malt ~[[0xbeef 0]]) `@ux`'zigs']]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    :+  %|
      :_  ~
      :+  me.cart  town-id.cart
      [`[%take 0xffff `new-id 0x1.dead 10] ~ (silt ~[new-id 0x1.dead])]
    [~ (malt ~[[new-id new]]) ~]
  (expect-eq !>(res) !>(correct))
::
++  test-take-over-allowance
  =/  =embryo
    :-  `[%take 0xbeef `0x1.beef 0x1.dead 20]
    ~
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-3 account-3] [id:account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-take-over-balance
  =/  =embryo
    :-  `[%take 0xdead `0x1.dead 0x1.beef 60]
    ~
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-1 account-1] [id:account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
++  test-take-no-allowance
  =/  =embryo
    :-  `[%take 0xdead `0x1.dead 0x1.beef 60]
    ~
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 (malt ~[[id:account-1 account-1] [id:account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
::  tests for %set-allowance
::
++  test-set-allowance-simple
  =/  =embryo
    :-  `[%set-allowance 0xcafe 100]
    (malt ~[[id:account-1 account-1]])
  =/  updated-1=grain
    :*  0x1.beef
        `@ux`'zigs'
        0xbeef
        0x1
        [%& `@`'zigs' [50 (malt ~[[0xdead 1.000] [0xcafe 100]]) `@ux`'zigs']]
    ==
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 ~]
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1]]) ~ ~]
  (expect-eq !>(correct) !>(res))
::
++  test-set-allowance-again
  =/  =embryo
    :-  `[%set-allowance 0xdead 100]
    (malt ~[[id:account-1 account-1]])
  =/  updated-1=grain
    :*  0x1.beef
        `@ux`'zigs'
        0xbeef
        0x1
        [%& `@`'zigs' [50 (malt ~[[0xdead 100]]) `@ux`'zigs']]
    ==
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 ~]
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1]]) ~ ~]
  (expect-eq !>(correct) !>(res))
::
++  test-set-allowance-zero
  =/  =embryo
    :-  `[%set-allowance 0xdead 0]
    (malt ~[[id:account-1 account-1]])
  =/  updated-1=grain
    :*  0x1.beef
        `@ux`'zigs'
        0xbeef
        0x1
        [%& `@`'zigs' [50 (malt ~[[0xdead 0]]) `@ux`'zigs']]
    ==
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 ~]
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id:updated-1 updated-1]]) ~ ~]
  (expect-eq !>(correct) !>(res))
::
++  test-set-allowance-self
  =/  =embryo
    :-  `[%set-allowance 0xbeef 100]
    (malt ~[[id:account-1 account-1]])
  =/  =cart
    [`@ux`'zigs' 0xbeef init-now 0x1 ~]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
--