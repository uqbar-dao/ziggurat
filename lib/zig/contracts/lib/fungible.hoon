::  /+  *zig-sys-smart
|%
::
::  molds used by writes to this contract
::
++  sur
  |%
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
        nonce=@ud                       ::  necessary for gasless approves
    ==
  ::
  +$  approve
    $:  from=id       ::  pubkey giving
        to=id         ::  pubkey permitted to take
        amount=@ud    ::  how many tokens the taker can take
        nonce=@ud     ::  current nonce of the giver
        deadline=@da  ::  how long this approve is valid
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
        [%take-with-sig to=id account=(unit id) from-rice=id amount=@ud nonce=@ud deadline=@da =sig]
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
::
++  lib
  |%
  ++  enjs
    =,  enjs:format
    |%
    ++  account
      |^
      |=  =account:sur
      ^-  json
      %-  pairs
      :*  [%balance (numb balance.account)]
          [%allowances (allowances allowances.account)]
          [%metadata (metadata metadata.account)]
          [%nonce (numb nonce.account)]
          ~
      ==
      ::
      ++  allowances
        |=  allowances=(map id @ud)
        ^-  json
        %-  pairs
        %+  turn  ~(tap by allowances)
        |=  [i=id allowance=@ud]
        [(scot %ux i) (numb allowance)]
      ::
      ++  metadata  ::  TODO: grab token-metadata?
        |=  md-id=id
        [%s (scot %ux md-id)]
      --
    ::
    ++  token-metadata
      |=  md=token-metadata:sur
      ^-  json
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
    ++  arguments
      |=  a=arguments:sur
      |^
      ^-  json
      %+  frond  -.a
      ?-    -.a
      ::
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
          %take-with-sig  ::  placeholder, not finished
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
        |=  set-mint=(set mint:sur)
        ^-  json
        :-  %a
        %+  turn  ~(tap in set-mint)
        |=  =mint:sur
        (give-or-mint mint)
      ::
      ++  distribution
        |=  set-id-bal=(set [id @ud])
        ^-  json
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
      |=  set-id=(set id)
      ^-  json
      :-  %a
      %+  turn  ~(tap in set-id)
      |=  i=id
      [%s (scot %ux i)]
    --
  --
--
