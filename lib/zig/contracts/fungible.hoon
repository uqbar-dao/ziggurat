::  fungible.hoon [UQ| DAO]
::
::  Fungible token implementation. Any new token that wishes to use this
::  format can be issued through this contract. The contract uses an account
::  model, where each pubkey holds one rice that contains their balance and
::  alllowances. (Allowances permit a certain pubkey to spend tokens on your
::  behalf.) When issuing a new token, you can either designate a pubkey or
::  pubkeys who is permitted to mint, or set a permanent supply, all of which
::  must be distributed at first issuance.
::
::  Each newly issued token also issues a single rice which stores metadata
::  about the token, which this contract both holds and is lord of, and must
::  be included in any transactions involving that token.
::
::  Many tokens that perform various utilities will want to retain control
::  over minting, burning, and sending. They can of course write their own
::  contract to custom-handle all of these scenarios, or write a manager
::  which performs custom logic but calls back to this contract for the
::  base token actions. Any token that maintains the same metadata and account
::  format, even if using a different contract (such as zigs) should be
::  composable among tools designed to this standard.
::
::  Tokens that wish to be properly displayed and handled with no additional
::  work in the wallet agent should implement the same structure for their
::  rice.
::
/+  *zig-sys-smart
/=  fungible  /lib/zig/contracts/lib/fungible
=,  fungible
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  =/  act  ;;(action:sur action.inp)
  ::
  ::  the execution arm. branches on argument type and returns final result.
  ::  note that many of these lines will crash with bad input. this is good,
  ::  because we don't want failing transactions to waste more gas than required
  ::
  ?-    -.act
      %give
    ::  grab giver's rice from the input. it should be only rice in the map
    =/  giv=grain  +.-:grains.inp
    ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
    =/  giver=account:sur  ;;(account:sur data.p.germ.giv)
    ?>  (gte balance.giver amount.act)
    ?:  ?=(~ owns.cart)
      ::  if receiver doesn't have an account, try to produce one for them
      =/  =id  (fry-rice me.cart to.act town-id.cart salt.p.germ.giv)
      =/  rice         [%& salt.p.germ.giv %account [0 ~ metadata.giver]]
      =/  new=grain    [id me.cart to.act town-id.cart rice]
      =/  =action:sur  [%give to.act amount.act]
      ::  continuation call: %give to rice we issued
      %+  continuation
        (call me.cart town-id.cart action ~[id.giv] ~[id.new])^~
      (result ~ issued=[new ~] ~ ~)
    ::  otherwise, add to the existing account for that pubkey
    ::  giving account in embryo, and receiving one in owns.cart
    =/  rec=grain  +.-:owns.cart
    ?>  &(=(holder.rec to.act) ?=(%& -.germ.rec))
    =/  receiver=account:sur  ;;(account:sur data.p.germ.rec)
    ::  assert that tokens match
    ?>  =(metadata.receiver metadata.giver)
    ::  alter the two balances inside the grains
    =:  data.p.germ.giv  giver(balance (sub balance.giver amount.act))
        data.p.germ.rec  receiver(balance (add balance.receiver amount.act))
    ==
    ::  return the result: two changed grains
    (result [giv rec ~] ~ ~ ~)
  ::
      %take
    ::  %take expects the account that will be taken from in owns.cart
    ::  if the receiving account is known, it will also be in owns.cart, otherwise
    ::  the address book should be there to find it, like in %give.
    =/  giv=grain  (~(got by owns.cart) from-account.act)
    ?>  ?=(%& -.germ.giv)
    =/  giver=account:sur  ;;(account:sur data.p.germ.giv)
    =/  allowance=@ud  (~(got by allowances.giver) id.from.cart)
    ::  assert caller is permitted to spend this amount of token
    ?>  (gte balance.giver amount.act)
    ?>  (gte allowance amount.act)
    ?~  account.act
      ::  create new rice for reciever and add it to state
      =/  =id  (fry-rice me.cart to.act town-id.cart salt.p.germ.giv)
      =/  rice         [%& salt.p.germ.giv %account [0 ~ metadata.giver]]
      =/  new=grain    [id me.cart to.act town-id.cart rice]
      =/  =action:sur  [%take to.act `id.new id.giv amount.act]
      ::  continuation call: %take to rice found in book
      %+  continuation
        (call me.cart town-id.cart action ~ ~[id.giv id.new])^~
      (result ~ issued=[new ~] ~ ~)
    ::  direct send
    =/  rec=grain  (~(got by owns.cart) u.account.act)
    ?>  &(=(holder.rec to.act) ?=(%& -.germ.rec))
    =/  receiver=account:sur  ;;(account:sur data.p.germ.rec)
    ?>  =(metadata.receiver metadata.giver)
    ::  update the allowance of taker
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
    ::  let some pubkey spend tokens on your behalf
    ::  note that you can arbitrarily allow as much spend as you want,
    ::  but spends will still be constrained by token balance
    ::  single rice expected, account
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
  ::
      %mint
    ::  expects token metadata in owns.cart
    =/  tok=grain  (~(got by owns.cart) token.act)
    ?>  &(=(lord.tok me.cart) ?=(%& -.germ.tok))
    =/  meta  ;;(token-metadata:sur data.p.germ.tok)
    ::  first, check if token is mintable
    ?>  &(mintable.meta ?=(^ cap.meta) ?=(^ minters.meta))
    ::  check if caller is permitted to mint
    ?>  (~(has in `(set id)`minters.meta) id.from.cart)
    ::  for accounts which we know rice of, find in owns.cart
    ::  and alter. for others, generate id and add to c-call
    =/  mints  ~(tap in mints.act)
    =|  changed=(list grain)
    =|  to-issue=(list grain)
    =|  minted-total=@ud
    =|  next-mints=(set mint:sur)
    |-
    ?~  mints
      ::  finished minting, return chick
      =/  new-supply  (add supply.meta minted-total)
      =.  data.p.germ.tok
        %=  meta
          supply    new-supply
          mintable  ?:(=(u.cap.meta new-supply) %.y %.n)
        ==
      ?~  to-issue
        ::  no new accounts to issue
        (result [tok changed] ~ ~ ~)
      ::  finished but need to mint to newly-issued rices
      =/  =action:sur  [%mint token.act next-mints]
      %+  continuation
        (call me.cart town-id.cart action ~ (turn to-issue |=(=grain id.grain)))^~
      (result changed to-issue ~ ~)
    ::
    ?~  account.i.mints
      ::  need to issue
      =/  =id     (fry-rice me.cart to.i.mints town-id.cart salt.meta)
      =/  rice    [%& salt.meta %account [0 ~ token.act]]
      =/  =grain  [id me.cart to.i.mints town-id.cart rice]
      %=  $
        mints        t.mints
        to-issue     [grain to-issue]
        next-mints   (~(put in next-mints) [to.i.mints `id amount.i.mints])
      ==
    ::  have rice, can modify
    =/  =grain  (~(got by owns.cart) u.account.i.mints)
    ?>  &(=(lord.grain me.cart) ?=(%& -.germ.grain))
    =/  acc  ;;(account:sur data.p.germ.grain)
    ?>  =(metadata.acc token.act)
    =.  data.p.germ.grain  acc(balance (add balance.acc amount.i.mints))
    %=  $
      mints         t.mints
      changed       [grain changed]
      minted-total  (add minted-total amount.i.mints)
    ==
  ::
      %deploy
    ::  no rice expected as input, only arguments
    ::  enforce 0 <= decimals <= 18
    ?>  &((gte decimals.act 0) (lte decimals.act 18))
    ::  if mintable, enforce minter set not empty
    ?>  ?:(mintable.act ?=(^ minters.act) %.y)
    ::  if !mintable, enforce distribution adds up to cap
    ::  otherwise, enforce distribution < cap
    =/  distribution-total  ^-  @ud
      %.  add
      %~  rep  in
      ^-  (set @ud)
      (~(run in distribution.act) |=([id bal=@ud] bal))
    ?>  ?:  mintable.act
          (gth cap.act distribution-total)
        =(cap.act distribution-total)
    ::  generate salt
    =/  salt  (sham (cat 3 id.from.cart symbol.act))
    ::  generate metadata
    =/  metadata-grain  ^-  grain
      :*  (fry-rice me.cart me.cart town-id.cart salt)
          me.cart
          me.cart
          town-id.cart
          :^  %&  salt  %metadata
          ^-  token-metadata:sur
          :*  name.act
              symbol.act
              decimals.act
              supply=distribution-total
              ?:(mintable.act `cap.act ~)
              mintable.act
              minters.act
              deployer=id.from.cart
              salt
      ==  ==
    ::  generate accounts
    =/  accounts
      %-  ~(gas by *(map id grain))
      %+  turn  ~(tap in distribution.act)
      |=  [=id bal=@ud]
      =+  (fry-rice me.cart id town-id.cart salt)
      :-  -
      [- me.cart id town-id.cart [%& salt %account [bal ~ id.metadata-grain]]]
    ::  big ol issued map
    [%& ~ (~(put by accounts) id.metadata-grain metadata-grain) ~ ~]
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
      ?:  ?=(%account label.p.germ.g)
        (account:enjs:lib ;;(account:sur data.p.germ.g))
      (token-metadata:enjs:lib ;;(token-metadata:sur data.p.germ.g))
    ::
        [%rice-data @ ~]
      =/  g  ;;(grain (cue (slav %ud i.t.path)))
      ?>  ?=(%& -.germ.g)
      ?:  ?=(%account label.p.germ.g)
        (account:enjs:lib ;;(account:sur data.p.germ.g))
      (token-metadata:enjs:lib ;;(token-metadata:sur data.p.germ.g))
    ::
        [%egg-args @ ~]
      %-  action:enjs:lib
      ;;(action:sur (cue (slav %ud i.t.path)))
    ==
  ::
  ++  noun
    ~
  --
--
