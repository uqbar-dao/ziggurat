::  /+  *zig-sys-smart
|%
++  sur
  |%
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
      :^    [%balance (numb balance.account)]
          [%allowances (allowances allowances.account)]
        [%metadata (metadata metadata.account)]
      ~
      ::
      ++  allowances
        |=  a=(map id @ud)
        ^-  json
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
    ++  token-metadata
      |^
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
    ::
    ++  arguments
      |=  a=arguments:sur
      ^-  json
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
  --
--
