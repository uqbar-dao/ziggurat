::  nft.hoon [UQ| DAO]
::
::  NFT standard. Provides abilities similar to ERC-721 tokens, also ability
::  to deploy and mint new sets of tokens.
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
  +$  collection-metadata
    $:  name=@t
        symbol=@t
        attributes=(set @t)
        supply=@ud
        cap=(unit @ud)  ::  (~ if mintable is false)
        mintable=?      ::  automatically set to %.n if supply == cap
        minters=(set id)
        deployer=id
        salt=@
    ==
  ::
  +$  account  ::  holds your items from a given collection
    $:  metadata=id
        items=(map @ud item)      :: maps to item ids
        allowances=(jug id @ud)   :: maps to item ids
        full-allowances=(set id)  :: those with permission across all items
    ==
  ::
  ::  item id is # in collection (<=supply)
  +$  item  [id=@ud item-contents]
  +$  item-contents
    $:  data=(set [@t @t])  ::  path (remote scry source)
        desc=@t
        uri=@t
        transferrable=?
    ==
  ::
  +$  mint
    $:  to=id
        account=(unit id)
        items=(set item-contents)
    ==
  +$  arguments
    $%  [%give to=id account=(unit id) item-id=@ud]
        [%take to=id account=(unit id) from-rice=id item-id=@ud]
        ::  full-set flag gives taker permission to any item in account
        [%set-allowance who=id full-set=? items=(map @ud ?)]
        [%mint token=id mints=(set mint)]
        $:  %deploy
            distribution=(jug id item-contents)
            minters=(set id)
            name=@t
            symbol=@t
            attributes=(set @t)
            cap=@ud
            mintable=?
    ==  ==
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
        %give
      =/  giv=grain  -:~(val by grains.inp)
      ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
      =/  giver=account  ;;(account data.p.germ.giv)
      =/  =item  (~(got by items.giver) item-id.args)
      ?>  transferrable.item  ::  asset item is transferrable
      ?~  account.args
        =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new=grain
          [- me.cart to.args town-id.cart [%& salt.p.germ.giv [metadata.giver ~ ~ ~]]]
        :+  %|
          :+  me.cart  town-id.cart
          [caller.inp `[%give to.args `id.new item-id.args] (silt ~[id.giv]) (silt ~[id.new])]
        [~ (malt ~[[id.new new]]) ~]
      =/  rec=grain  (~(got by owns.cart) u.account.args)
      ?>  &(=(holder.rec to.args) ?=(%& -.germ.rec))
      =/  receiver=account  ;;(account data.p.germ.rec)
      ?>  =(metadata.receiver metadata.giver)
      =:  data.p.germ.giv  giver(items (~(del by items.giver) item-id.args))
          data.p.germ.rec  receiver(items (~(put by items.receiver) item-id.args item))
      ==
      [%& (malt ~[[id.giv giv] [id.rec rec]]) ~ ~]
    ::
        %take
      =/  giv=grain  (~(got by owns.cart) from-rice.args)
      ?>  ?=(%& -.germ.giv)
      =/  giver=account  ;;(account data.p.germ.giv)
      ?>  ?|  (~(has in full-allowances.giver) caller-id)
              (~(has ju allowances.giver) caller-id item-id.args)
          ==
      =/  =item  (~(got by items.giver) item-id.args)
      ?~  account.args
        =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new=grain
          [- me.cart to.args town-id.cart [%& salt.p.germ.giv [metadata.giver ~ ~ ~]]]
        :+  %|
          :+  me.cart  town-id.cart
          [caller.inp `[%take to.args `id.new id.giv item-id.args] ~ (silt ~[id.giv id.new])]
        [~ (malt ~[[id.new new]]) ~]
      =/  rec=grain  (~(got by owns.cart) u.account.args)
      ?>  &(=(holder.rec to.args) ?=(%& -.germ.rec))
      =/  receiver=account  ;;(account data.p.germ.rec)
      ?>  =(metadata.receiver metadata.giver)
      =:  data.p.germ.rec  receiver(items (~(put by items.receiver) item-id.args item))
          data.p.germ.giv
        %=  giver
          items  (~(del by items.giver) item-id.args)
          allowances  (~(del ju allowances.giver) caller-id item-id.args)
        ==
      ==
      [%& (malt ~[[id.giv giv] [id.rec rec]]) ~ ~]
    ::
        %set-allowance
      =/  acc=grain  -:~(val by grains.inp)
      ?>  !=(who.args holder.acc)
      ?>  &(=(lord.acc me.cart) ?=(%& -.germ.acc))
      =/  =account  ;;(account data.p.germ.acc)
      ?:  full-set.args
        ::  give full permission
        =.  data.p.germ.acc
          account(full-allowances (~(put in full-allowances.account) who.args))
        [%& (malt ~[[id.acc acc]]) ~ ~]
      ::  loop through items.args and set individual permissions
      =/  items=(list [@ud ?])  ~(tap by items.args)
      |-
      ?~  items
        ::  revoke full permission
        =.  full-allowances.account  (~(del in full-allowances.account) who.args)
        [%& (malt ~[[id.acc acc(data.p.germ account)]]) ~ ~]
      %=  $
        items  t.items
        ::
          allowances.account
        ?:  +.i.items
          (~(put ju allowances.account) who.args -.i.items)
        (~(del ju allowances.account) who.args -.i.items)
      ==
    ::
        %mint
      ::  expects token metadata in owns.cart
      =/  tok=grain  (~(got by owns.cart) token.args)
      ?>  &(=(lord.tok me.cart) ?=(%& -.germ.tok))
      =/  meta  ;;(collection-metadata data.p.germ.tok)
      ::  first, check if token is mintable
      ?>  &(mintable.meta ?=(^ cap.meta) ?=(^ minters.meta))
      ::  check if mint will surpass supply cap
      ?>  (gth u.cap.meta (add supply.meta ~(wyt in mints.args)))
      ::  TODO validate attributes
      ::  cleared to execute!
      =/  next-item-id  supply.meta
      ::  for accounts which we know rice of, find in owns.cart
      ::  and alter. for others, generate id and add to c-call
      =/  changed-rice  (malt ~[[id.tok tok]])
      =/  issued-rice   *(map id grain)
      =/  mints         ~(tap in mints.args)
      =/  next-mints    *(set mint)
      |-
      ?~  mints
        ::  update metadata token with new supply
        =.  data.p.germ.tok
          %=  meta
            supply    next-item-id
            mintable  ?:(=(u.cap.meta supply.meta) %.y %.n)
          ==
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
          [- me.cart to.i.mints town-id.cart [%& salt.meta [token.args ~ ~ ~]]]
        %=  $
          mints   t.mints
          issued-rice  (~(put by issued-rice) id.new new)
          next-mints   (~(put in next-mints) [to.i.mints `id.new items.i.mints])
        ==
      ::  have rice, can modify
      =/  =grain  (~(got by owns.cart) u.account.i.mints)
      ?>  &(=(lord.grain me.cart) ?=(%& -.germ.grain))
      =/  acc  ;;(account data.p.germ.grain)
      ?>  =(metadata.acc token.args)
      ::  create map of items in this mint to unify with accounts
      =/  mint-list  ~(tap in items.i.mints)
      =/  new-items=(map @ud item)
        =+  new-items=*(map @ud item)
        |-
        ?~  mint-list
          new-items
        =+  [+(next-item-id) i.mint-list]
        %=  $
          mint-list  t.mint-list
          new-items      (~(put by new-items) -.- -)
          next-item-id   +(next-item-id)
        ==
      =.  data.p.germ.grain  acc(items (~(uni by items.acc) new-items))
      $(mints t.mints, changed-rice (~(put by changed-rice) id.grain grain))
    ::
        %deploy
      ::  no rice expected as input, only arguments
      ::  if mintable, enforce minter set not empty
      ?>  ?:(mintable.args ?=(^ minters.args) %.y)
      ::  if !mintable, enforce distribution adds up to cap
      ::  otherwise, enforce distribution < cap
      =/  distribution-total=@ud
        %+  roll
          %+  turn  ~(tap by distribution.args)
          |=  [@ ics=(set item-contents)]
          ~(wyt in ics)
        add
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
            ^-  collection-metadata
            :*  name.args
                symbol.args
                attributes.args
                supply=distribution-total
                ?:(mintable.args `cap.args ~)
                mintable.args
                minters.args
                deployer=caller-id
                salt
        ==  ==
      ::  generate accounts
      =+  next-item-id=0
      =/  accounts
        %-  ~(gas by *(map id grain))
        %+  turn  ~(tap by distribution.args)
        |=  [=id items=(set item-contents)]
        =/  mint-list  ~(tap in items)
        =/  new-items=(map @ud item)
          =+  new-items=*(map @ud item)
          |-
          ?~  mint-list
            new-items
          =+  [+(next-item-id) i.mint-list]
          %=  $
            mint-list  t.mint-list
            new-items      (~(put by new-items) -.- -)
            next-item-id   +(next-item-id)
          ==
        =+  (fry-rice id me.cart town-id.cart salt)
        :-  -
        [- me.cart id town-id.cart [%& salt [id.metadata-grain new-items ~ ~]]]
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
      ?.  ?=([@ @ ?(~ ^) @ ?(~ [~ @]) ? ?(~ ^) @ @] data.p.germ.g)
        (enjs-account ;;(account data.p.germ.g))
      (enjs-collection-metadata ;;(collection-metadata data.p.germ.g))
    ::
        [%egg-args @ ~]
      %-  enjs-arguments
      ;;(arguments (cue (slav %ud i.t.args)))
    ==
    ::
    ++  enjs-account
      =,  enjs:format
      |^
      |=  acct=account
      ^-  ^json
      %-  pairs
      :~  [%metadata (enjs-metadata metadata.acct)]
          [%items (enjs-item-map items.acct)]
          [%allowances (enjs-allowances allowances.acct)]
          [%full-allowances (enjs-full-allowances full-allowances.acct)]
      ==
      ::
      ++  enjs-metadata  ::  TODO: grab token-metadata?
        |=  md-id=id
        [%s (scot %ux md-id)]
      ::
      ++  enjs-item-map
        |=  im=(map @ud item)
        ^-  ^json
        %-  pairs
        %+  turn  ~(tap by im)
        |=  [nft=@ud i=item]
        [(scot %ud nft) (enjs-item i)]
      ::
      ++  enjs-allowances
        |=  a=(jug id @ud)
        ^-  ^json
        %-  pairs
        %+  turn  ~(tap by a)
        |=  [i=id nfts=(set @ud)]
        [(scot %ux i) (enjs-nfts nfts)]
      ::
      ++  enjs-nfts
        |=  nfts=(set @ud)
        :-  %a
        %+  turn  ~(tap in nfts)
        |=  nft=@ud
        (numb nft)
      ::
      ++  enjs-full-allowances
        enjs-set-id
      ::
      ++  enjs-item
        |=  i=item
        %-  pairs
        :+  [%id (numb id.i)]
          [%item-contents (enjs-item-contents +.i)]
        ~
      --
    ::
    ++  enjs-collection-metadata
      =,  enjs:format
      |^
      |=  md=collection-metadata
      ^-  ^json
      %-  pairs
      :~  [%name %s name.md]
          [%symbol %s symbol.md]
          [%attributes (enjs-attributes attributes.md)]
          [%supply (numb supply.md)]
          [%cap ?~(cap.md ~ (numb u.cap.md))]
          [%mintable %b mintable.md]
          [%minters (enjs-minters minters.md)]
          [%deployer %s (scot %ux deployer.md)]
          [%salt (numb salt.md)]
      ==
      ::
      ++  enjs-attributes
        |=  a=(set @t)
        ^-  ^json
        :-  %a
        %+  turn  ~(tap in a)
        |=  attribute=@t
        [%s attribute]
      --
    ::
    ++  enjs-arguments
      =,  enjs:format
      |=  a=arguments
      |^
      ^-  ^json
      %+  frond  -.a
      ?-    -.a
          %give
        %-  pairs
        :^    [%to %s (scot %ux to.a)]
            [%account ?~(account.a ~ [%s (scot %ux u.account.a)])]
          [%item-id (numb item-id.a)]
        ~
      ::
          %take
        %-  pairs
        :~  [%to %s (scot %ux to.a)]
            [%account ?~(account.a ~ [%s (scot %ux u.account.a)])]
            [%from-rice %s (scot %ux from-rice.a)]
            [%item-id (numb item-id.a)]
        ==
      ::
          %set-allowance
        %-  pairs
        :^    [%who %s (scot %ux who.a)]
            [%full-set %b full-set.a]
          [%items (enjs-set-allowance-items items.a)]
        ~
      ::
          %mint
        %-  pairs
        :+  [%token %s (scot %ux token.a)]
          [%mints (enjs-mints mints.a)]
        ~
      ::
          %deploy
        %-  pairs
        :~  [%distribution (enjs-distribution distribution.a)]
            [%minters (enjs-minters minters.a)]
            [%name %s name.a]
            [%symbol %s symbol.a]
            [%attributes (enjs-attributes attributes.a)]
            [%cap (numb cap.a)]
            [%mintable %b mintable.a]
        ==
      ==
      ::
      ++  enjs-set-allowance-items
        |=  items=(map @ud ?)
        ^-  ^json
        %-  pairs
        %+  turn  ~(tap by items)
        |=  [nft=@ud allowed=?]
        [(scot %ud nft) %b allowed]
      ::
      ++  enjs-mints
        |=  mints=(set mint)
        ^-  ^json
        :-  %a
        %+  turn  ~(tap in mints)
        |=  m=mint
        %-  pairs
        :^    [%to %s (scot %ux to.m)]
            [%account ?~(account.m ~ [%s (scot %ux u.account.m)])]
          [%items (enjs-set-item-contents items.m)]
        ~
      ::
      ++  enjs-distribution
        |=  distribution=(jug id item-contents)
        ^-  ^json
        %-  pairs
        %+  turn  ~(tap by distribution)
        |=  [i=id ics=(set item-contents)]
        [(scot %ux i) (enjs-set-item-contents ics)]
      ::
      ++  enjs-set-item-contents
        |=  ics=(set item-contents)
        ^-  ^json
        :-  %a
        %+  turn  ~(tap in ics)
        |=  ic=item-contents
        (enjs-item-contents ic)
      ::
      ++  enjs-attributes
        |=  attributes=(set @t)
        ^-  ^json
        :-  %a
        %+  turn  ~(tap in attributes)
        |=  attribute=@t
        [%s attribute]
      --
    ::
    ++  enjs-minters
      enjs-set-id
    ::
    ++  enjs-set-id
      =,  enjs:format
      |=  set-id=(set id)
      ^-  ^json
      :-  %a
      %+  turn  ~(tap in set-id)
      |=  i=id
      [%s (scot %ux i)]
    ::
    ++  enjs-item-contents
      =,  enjs:format
      |=  ic=item-contents
      %-  pairs
      :~  [%data (enjs-item-contents-data data.ic)]
          [%desc %s desc.ic]
          [%uri %s uri.ic]
          [%transferrable %b transferrable.ic]
      ==
    ::
    ++  enjs-item-contents-data  ::  TODO: what is this?
      =,  enjs:format
      |=  icd=(set [@t @t])
      ^-  ^json
      :-  %a
      %+  turn  ~(tap in icd)
      |=  [p=@t q=@t]
      :-  %a
      ~[[%s p] [%s q]]
    ::
    +$  collection-metadata
      $:  name=@t
          symbol=@t
          attributes=(set @t)
          supply=@ud
          cap=(unit @ud)  ::  (~ if mintable is false)
          mintable=?      ::  automatically set to %.n if supply == cap
          minters=(set id)
          deployer=id
          salt=@
      ==
    ::
    +$  account  ::  holds your items from a given collection
      $:  metadata=id
          items=(map @ud item)      :: maps to item ids
          allowances=(jug id @ud)   :: maps to item ids
          full-allowances=(set id)  :: those with permission across all items
      ==
    ::
    ::  item id is # in collection (<=supply)
    +$  item  [id=@ud item-contents]
    +$  item-contents
      $:  data=(set [@t @t])  ::  path (remote scry source)
          desc=@t
          uri=@t
          transferrable=?
      ==
    ::
    +$  mint
      $:  to=id
          account=(unit id)
          items=(set item-contents)
      ==
    +$  arguments
      $%  [%give to=id account=(unit id) item-id=@ud]
          [%take to=id account=(unit id) from-rice=id item-id=@ud]
          ::  full-set flag gives taker permission to any item in account
          [%set-allowance who=id full-set=? items=(map @ud ?)]
          [%mint token=id mints=(set mint)]
          $:  %deploy
              distribution=(jug id item-contents)
              minters=(set id)
              name=@t
              symbol=@t
              attributes=(set @t)
              cap=@ud
              mintable=?
      ==  ==
    --
  ++  noun
    ~
  --
--
