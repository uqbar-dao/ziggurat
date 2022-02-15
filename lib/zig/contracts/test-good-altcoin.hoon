/+  tiny
=>  |%
    +$  token-data
      $:  total=@ud
          balances=(map id:tiny @ud)
          allowances=(map [owner=id:tiny sender=id:tiny] @ud)
          coinbase-rate=@ud
      ==
    --
|%
++  test-good-altcoin-contract
  ^-  contract:tiny
  |_  [mem=(unit vase) me=id:tiny]
  ++  write
    |=  inp=contract-input:tiny
    ^-  contract-output:tiny
    ?~  args.inp  *contract-output:tiny
    ?~  tgas=(~(get by:tiny rice.inp) me)  *contract-output:tiny
    =/  data  ;;(token-data data.germ.u.tgas)
    =/  caller-id=id:tiny
      ?:  ?=(@ux caller.inp)
        caller.inp
      id.caller.inp
    =*  args  +.u.args.inp
    =.  data.germ.u.tgas
      ?+    -.u.args.inp  data
          %give
        ::  expected args: id, amount
        ?.  ?=([=id:tiny amount=@ud] args)  data
        ::  check our balance to make sure we can afford spend
        ?~  curr-bal=(~(get by:tiny balances.data) id.args)  data
        ?:  (gth:tiny amount.args u.curr-bal)  data
        ::  add to receiver balance, subtract from ours
        =.  balances.data
          ::  this pattern could be a good stdlib function
          %+  %~  jab  by:tiny
              ?.  (~(has by:tiny balances.data) id.args)
                ::  if receiver's account doesn't have a balance, insert
                (~(put by:tiny balances.data) id.args amount.args)
              ::  otherwise, add to their existing balance
              (~(jab by:tiny balances.data) id.args |=(bal=@ud (add:tiny bal amount.args)))
            caller-id
          |=(bal=@ud (sub:tiny bal amount.args))
        data
      ::
          %take
        ::  expected args: from, to, amount
        ?.  ?=([from=id:tiny to=id:tiny amount=@ud] args)  data
        ::  check our allowance to make sure we're approved to spend
        ?~  curr-allow=(~(get by:tiny allowances.data) [from.args caller-id])
          data
        ?:  (gth:tiny amount.args u.curr-allow)  data
        ::  check owner's balance to make sure they can afford spend
        ?~  curr-bal=(~(get by:tiny balances.data) from.args)  data
        ?:  (gth:tiny amount.args u.curr-bal)  data
        ::  adjust allowance and balances to reflect spend
        =:  allowances.data
          %+  ~(jab by:tiny allowances.data)
            [from.args caller-id]
          |=(bal=@ud (sub:tiny bal amount.args))
        ::
            balances.data
          %+  %~  jab  by:tiny
              ?.  (~(has by:tiny balances.data) id.args)
                ::  if receiver's account doesn't have a balance, insert
                (~(put by:tiny balances.data) id.args amount.args)
              ::  otherwise, add to their existing balance
              (~(jab by:tiny balances.data) id.args |=(bal=@ud (add:tiny bal amount.args)))
            caller-id
          |=(bal=@ud (sub:tiny bal amount.args))
        ==
        data
      ::
          %set-allowance
        ::  expected args: sender, amount
        ?.  ?=([sender=id:tiny amount=@ud] args)  data
        data(allowances (~(put by:tiny allowances.data) [caller-id sender.args] amount.args))
      ==
    :*  %result
        %write
        %-  %~  gas by:tiny  *(map:tiny id:tiny grain:tiny)
        ~[[me u.tgas]]
        ~
    ==
  ::
  ++  read
    |=  inp=contract-input:tiny
    ^-  contract-output:tiny
    :+  %result
      %read
    ?~  args.inp  ~
    ?~  tgas=(~(get by:tiny rice.inp) me)  ~
    ::  check lord of tgas here, make sure its us
    =/  data  ;;(token-data data.germ.u.tgas)
    =*  args  +.u.args.inp
    ?+    -.u.args.inp  ~
        %get-balance
      ::  expected args: id
      ?.  ?=(=id:tiny args)  ~
      (~(get by:tiny balances.data) id.args)
    ::
        %get-allowance
      ::  expected args: owner, sender
      ?.  ?=([owner=id:tiny sender=id:tiny] args)  ~
      (~(get by:tiny allowances.data) [owner.args sender.args])
    ::
        %get-total
      ::  expected args: none
      total.data
    ==
  ::
  ++  event
    |=  res=contract-result:tiny
    ^-  contract-output:tiny
    *contract-output:tiny
  --
--
