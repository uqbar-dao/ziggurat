::  Tests for nft.hoon (non-fungible token contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/+  *test, cont=zig-contracts-nft-slim, *zig-sys-smart
/=  nft  /lib/zig/contracts/lib/nft-slim
=,  nft
=>  ::  test data
    |%
    ++  init-now  *@da
    ++  nft-id    `@ux`'nft'
    ++  collection-1  ^-  grain
      :*  `@ux`'simple'
          nft-id
          0xabcd.abcd
          town-id=0x1
          :+  %&  `@`'salt'
          ^-  collection-metadata
          :*  name='Simple NFT'
              symbol='SNFT'
              supply=3
              cap=3
              minters=(silt ~[0xabcd.abcd])
              deployer=0xabcd.abcd
      ==  ==
    ::
    ++  item-1  ^-  item
      [id:collection-1 1 (malt ~[['hair' 'red'] ['eyes' 'blue'] ['mouth' 'smile']]) 'a smiling face' 'ipfs://fake1' %.y]
    ++  item-2  ^-  item
      [id:collection-1 2 (malt ~[['hair' 'brown'] ['eyes' 'green'] ['mouth' 'frown']]) 'a frowny face' 'ipfs://fake2' %.y]
    ++  item-3  ^-  item
      [id:collection-1 3 (malt ~[['hair' 'grey'] ['eyes' 'black'] ['mouth' 'squiggle']]) 'a weird face' 'ipfs://fake3' %.n]
    ::
    ++  owner-1  ^-  account
      [0xbeef 0 0x1234.5678]
    ++  owner-2  ^-  account
      [0xdead 0 0x1234.5678]
    ++  owner-3  ^-  account
      [0xcafe 0 0x1234.5678]
    --
::  testing arms
|%
++  test-matches-type
  ^-  tang
  =/  valid  (mule |.(;;(contract cont)))
  (expect-eq !>(%.y) !>(-.valid))
::
++  test-deploy-works
  ^-  tang
  ~
++  test-mint-works
  ^-  tang
  ~
++  test-give-works
  ^-  tang
  ~
--