::  publish.hoon  [UQ| DAO]
::
::  Smart contract that processes deployment and upgrades
::  for other smart contracts. Automatically (?) inserted
::  on any town that wishes to allow contract production.
::
::  /+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(arguments u.args.inp) (pin caller.inp))
  ::
  +$  arguments
    $%  ::  add kelvin versioning to contracts?
        [%deploy mutable=? cont=[bat=* pay=*] owns=(list rice)]
        [%upgrade to-upgrade=id new-nok=[bat=* pay=*]]  ::  not yet real
    ==
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
        %deploy
      ::  0x0 denotes immutable contract
      =/  lord=id  ?.(mutable.args 0x0 me.cart)
      =+  our-id=(fry-contract lord town-id.cart bat.cont.args)
      ::  generate grains out of new rice we spawn
      =/  produced=(map id grain)
        %-  ~(gas by *(map id grain))
        %+  turn  owns.args
        |=  =rice
        ^-  [id grain]
        =+  (fry-rice our-id our-id town-id.cart salt.rice)
        [- [- our-id our-id town-id.cart [%& rice]]]
      ::
      =/  our-grain=grain
        [our-id lord caller-id town-id.cart [%| `cont.args ~(key by produced)]]
      [%& ~ (~(put by produced) our-id our-grain) ~]
    ::
        %upgrade
      ::  expect wheat of contract-to-upgrade in owns.cart
      ::  caller must be holder
      =/  contract  (~(got by owns.cart) to-upgrade.args)
      ?>  ?&  =(holder.contract caller-id)
              ?=(%| -.germ.contract)
          ==
      =.  cont.p.germ.contract  `new-nok.args
      [%& (malt ~[[id.contract contract]]) ~ ~]
    ==
  --
::
++  read
  |_  =path
  ++  json
    ~
  ++  noun
    ~
  --
--
