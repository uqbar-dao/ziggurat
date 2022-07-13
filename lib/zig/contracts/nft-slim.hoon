::  nft-slim.hoon [UQ| DAO]
::
::  Slimmed down version of the NFT standard.
::  Allows deploying and mint new sets of tokens.
::
  /+  *zig-sys-smart
/=  nft  /lib/zig/contracts/lib/nft-slim
=,  nft
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(action u.args.inp) (pin caller.inp))
  ::
  ++  process
    |=  [args=action caller-id=id]
    =,  enjs:format
    ?-    -.args
        %deploy
      ?>  ?=(^ minters.args)  ::  minters must not be empty
      ?>  (gth cap.args 0)    ::  cap cannot be 0
      =/  salt  (sham (cat 3 caller-id symbol.args))
      =/  gid   (fry-rice me.cart me.cart town-id.cart salt)
      =/  collection-grain=grain
        :*  gid
            me.cart
            me.cart
            town-id.cart
            :+  %&  salt
            ^-  collection
            :*  name.args
                symbol.args
                supply=0
                cap.args
                minters.args
                deployer=caller-id
        ==  ==
      =/  =crow  [%deployed (numb gid)]~
      [%& ~ (malt ~[[id.collection-grain collection-grain]]) crow]
    ::
        %mint
      =/  col-grain=grain  -:~(val by owns.cart)
      ?>  ?=(%& -.germ.col-grain)
      =/  collect            ;;(collection data.p.germ.col-grain)
      ::  pre-mint checks
      =/  mintable           (lth supply.collect cap.collect)
      =/  caller-can-mint    (~(has in minters.collect) caller-id)
      =/  below-cap          (gte cap.collect (add supply.collect ~(wyt in items.args)))
      ?>  &(mintable caller-can-mint below-cap)
      ::  cleared to mint!
      =/  items-list  ~(tap in items.args)
      =|  issued=(map id grain)
      =/  [new-issued=(map id grain) new-collect=collection]
        |-
        ?~  items-list
          [issued collect]
        =/  contents        i.items-list
        =.  supply.collect  +(supply.collect)
        =*  next-id         supply.collect
        =/  salt            (sham (cat 3 next-id id.col-grain))
        =/  new-item=grain
          :*  (fry-rice me.cart caller-id town-id.cart salt)
              lord=me.cart
              holder=caller-id
              town-id.cart
              :+  %&  salt
              ^-  item
              :*  id.col-grain
                  next-id
                  contents
              ==
          ==
        =.  issued  (~(put by issued) id.new-item new-item)
        $(items-list t.items-list)
      ::
      =.  data.p.germ.col-grain  new-collect
      =/  minted-ids  (turn ~(tap in ~(key by new-issued)) numb)
      =/  =crow       [%minted a+minted-ids]~
      [%& (malt ~[[id.col-grain col-grain]]) new-issued crow]
    ::
        %give
      =/  item=grain  -:~(val by grains.inp)
      ?>  &(=(lord.item me.cart) ?=(%& -.germ.item))
      ?>  =(caller-id holder.item)
      =/  item-data  ;;(^item data.p.germ.item)
      ?>  transferrable.item-data
      =.  holder.item  to.args
      =/  =crow  [%gave o+(malt ~[['from' (numb caller-id)] ['to' (numb to.args)]])]~
      [%& (malt ~[[id.item item]]) ~ crow]
    ==
  --
::
++  read
  |_  args=path
  ++  json
    ~
  ::
  ++  noun
    ?+    args  !!
        [%collection-data ~]
      ?>  =(1 ~(wyt by owns.cart))
      =/  g=grain  -:~(val by owns.cart)
      ?>  ?=(%& -.germ.g)
      ;;(collection data.p.germ.g)
    ::
        [%mintable ~]
      ?>  =(1 ~(wyt by owns.cart))
      =/  g=grain  -:~(val by owns.cart)
      ?>  ?=(%& -.germ.g)
      =/  collect  ;;(collection data.p.germ.g)
      (lth supply.collect cap.collect)
    ==
  --
--
