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
    ++  nft-wheat-id    `@ux`'nft'
    ++  nft-symbol  'SNFT'
    ++  caller-id  0xbeef
    ++  salt  (sham (cat 3 caller-id nft-symbol))
    ++  collection-id  (fry-rice nft-wheat-id nft-wheat-id 0x1 salt)
    ++  collection-metadata
      |=  sup=@ud
      ^-  grain
      :*  collection-id
          nft-wheat-id
          nft-wheat-id
          town-id=0x1
          :+  %&  salt
          ^-  collection
          :*  name='Simple NFT'
              symbol=nft-symbol
              supply=sup
              cap=3
              minters=(silt ~[0xbeef])
              deployer=caller-id
      ==  ==
    ::
    ++  item-1  ^-  item
      [id:(collection-metadata 0) 1 (malt ~[['hair' 'red'] ['eyes' 'blue'] ['mouth' 'smile']]) 'a smiling face' 'ipfs://fake1' %.y]
    ++  item-2  ^-  item
      [id:(collection-metadata 0) 2 (malt ~[['hair' 'brown'] ['eyes' 'green'] ['mouth' 'frown']]) 'a frowny face' 'ipfs://fake2' %.y]
    ++  item-3  ^-  item
      [id:(collection-metadata 0) 3 (malt ~[['hair' 'grey'] ['eyes' 'black'] ['mouth' 'squiggle']]) 'a weird face' 'ipfs://fake3' %.n]
    ::
    ++  generate-item-grain
      |=  [item-id=@ud =item holder=id]
      ^-  [=id =grain]
      =/  salt  (sham (cat 3 item-id collection-id))
      =/  rice-id=id  (fry-rice nft-wheat-id caller-id 0x1 salt)
      [rice-id [rice-id nft-wheat-id holder 0x1 [%& salt item]]]
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
  =/  =cart  [nft-wheat-id init-now 0x1 ~]
  =/  =embryo  [caller-id `[%deploy 'Simple NFT' nft-symbol 3 (silt ~[caller-id])] ~]
  =/  res  (~(write cont cart) embryo)

  =/  =crow  [%deployed (numb:enjs:format collection-id)]^~
  =/  correct=chick  [%& ~ (malt ~[[collection-id (collection-metadata 0)]]) crow]
  
  (expect-eq !>(correct) !>(res))
++  test-mint-works
  ^-  tang
  =/  =cart  [nft-wheat-id init-now 0x1 (malt ~[[collection-id (collection-metadata 0)]])]
  =/  =embryo  :+  caller-id
                 `[%mint ~[+>:item-1 +>:item-2 +>:item-3]]
               (malt ~[[collection-id (collection-metadata 0)]])
  =/  res  (~(write cont cart) embryo)
 
  =/  new-issued  (malt (turn ~[[1 item-1 caller-id] [2 item-2 caller-id] [3 item-3 caller-id]] generate-item-grain))
  =/  minted-ids  (turn ~(tap in ~(key by new-issued)) numb:enjs:format)
  =/  =crow       [%minted a+minted-ids]~
  =/  correct=chick  [%& (malt ~[[collection-id (collection-metadata 3)]]) new-issued crow]
  
  (expect-eq !>(correct) !>(res))
++  test-give-works
  ^-  tang
  =/  nft  (generate-item-grain 1 item-1 caller-id)
  =/  =cart  [nft-wheat-id init-now 0x1 (malt ~[[nft]])]
  =/  =embryo  [caller-id `[%give 0xdead] ~]
  =/  res  (~(write cont cart) embryo)
  =/  =crow   [%gave o+(malt ~[['nft' (numb:enjs:format -.nft)] ['from' (numb:enjs:format caller-id)] ['to' (numb:enjs:format 0xdead)]])]~
  =/  new-item  (generate-item-grain 1 item-1 0xdead)
  =/  correct=chick  [%& (malt ~[[-.nft +.new-item]]) ~ crow]
  
  (expect-eq !>(correct) !>(res))
--