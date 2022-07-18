::  publish.hoon  [UQ| DAO]
::
::  Smart contract that processes deployment and upgrades
::  for other smart contracts. Automatically (?) inserted
::  on any town that wishes to allow contract production.
::
::  /+  *zig-sys-smart
/=  pub  /lib/zig/contracts/lib/publish
=,  pub
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  =/  act  ;;(action action.inp)
  ?-    -.act
      %deploy
    ::  0x0 denotes immutable contract
    =/  lord=id  ?.(mutable.act 0x0 me.cart)
    =+  our-id=(fry-contract lord town-id.cart `cont.act)
    ::  generate grains out of new rice we spawn
    =/  produced=(map id grain)
      %-  ~(gas by *(map id grain))
      %+  turn  owns.act
      |=  =rice
      ^-  [id grain]
      =+  (fry-rice our-id our-id town-id.cart salt.rice)
      [- [- our-id our-id town-id.cart [%& rice]]]
    ::
    =/  =wheat  [`cont.act ~(key by produced)]
    =/  =grain  [our-id lord id.from.cart town-id.cart [%| wheat]]
    [%& ~ produced ~ ~]
  ::
      %upgrade
    ::  expect wheat of contract-to-upgrade in owns.cart
    ::  caller must be holder
    =/  contract  (~(got by owns.cart) to-upgrade.act)
    ?>  ?&  =(holder.contract id.from.cart)
            ?=(%| -.germ.contract)
        ==
    =.  cont.p.germ.contract  `new-nok.act
    (result [contract ~] ~ ~ ~)
  ==
::
++  read
  |_  =path
  ++  json
    ~
  ++  noun
    ~
  --
--
