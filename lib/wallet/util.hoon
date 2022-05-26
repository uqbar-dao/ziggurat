/-  *wallet, uqbar-indexer
=>  |%
    +$  card  card:agent:gall
    --
|%
++  hash-egg
  |=  =egg:smart
  ^-  @ux
  ::  hash the immutable+unique aspects of a transaction
  (shax (jam [from.p.egg sig.p.egg town-id.p.egg]))
::
++  tx-update-card
  |=  [=egg:smart args=(unit supported-args)]
  ^-  card
  =+  [%tx-status (hash-egg egg) egg args]
  [%give %fact ~[/tx-updates] %zig-wallet-update !>(-)]
::
++  create-holder-and-id-subs
  |=  [pubkeys=(set @ux) indexer=ship]
  ^-  (list card)
  %+  weld
    %+  turn
      ~(tap in pubkeys)
    |=  k=@ux
    =-  [%pass - %agent [indexer %uqbar-indexer] %watch -]
    /id/(scot %ux k)
  %+  turn
    ~(tap in pubkeys)
  |=  k=@ux
  =-  [%pass - %agent [indexer %uqbar-indexer] %watch -]
  /holder/(scot %ux k)
::
++  clear-holder-and-id-sub
  |=  [id=@ux wex=boat:gall]
  ^-  (list card)
  %+  murn  ~(tap by wex)
  |=  [[=wire =ship =term] *]
  ^-  (unit card)
  ?.  |(=([%id id] wire) =([%holder id] wire))  ~
  `[%pass wire %agent [ship term] %leave ~]
::
++  clear-all-holder-and-id-subs
  |=  wex=boat:gall
  ^-  (list card)
  %+  murn  ~(tap by wex)
  |=  [[=wire =ship =term] *]
  ^-  (unit card)
  ?.  |(?=([%id *] wire) ?=([%holder *] wire))  ~
  `[%pass wire %agent [ship term] %leave ~]  
::
++  create-asset-subscriptions
  |=  [tokens=(map @ux =book) indexer=ship]
  ^-  (list card)
  %+  turn
    ::  find every grain in all our books
    ^-  (list [=token-type grain:smart])
    %-  zing
    %+  turn  ~(tap by tokens)
    |=  [@ux =book]
    ~(val by book)
  |=  [=token-type =grain:smart]
  =-  [%pass - %agent [indexer %uqbar-indexer] %watch -]
  /grain/(scot %ux id.grain)
::
++  clear-asset-subscriptions
  |=  wex=boat:gall
  ^-  (list card)
  %+  murn  ~(tap by wex)
  |=  [[=wire =ship =term] *]
  ^-  (unit card)
  ?.  ?=([%grain *] wire)  ~
  `[%pass wire %agent [ship term] %leave ~]
::
++  indexer-update-to-books
  |=  [=update:uqbar-indexer our=@ux =metadata-store]
  ::  get most recent version of the grain
  ::  TODO replace this with a (way) more efficient strategy
  ::  preferably adding a type to indexer that only contains
  ::  most recent data
  =/  =book  *book
  ?.  ?=(%grain -.update)  book
  =/  grains-list  `(list [=town-location:uqbar-indexer =grain:smart])`~(val by grains.update)
  |-  ^-  ^book
  ?~  grains-list  book
  =/  =grain:smart  grain.i.grains-list
  ::  currently only storing owned *rice*
  ?.  ?=(%& -.germ.grain)  $(grains-list t.grains-list)
  ::  determine type token/nft/unknown
  =/  =token-type
    ?~  stored=(~(get by metadata-store) salt.p.germ.grain)
      %unknown
    -.u.stored
  %=    $
      book
    %+  ~(put by book)
      [town-id.grain lord.grain salt.p.germ.grain]
    [token-type grain]
    ::
    grains-list  t.grains-list
  ==
::
++  find-new-metadata
  |=  [=book our=ship =metadata-store [our=ship now=time]]
  =/  book=(list [[town=@ud lord=id:smart salt=@] [=token-type =grain:smart]])  ~(tap by book)
  |-  ^-  ^metadata-store
  ?~  book  metadata-store
  ?:  (~(has by metadata-store) salt.i.book)  $(book t.book)
  ::  if we don't know the type of an asset, we need to try and fit it to
  ::  a mold we know of. this is not great and should be eventually provided
  ::  from some central authority
  ?.  ?=(%& -.germ.grain.i.book)  $(book t.book)
  =*  rice  p.germ.grain.i.book
  ::  put %token / %nft label inside chain standard?
  =/  found=(unit asset-metadata)
    =+  tok=(mule |.(;;(token-account data.rice)))
    ?:  ?=(%& -.tok)
      (fetch-metadata %token metadata.p.tok [our now])
    =+  nft=(mule |.(;;(nft-account data.rice)))
    ?:  ?=(%& -.nft)
      (fetch-metadata %nft metadata.p.nft [our now])
    ~
  ?~  found  $(book t.book)
  $(book t.book, metadata-store (~(put by metadata-store) salt.rice u.found))
++  fetch-metadata
  |=  [=token-type =id:smart [our=ship now=time]]
  ^-  (unit asset-metadata)
  ::  manually import metadata for a token
  =/  has-grain  .^(? %gx /(scot %p our)/uqbar-indexer/(scot %da now)/has-grain/(scot %ux id)/noun)
  ?.  has-grain
    ~&  >>>  "%wallet: failed to find matching metadata for a grain we hold"
    ~
  =+  .^(update:uqbar-indexer %gx /(scot %p our)/uqbar-indexer/(scot %da now)/grain/(scot %ux id)/noun)
  ?>  ?=(%grain -.-)
  =/  meta-grain=grain:smart  +.+.-:~(tap by grains.-)
  ?>  ?=(%& -.germ.meta-grain)
  =/  found=(unit asset-metadata)
    ?+  token-type  ~
      %token  `[%token ;;(token-metadata data.p.germ.meta-grain)]
      %nft    `[%nft ;;(nft-metadata data.p.germ.meta-grain)]
    ==
  ?~  found  ~
  ?>  =(salt.p.germ.meta-grain salt.u.found)
  found
--
