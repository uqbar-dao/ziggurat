/-  *sequencer
/+  smart=zig-sys-smart, ethereum
/*  zigs-contract     %noun  /lib/zig/compiled/zigs-parallel/noun
/*  nft-contract      %noun  /lib/zig/compiled/nft/noun
/*  publish-contract  %noun  /lib/zig/compiled/publish/noun
/*  trivial-contract  %noun  /lib/zig/compiled/trivial/noun
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [rollup-host=@p town-id=@ux private-key=@ux ~] ~]
=/  pubkey-1  0x7772.b8a7.6840.8922.2903.5b28.7494.436f.8850.713c
=/  pubkey-2  0xc7ec.a38c.5c74.d58d.04b0.6650.4772.f3a6.d02e.92f5
=/  pubkey-3  0x435a.11af.b1f8.24b8.a1d7.de8a.c8c1.cce1.363c.6f3b
=/  zigs-1  (fry-rice:smart pubkey-1 zigs-wheat-id:smart town-id `@`'zigs')
=/  zigs-2  (fry-rice:smart pubkey-2 zigs-wheat-id:smart town-id `@`'zigs')
=/  zigs-3  (fry-rice:smart pubkey-3 zigs-wheat-id:smart town-id `@`'zigs')
=/  beef-zigs-grain
  ^-  grain:smart
  :*  zigs-1
      zigs-wheat-id:smart
      pubkey-1
      town-id
      [%& `@`'zigs' [10.321.055.000.000.000.000 ~ `@ux`'zigs-metadata']]
  ==
=/  dead-zigs-grain
  ^-  grain:smart
  :*  zigs-2
      zigs-wheat-id:smart
      pubkey-2
      town-id
      [%& `@`'zigs' [50.000.000.000.000.000.000 ~ `@ux`'zigs-metadata']]
  ==
=/  cafe-zigs-grain
  ^-  grain:smart
  :*  zigs-3
      zigs-wheat-id:smart
      pubkey-3
      town-id
      [%& `@`'zigs' [50.000.000.000.000.000.000 ~ `@ux`'zigs-metadata']]
  ==
=/  zigs-metadata-grain
  ^-  grain:smart
  :*  `@ux`'zigs-metadata'
      zigs-wheat-id:smart
      zigs-wheat-id:smart
      town-id
      :+  %&  `@`'zigs'
      :*  name='UQ| Tokens'
          symbol='ZIG'
          decimals=18
          supply=1.000.000.000.000.000.000.000.000
          cap=~
          mintable=%.n
          minters=~
          deployer=0x0
          salt=`@`'zigs'
      ==
  ==
=/  zigs-wheat-grain
  ^-  grain:smart
  =/  =wheat:smart  ;;(wheat:smart (cue q.q.zigs-contract))
  :*  zigs-wheat-id:smart  ::  id
      zigs-wheat-id:smart  ::  lord
      zigs-wheat-id:smart  ::  holder
      town-id              ::  town-id
      [%| wheat(owns (silt ~[zigs-1 zigs-2 zigs-3 `@ux`'zigs-metadata']))]
  ==
::  publish.hoon contract
=/  publish-grain
  ^-  grain:smart
  :*  0x1111.1111     ::  id
      0x1111.1111     ::  lord
      0x1111.1111     ::  holder
      town-id         ::  town-id
      [%| ;;(wheat:smart (cue q.q.publish-contract))]  ::  germ
  ==
::  ::  trivial.hoon contract
=/  trivial-grain
  ^-  grain:smart
  :*  0xdada.dada     ::  id
      0xdada.dada     ::  lord
      0xdada.dada     ::  holder
      town-id         ::  town-id
      [%| ;;(wheat:smart (cue q.q.trivial-contract))]  ::  germ
  ==
::
::  NFT stuff
=/  nft-metadata-grain
  ^-  grain:smart
  :*  `@ux`'nft-metadata'
      0xcafe.babe
      0xcafe.babe
      town-id
      :+  %&  `@`'nftsalt'
      :*  name='Monkey JPEGs'
          symbol='BADART'
          attributes=(silt ~['hair' 'eyes' 'mouth'])
          supply=1
          cap=~
          mintable=%.n
          minters=~
          deployer=0x0
          salt=`@`'nftsalt'
  ==  ==
=/  item-1
  [1 (silt ~[['hair' 'red'] ['eyes' 'blue'] ['mouth' 'smile']]) 'a smiling monkey' 'ipfs://QmUbFVTm113tJEuJ4hZY2Hush4Urzx7PBVmQGjv1dXdSV9' %.y]
=/  nft-acc-id  (fry-rice:smart pubkey-1 0xcafe.babe town-id `@`'nftsalt')
=/  nft-acc-grain
  :*  nft-acc-id
      0xcafe.babe
      pubkey-1
      town-id
      [%& `@`'nftsalt' [`@ux`'nft-metadata' (malt ~[[1 item-1]]) ~ ~]]
  ==
=/  nft-wheat-grain
  ^-  grain:smart
  =/  =wheat:smart  ;;(wheat:smart (cue q.q.nft-contract))
  :*  0xcafe.babe     ::  id
      0xcafe.babe     ::  lord
      0xcafe.babe     ::  holder
      town-id         ::  town-id
      [%| wheat(owns (silt ~[`@ux`'nft-metadata' nft-acc-id]))]  ::  germ
  ==
::
=/  fake-granary
  ^-  granary
  =/  grains=(list:smart (pair:smart id:smart grain:smart))
    :~  [id.zigs-wheat-grain zigs-wheat-grain]
        [id.zigs-metadata-grain zigs-metadata-grain]
        :: [id.nft-wheat-grain nft-wheat-grain]
        :: [id.nft-metadata-grain nft-metadata-grain]
        :: [id.publish-grain publish-grain]
        :: [id.trivial-grain trivial-grain]
        [zigs-1 beef-zigs-grain]
        [zigs-2 dead-zigs-grain]
        [zigs-3 cafe-zigs-grain]
        :: [nft-acc-id nft-acc-grain]
    ==
  (~(gas by:smart *(map:smart id:smart grain:smart)) grains)
=/  fake-populace
  ^-  populace
  %-  %~  gas  by:smart  *(map:smart id:smart @ud)
  ~[[pubkey-1 0] [pubkey-2 0] [pubkey-3 0]]
::
=/  =address:smart  (address-from-prv:key:ethereum private-key)
::
:-  %sequencer-town-action
^-  town-action
:*  %init
    rollup-host
    address
    private-key
    town-id
    `[fake-granary fake-populace]
    [%full-publish ~]
==
