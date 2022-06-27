::  zigs.hoon [UQ| DAO]
::
::  Contract for 'zigs' (official name TBD) token, the gas-payment
::  token for the UQ| network.
::  This token is unique from those defined by the token standard
::  because %give must include their gas budget, in order for
::  zig spends to be guaranteed not to underflow.
::
/+  *zig-sys-smart
/=  sur  /lib/zig/contracts/lib/zigs
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
    ?>  (gte balance.giver (add amount.act budget.act))
    ?~  account.act
      ::  if receiver doesn't have an account, must produce one for them
      =+  (fry-rice to.act me.cart town-id.cart salt.p.germ.giv)
      =/  new=grain  [- me.cart to.act town-id.cart [%& salt.p.germ.giv [0 ~ metadata.giver]]]
      =/  =action    [%give to.act `id.new amount.act budget.act]
      =/  give-call  (call me.cart town-id.cart action ~[id.giv] ~[id.new])
      (continuation ~[give-call] (result ~ ~[new] ~))
    ::  otherwise, add to the existing account for that pubkey
    =/  rec=grain  (~(got by owns.cart) u.account.act)
    ?>  &(=(holder.rec to.act) ?=(%& -.germ.rec))
    =/  receiver=account  ;;(account data.p.germ.rec)
    ?>  =(metadata.receiver metadata.giver)
    =:  data.p.germ.giv  giver(balance (sub balance.giver amount.act))
        data.p.germ.rec  receiver(balance (add balance.receiver amount.act))
    ==
    (result ~[giv rec] ~ ~)
  ::
      %take
    =/  giv=grain  (~(got by owns.cart) from-account.act)
    ?>  ?=(%& -.germ.giv)
    =/  giver=account  ;;(account data.p.germ.giv)
    =/  allowance=@ud  (~(got by allowances.giver) from.cart)
    ?>  (gte balance.giver amount.act)
    ?>  (gte allowance amount.act)
    ?~  account.act
      =+  (fry-rice to.act me.cart town-id.cart salt.p.germ.giv)
      =/  new=grain  [- me.cart to.act town-id.cart [%& salt.p.germ.giv [0 ~ metadata.giver]]]
      =/  =action    [%take to.act `id.new id.giv amount.act]
      =/  give-call  (call me.cart town-id.cart action ~ ~[id.giv id.new])
      (continuation ~[give-call] (result ~ ~[new] ~))
    =/  rec=grain  (~(got by owns.cart) u.account.act)
    ?>  &(=(holder.rec to.act) ?=(%& -.germ.rec))
    =/  receiver=account  ;;(account data.p.germ.rec)
    ?>  =(metadata.receiver metadata.giver)
    =:  data.p.germ.rec  receiver(balance (add balance.receiver amount.act))
        data.p.germ.giv
      %=  giver
        balance  (sub balance.giver amount.act)
        allowances  (~(jab by allowances.giver) from.cart |=(old=@ud (sub old amount.act)))
      ==
    ==
    (result ~[giv rec] ~ ~)
  ::
      %set-allowance
    =/  acc=grain  -:~(val by grains.inp)
    ?>  !=(who.act holder.acc)
    ?>  &(=(lord.acc me.cart) ?=(%& -.germ.acc))
    =/  =account  ;;(account data.p.germ.acc)
    =.  data.p.germ.acc
      account(allowances (~(put by allowances.account) who.act amount.act))
    (result ~[acc] ~ ~)
  ==
::
++  read
  |_  act=path
  ++  json
    |^  ^-  ^json
    ?+    act  !!
        [%rice-data ~]
      ?>  =(1 ~(wyt by owns.cart))
      =/  g=grain  -:~(val by owns.cart)
      ?>  ?=(%& -.germ.g)
      ?.  ?=([@ @ @ @ ?(~ [~ @]) ? ?(~ ^) @ @] data.p.germ.g)
        (enjs-account ;;(account data.p.germ.g))
      (enjs-token-metadata ;;(token-metadata data.p.germ.g))
    ::
        [%egg-act @ ~]
      %-  enjs-actions
      ;;(action (cue (slav %ud i.t.act)))
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
    ++  enjs-actions
      =,  enjs:format
      |=  a=action
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
    --
  ++  noun
    ~
  --
--
