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
    ==
  ::
  ::  item id is # in collection (<=supply)
  +$  item  
    $:  collection=id
        item-num=@ud  :: used to be id=@ud
        allowance=(unit id)
        item-contents
    ==
  +$  item-contents
    $:  data=(set [@t @t])  ::  path (remote scry source)
        desc=@t
        uri=@t
        transferrable=?
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
++  lib
  |%
  ++  enjs
    =,  enjs:format
    |%
    ++  item
      |=  =item:sur
      ^-  json
      %-  pairs
      :^    [%id (numb item-num.item)]
          ?~  allowance.item  [%allowance ~]
          [%allowance %s (scot %ux u.allowance.item)]
        [%item-contents (item-contents +>+.item)]
      ~
    ::
    ++  collection-metadata
      |^
      |=  md=collection-metadata:sur
      ^-  json
      %-  pairs
      :~  [%name %s name.md]
          [%symbol %s symbol.md]
          [%attributes (attributes attributes.md)]
          [%supply (numb supply.md)]
          [%cap ?~(cap.md ~ (numb u.cap.md))]
          [%mintable %b mintable.md]
          [%minters (minters minters.md)]
          [%deployer %s (scot %ux deployer.md)]
          [%salt (numb salt.md)]
      ==
      ::
      ++  attributes
        |=  a=(set @t)
        ^-  json
        :-  %a
        %+  turn  ~(tap in a)
        |=  attribute=@t
        [%s attribute]
      --
    ::
    ++  arguments
      |=  a=arguments:sur
      |^
      ^-  json
      %+  frond  -.a
      ?-    -.a
      ::
          %give
        %-  pairs
        ~[[%to %s (scot %ux to.a)]]
      ::
          %take  ~
      ::
          %set-allowance
        %-  pairs
        ?~  who.a  ~
        ~[[%who %s (scot %ux u.who.a)]]
      ::
          %mint
        %-  pairs
        :^    [%collection %s (scot %ux collection.a)]
            [%to %s (scot %ux to.a)]
          [%item-contents (item-contents +>+.a)]
        ~
      ::
          %deploy
        %-  pairs
        :~  [%distribution (distribution distribution.a)]
            [%minters (minters minters.a)]
            [%name %s name.a]
            [%symbol %s symbol.a]
            [%attributes (attributes attributes.a)]
            [%cap (numb cap.a)]
            [%mintable %b mintable.a]
        ==
      ==
      ::
      ++  distribution
        |=  distribution=(jug id item-contents:sur)
        ^-  json
        %-  pairs
        %+  turn  ~(tap by distribution)
        |=  [i=id ics=(set item-contents:sur)]
        [(scot %ux i) (set-item-contents ics)]
      ::
      ++  set-item-contents
        |=  ics=(set item-contents:sur)
        ^-  json
        :-  %a
        %+  turn  ~(tap in ics)
        |=  ic=item-contents:sur
        (item-contents ic)
      ::
      ++  attributes
        |=  attributes=(set @t)
        ^-  json
        :-  %a
        %+  turn  ~(tap in attributes)
        |=  attribute=@t
        [%s attribute]
      --
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
    ::
    ++  item-contents
      |=  =item-contents:sur
      %-  pairs
      :~  [%data (item-contents-data data.item-contents)]
          [%desc %s desc.item-contents]
          [%uri %s uri.item-contents]
          [%transferrable %b transferrable.item-contents]
      ==
    ::
    ++  item-contents-data  ::  TODO: what is this?
      |=  icd=(set [@t @t])
      ^-  json
      :-  %a
      %+  turn  ~(tap in icd)
      |=  [p=@t q=@t]
      :-  %a
      ~[[%s p] [%s q]]
    --
  --
--
