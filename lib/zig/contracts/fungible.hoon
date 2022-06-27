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
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(arguments u.args.inp) (pin caller.inp))
  ::
  ::  molds used by writes to this contract
  ::
  +$  token-metadata
    $:  name=@t           ::  the name of a token (not unique!)
        symbol=@t         ::  abbreviation (also not unique)
        decimals=@ud      ::  granularity, minimum 0, maximum 18
        supply=@ud        ::  total amount of token in existence
        cap=(unit @ud)    ::  supply cap (~ if mintable is false)
        mintable=?        ::  whether or not more can be minted
        minters=(set id)  ::  pubkeys permitted to mint, if any
        deployer=id       ::  pubkey which first deployed token
        salt=@            ::  data added to hash for rice IDs of this token
                          ::  (currently hashed: symbol+deployer)
    ==
  ::
  +$  account
    $:  balance=@ud                     ::  the amount of tokens someone has
        allowances=(map sender=id @ud)  ::  a map of pubkeys they've permitted to spend their tokens and how much
        metadata=id                     ::  address of the rice holding this token's metadata
    ==
  ::
  ::  patterns of arguments supported by this contract
  ::  "args" in input must fit one of these molds
  ::
  +$  mint  [to=id account=(unit id) amount=@ud]  ::  helper type for mint
  +$  arguments
    $%  ::  token holder actions
        ::
        [%give to=id account=(unit id) amount=@ud]
        [%take to=id account=(unit id) from-rice=id amount=@ud]
        [%set-allowance who=id amount=@ud]  ::  (to revoke, call with amount=0)
        ::  token management actions
        ::
        [%mint token=id mints=(set mint)]  ::  can only be called by minters, can't mint above cap
        $:  %deploy
            distribution=(set [id bal=@ud])  ::  sums to <= cap if mintable, == cap otherwise
            minters=(set id)                 ::  ignored if !mintable, otherwise need at least one
            name=@t
            symbol=@t                        ::  size limit?
            decimals=@ud                     ::  min 0, max 18
            cap=@ud                          ::  is equivalent to total supply unless token is mintable
            mintable=?
        ==
    ==
  ::
  ::  the actual execution arm. branches on argument type and returns final result
  ::  note that many of these lines will crash with bad input. this is good,
  ::  because we don't want failing transactions to waste more gas than required
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
        %give
      ::  grab giver's rice from the input. it should be only rice in the map
      =/  giv=grain  -:~(val by grains.inp)
      ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
      =/  giver=account  ;;(account data.p.germ.giv)
      ?>  (gte balance.giver amount.args)
      ?~  account.args
        ::  create new rice for reciever and add it to state
        =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new=grain
          [- me.cart to.args town-id.cart [%& salt.p.germ.giv [0 ~ metadata.giver]]]
        ::  continuation call: %give to rice we issued
        :+  %|
          :+  me.cart  town-id.cart
          [caller.inp `[%give to.args `id.new amount.args] (silt ~[id.giv]) (silt ~[id.new])]
        [~ (malt ~[[id.new new]]) ~]
      ::  giving account in embryo, and receiving one in owns.cart
      =/  rec=grain  (~(got by owns.cart) u.account.args)
      ?>  ?=(%& -.germ.rec)
      =/  receiver=account  ;;(account data.p.germ.rec)
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
      =/  giver=account  ;;(account data.p.germ.giv)
      =/  allowance=@ud  (~(got by allowances.giver) caller-id)
      ::  assert caller is permitted to spend this amount of token
      ?>  (gte balance.giver amount.args)
      ?>  (gte allowance amount.args)
      ?~  account.args
        ::  create new rice for reciever and add it to state
        =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new=grain
          [- me.cart to.args town-id.cart [%& salt.p.germ.giv [amount.args ~ metadata.giver]]]
        ::  continuation call: %take to rice found in book
        :+  %|
          :+  me.cart  town-id.cart
          [caller.inp `[%take to.args `id.new id.giv amount.args] ~ (silt ~[id.giv id.new])]
        [~ (malt ~[[id.new new]]) ~]
      ::  direct send
      =/  rec=grain  (~(got by owns.cart) u.account.args)
      ?>  ?=(%& -.germ.rec)
      =/  receiver=account  ;;(account data.p.germ.rec)
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
        %set-allowance
      ::  let some pubkey spend tokens on your behalf
      ::  note that you can arbitrarily allow as much spend as you want,
      ::  but spends will still be constrained by token balance
      ::  single rice expected, account
      =/  acc=grain  -:~(val by grains.inp)
      ?>  &(=(lord.acc me.cart) ?=(%& -.germ.acc))
      =/  =account  ;;(account data.p.germ.acc)
      =.  data.p.germ.acc
        account(allowances (~(put by allowances.account) who.args amount.args))
      ::  return single changed rice
      [%& (malt ~[[id.acc acc]]) ~ ~]
    ::
        %mint
      ::  expects token metadata in owns.cart
      =/  tok=grain  (~(got by owns.cart) token.args)
      ?>  &(=(lord.tok me.cart) ?=(%& -.germ.tok))
      =/  meta  ;;(token-metadata data.p.germ.tok)
      ::  first, check if token is mintable
      ?>  &(mintable.meta ?=(^ cap.meta) ?=(^ minters.meta))
      ::  check if mint will surpass supply cap
      =/  new-total
        %+  add  supply.meta
        %.  add
        %~  rep  in
        ^-  (set @ud)  ::  non-optional cast
        (~(run in mints.args) |=(=mint amount.mint))
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
      =/  next-mints    *(set mint)
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
          [- me.cart to.i.mints town-id.cart [%& salt.meta [0 ~ token.args]]]
        %=  $
          mints   t.mints
          issued-rice  (~(put by issued-rice) id.new new)
          next-mints   (~(put in next-mints) [to.i.mints `id.new amount.i.mints])
        ==
      ::  have rice, can modify
      =/  =grain  (~(got by owns.cart) u.account.i.mints)
      ?>  &(=(lord.grain me.cart) ?=(%& -.germ.grain))
      =/  acc  ;;(account data.p.germ.grain)
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
            ^-  token-metadata
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
        [- me.cart id town-id.cart [%& salt [bal ~ id.metadata-grain]]]
      ::  big ol issued map
      [%& ~ (~(put by accounts) id.metadata-grain metadata-grain) ~]
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
        [%egg-args ~]
      ~
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
    ++  enjs-arguments
      =,  enjs:format
      |=  a=arguments
      |^
      ^-  ^json
      %+  frond  -.a
      ?-    -.a
          %give
        (give-or-mint +.a)
      ::
          %take
        %-  pairs
        :~  [%to %s (scot %ux to.a)]
            [%account ?~(account.a ~ [%s (scot %ux u.account.a)])]
            [%from-rice %s (scot %ux from-rice.a)]
            [%amount (numb amount.a)]
        ==
      ::
          %set-allowance
        %-  pairs
        :+  [%who %s (scot %ux who.a)]
          [%amount (numb amount.a)]
        ~
      ::
          %mint
        %-  pairs
        :+  [%token %s (scot %ux token.a)]
          [%mints (mints mints.a)]
        ~
      ::
          %deploy
        %-  pairs
        :~  [%distribution (distribution distribution.a)]
            [%minters (minters minters.a)]
            [%name %s name.a]
            [%symbol %s symbol.a]
            [%decimals (numb decimals.a)]
            [%cap (numb cap.a)]
            [%mintable %b mintable.a]
        ==
      ==
      ::
      ++  give-or-mint
        |=  [to=id account=(unit id) amount=@ud]
        %-  pairs
        :^    [%to %s (scot %ux to)]
            [%account ?~(account ~ [%s (scot %ux u.account)])]
          [%amount (numb amount)]
        ~
      ::
      ++  mints
        |=  set-mint=(set mint)
        ^-  ^json
        :-  %a
        %+  turn  ~(tap in set-mint)
        |=  m=mint
        (give-or-mint m)
      ::
      ++  distribution
        |=  set-id-bal=(set [id @ud])
        ^-  ^json
        :-  %a
        %+  turn  ~(tap in set-id-bal)
        |=  [i=id bal=@ud]
        %-  pairs
        :+  [%id %s (scot %ux i)]
          [%bal (numb bal)]
        ~
      --
    ::
    ++  minters
      set-id
    ::
    ++  set-id
      =,  enjs:format
      |=  set-id=(set id)
      ^-  ^json
      :-  %a
      %+  turn  ~(tap in set-id)
      |=  i=id
      [%s (scot %ux i)]
    ::
    +$  token-metadata
      $:  name=@t           ::  the name of a token (not unique!)
          symbol=@t         ::  abbreviation (also not unique)
          decimals=@ud      ::  granularity, minimum 0, maximum 18
          supply=@ud        ::  total amount of token in existence
          cap=(unit @ud)    ::  supply cap (~ if mintable is false)
          mintable=?        ::  whether or not more can be minted
          minters=(set id)  ::  pubkeys permitted to mint, if any
          deployer=id       ::  pubkey which first deployed token
          salt=@            ::  data added to hash for rice IDs of this token
                            ::  (currently hashed: symbol+deployer)
      ==
    ::
    +$  account
      $:  balance=@ud                     ::  the amount of tokens someone has
          allowances=(map sender=id @ud)  ::  a map of pubkeys they've permitted to spend their tokens and how much
          metadata=id                     ::  address of the rice holding this token's metadata
      ==
    ::
    ::  patterns of arguments supported by this contract
    ::  "args" in input must fit one of these molds
    ::
    +$  mint  [to=id account=(unit id) amount=@ud]  ::  helper type for mint
    +$  arguments
      $%  ::  token holder actions
          ::
          [%give to=id account=(unit id) amount=@ud]
          [%take to=id account=(unit id) from-rice=id amount=@ud]
          [%set-allowance who=id amount=@ud]  ::  (to revoke, call with amount=0)
          ::  token management actions
          ::
          [%mint token=id mints=(set mint)]  ::  can only be called by minters, can't mint above cap
          $:  %deploy
              distribution=(set [id bal=@ud])  ::  sums to <= cap if mintable, == cap otherwise
              minters=(set id)                 ::  ignored if !mintable, otherwise need at least one
              name=@t
              symbol=@t                        ::  size limit?
              decimals=@ud                     ::  min 0, max 18
              cap=@ud                          ::  is equivalent to total supply unless token is mintable
              mintable=?
          ==
      ==
    --
  ++  noun
    ~
  --
--
