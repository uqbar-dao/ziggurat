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
    ?-    -.args
    ::  TODO invert order
        %give
      =/  item=grain  -:~(val by grains.inp)
      ?>  &(=(lord.item me.cart) ?=(%& -.germ.item))
      ?>  =(caller-id holder.item)
      =/  item-data  ;;(^item data.p.germ.item)
      ?>  transferrable.item-data
      =.  holder.item  to.args
      [%& (malt ~[[id.item item]]) ~ ~]
    ::
        %mint
      =/  meta-grain=grain  (~(got by owns.cart) meta.args)
      ?>  &(=(lord.meta-grain me.cart) ?=(%& -.germ.meta-grain))
      =/  meta               ;;(collection-metadata data.p.germ.meta-grain)
      =/  mintable           (lth supply.meta cap.meta)
      =/  caller-can-mint    (~(has in minters.meta) caller-id)
      =/  below-cap          (gth cap.meta (add supply.meta ~(wyt in items.args)))
      ?>  &(mintable caller-can-mint below-cap)
      ::  cleared to mint!
      =/  items-list  ~(tap in items.args)
      =|  issued=(map id grain)
      =/  [new-issued=(map id grain) new-meta=collection-metadata]
        |-
        ?~  items-list
          [issued meta]
        =/  contents  i.items-list
        =/  next-id   supply.meta
        =/  salt      (sham (cat 3 next-id id.meta-grain))
        =/  new-item=grain
          :*  (fry-rice me.cart caller-id town-id.cart salt)
              lord=me.cart
              holder=caller-id
              town-id.cart
              :+  %&  salt
              ^-  item
              :*  id.meta-grain
                  next-id
                  contents
              ==
          ==
        =.  supply.meta  +(supply.meta)
        =.  issued       (~(put by issued) id.new-item new-item)
        $(items-list t.items-list)
      ::
      =.  data.p.germ.meta-grain  new-meta
      [%& new-issued (malt ~[[id.meta-grain meta-grain]]) ~]
    ::
        %deploy
      ?>  ?=(^ minters.args)
      ::  generate salt
      =/  salt  (sham (cat 3 caller-id symbol.args))
      ::  create metadata
      =/  metadata-grain=grain
        :*  (fry-rice me.cart me.cart town-id.cart salt)
            me.cart
            me.cart
            town-id.cart
            :+  %&  salt
            ^-  collection-metadata
            :*  name.args
                symbol.args
                supply=0
                cap.args
                minters.args
                deployer=caller-id
        ==  ==
      [%& ~ (malt ~[[id.metadata-grain metadata-grain]]) ~]
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
      ;;(collection-metadata data.p.germ.g)
    ::
        [%mintable ~]
      ?>  =(1 ~(wyt by owns.cart))
      =/  g=grain  -:~(val by owns.cart)
      ?>  ?=(%& -.germ.g)
      =/  meta  ;;(collection-metadata data.p.germ.g)
      (lth supply.meta cap.meta)
    ==
  --
--
