::  UQ| token standard v0.1
::  last updated: 2022/07/14
::
/+  *zig-sys-smart
|%
++  sur
  |%
  ::
  ::  types that populate grains this standard generates
  ::
  +$  token-metadata
    $:  name=@t           ::  the name of a token (not unique!)
        symbol=@t         ::  abbreviation (also not unique)
        decimals=@ud      ::  granularity (maximum defined by implementation)
        supply=@ud        ::  total amount of token in existence
        cap=(unit @ud)    ::  supply cap (~ if mintable is false)
        mintable=?        ::  whether or not more can be minted
        minters=(set id)  ::  pubkeys permitted to mint, if any
        deployer=id       ::  pubkey which first deployed token
        salt=@            ::  salt value for rice holding accounts of this token
    ==
  ::
  +$  account
    $:  balance=@ud                     ::  the amount of tokens someone has
        allowances=(map sender=id @ud)  ::  a map of pubkeys they've permitted to spend their tokens and how much
        metadata=id                     ::  address of the rice holding this token's metadata
    ==
  ::
  ::  patterns of arguments supported by this contract
  ::  "action" in input must fit one of these molds
  ::
  +$  mint  [to=id account=(unit id) amount=@ud]  ::  helper type for mint
  +$  action
    $%  ::  token holder actions
        ::
        [%give to=id amount=@ud]
        [%take to=id account=(unit id) from-account=id amount=@ud]
        [%set-allowance who=id amount=@ud]  ::  (to revoke, call with amount=0)
        ::  token management actions
        ::
        [%mint token=id mints=(set mint)]  ::  can only be called by minters, can't mint above cap
        $:  %deploy
            distribution=(set [id bal=@ud])  ::  sums to <= cap if mintable, == cap otherwise
            minters=(set id)                 ::  ignored if !mintable, otherwise need at least one
            name=@t
            symbol=@t
            decimals=@ud
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
      :~  [%balance (numb balance.account)]
          [%allowances (allowances allowances.account)]
          [%metadata (metadata metadata.account)]
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
      ++  metadata
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
    ++  action
      |=  a=action:sur
      |^
      ^-  json
      %+  frond  -.a
      ?-    -.a
      ::
          %give
        %-  pairs
        :~  [%to %s (scot %ux to.a)]
            [%amount (numb amount.a)]
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
        :~  [%who %s (scot %ux who.a)]
            [%amount (numb amount.a)]
        ==
      ::
          %mint
        %-  pairs
        :~  [%token %s (scot %ux token.a)]
            [%mints (mints mints.a)]
        ==
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
      ++  mints
        |=  set-mint=(set mint:sur)
        ^-  json
        :-  %a
        %+  turn  ~(tap in set-mint)
        |=  =mint:sur
        %-  pairs
        :~  [%to %s (scot %ux to.mint)]
            [%account ?~(account.mint ~ [%s (scot %ux u.account.mint)])]
            [%amount (numb amount.mint)]
        ==
      ::
      ++  distribution
        |=  set-id-bal=(set [id @ud])
        ^-  json
        :-  %a
        %+  turn  ~(tap in set-id-bal)
        |=  [i=id bal=@ud]
        %-  pairs
        :~  [%id %s (scot %ux i)]
            [%bal (numb bal)]
        ==
      --
    ::
    ++  minters
      |=  set-id=(set id)
      ^-  json
      :-  %a
      %+  turn  ~(tap in set-id)
      |=  i=id
      [%s (scot %ux i)]
    --
  --
--
