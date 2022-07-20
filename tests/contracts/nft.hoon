::  Tests for nft.hoon (non-fungible token contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/+  *test, cont=zig-contracts-nft, *zig-sys-smart
/=  lib  /lib/zig/contracts/lib/nft
=,  lib
=>  ::  test data
    |%
    ++  init-now  *@da
    ++  metadata-1  ^-  grain
      :*  `@ux`'simple'
          `@ux`'nft'
          `@ux`'holder'
          town-id=0x1
          :+  %&  `@`'salt'
          ::
          ^-  collection-metadata:sur
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
    ++  item-1  ^-  item:sur
      [id:metadata-1 1 ~ (silt ~[['hair' 'red'] ['eyes' 'blue'] ['mouth' 'smile']]) 'a smiling face' 'ipfs://fake1' %.y]
    ++  item-2  ^-  item:sur
      [id:metadata-1 2 ~ (silt ~[['hair' 'brown'] ['eyes' 'green'] ['mouth' 'frown']]) 'a frowny face' 'ipfs://fake2' %.y]
    ++  item-3  ^-  item:sur
      [id:metadata-1 3 ~ (silt ~[['hair' 'grey'] ['eyes' 'black'] ['mouth' 'squiggle']]) 'a weird face' 'ipfs://fake3' %.n]
    ::
    ++  nft-1  ^-  grain
      :*  0x4e17.990a.dea4.06c4.2c09.af3c.7a3b.f3e5
          `@ux`'nft'
          0xbeef
          town-id=0x1
          :+  %&  `@`0x296e.44d8.f5ff.9bcf.8ecf.8343.34fa.2e0b  item-1
      ==
    ++  nft-2  ^-  grain
      :*  0x4e17.990a.dea4.06c4.e661.24fe.e7b5.3871
          `@ux`'nft'
          0xdead
          town-id=0x1
          :+  %&  `@`0x291f.e256.8e04.04ca.e98d.bb20.1e0c.1e3c  item-2
      ==
    ++  nft-3  ^-  grain
      :*  0x4e17.990a.dea4.06c4.b298.eda7.4ba4.7ccb
          `@ux`'nft'
          0xcafe
          town-id=0x1
          :+  %&  `@`0x1545.3107.06de.ed82.e98f.3057.cd0a.6a8b  item-3
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
++  test-set-allowance  ~
::
++  test-revoke-allowance  ~
::
::  tests for %take
::
++  test-take  ~
::
++  test-take-not-approved  ~
::
::  tests for %mint
::

::
::  tests for %deploy
::
++  test-deploy
  ^-  tang
  =/  distribution
    %-  ~(gas ju *(jug id item-contents:sur))
    :~  [0xbeef +>+:item-1]
        [0xdead +>+:item-2]
        [0xcafe +>+:item-3]
    ==
  =/  =embryo
    :*  owner-1
        %-  some
        :*  %deploy 
            distribution
            minters=~
            name='Simple NFT'
            symbol='SNFT'
            attributes=(silt ~['hair' 'eyes' 'mouth'])
            cap=3
            mintable=%.n
        ==
        ::
        grains=~
    ==
  =/  cart       [`@ux`'nft' init-now 0x1 ~]
  =/  res=chick  (~(write cont cart) embryo)
  ?>  ?=(%& -.germ.p.res)
  =/  correct-issued
    %-  malt
    :~  [id:metadata-1 metadata-1]
        [id:nft-1 nft-1]
        [id:nft-2 nft-2]
        [id:nft-3 nft-3]
    ==
  ::
  =/  issued-equal
    =/  still-equal  %.y
    =/  vals  ~(val by issued.res)
    |-
    ?:  
  =/  correct=chick
    :*  %& 
        changed=~
        correct-issued
        ::
        crow=~
    ==
  (expect-eq !>(correct) !>(res))

::
::  read
::
++  test-read-collection-metadata
  =/  =path  /rice-data
  =/  =cart
    [`@ux`'nft' init-now 0x1 (malt ~[[id:`grain`metadata-1 metadata-1]])]
  =/  meme  ~(json ~(read cont cart) path)
  ~&  >>  meme
  ~
++  test-read-item-metadata
  =/  =path  /rice-data
  =/  =cart
    [`@ux`'nft' init-now 0x1 (malt ~[[id:`grain`nft-1 nft-1]])]
  =/  meme  ~(json ~(read cont cart) path)
  ~&  >>  meme
  ~
++  test-read-arguments
  =/  =path  [%egg-args %give ~]
  =/  =cart
    [`@ux`'nft' init-now 0x1 (malt ~[[id:`grain`nft-1 nft-1]])]
  =/  meme  ~(json ~(read cont cart) path)
  ~&  >>  meme
  ~
++  test-read-item-metadata-atom
  =/  meme  (numb:enjs:format (jam nft-1))
  =/  meme-2  p.+.meme

  :: =/  =path  [%rice-data meme-2 ~]
  ~&  >>  meme-2  
  :: ~&  >>  i.-.+.path

  :: TODO: how do you jam an atom to a ta? e.g. 123.123 to '123.123' instead of whatever retardation is default
  :: =/  asdf  (slav %ta meme-2)
  :: ~&  >>  meme
  :: =/  =cart
  ::   [`@ux`'nft' init-now 0x1 (malt ~[[id:`grain`nft-1 nft-1]])]
  :: =/  meme  ~(json ~(read cont cart) path)
  :: ~&  >>  meme
  ~
--