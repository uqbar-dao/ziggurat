::
::  Tests for lib/zig/mill.hoon
::  Basic goal: construct a simple granary / helix state
::  and manipulate it with some calls to our zigs contract.
::  Mill should handle clearing a mempool populated by
::  calls and return an updated granary. The zigs contract
::  should manage transactions properly so this is testing
::  the arms of that contract as well.
::
/+  *test, *zig-mill, tiny, *zig-contracts-zigs
/=  zigs-contract  /lib/zig/contracts/zigs
/=  tgas-contract  /lib/zig/contracts/test-good-altcoin
|%
++  zigs
  |%
  ++  user-balances
    ^-  (map:tiny id:tiny @ud)
    %-  ~(gas by:tiny *(map:tiny id:tiny @ud))
    :~  [0xaa 1.000]
        [0xbb 1.000]
        [0xcc 500]
        [0xdd 500]
        [0xee 490]
        [0xff 10]
    ==
  ++  user-allowances
    ^-  (map:tiny [owner=id:tiny sender=id:tiny] @ud)
    %-
      %~  gas  by:tiny
      *(map:tiny [owner=id:tiny sender=id:tiny] @ud)
    :~  [[0xaa 0xbb] 100]
        [[0xee 0xff] 100]
    ==
  ++  rice-data
    :*  total=3.500
        balances=user-balances
        allowances=user-allowances
        coinbase-rate=50  ::  # of tokens granted in +coinbase
    ==
  ++  rice
    ^-  rice:tiny
    :+  zigs-rice-id:tiny   ::  holder
      ~                     ::  holds
    rice-data               ::  data
  ++  rice-grain
    ^-  grain:tiny
    :*  zigs-rice-id:tiny   ::  id
        zigs-rice-id:tiny   ::  lord
        0                   ::  town-id
        [%& rice]           ::  germ
    ==
  ++  wheat
    ^-  wheat:tiny
    `zigs-contract
  ++  wheat-grain
    ^-  grain:tiny
    :*  zigs-wheat-id:tiny  ::  id
        zigs-wheat-id:tiny  ::  lord
        0                   ::  town-id
        [%| wheat]          ::  germ
    ==
  ++  fake-land
    ^-  land:tiny
    (~(gas by:tiny *(map:tiny @ud town:tiny)) ~[[0 fake-town]])
  ++  fake-town
    ^-  town:tiny
    [fake-granary fake-populace]
  ++  fake-granary
    ^-  granary:tiny
    =/  grains=(list:tiny (pair:tiny id:tiny grain:tiny))
      :~  [zigs-wheat-id:tiny wheat-grain]
          [zigs-rice-id:tiny rice-grain]
      ==
    (~(gas by:tiny *(map:tiny id:tiny grain:tiny)) grains)
  ++  fake-populace
    ^-  populace:tiny
    %-  %~  gas  by:tiny  *(map:tiny id:tiny @ud)
    ~[[0xaa 0] [0xbb 0] [0xcc 0]]
  --
++  tgas
  |%
  ++  user-balances
    ^-  (map:tiny id:tiny @ud)
    %-  ~(gas by:tiny *(map:tiny id:tiny @ud))
    :~  [0xaa 1.000]
        [0xbb 1.000]
        [0xcc 500]
        [0xdd 500]
        [0xee 490]
        [0xff 10]
    ==
  ++  user-allowances
    ^-  (map:tiny [owner=id:tiny sender=id:tiny] @ud)
    %-
      %~  gas  by:tiny
      *(map:tiny [owner=id:tiny sender=id:tiny] @ud)
    :~  [[0xaa 0xbb] 100]
        [[0xee 0xff] 100]
    ==
  ++  rice-data
    :*  total=3.500
        balances=user-balances
        allowances=user-allowances
        coinbase-rate=50  ::  # of tokens granted in +coinbase
    ==
  ++  rice
    ^-  rice:tiny
    :+  zigs-rice-id:tiny   ::  holder
      ~                     ::  holds
    rice-data               ::  data
  ++  rice-grain
    ^-  grain:tiny
    :*  tgas-rice-id        ::  id
        tgas-rice-id        ::  lord
        0                   ::  town-id
        [%& rice]           ::  germ
    ==
  ++  wheat
    ^-  wheat:tiny
    `tgas-contract
  ++  wheat-grain
    ^-  grain:tiny
    :*  tgas-wheat-id       ::  id
        tgas-wheat-id       ::  lord
        0                   ::  town-id
        [%| wheat]          ::  germ
    ==
  ++  fake-land
    ^-  land:tiny
    (~(gas by:tiny *(map:tiny @ud town:tiny)) ~[[0 fake-town]])
  ++  fake-town
    ^-  town:tiny
    [fake-granary fake-populace]
  ++  fake-granary
    ^-  granary:tiny
    =/  grains=(list:tiny (pair:tiny id:tiny grain:tiny))
      :~  [zigs-wheat-id:tiny wheat-grain:zigs]
          [zigs-rice-id:tiny rice-grain:zigs]
          [tgas-wheat-id wheat-grain]
          [tgas-rice-id rice-grain]
      ==
    (~(gas by:tiny *(map:tiny id:tiny grain:tiny)) grains)
  ++  fake-populace
    ^-  populace:tiny
    %-  %~  gas  by:tiny  *(map:tiny id:tiny @ud)
    ~[[0xaa 0] [0xbb 0] [0xcc 0]]
  ++  tgas-wheat-id
    ^-  id:tiny
    0x2
  ++  tgas-rice-id
    ^-  id:tiny
    0x3
  --
++  test-zigs-basic-give
  =/  write
     :*  %write
         [0xaa 1]
         %-  %~  gas  in:tiny  *(set:tiny id:tiny)
         ~[zigs-rice-id:tiny]
         [~ [%give 0xbb 200 500]]
     ==
  =/  call
    [[0xaa 1] zigs-wheat-id:tiny rate=1 budget=500 town-id=0 write]
  =/  res=town:tiny
    (mill 0 fake-town:zigs call)
  ::  what's the best way to create a correct updated granary to check against?
  ::  also need to calculate exact fee to get proper outcome
  (expect-eq !>(~) !>(res))
++  test-zigs-failed-give
  =/  write
     :*  %write
         [0xaa 1]
         %-  %~  gas  in:tiny  *(set:tiny id:tiny)
         ~[zigs-rice-id:tiny]
         [~ [%give 0xbb 2.000 500]]
     ==
  =/  call
    [[0xaa 1] zigs-wheat-id rate=1 budget=500 town-id=0 write]
  =/  res=town:tiny
    (mill 0 fake-town:zigs call)
  ::  updated granary should be same but minus 0xaa's fee
  (expect-eq !>(~) !>(res))
++  test-mill-tgas-basic-give
  =/  write
     :*  %write
         [0xaa 1]
         %-  %~  gas  in:tiny  *(set:tiny id:tiny)
         ~[tgas-rice-id:tgas]
         [~ [%give 0xbb 200 500]]
     ==
  =/  call
    [[0xaa 1] tgas-wheat-id:tgas rate=1 budget=500 town-id=0 write]
  =/  res=town:tiny
    (mill 0 fake-town:tgas call)
  ::  what's the best way to create a correct updated granary to check against?
  ::  also need to calculate exact fee to get proper outcome
  (expect-eq !>(~) !>(res))
::
::  Tests here should cover:
::  (all calls to exclusively zigs-contract)
::
::  * executing a single call with +mill
::  * executing same call unsuccessfully -- not enough gas
::  * unsuccessfully -- some constraint in contract unfulfilled
::  * (test all constraints in contract: balance, gas, +give, etc)
::  * executing multiple calls with +mill-all
::
::  Tests for contracts on mill in general
::  (probably good in a separate file / test suite)
::  These will be more involved, requiring custom contracts w
::
::  * test deploying a contract (successful / unsuccessful du
::  * bad: call a contract that issues rice as wheat, vice ve
::  * rule breaking: call contracts that break their lord per
::    (aka: writing to rice that they don't own, cheating)
::  * good: call contract that reads things from other contra
::
--
