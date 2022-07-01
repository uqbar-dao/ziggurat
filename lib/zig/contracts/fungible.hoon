::  fungible.hoon [UQ| DAO]
::
::  Fungible token standard. Any new token that wishes to use this standard
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
::  rice. In the future we can look to support other modes of data management,
::  such as UTXOs, single balance sheets, or hybrid models.
::
::  I will heavily comment this contract in order to make it a good example
::  for others to use.
::
::  /+  *zig-sys-smart
/=  fungible  /lib/zig/contracts/lib/fungible
=,  fungible
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(arguments:sur u.args.inp) (pin caller.inp))
  
  ::
  ::  used for validating gasless approvals
  ::
  +$  approve  $:  from=id
                   to=id
                   amount=@ud
                   nonce=@ud
                   deadline=@da
                ==
  ::
  ::  the actual execution arm. branches on argument type and returns final result
  ::  note that many of these lines will crash with bad input. this is good,
  ::  because we don't want failing transactions to waste more gas than required
  ::
  ++  address-from-pub
    =,  keccak:crypto
    |=  pub=@
    %+  end  [3 20]
    %+  keccak-256  64
    (rev 3 64 pub)
  ++  process
    |=  [args=arguments:sur caller-id=id]
    ?-    -.args
        %give
      ::  grab giver's rice from the input. it should be only rice in the map
      =/  giv=grain  -:~(val by grains.inp)
      ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
      =/  giver=account:sur  ;;(account:sur data.p.germ.giv)
      ?>  (gte balance.giver amount.args)
      ?~  account.args
        ::  create new rice for reciever and add it to state
        =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new=grain
          [- me.cart to.args town-id.cart [%& salt.p.germ.giv [0 ~ metadata.giver 0]]]
        ::  continuation call: %give to rice we issued
        :+  %|
          :+  me.cart  town-id.cart
          [caller.inp `[%give to.args `id.new amount.args] (silt ~[id.giv]) (silt ~[id.new])]
        [~ (malt ~[[id.new new]]) ~]
      ::  giving account in embryo, and receiving one in owns.cart
      =/  rec=grain  (~(got by owns.cart) u.account.args)
      ?>  ?=(%& -.germ.rec)
      =/  receiver=account:sur  ;;(account:sur data.p.germ.rec)
      ::  assert that tokens match
      ?>  =(metadata.receiver metadata.giver)
      ::  alter the two balances inside the grains
      =:  data.p.germ.giv  giver(balance (sub balance.giver amount.args))
          data.p.germ.rec  receiver(balance (add balance.receiver amount.args))
      ==
      ::  return the result: two changed grains
      [%& (malt ~[[id.giv giv] [id.rec rec]]) ~ ~]
    ::
        %take
      ::  %take expects the account that will be taken from in owns.cart
      ::  if the receiving account is known, it will also be in owns.cart, otherwise
      ::  the address book should be there to find it, like in %give.
      =/  giv=grain  (~(got by owns.cart) from-rice.args)
      ?>  ?=(%& -.germ.giv)
      =/  giver=account:sur  ;;(account:sur data.p.germ.giv)
      =/  allowance=@ud  (~(got by allowances.giver) caller-id)
      ::  assert caller is permitted to spend this amount of token
      ?>  (gte balance.giver amount.args)
      ?>  (gte allowance amount.args)
      ?~  account.args
        ::  create new rice for reciever and add it to state
        =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new=grain
          [- me.cart to.args town-id.cart [%& salt.p.germ.giv [amount.args ~ metadata.giver 0]]]
        ::  continuation call: %take to rice found in book
        :+  %|
          :+  me.cart  town-id.cart
          [caller.inp `[%take to.args `id.new id.giv amount.args] ~ (silt ~[id.giv id.new])]
        [~ (malt ~[[id.new new]]) ~]
      ::  direct send
      =/  rec=grain  (~(got by owns.cart) u.account.args)
      ?>  ?=(%& -.germ.rec)
      =/  receiver=account:sur  ;;(account:sur data.p.germ.rec)
      ?>  =(metadata.receiver metadata.giver)
      ::  update the allowance of taker
      =.  allowances.giver
        %+  ~(jab by allowances.giver)  caller-id
        |=(old=@ud (sub old amount.args))
      =:  data.p.germ.rec  receiver(balance (add balance.receiver amount.args))
          data.p.germ.giv
        %=  giver
          balance  (sub balance.giver amount.args)
          allowances  (~(jab by allowances.giver) caller-id |=(old=@ud (sub old amount.args)))
        == 
      ==
      [%& (malt ~[[id.giv giv] [id.rec rec]]) ~ ~]
    ::
        %take-with-sig
      =/  giv=grain  (~(got by owns.cart) from-rice.args)
      ?>  ?=(%& -.germ.giv)
      =/  giver=account:sur  ;;(account:sur data.p.germ.giv)
      =/  =typed-message
        :-  (fry-rice holder.giv me.cart town-id.cart 0)  ::  domain == rice-id, TODO: get salt somehow
        (sham ;;(approve [holder.giv to.args amount.args nonce.args deadline.args]))
      =/  signed-hash  (sham typed-message)
      =,  secp256k1:secp:crypto :: will fail when deployed to rollup because crypto library isn't there
      =/  recovered-address
        %-  address-from-pub
        %-  serialize-point
        (ecdsa-raw-recover signed-hash sig.args)

      ?>  =(recovered-address holder.giv)       ::  assert that the signature is valid
      ?>  (gte deadline.args now.cart)     ::  assert that the deadline is valid
      ?>  (gte balance.giver amount.args)  ::  assert the giver has enough to cover the spend
      ?~  account.args  !!
      ::   ::  create new rice for reciever and add it to state
      ::   =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
      ::   =/  new=grain
      ::     [- me.cart to.args town-id.cart [%& salt.p.germ.giv [amount.args ~ metadata.giver 0]]]
      ::   ::  continuation call: %take to rice found in book
      ::   :+  %|
      ::     :+  me.cart  town-id.cart
      ::     [caller.inp `[%take to.args `id.new id.giv amount.args] ~ (silt ~[id.giv id.new])]
      ::   [~ (malt ~[[id.new new]]) ~]
      ::  direct send
      =/  rec=grain  (~(got by owns.cart) u.account.args)
      ?>  ?=(%& -.germ.rec)
      =/  receiver=account:sur  ;;(account:sur data.p.germ.rec)
      ?>  =(metadata.receiver metadata.giver)
      =:  data.p.germ.rec  receiver(balance (add balance.receiver amount.args))
          data.p.germ.giv
        %=  giver
          balance  (sub balance.giver amount.args)
          nonce  .+(nonce.giver)
        == 
      ==
      [%& (malt ~[[id.giv giv] [id.rec rec]]) ~ ~]
    ::
        %set-allowance
      ::  let some pubkey spend tokens on your behalf
      ::  note that you can arbitrarily allow as much spend as you want,
      ::  but spends will still be constrained by token balance
      ::  single rice expected, account
      =/  acc=grain  -:~(val by grains.inp)
      ?>  &(=(lord.acc me.cart) ?=(%& -.germ.acc))
      =/  =account:sur  ;;(account:sur data.p.germ.acc)
      =.  data.p.germ.acc
        account(allowances (~(put by allowances.account) who.args amount.args))
      ::  return single changed rice
      [%& (malt ~[[id.acc acc]]) ~ ~]
    ::
        %mint
      ::  expects token metadata in owns.cart
      =/  tok=grain  (~(got by owns.cart) token.args)
      ?>  &(=(lord.tok me.cart) ?=(%& -.germ.tok))
      =/  meta  ;;(token-metadata:sur data.p.germ.tok)
      ::  first, check if token is mintable
      ?>  &(mintable.meta ?=(^ cap.meta) ?=(^ minters.meta))
      ::  check if mint will surpass supply cap
      =/  new-total
        %+  add  supply.meta
        %.  add
        %~  rep  in
        ^-  (set @ud)  ::  non-optional cast
        (~(run in mints.args) |=(=mint:sur amount.mint))
      ?>  (gth u.cap.meta new-total)
      ::  cleared to execute!
      ::  update metadata token
      =.  data.p.germ.tok
        %=  meta
          supply    new-total
          mintable  ?:(=(u.cap.meta supply.meta) %.y %.n)
        ==
      ::  for accounts which we know rice of, find in owns.cart
      ::  and alter. for others, generate id and add to c-call
      =/  changed-rice  (malt ~[[id.tok tok]])
      =/  issued-rice   *(map id grain)
      =/  mints         ~(tap in mints.args)
      =/  next-mints    *(set mint:sur)
      |-
      ?~  mints
        ::  finished minting, return chick
        ?~  issued-rice
          [%& changed-rice ~ ~]
        ::  finished but need to mint to newly-issued rices
        =/  call-grains=(set id)
          ~(key by `(map id grain)`issued-rice)
        :+  %|
          :+  me.cart  town-id.cart
          [caller.inp `[%mint token.args next-mints] ~ call-grains]
        [changed-rice issued-rice ~]
      ::
      ?~  account.i.mints
        ::  need to issue
        =+  (fry-rice to.i.mints me.cart town-id.cart salt.meta)
        =/  new=grain
          [- me.cart to.i.mints town-id.cart [%& salt.meta [0 ~ token.args 0]]]
        %=  $
          mints        t.mints
          issued-rice  (~(put by issued-rice) id.new new)
          next-mints   (~(put in next-mints) [to.i.mints `id.new amount.i.mints])
        ==
      ::  have rice, can modify
      =/  =grain  (~(got by owns.cart) u.account.i.mints)
      ?>  &(=(lord.grain me.cart) ?=(%& -.germ.grain))
      =/  acc  ;;(account:sur data.p.germ.grain)
      ?>  =(metadata.acc token.args)
      =.  data.p.germ.grain  acc(balance (add balance.acc amount.i.mints))
      $(mints t.mints, changed-rice (~(put by changed-rice) id.grain grain))
    ::
        %deploy
      ::  no rice expected as input, only arguments
      ::  enforce 0 <= decimals <= 18
      ?>  &((gte decimals.args 0) (lte decimals.args 18))
      ::  if mintable, enforce minter set not empty
      ?>  ?:(mintable.args ?=(^ minters.args) %.y)
      ::  if !mintable, enforce distribution adds up to cap
      ::  otherwise, enforce distribution < cap
      =/  distribution-total  ^-  @ud
        %.  add
        %~  rep  in
        ^-  (set @ud)
        (~(run in distribution.args) |=([id bal=@ud] bal))
      ?>  ?:  mintable.args
            (gth cap.args distribution-total)
          =(cap.args distribution-total)
      ::  generate salt
      =/  salt  (sham (cat 3 caller-id symbol.args))
      ::  generate metadata
      =/  metadata-grain  ^-  grain
        :*  (fry-rice me.cart me.cart town-id.cart salt)
            me.cart
            me.cart
            town-id.cart
            :+  %&  salt
            ^-  token-metadata:sur
            :*  name.args
                symbol.args
                decimals.args
                supply=distribution-total
                ?:(mintable.args `cap.args ~)
                mintable.args
                minters.args
                deployer=caller-id
                salt
        ==  ==
      ::  generate accounts
      =/  accounts
        %-  ~(gas by *(map id grain))
        %+  turn  ~(tap in distribution.args)
        |=  [=id bal=@ud]
        =+  (fry-rice id me.cart town-id.cart salt)
        :-  -
        [- me.cart id town-id.cart [%& salt [bal ~ id.metadata-grain 0]]]
      ::  big ol issued map
      [%& ~ (~(put by accounts) id.metadata-grain metadata-grain) ~]
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
