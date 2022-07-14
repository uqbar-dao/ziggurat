::  [UQ| DAO]
::  zigs.hoon v0.8
::
::  Contract for 'zigs' (official name TBD) token, the gas-payment
::  token for the Uqbar network.
::  This token is unique from those defined by the token standard
::  because %give must include their gas budget, in order for
::  zig spends to be guaranteed not to underflow.
::
::  /+  *zig-sys-smart
/=  zigs  /lib/zig/contracts/lib/zigs
=,  zigs
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  =/  act  ;;(action:sur action.inp)
  ?-    -.act
      %give
    =/  giv=grain  +.-:grains.inp
    ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
    =/  giver=account:sur  ;;(account:sur data.p.germ.giv)
    ?>  (gte balance.giver (add amount.act budget.act))
    ?:  ?=(~ owns.cart)
      ::  if receiver doesn't have an account, try to produce one for them
      =/  =id  (fry-rice me.cart to.act town-id.cart salt.p.germ.giv)
      =/  rice         [%& salt.p.germ.giv %account [0 ~ metadata.giver]]
      =/  new=grain    [id me.cart to.act town-id.cart rice]
      =/  =action:sur  [%give to.act amount.act]
      %+  continuation
        (call me.cart town-id.cart action ~[id.giv] ~[id.new])^~
      (result ~ issued=[new ~] ~ ~)
    ::  otherwise, add to the existing account for that pubkey
    =/  rec=grain  +.-:owns.cart
    ?>  &(=(holder.rec to.act) ?=(%& -.germ.rec))
    =/  receiver=account:sur  ;;(account:sur data.p.germ.rec)
    ?>  =(metadata.receiver metadata.giver)
    =:  data.p.germ.giv  giver(balance (sub balance.giver amount.act))
        data.p.germ.rec  receiver(balance (add balance.receiver amount.act))
    ==
    (result [giv rec ~] ~ ~ ~)
  ::
      %take
    =/  giv=grain  (~(got by owns.cart) from-account.act)
    ?>  ?=(%& -.germ.giv)
    =/  giver=account:sur  ;;(account:sur data.p.germ.giv)
    =/  allowance=@ud  (~(got by allowances.giver) id.from.cart)
    ?>  (gte balance.giver amount.act)
    ?>  (gte allowance amount.act)
    ?~  account.act
      =/  =id  (fry-rice me.cart to.act town-id.cart salt.p.germ.giv)
      =/  rice         [%& salt.p.germ.giv %account [0 ~ metadata.giver]]
      =/  new=grain    [id me.cart to.act town-id.cart rice]
      =/  =action:sur  [%take to.act `id.new id.giv amount.act]
      %+  continuation
        (call me.cart town-id.cart action ~ ~[id.giv id.new])^~
      (result ~ issued=[new ~] ~ ~)
    =/  rec=grain  (~(got by owns.cart) u.account.act)
    ?>  &(=(holder.rec to.act) ?=(%& -.germ.rec))
    =/  receiver=account:sur  ;;(account:sur data.p.germ.rec)
    ?>  =(metadata.receiver metadata.giver)
    =:  data.p.germ.rec
      receiver(balance (add balance.receiver amount.act))
    ::
        data.p.germ.giv
      %=  giver
        balance     (sub balance.giver amount.act)
        allowances  %+  ~(jab by allowances.giver)
                      id.from.cart
                    |=(old=@ud (sub old amount.act))
      ==
    ==
    (result [giv rec ~] ~ ~ ~)
  ::
      %set-allowance
    =/  acc=grain  +.-:grains.inp
    ?>  !=(who.act holder.acc)
    ?>  &(=(lord.acc me.cart) ?=(%& -.germ.acc))
    =/  =account:sur  ;;(account:sur data.p.germ.acc)
    =.  data.p.germ.acc
      %=    account
          allowances
        (~(put by allowances.account) who.act amount.act)
      ==
    (result ~[acc] ~ ~ ~)
  ==
::
++  read
  |_  =path
  ++  json
    ^-  ^json
    ?+    path  !!
        [%rice-data ~]
      ?>  =(1 ~(wyt by owns.cart))
      =/  g=grain  -:~(val by owns.cart)
      ?>  ?=(%& -.germ.g)
      ?.  ?=([@ @ @ @ ?(~ [~ @]) ? ?(~ ^) @ @] data.p.germ.g)
        (account:enjs:lib ;;(account:sur data.p.germ.g))
      (token-metadata:enjs:lib ;;(token-metadata:sur data.p.germ.g))
    ::
        [%rice-data @ ~]
      =/  data  (cue (slav %ud i.t.path))
      ?.  ?=([@ @ @ @ ?(~ [~ @]) ? ?(~ ^) @ @] data)
        (account:enjs:lib ;;(account:sur data))
      (token-metadata:enjs:lib ;;(token-metadata:sur data))
    ::
        [%egg-action @ ~]
      %-  action:enjs:lib
      ;;(action:sur (cue (slav %ud i.t.path)))
    ==
  ::
  ++  noun
    ~
  --
--
