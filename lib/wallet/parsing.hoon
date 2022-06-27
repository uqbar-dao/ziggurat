/-  *wallet, indexer
/+  *wallet-util
=,  enjs:format
|%
++  parse-asset
  |=  [=token-type =grain:smart]
  ^-  [p=@t q=json]
  ?.  ?=(%& -.germ.grain)  !!
  :-  (scot %ux id.grain)
  %-  pairs
  :~  ['id' [%s (scot %ux id.grain)]]
      ['lord' [%s (scot %ux lord.grain)]]
      ['holder' [%s (scot %ux holder.grain)]]
      ['town' [%s (scot %ux town-id.grain)]]
      ['token_type' [%s (scot %tas token-type)]]
      :-  'data'
      %-  pairs
      ?+    token-type  ~[['unknown_data_structure' [%s '?']]]
          %token
        =+  ;;(token-account data.p.germ.grain)
        :~  ['balance' (numb balance.-)]
            ['metadata' [%s (scot %ux metadata.-)]]
            ['salt' [%s (scot %u salt.p.germ.grain)]]
        ==
      ::
          %nft
        =+  ;;(nft-account data.p.germ.grain)
        :~  ['metadata' [%s (scot %ux metadata.-)]]
            ['salt' [%s (scot %u salt.p.germ.grain)]]
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
  ?.  ?=(account:smart from.p.t)  !!
  :-  (scot %ux hash)
  %-  pairs
  :~  ['from' [%s (scot %ux id.from.p.t)]]
      ['nonce' (numb nonce.from.p.t)]
      ['to' [%s (scot %ux to.p.t)]]
      ['rate' (numb rate.p.t)]
      ['budget' (numb budget.p.t)]
      ['town' [%s (scot %ux town-id.p.t)]]
      ['status' (numb status.p.t)]
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
