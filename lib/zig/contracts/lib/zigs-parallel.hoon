/+  *zig-sys-smart
|%
+$  token-metadata
  ::  will be automatically inserted into town state
  ::  at instantiation, along with this contract
  ::  hardcoded values included to match token standard
  $:  name=@t
      symbol=@t
      decimals=@ud
      supply=@ud
      cap=~
      mintable=%.n
      minters=~
      deployer=id  ::  will be 0x0
      salt=@       ::  'zigs'
  ==
::
+$  ticket
  $:  value=@ud
      redeemed=?
      metadata=id
  ==
::
+$  account
  $:  balance=@ud
      allowances=(map sender=id @ud)
      metadata=id
  ==
::
+$  action
  $%  [%give to=id amount=@ud budget=@ud]        ::  produces single ticket
      [%take to=id amount=@ud from-account=id]   ::  produces single ticket
      [%give-set tickets=(set [=id amount=@ud]) budget=@ud]       ::  produces ticket(s)
      [%take-set tickets=(set [=id amount=@ud]) from-account=id]  ::  produces ticket(s)
      [%redeem my-account=id]             ::  takes every other grain in embryo and cashes in ticket
      [%set-allowance who=id amount=@ud]  ::  (to revoke, call with amount=0)
  ==
--
