::  zigs.hoon [UQ| DAO]
::
::  Contract for 'zigs' (official name TBD) token, the gas-payment
::  token for the UQ| network.
::  This token is unique from those defined by the token standard
::  because %give must include their gas budget, in order for
::  zig spends to be guaranteed not to underflow.
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
  +$  token-metadata
    ::  will be automatically inserted into town state
    ::  at instantiation, along with this contract
    $:  name=@t
        symbol=@t
        decimals=@ud
        supply=@ud
        cap=(unit @ud)
        mintable=?  ::  will be unmintable, with zigs instead generated in mill
        minters=(set id)
        deployer=id  ::  will be 0x0
        salt=@  ::  'zigs'
    ==
  ::
  +$  account
    $:  balance=@ud
        allowances=(map sender=id @ud)
        metadata=id
    ==
  ::
  +$  arguments
    $%  [%give to=id account=(unit id) amount=@ud budget=@ud]
        [%take to=id account=(unit id) from-account=id amount=@ud]
        [%set-allowance who=id amount=@ud]  ::  (to revoke, call with amount=0)
    ==
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
        %give
      =/  giv=grain  -:~(val by grains.inp)
      ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
      =/  giver=account  ;;(account data.p.germ.giv)
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
      =/  receiver=account  ;;(account data.p.germ.rec)
      ?>  =(metadata.receiver metadata.giver)
      =:  data.p.germ.giv  giver(balance (sub balance.giver amount.args))
          data.p.germ.rec  receiver(balance (add balance.receiver amount.args))
      ==
      [%& (malt ~[[id.giv giv] [id.rec rec]]) ~ ~]
    ::
        %take
      =/  giv=grain  (~(got by owns.cart) from-account.args)
      ?>  ?=(%& -.germ.giv)
      =/  giver=account  ;;(account data.p.germ.giv)
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
      =/  receiver=account  ;;(account data.p.germ.rec)
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
      =/  =account  ;;(account data.p.germ.acc)
      =.  data.p.germ.acc
        account(allowances (~(put by allowances.account) who.args amount.args))
      [%& (malt ~[[id.acc acc]]) ~ ~]
    ==
  --
::
++  read
  |_  args=path
  ++  json
    |^  ^-  ^json
    ?+    args  !!
        [%rice-data ~]
      ?>  =(1 ~(wyt by owns.cart))
      =/  g=grain  -:~(val by owns.cart)
      ?>  ?=(%& -.germ.g)
      ?.  ?=([@ @ @ @ ?(~ [~ @]) ? ?(~ ^) @ @] data.p.germ.g)
        (enjs-account ;;(account data.p.germ.g))
      (enjs-token-metadata ;;(token-metadata data.p.germ.g))
    ::
        [%egg-args @ ~]
      %-  enjs-arguments
      ;;(arguments (cue (slav %ud i.t.args)))
    ==
    ::
    ++  enjs-account
      =,  enjs:format
      |^
      |=  acct=account
      ^-  ^json
      %-  pairs
      :^    [%balance (numb balance.acct)]
          [%allowances (allowances allowances.acct)]
        [%metadata (metadata metadata.acct)]
      ~
      ::
      ++  allowances
        |=  a=(map id @ud)
        ^-  ^json
        %-  pairs
        %+  turn  ~(tap by a)
        |=  [i=id allowance=@ud]
        [(scot %ux i) (numb allowance)]
      ::
      ++  metadata  ::  TODO: grab token-metadata?
        |=  md-id=id
        [%s (scot %ux md-id)]
      --
    ::
    ++  enjs-token-metadata
      =,  enjs:format
      |^
      |=  md=token-metadata
      ^-  ^json
      %-  pairs
      :~  [%name %s name.md]
          [%symbol %s symbol.md]
          [%decimals (numb decimals.md)]
          [%supply (numb supply.md)]
          [%cap ?~(cap.md ~ (numb u.cap.md))]
          [%mintable %b mintable.md]
          [%minters (minters minters.md)]
          [%deployer %s (scot %ux deployer.md)]
          [%salt (numb salt.md)]
      ==
      ::
      ++  minters
        set-id
      ::
      ++  set-id
        |=  set-id=(set id)
        ^-  ^json
        :-  %a
        %+  turn  ~(tap in set-id)
        |=  i=id
        [%s (scot %ux i)]
      --
    ::
    ++  enjs-arguments
      =,  enjs:format
      |=  a=arguments
      ^-  ^json
      %+  frond  -.a
      ?-    -.a
      ::
          %give
        %-  pairs
        :~  [%to %s (scot %ux to.a)]
            [%account ?~(account.a ~ [%s (scot %ux u.account.a)])]
            [%amount (numb amount.a)]
            [%budget (numb budget.a)]
        ==
      ::
          %take
        %-  pairs
        :~  [%to %s (scot %ux to.a)]
            [%account ?~(account.a ~ [%s (scot %ux u.account.a)])]
            [%from-account %s (scot %ux from-account.a)]
            [%amount (numb amount.a)]
        ==
      ::
          %set-allowance
        %-  pairs
        :+  [%who %s (scot %ux who.a)]
          [%amount (numb amount.a)]
        ~
      ==
    ::
    +$  token-metadata
      ::  will be automatically inserted into town state
      ::  at instantiation, along with this contract
      $:  name=@t
          symbol=@t
          decimals=@ud
          supply=@ud
          cap=(unit @ud)
          mintable=?  ::  will be unmintable, with zigs instead generated in mill
          minters=(set id)
          deployer=id  ::  will be 0x0
          salt=@  ::  'zigs'
      ==
    ::
    +$  account
      $:  balance=@ud
          allowances=(map sender=id @ud)
          metadata=id
      ==
    ::
    +$  arguments
      $%  [%give to=id account=(unit id) amount=@ud budget=@ud]
          [%take to=id account=(unit id) from-account=id amount=@ud]
          [%set-allowance who=id amount=@ud]  ::  (to revoke, call with amount=0)
      ==
    --
  ++  noun
    ~
  --
--
