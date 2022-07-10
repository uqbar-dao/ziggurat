::  zigs.hoon [UQ| DAO]
::
::  Contract for 'zigs' (official name TBD) token, the gas-payment
::  token for the UQ| network.
::  This token is unique from those defined by the token standard
::  because %give must include their gas budget, in order for
::  zig spends to be guaranteed not to underflow.
::
/+  *zig-sys-smart
/=  sur  /lib/zig/contracts/lib/zigs-parallel
=,  sur
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  ?~  action.inp  !!
  =/  act  ;;(action u.action.inp)
  ?-    -.act
      %give
    =/  giv=grain  +.-:grains.inp
    ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
    =/  giver=account  ;;(account data.p.germ.giv)
    ?>  (gth balance.giver (add amount.act budget.act))
    ::  produce a redeemable ticket
    =/  =ticket    [amount.act %.n metadata.giver]
    =/  salt=@ux   (shax (cat 3 salt.p.germ.giv (cat 3 from.cart)))
    =/  =id        (fry-rice to.act me.cart town-id.cart -)
    =/  new=grain  [id me.cart to.act town-id.cart [%& salt ticket]]
    ::  modify sending account
    =.  data.p.germ.giv  giver(balance (sub balance.giver amount.act))
    (result ~[giv] ~[new] ~ ~)
  ::
      %take
    =/  giv=grain  (~(got by owns.cart) from-account.act)
    ?>  ?=(%& -.germ.giv)
    =/  giver=account  ;;(account data.p.germ.giv)
    =/  allowance=@ud  (~(got by allowances.giver) id.from.cart)
    ?>  (gte balance.giver amount.act)
    ?>  (gte allowance amount.act)
    ::  produce a redeemable ticket
    =/  =ticket    [amount.act %.n metadata.giver]
    =/  salt=@ux   (shax (cat 3 salt.p.germ.giv (cat 3 from.cart)))
    =/  =id        (fry-rice to.act me.cart town-id.cart -)
    =/  new=grain  [id me.cart to.act town-id.cart [%& salt ticket]]
    ::  modify sending account
    =.  data.p.germ.giv
      %=    giver
          balance
        (sub balance.giver amount.act)
      ::
          allowances
        %+  ~(jab by allowances.giver)
          id.from.cart
        |=  old=@ud
        (sub old amount.act)
      ==
    (result ~[giv] ~[new] ~ ~)
  ::
      %redeem
    ::  deposit tickets into account
    =/  home=grain  (~(got by grains.inp) my-account.act)
    ?>  &(=(lord.home me.cart) ?=(%& -.germ.home))
    =/  rec=account  ;;(account data.p.germ.home)
    ::  all other grains in grains.inp are tickets
    =^  spent=(list grain)  rec
      %^    spin
          ~(val by (~(del by grains.inp) my-account.act))
        rec
      |=  [=grain =account]
      ^-  [^grain ^account]
      ?>  &(=(lord.grain me.cart) ?=(%& -.germ.grain))
      =/  tik  ;;(ticket data.p.germ.grain)
      ?<  redeemed.tik
      :-  grain(data.p.germ tik(redeemed %.y))
      account(balance (add balance.account value.tik))
    =.  data.p.germ.home  rec
    (result [home spent] ~ ~ ~)
  ::
      %give-set
    =/  giv=grain  +.-:grains.inp
    ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
    =/  giver=account  ;;(account data.p.germ.giv)
    ::  produce list of tickets
    =/  make  ~(tap in tickets.act)
    =|  made=(list grain)
    |-
    ?~  make  (result ~[giv(data.p.germ giver)] made ~ ~)
    =/  =ticket    [amount.i.make %.n metadata.giver]
    =/  salt=@ux   (shax (cat 3 salt.p.germ.giv (cat 3 from.cart)))
    =/  =id        (fry-rice id.i.make me.cart town-id.cart -)
    =/  new=grain  [id me.cart id.i.make town-id.cart [%& salt ticket]]
    %=  $
      make  t.make
      made  [new made]
      balance.giver  (sub balance.giver amount.i.make)
    ==
  ::
      %take-set
    =/  giv=grain  +.-:grains.inp
    ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
    =/  giver=account  ;;(account data.p.germ.giv)
    =/  allowance=@ud  (~(got by allowances.giver) id.from.cart)
    ::  produce list of tickets
    =/  make  ~(tap in tickets.act)
    =|  made=(list grain)
    |-
    ?~  make  (result ~[giv(data.p.germ giver)] made ~ ~)
    =/  =ticket    [amount.i.make %.n metadata.giver]
    =/  salt=@ux   (shax (cat 3 salt.p.germ.giv (cat 3 from.cart)))
    =/  =id        (fry-rice id.i.make me.cart town-id.cart -)
    =/  new=grain  [id me.cart id.i.make town-id.cart [%& salt ticket]]
    %=  $
      make  t.make
      made  [new made]
      balance.giver  (sub balance.giver amount.i.make)
    ::
        allowances.giver
      %+  ~(jab by allowances.giver)
        id.from.cart
      |=  old=@ud
      (sub old amount.i.make)
    ==
  ::
      %set-allowance
    =/  acc=grain  -:~(val by grains.inp)
    ?>  !=(who.act holder.acc)
    ?>  &(=(lord.acc me.cart) ?=(%& -.germ.acc))
    =/  =account  ;;(account data.p.germ.acc)
    ::  modify our account
    =.  data.p.germ.acc
      %=    account
          allowances
        (~(put by allowances.account) who.act amount.act)
      ==
    (result ~[acc] ~ ~ ~)
  ==
::
++  read
  |_  act=path
  ++  json
    ~
  ++  noun
    ~
  --
--
