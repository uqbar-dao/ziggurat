::  Tests for nft.hoon (non-fungible token contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/+  *test, cont=zig-contracts-nft, *zig-sys-smart
=>  ::  test data
    |%
    ++  init-now  *@da
    ++  metadata-1  ^-  grain
      :*  `@ux`'simple'
          `@ux`'nft'
          `@ux`'holder'
          town-id=0x1
          :+  %&  `@`'salt'
          :*  name='Simple NFT'
              symbol='SNFT'
              attributes=(silt ~['hair' 'eyes' 'mouth'])
              supply=3
              cap=~
              mintable=%.n
              minters=~
              deployer=0x0
              salt=`@`'salt'
      ==  ==
    ::
    +$  item  [id=@ud item-contents]  
    +$  item-contents
      $:  data=(set [@t @t])
          desc=@t
          uri=@t
          transferrable=?
      ==
    ::
    ++  item-1  ^-  item
      [1 (silt ~[['hair' 'red'] ['eyes' 'blue'] ['mouth' 'smile']]) 'a smiling face' 'ipfs://fake1' %.y]
    ++  item-2  ^-  item
      [2 (silt ~[['hair' 'brown'] ['eyes' 'green'] ['mouth' 'frown']]) 'a frowny face' 'ipfs://fake2' %.y]
    ++  item-3  ^-  item
      [3 (silt ~[['hair' 'grey'] ['eyes' 'black'] ['mouth' 'squiggle']]) 'a weird face' 'ipfs://fake3' %.n]
    ::
    ++  account-1  ^-  grain
      :*  0x1.beef
          `@ux`'nft'
          0xbeef
          0x1
          [%& `@`'salt' [`@ux`'nft' (malt ~[[1 item-1]]) ~ ~]]
      ==
    ++  owner-1  ^-  account
      [0xbeef 0 0x1234.5678]
    ::
    ++  account-2  ^-  grain
      :*  0x1.dead
          `@ux`'nft'
          0xdead
          0x1
          [%& `@`'salt' [`@ux`'nft' (malt ~[[2 item-2] [3 item-3]]) ~ ~]]
      ==
    ++  owner-2  ^-  account
      [0xdead 0 0x1234.5678]
    ::
    ++  account-3  ^-  grain
      :*  0x1.cafe
          `@ux`'nft'
          0xcafe
          0x1
          [%& `@`'salt' [`@ux`'nft' ~ ~ ~]]
      ==
    ++  owner-3  ^-  account
      [0xcafe 0 0x1234.5678]
    ::
    ::  bad items, bad owners, another nft, etc..
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
      `[%give 0xdead `0x1.dead 1]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'nft' init-now 0x1 (malt ~[[id:`grain`account-2 account-2]])]
  =/  updated-1  ^-  grain
    :*  0x1.beef
          `@ux`'nft'
          0xbeef
          0x1
          [%& `@`'salt' [`@ux`'nft' ~ ~ ~]]
      ==
  =/  updated-2  ^-  grain
    :*  0x1.dead
          `@ux`'nft'
          0xdead
          0x1
          [%& `@`'salt' [`@ux`'nft' (malt ~[[1 item-1] [2 item-2] [3 item-3]]) ~ ~]]
      ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    [%& (malt ~[[id.updated-1 updated-1] [id.updated-2 updated-2]]) ~ ~]
  (expect-eq !>(correct) !>(res))
::
++  test-give-unknown-receiver  ^-  tang
  =/  =embryo
    :+  owner-1
      `[%give 0xffff ~ 1]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'nft' init-now 0x1 ~]
  =/  new-id  (fry-rice `@ux`'nft' 0xffff 0x1 `@`'salt')
  =/  new
    :*  new-id
        `@ux`'nft'
        0xffff
        0x1
        [%& `@`'salt' [`@ux`'nft' ~ ~ ~]]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
  =/  correct=chick
    :+  %|
      :+  me.cart  town-id.cart
      [owner-1 `[%give 0xffff `new-id 1] (silt ~[0x1.beef]) (silt ~[new-id])]
    [~ (malt ~[[new-id new]]) ~]
  (expect-eq !>(correct) !>(res))
::
++  test-give-doesnt-have  ^-  tang
  =/  =embryo
    :+  owner-1
      `[%give 0xdead `0x1.dead 2]
    (malt ~[[id:`grain`account-1 account-1]])
  =/  =cart
    [`@ux`'nft' init-now 0x1 (malt ~[[id:`grain`account-2 account-2]])]
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
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