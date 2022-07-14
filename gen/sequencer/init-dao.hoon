/-  *ziggurat,
    d=dao
/+  deploy=zig-deploy,
    smart=zig-sys-smart
/*  zigs-contract  %noun  /lib/zig/compiled/zigs/noun
/*  dao-contract  %noun  /lib/zig/compiled/dao/noun
=/  pubkey-1  0x3.e87b.0cbb.431d.0e8a.2ee2.ac42.d9da.cab8.063d.6bb6.2ff9.b2aa.e1b9.0f56.9c3f.3423
=/  pubkey-2  0x2.eaea.cffd.2bbe.e0c0.02dd.b5f8.dd04.e63f.297f.14cf.d809.b616.2137.126c.da9e.8d3d
=/  pubkey-3  0x2.4a1c.4643.b429.dc12.6f3b.03f3.f519.aebb.5439.08d3.e0bf.8fc3.cb52.b92c.9802.636e
=>
  |%
  ::
  ++  make-dao-self
    |=  [name=@tas dao-id=id:smart our-id=id:smart our=ship]
    ^-  dao:d
    |^
    =|  =dao:d
    =:  name.dao         name
        permissions.dao  (make-permissions dao-id)
        members.dao      make-members
        id-to-ship.dao   (make-id-to-ship our-id our)
        ship-to-id.dao   (make-ship-to-id our-id our)
    ==
    dao
    ::
    ++  make-permissions
      |=  dao-id=id:smart
      ^-  permissions:d
      %-  %~  gas  by  *permissions:d
          :~  :-  name=%host
            %-  %~  gas  ju  *(jug address:d role:d)
            :-  [dao-id %comms-host]
            ~
      ::
          :-  name=%write
          %-  %~  gas  ju  *(jug address:d role:d)
          :~  [dao-id %owner]
              [[~zod %dao-chat] %owner]
              [[~zod %dao-chat] %pleb]
              [[~zod %dao-links] %owner]
          ==
      ::
          :-  name=%read
          %-  %~  gas  ju  *(jug address:d role:d)
          :~  [[~zod %dao-chat] %owner]
              [[~zod %dao-chat] %pleb]
              [[~zod %dao-links] %owner]
              [[~zod %dao-links] %pleb]
              [[~nec %dao-chat] %owner]
              [[~nec %dao-chat] %pleb]
              [[~nec %dao-links] %owner]
              [[~nec %dao-links] %pleb]
          ==
      ::
      ==
    ::
    ++  make-members
      ^-  members:d
      %-  %~  gas  ju  *members:d
      :~  [pubkey-1 %owner]
          [pubkey-1 %comms-host]
          [pubkey-2 %pleb]
          [pubkey-3 %pleb]
      ==
    ::
    ++  make-id-to-ship
      |=  [our-id=id:smart our=ship]
      ^-  id-to-ship:d
      %-  %~  gas  by  *id-to-ship:d
      :^    [pubkey-1 ~zod]
          [pubkey-2 ~nec]
        [pubkey-3 ~bus]
      ~
    ::
    ++  make-ship-to-id
      |=  [our-id=id:smart our=ship]
      ^-  ship-to-id:d
      %-  %~  gas  by  *ship-to-id:d
      :^    [~zod pubkey-1]
          [~nec pubkey-2]
        [~bus pubkey-3]
      ~
    ::
    --
  ::
  --
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [town-id=@ud ~] ~]
=/  dao-contract-id=id:smart  `@ux`'dao'
=/  dao-salt=@  `@`'uqbar-dao'
=/  uqbar-dao-id=id:smart
  %:  fry-rice:smart
      dao-contract-id
      dao-contract-id
      town-id
      dao-salt
  ==
~&  >  "uqbar-dao-id: {<uqbar-dao-id>}"
=*  our  p.bek
=/  uqbar-dao=dao:d
  (make-dao-self 'Uqbar DAO' uqbar-dao-id pubkey-1 our)
=/  uqbar-dao-grain  ::  ~zod
  ^-  grain:smart
  :*  uqbar-dao-id
      dao-contract-id
      dao-contract-id
      town-id
      [%& dao-salt uqbar-dao]
  ==
::  store only contract code, insert into shared subject
=/  dao-contract-wheat
  ^-  wheat:smart
  :: =/  cont  (of-wain:format dao-contract)
  :: :-  `(~(text-deploy deploy p.bek now) cont)
  =/  =wheat:smart  ;;(wheat:smart (cue q.q.dao-contract))
  wheat(owns (silt ~[uqbar-dao-id]))
=/  dao-contract-grain
  ^-  grain:smart
  :*  dao-contract-id          ::  id
      dao-contract-id          ::  lord
      dao-contract-id          ::  holder
      town-id                  ::  town-id
      [%| dao-contract-wheat]  ::  germ
  ==
::
=/  zigs-1  (fry-rice:smart zigs-wheat-id:smart pubkey-1 town-id `@`'zigs')
=/  zigs-2  (fry-rice:smart zigs-wheat-id:smart pubkey-2 town-id `@`'zigs')
=/  zigs-3  (fry-rice:smart zigs-wheat-id:smart pubkey-3 town-id `@`'zigs')
=/  beef-zigs-grain  ::  ~zod
  ^-  grain:smart
  :*  zigs-1
      zigs-wheat-id:smart
      ::  associated seed: 0xbeef
      pubkey-1
      town-id
      [%& `@`'zigs' [10.321.055.000.000.000.000 ~ `@ux`'zigs-metadata']]
  ==
=/  dead-zigs-grain  ::  ~bus
  ^-  grain:smart
  :*  zigs-2
      zigs-wheat-id:smart
      ::  associated seed: 0xdead
      pubkey-2
      town-id
      [%& `@`'zigs' [50.000.000.000.000.000.000 ~ `@ux`'zigs-metadata']]
  ==
=/  cafe-zigs-grain  ::  ~nec
  ^-  grain:smart
  :*  zigs-3
      zigs-wheat-id:smart
      ::  associated seed: 0xcafe
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
      :*  name='Uqbar Tokens'
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
::  store only contract code, insert into shared subject
=/  zigs-wheat
  ^-  wheat:smart
  =/  =wheat:smart  ;;(wheat:smart (cue q.q.zigs-contract))
  wheat(owns (silt ~[zigs-1 zigs-2 zigs-3 `@ux`'zigs-metadata']))
=/  zigs-wheat-grain
  ^-  grain:smart
  :*  zigs-wheat-id:smart  ::  id
      zigs-wheat-id:smart  ::  lord
      zigs-wheat-id:smart  ::  holder
      town-id              ::  town-id
      [%| zigs-wheat]      ::  germ
  ==
=/  fake-granary
  ^-  granary:smart
  =/  grains=(list:smart (pair:smart id:smart grain:smart))
    :~  [id.zigs-wheat-grain zigs-wheat-grain]
        [id.zigs-metadata-grain zigs-metadata-grain]
        [zigs-1 beef-zigs-grain]
        [zigs-2 dead-zigs-grain]
        [zigs-3 cafe-zigs-grain]
        [dao-contract-id dao-contract-grain]
        [uqbar-dao-id uqbar-dao-grain]
    ==
  (~(gas by:smart *(map:smart id:smart grain:smart)) grains)
=/  fake-populace
  ^-  populace:smart
  %-  %~  gas  by:smart  *(map:smart id:smart @ud)
  ~[[pubkey-1 0] [pubkey-2 0] [pubkey-3 0]]
:-  %zig-hall-poke
^-  hall-poke
:*  %init
    town-id
    `[fake-granary fake-populace]
    [rate=1 bud=10.000]
==
