/-  *wallet, indexer
/+  *wallet-util
=,  enjs:format
|%
++  parse-asset
  |=  [=token-type =grain:smart]
  ^-  [p=@t q=json]
  ?.  ?=(%& -.grain)  !!
  :-  (scot %ux id.p.grain)
  %-  pairs
  :~  ['id' [%s (scot %ux id.p.grain)]]
      ['lord' [%s (scot %ux lord.p.grain)]]
      ['holder' [%s (scot %ux holder.p.grain)]]
      ['town' [%s (scot %ux town-id.p.grain)]]
      ['token_type' [%s (scot %tas token-type)]]
      :-  'data'
      %-  pairs
      ?+    token-type  ~[['unknown_data_structure' [%s '?']]]
          %token
        =+  ;;(token-account data.p.grain)
        :~  ['balance' (numb balance.-)]
            ['metadata' [%s (scot %ux metadata.-)]]
            ['salt' [%s (scot %u salt.p.grain)]]
        ==
      ::
          %nft
        =+  ;;(nft-account data.p.grain)
        :~  ['metadata' [%s (scot %ux metadata.-)]]
            ['salt' [%s (scot %u salt.p.grain)]]
            :-  'items'
            %-  pairs
            %+  turn  ~(tap by items.-)
            |=  [id=@ud =item]
            :-  (scot %ud id)
            %-  pairs
            :~  ['desc' [%s desc.item]]
                ['attributes' [%s 'TODO...']]
                ['URI' [%s uri.item]]
            ==
        ==
      ==
  ==
::
++  parse-transaction
  |=  [hash=@ux t=egg:smart args=(unit supported-args)]
  ^-  [p=@t q=json]
  ?.  ?=(account:smart from.shell.t)  !!
  :-  (scot %ux hash)
  %-  pairs
  :~  ['from' [%s (scot %ux id.from.shell.t)]]
      ['nonce' (numb nonce.from.shell.t)]
      ['to' [%s (scot %ux to.shell.t)]]
      ['rate' (numb rate.shell.t)]
      ['budget' (numb budget.shell.t)]
      ['town' [%s (scot %ux town-id.shell.t)]]
      ['status' (numb status.shell.t)]
      ?~  args  ['args' [%s 'received']]
      :-  'args'
      %-  frond
      :-  (scot %tas -.args)
      %-  pairs
      ?-    -.u.args
          %give
        :~  ['salt' [%s (scot %ux salt.u.args)]]
            ['to' [%s (scot %ux to.u.args)]]
            ['amount' (numb amount.u.args)]
        ==
          %give-nft
        :~  ['salt' [%s (scot %ux salt.u.args)]]
            ['to' [%s (scot %ux to.u.args)]]
            ['item-id' (numb item-id.u.args)]
        ==
      ::
          %custom
        ~[['args' [%s args.u.args]]]
      ==
  ==
--
