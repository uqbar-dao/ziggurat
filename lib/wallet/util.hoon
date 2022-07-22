/-  *wallet, ui=indexer
=>  |%
    +$  card  card:agent:gall
    --
|%
++  hash-egg
  |=  =egg:smart
  ^-  @ux
  ::  hash the immutable+unique aspects of a transaction
  `@ux`(sham [shell yolk]:egg)
::
++  tx-update-card
  |=  [=egg:smart args=(unit supported-args)]
  ^-  card
  =+  [%tx-status (hash-egg egg) egg args]
  [%give %fact ~[/tx-updates] %zig-wallet-update !>(-)]
::
++  create-holder-and-id-subs
  |=  [pubkeys=(set @ux) our=@p]
  ^-  (list card)
  %+  weld
    %+  turn
      ~(tap in pubkeys)
    |=  k=@ux
    =-  [%pass - %agent [our %uqbar] %watch -]
    :: /id/(scot %ux k)
    /id/0x0/(scot %ux k)
  %+  turn
    ~(tap in pubkeys)
  |=  k=@ux
  =-  [%pass - %agent [our %uqbar] %watch -]
  :: /holder/(scot %ux k)
  /holder/0x0/(scot %ux k)
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
  =-  [%pass - %agent [indexer %indexer] %watch -]
  /grain/(scot %ux id.p.grain)
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
  |=  [=update:ui our=@ux =metadata-store]
  ^-  book
  =/  =book  *book
  ?.  ?=(%grain -.update)  book
  =/  grains-list  `(list [@da =batch-location:ui =grain:smart])`(zing ~(val by grains.update))
  |-  ^-  ^book
  ?~  grains-list  book
  =/  =grain:smart  grain.i.grains-list
  ::  currently only storing owned *rice*
  ?.  ?=(%& -.grain)  $(grains-list t.grains-list)
  ::  determine type token/nft/unknown
  =/  =token-type
    ?~  stored=(~(get by metadata-store) salt.p.grain)
      %unknown
    -.u.stored
  %=    $
      book
    %+  ~(put by book)
      [town-id.p.grain lord.p.grain salt.p.grain]
    [token-type grain]
    ::
    grains-list  t.grains-list
  ==
::
::  TODO: replace this whole janky system with a contract read that returns the type of the its rice
::
++  find-new-metadata
  |=  [=book our=ship =metadata-store [our=ship now=time]]
  =/  book=(list [[town=id:smart lord=id:smart salt=@] [=token-type =grain:smart]])  ~(tap by book)
  |-  ^-  ^metadata-store
  ?~  book  metadata-store
  ?:  (~(has by metadata-store) salt.i.book)  $(book t.book)
  ::  if we don't know the type of an asset, we need to try and fit it to
  ::  a mold we know of. this is not great and should be eventually provided
  ::  from some central authority
  ?.  ?=(%& -.grain.i.book)  $(book t.book)
  =*  rice  p.grain.i.book
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
  =/  update  .^(update:ui %gx /(scot %p our)/indexer/(scot %da now)/grain/(scot %ux id)/noun)
  ?~  update
    ~&  >>>  "%wallet: failed to find matching metadata for a grain we hold"
    ~
  ?>  ?=(%grain -.update)
  =/  meta-grain=grain:smart  +.+.-.+.-:~(tap by grains.update)
  ?>  ?=(%& -.meta-grain)
  =/  found=(unit asset-metadata)
    ?+  token-type  ~
      %token  `[%token ;;(token-metadata data.p.meta-grain)]
      %nft    `[%nft ;;(nft-metadata data.p.meta-grain)]
    ==
  ?~  found  ~
  ?>  =(salt.p.meta-grain salt.u.found)
  found
--
