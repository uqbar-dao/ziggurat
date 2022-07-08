/+  *zig-sys-smart
|%
++  sur
  |%
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
        :: TODO: base-uri=@t and other on-chain data compression
    ==
  ::
  ::  item id is # in collection (<=supply)
  +$  item  
    $:  id=@ud
        allowance=(unit id)
        item-contents
    ==
  +$  item-contents
    $:  data=(set [@t @t])  ::  path (remote scry source)
        desc=@t
        uri=@t
        transferrable=?
    ==
  ::
  +$  mint
    $:  to=id
        items=(set item-contents)
    ==
  +$  arguments
    $%  [%give to=id]
        [%take ~]  ::  TODO: is this correct for no arguments?
        ::  TODO: %give-many, %take-many, %allow-many, %mint-many (as a set)
        [%set-allowance who=(unit id)]
        [%mint collection=id to=id =item-contents]
        $:  %deploy
            distribution=(jug id item-contents)
            minters=(set id)
            name=@t
            symbol=@t
            attributes=(set @t)
            cap=@ud
            mintable=?
        ==
    ==
  --
::
++  lib  ~
  :: |%
  :: ++  enjs
  ::   =,  enjs:format
  ::   |%
  ::   ++  account
  ::     |^
  ::     |=  =account:sur
  ::     ^-  json
  ::     %-  pairs
  ::     :~  [%metadata (metadata metadata.account)]
  ::         [%items (item-map items.account)]
  ::         [%allowances (allowances allowances.account)]
  ::         [%full-allowances (full-allowances full-allowances.account)]
  ::     ==
  ::     ::
  ::     ++  metadata  ::  TODO: grab token-metadata?
  ::       |=  md-id=id
  ::       [%s (scot %ux md-id)]
  ::     ::
  ::     ++  item-map
  ::       |=  im=(map @ud item:sur)
  ::       ^-  json
  ::       %-  pairs
  ::       %+  turn  ~(tap by im)
  ::       |=  [nft=@ud i=item:sur]
  ::       [(scot %ud nft) (item i)]
  ::     ::
  ::     ++  allowances
  ::       |=  a=(jug id @ud)
  ::       ^-  json
  ::       %-  pairs
  ::       %+  turn  ~(tap by a)
  ::       |=  [i=id nft-set=(set @ud)]
  ::       [(scot %ux i) (nfts nft-set)]
  ::     ::
  ::     ++  nfts
  ::       |=  nfts=(set @ud)
  ::       ^-  json
  ::       :-  %a
  ::       %+  turn  ~(tap in nfts)
  ::       |=  nft=@ud
  ::       (numb nft)
  ::     ::
  ::     ++  item
  ::       |=  =item:sur
  ::       ^-  json
  ::       %-  pairs
  ::       :+  [%id (numb id.item)]
  ::         [%item-contents (item-contents +.item)]
  ::       ~
  ::     --
  ::   ::
  ::   ++  collection-metadata
  ::     |^
  ::     |=  md=collection-metadata:sur
  ::     ^-  json
  ::     %-  pairs
  ::     :~  [%name %s name.md]
  ::         [%symbol %s symbol.md]
  ::         [%attributes (attributes attributes.md)]
  ::         [%supply (numb supply.md)]
  ::         [%cap ?~(cap.md ~ (numb u.cap.md))]
  ::         [%mintable %b mintable.md]
  ::         [%minters (minters minters.md)]
  ::         [%deployer %s (scot %ux deployer.md)]
  ::         [%salt (numb salt.md)]
  ::     ==
  ::     ::
  ::     ++  attributes
  ::       |=  a=(set @t)
  ::       ^-  json
  ::       :-  %a
  ::       %+  turn  ~(tap in a)
  ::       |=  attribute=@t
  ::       [%s attribute]
  ::     --
  ::   ::
  ::   ++  arguments
  ::     |=  a=arguments:sur
  ::     |^
  ::     ^-  json
  ::     %+  frond  -.a
  ::     ?-    -.a
  ::     ::
  ::         %give
  ::       %-  pairs
  ::       :^    [%to %s (scot %ux to.a)]
  ::           [%account ?~(account.a ~ [%s (scot %ux u.account.a)])]
  ::         [%item-id (numb item-id.a)]
  ::       ~
  ::     ::
  ::         %take  ~
  ::     ::
  ::         %set-allowance
  ::       %-  pairs
  ::       :-  [%who %s (scot %ux who.a)]
  ::       ~
  ::     ::
  ::         %mint
  ::       %-  pairs
  ::       :+  [%token %s (scot %ux token.a)]
  ::         [%mints (mints mints.a)]
  ::       ~
  ::     ::
  ::         %deploy
  ::       %-  pairs
  ::       :~  [%distribution (distribution distribution.a)]
  ::           [%minters (minters minters.a)]
  ::           [%name %s name.a]
  ::           [%symbol %s symbol.a]
  ::           [%attributes (attributes attributes.a)]
  ::           [%cap (numb cap.a)]
  ::           [%mintable %b mintable.a]
  ::       ==
  ::     ==
  ::     ::
  ::     ++  set-allowance-items
  ::       |=  items=(map @ud ?)
  ::       ^-  json
  ::       %-  pairs
  ::       %+  turn  ~(tap by items)
  ::       |=  [nft=@ud allowed=?]
  ::       [(scot %ud nft) %b allowed]
  ::     ::
  ::     ++  mints
  ::       |=  mints=(set mint:sur)
  ::       ^-  json
  ::       :-  %a
  ::       %+  turn  ~(tap in mints)
  ::       |=  m=mint:sur
  ::       %-  pairs
  ::       :^    [%to %s (scot %ux to.m)]
  ::           [%account ?~(account.m ~ [%s (scot %ux u.account.m)])]
  ::         [%items (set-item-contents items.m)]
  ::       ~
  ::     ::
  ::     ++  distribution
  ::       |=  distribution=(jug id item-contents:sur)
  ::       ^-  json
  ::       %-  pairs
  ::       %+  turn  ~(tap by distribution)
  ::       |=  [i=id ics=(set item-contents:sur)]
  ::       [(scot %ux i) (set-item-contents ics)]
  ::     ::
  ::     ++  set-item-contents
  ::       |=  ics=(set item-contents:sur)
  ::       ^-  json
  ::       :-  %a
  ::       %+  turn  ~(tap in ics)
  ::       |=  ic=item-contents:sur
  ::       (item-contents ic)
  ::     ::
  ::     ++  attributes
  ::       |=  attributes=(set @t)
  ::       ^-  json
  ::       :-  %a
  ::       %+  turn  ~(tap in attributes)
  ::       |=  attribute=@t
  ::       [%s attribute]
  ::     --
  ::   ::
  ::   ++  minters
  ::     set-id
  ::   ::
  ::   ++  set-id
  ::     |=  set-id=(set id)
  ::     ^-  json
  ::     :-  %a
  ::     %+  turn  ~(tap in set-id)
  ::     |=  i=id
  ::     [%s (scot %ux i)]
  ::   ::
  ::   ++  item-contents
  ::     |=  =item-contents:sur
  ::     %-  pairs
  ::     :~  [%data (item-contents-data data.item-contents)]
  ::         [%desc %s desc.item-contents]
  ::         [%uri %s uri.item-contents]
  ::         [%transferrable %b transferrable.item-contents]
  ::     ==
  ::   ::
  ::   ++  item-contents-data  ::  TODO: what is this?
  ::     |=  icd=(set [@t @t])
  ::     ^-  json
  ::     :-  %a
  ::     %+  turn  ~(tap in icd)
  ::     |=  [p=@t q=@t]
  ::     :-  %a
  ::     ~[[%s p] [%s q]]
  ::   --
  :: --
--
