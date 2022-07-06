::  Tests for capitol.hoon (chain management contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/+  *test, cont=zig-contracts-capitol, *zig-sys-smart
=>  ::  test data
    |%
    ++  init-now  *@da
    ++  world-grain  ^-  grain
      :*  `@ux`'world'            ::  id
          `@ux`'capitol'          ::  lord
          `@ux`'capitol'          ::  holder
          0x0                     ::  town-id
          [%& `@`'world' data=*(map @ud @ux)]
      ==
    ::
    ++  ziggurat-grain  ^-  grain
      :*  `@ux`'ziggurat'
          `@ux`'capitol'
          `@ux`'capitol'
          0x0
          [%& `@`'ziggurat' data=*(map ship [@ux ship @ud])]
      ==
    ++  world-cart  ^-  cart
      :*  `@ux`'capitol'
          init-now
          0x0
          (malt ~[[`@ux`'world' world-grain]])
      ==
    ++  ziggurat-cart  ^-  cart
      :*  `@ux`'capitol'
          init-now
          0x0
          (malt ~[[`@ux`'ziggurat' ziggurat-grain]])
      ==
    --
::  testing arms
|%
++  test-matches-type  ^-  tang
  =/  valid  (mule |.(;;(contract cont)))
  (expect-eq !>(%.y) !>(-.valid))
::
::  Tests for %become-validator calls
::
++  test-become-validator  ^-  tang
  =/  inp=embryo
    :+  [0xbeef 0 0x1.beef]
      `[%become-validator [0x1111 ~zod 1]]
    ~
  =/  updated-ziggurat=grain
    :*  `@ux`'ziggurat'
        `@ux`'capitol'
        `@ux`'capitol'
        0x0
        [%& `@`'ziggurat' (malt ~[[~zod [0x1111 ~zod 1]]])]
    ==
  =/  res=chick
    (~(write cont ziggurat-cart) inp)
  =/  correct=chick
    [%& (malt ~[[`@ux`'ziggurat' updated-ziggurat]]) ~ ~]
  (expect-eq !>(res) !>(correct))
::
++  test-become-validator-already-one  ^-  tang
  =/  inp=embryo
    :+  [0xbeef 0 0x1.beef]
      `[%become-validator [0x1111 ~zod 1]]
    ~
  =/  initial=grain
    :*  `@ux`'ziggurat'
        `@ux`'capitol'
        `@ux`'capitol'
        0x0
        [%& `@`'ziggurat' (malt ~[[~zod [0x1111 ~zod 1]]])]
    ==
  =/  =cart
    [`@ux`'capitol' init-now 0x0 (malt ~[[`@ux`'ziggurat' initial]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) inp)))
  (expect-eq !>(%.n) !>(-.res))
::
::  Tests for %stop-validating calls
::
++  test-stop-validating  ^-  tang
  =/  inp=embryo
    :+  [0xbeef 0 0x1.beef]
      `[%stop-validating [0x1111 ~zod 1]]
    ~
  =/  initial=grain
    :*  `@ux`'ziggurat'
        `@ux`'capitol'
        `@ux`'capitol'
        0x0
        [%& `@`'ziggurat' (malt ~[[~zod [0x1111 ~zod 1]]])]
    ==
  =/  updated-ziggurat=grain
    :*  `@ux`'ziggurat'
        `@ux`'capitol'
        `@ux`'capitol'
        0x0
        [%& `@`'ziggurat' ~]
    ==
  =/  =cart
    [`@ux`'capitol' init-now 0x0 (malt ~[[`@ux`'ziggurat' initial]])]
  =/  res=chick
    (~(write cont cart) inp)
  =/  correct=chick
    [%& (malt ~[[`@ux`'ziggurat' updated-ziggurat]]) ~ ~]
  (expect-eq !>(res) !>(correct))
::
++  test-stop-validating-wasnt-one  ^-  tang
  =/  inp=embryo
    :+  [0xbeef 0 0x1.beef]
      `[%stop-validating [0x1111 ~zod 1]]
    ~
  =/  res=(each * (list tank))
    (mule |.((~(write cont ziggurat-cart) inp)))
  (expect-eq !>(%.n) !>(-.res))
::
::  Tests for %init calls
::
++  test-init-1
  =/  inp=embryo
    :+  [0xbeef 0 0x1.beef]
      `[%init [0x1111 ~zod 1] 1]
    ~
  =/  updated-world=grain
    :*  `@ux`'world'
        `@ux`'capitol'
        `@ux`'capitol'
        0x0
        [%& `@`'world' (malt ~[[1 (malt ~[[~zod [0xbeef [0x1111 ~zod 1]]]])]])]
    ==
  =/  res=chick
    (~(write cont world-cart) inp)
  =/  correct=chick
    [%& (malt ~[[`@ux`'world' updated-world]]) ~ ~]
  (expect-eq !>(res) !>(correct))
::
::  Tests for %join calls
::
++  test-join-1
  =/  inp=embryo
    :+  [0xdead 0 0x1.dead]
      `[%join [0x2222 ~bus 1] 1]
    ~
  =/  initial=grain
    :*  `@ux`'world'
        `@ux`'capitol'
        `@ux`'capitol'
        0x0
        [%& `@`'world' (malt ~[[1 (malt ~[[~zod [0xbeef [0x1111 ~zod 1]]]])]])]
    ==
  =/  updated-world=grain
    :*  `@ux`'world'
        `@ux`'capitol'
        `@ux`'capitol'
        0x0
        [%& `@`'world' (malt ~[[1 (malt ~[[~zod [0xbeef [0x1111 ~zod 1]]] [~bus [0xdead [0x2222 ~bus 1]]]])]])]
    ==
  =/  =cart
    [`@ux`'capitol' init-now 0x0 (malt ~[[`@ux`'world' initial]])]
  =/  res=chick
    (~(write cont cart) inp)
  =/  correct=chick
    [%& (malt ~[[`@ux`'world' updated-world]]) ~ ~]
  (expect-eq !>(res) !>(correct))
::
::  Tests for %exit calls
::
++  test-exit-1
  =/  inp=embryo
    :+  [0xdead 0 0x1.dead]
      `[%exit [0x2222 ~bus 1] 1]
    ~
  =/  initial=grain
    :*  `@ux`'world'
        `@ux`'capitol'
        `@ux`'capitol'
        0x0
        [%& `@`'world' (malt ~[[1 (malt ~[[~zod [0xbeef [0x1111 ~zod 1]]] [~bus [0xdead [0x2222 ~bus 1]]]])]])]
    ==
  =/  updated-world=grain
    :*  `@ux`'world'
        `@ux`'capitol'
        `@ux`'capitol'
        0x0
        [%& `@`'world' (malt ~[[1 (malt ~[[~zod [0xbeef [0x1111 ~zod 1]]]])]])]
    ==
  =/  =cart
    [`@ux`'capitol' init-now 0x0 (malt ~[[`@ux`'world' initial]])]
  =/  res=chick
    (~(write cont cart) inp)
  =/  correct=chick
    [%& (malt ~[[`@ux`'world' updated-world]]) ~ ~]
  (expect-eq !>(res) !>(correct))
--