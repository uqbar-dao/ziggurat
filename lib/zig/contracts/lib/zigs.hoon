/+  *zig-sys-smart
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
+$  action
  $%  [%give to=id account=(unit id) amount=@ud budget=@ud]
      [%take to=id account=(unit id) from-account=id amount=@ud]
      [%set-allowance who=id amount=@ud]  ::  (to revoke, call with amount=0)
  ==
--
