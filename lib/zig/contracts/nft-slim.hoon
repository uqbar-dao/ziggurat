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
      ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
      ?>  =(caller-id holder.item)
      ?>  transferrable.item
      =.  holder.item  to.args
      [%& (malt ~[[id.item item]]) ~ ~]
    ::
        %mint
      ::  expects token metadata in owns.cart
      =/  tok=grain  (~(got by owns.cart) meta.args)
      ?>  &(=(lord.tok me.cart) ?=(%& -.germ.tok))
      =/  meta  ;;(collection-metadata data.p.germ.tok)
      ::  first, make sure token is mintable
      ?>  &(mintable.meta ?=(^ cap.meta) ?=(^ minters.meta))
      ?>  (~(has in minters.meta) caller-id)
      ::  make sure mint won't surpass supply cap
      ?>  (gth u.cap.meta (add supply.meta ~(wyt in mints.args)))
      ::  cleared to execute!
      =/  next-item-id  supply.meta
      ::  TODO a further simplification could be to only allow 1 mint per tx.
      =/  mints         ~(tap in mints.args)
      =/  issued-items  *(map id grain)
      |-
      ?~  mints
        =.  data.p.germ.tok
          %=  meta
            supply    next-item-id
            mintable  (lth supply.meta u.cap.meta)
          ==
        [%& ~ issued-items ~]
      *chick
      ::  basically, we need to recurse over mints and
      ::  a) create item grains for all items in items.i.mints
      ::  b) make sure their holder is set to to.i.mints
      ::  c) update the supply/cap/mintable as per old logic
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
