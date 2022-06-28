::  zigs.hoon [UQ| DAO]
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
  |^
  ?~  args.inp  !!
  (process ;;(arguments:sur u.args.inp) (pin caller.inp))
  ::
  ++  process
    |=  [args=arguments:sur caller-id=id]
    ?-    -.args
        %give
      =/  giv=grain  -:~(val by grains.inp)
      ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
      =/  giver=account:sur  ;;(account:sur data.p.germ.giv)
      ?>  (gte balance.giver (add amount.args budget.args))
      ?~  account.args
        ::  if receiver doesn't have an account, must produce one for them
        =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new=grain
          [- me.cart to.args town-id.cart [%& salt.p.germ.giv [0 ~ metadata.giver]]]
        :+  %|
          :+  me.cart  town-id.cart
          [caller.inp `[%give to.args `id.new amount.args budget.args] (silt ~[id.giv]) (silt ~[id.new])]
        [~ (malt ~[[id.new new]]) ~]
      ::  otherwise, add to the existing account for that pubkey
      =/  rec=grain  (~(got by owns.cart) u.account.args)
      ?>  &(=(holder.rec to.args) ?=(%& -.germ.rec))
      =/  receiver=account:sur  ;;(account:sur data.p.germ.rec)
      ?>  =(metadata.receiver metadata.giver)
      =:  data.p.germ.giv  giver(balance (sub balance.giver amount.args))
          data.p.germ.rec  receiver(balance (add balance.receiver amount.args))
      ==
      [%& (malt ~[[id.giv giv] [id.rec rec]]) ~ ~]
    ::
        %take
      =/  giv=grain  (~(got by owns.cart) from-account.args)
      ?>  ?=(%& -.germ.giv)
      =/  giver=account:sur  ;;(account:sur data.p.germ.giv)
      =/  allowance=@ud  (~(got by allowances.giver) caller-id)
      ?>  (gte balance.giver amount.args)
      ?>  (gte allowance amount.args)
      ?~  account.args
        =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new=grain
          [- me.cart to.args town-id.cart [%& salt.p.germ.giv [0 ~ metadata.giver]]]
        :+  %|
          :+  me.cart  town-id.cart
          [caller.inp `[%take to.args `id.new id.giv amount.args] ~ (silt ~[id.giv id.new])]
        [~ (malt ~[[id.new new]]) ~]
      =/  rec=grain  (~(got by owns.cart) u.account.args)
      ?>  &(=(holder.rec to.args) ?=(%& -.germ.rec))
      =/  receiver=account:sur  ;;(account:sur data.p.germ.rec)
      ?>  =(metadata.receiver metadata.giver)
      =:  data.p.germ.rec  receiver(balance (add balance.receiver amount.args))
          data.p.germ.giv
        %=  giver
          balance  (sub balance.giver amount.args)
          allowances  (~(jab by allowances.giver) caller-id |=(old=@ud (sub old amount.args)))
        == 
      ==
      [%& (malt ~[[id.giv giv] [id.rec rec]]) ~ ~]
    ::
        %set-allowance
      =/  acc=grain  -:~(val by grains.inp)
      ?>  !=(who.args holder.acc)
      ?>  &(=(lord.acc me.cart) ?=(%& -.germ.acc))
      =/  =account:sur  ;;(account:sur data.p.germ.acc)
      =.  data.p.germ.acc
        account(allowances (~(put by allowances.account) who.args amount.args))
      [%& (malt ~[[id.acc acc]]) ~ ~]
    ==
  --
::
++  read
  |_  args=path
  ++  json
    ^-  ^json
    ?+    args  !!
        [%rice-data ~]
      ?>  =(1 ~(wyt by owns.cart))
      =/  g=grain  -:~(val by owns.cart)
      ?>  ?=(%& -.germ.g)
      ?.  ?=([@ @ @ @ ?(~ [~ @]) ? ?(~ ^) @ @] data.p.germ.g)
        (account:enjs:lib ;;(account:sur data.p.germ.g))
      (token-metadata:enjs:lib ;;(token-metadata:sur data.p.germ.g))
    ::
        [%rice-data @ ~]
      =/  data  (cue (slav %ud i.t.args))
      ?.  ?=([@ @ @ @ ?(~ [~ @]) ? ?(~ ^) @ @] data)
        (account:enjs:lib ;;(account:sur data))
      (token-metadata:enjs:lib ;;(token-metadata:sur data))
    ::
        [%egg-args @ ~]
      %-  arguments:enjs:lib
      ;;(arguments:sur (cue (slav %ud i.t.args)))
    ==
  ::
  ++  noun
    ~
  --
--
