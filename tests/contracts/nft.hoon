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
    +$  item  [id=@ud allowance=(unit id) item-contents]  
    +$  item-contents
      $:  data=(set [@t @t])
          desc=@t
          uri=@t
          transferrable=?
      ==
    ::
    ++  item-1  ^-  item
      [1 ~ (silt ~[['hair' 'red'] ['eyes' 'blue'] ['mouth' 'smile']]) 'a smiling face' 'ipfs://fake1' %.y]
    ++  item-2  ^-  item
      [2 ~ (silt ~[['hair' 'brown'] ['eyes' 'green'] ['mouth' 'frown']]) 'a frowny face' 'ipfs://fake2' %.y]
    ++  item-3  ^-  item
      [3 ~ (silt ~[['hair' 'grey'] ['eyes' 'black'] ['mouth' 'squiggle']]) 'a weird face' 'ipfs://fake3' %.n]
    ::
    ++  nft-1  ^-  grain
      :*  `@ux`'nft-1'
          `@ux`'nft'
          0xbeef
          town-id=0x1
          :+  %&  `@`'salt'  item-1
      ==
    ++  nft-2  ^-  grain
      :*  `@ux`'nft-2'
          `@ux`'nft'
          0xdead
          town-id=0x1
          :+  %&  `@`'salt'  item-2
      ==
    ++  nft-3  ^-  grain
      :*  `@ux`'nft-3'
          `@ux`'nft'
          0xcafe
          town-id=0x1
          :+  %&  `@`'salt'  item-3
      ==
    ::
    ++  owner-1  ^-  account
      [0xbeef 0 0x1234.5678]
    ++  owner-2  ^-  account
      [0xdead 0 0x1234.5678]
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
++  test-give  ^-  tang
  ::  from 1 to 2
  =/  =embryo
    :+  owner-1
      `[%give 0xdead]
    (malt ~[[id:`grain`nft-1 nft-1]])
  =/  =cart
    [`@ux`'nft' init-now 0x1 (malt ~[[id:`grain`nft-1 nft-1]])]
  =/  updated  ^-  grain
    :*  `@ux`'nft-1'
        `@ux`'nft'
        0xdead
        0x1
        [%& `@`'salt' item-1]
    ==
  =/  res=chick
    (~(write cont cart) embryo)
   =/  correct=chick
    [%& (malt ~[[id.updated updated]]) ~ ~]
  (expect-eq !>(correct) !>(res))
::
++  test-give-doesnt-have  ^-  tang
  ::  give 1 to 2 with account 3
  =/  =embryo
    :+  owner-3
      `[%give 0xdead]
    (malt ~[[id:`grain`nft-1 nft-1]])
  =/  =cart
    [`@ux`'nft' init-now 0x1 (malt ~[[id:`grain`nft-1 nft-1]])]
  =/  updated  ^-  grain
    :*  `@ux`'nft-1'
        `@ux`'nft'
        0xdead
        0x1
        [%& `@`'salt' item-1]
    ==
  =/  res=(each * (list tank))
    (mule |.((~(write cont cart) embryo)))
  (expect-eq !>(%.n) !>(-.res))
::
::  tests for %set-allowance
::
++  set-allowance  ~
::
++  revoke-allowance  ~
::
::  tests for %take
::
++  take  ~
::
++  take-not-approved  ~
::
::  tests for %mint
::

::
::  tests for %deploy
::
--