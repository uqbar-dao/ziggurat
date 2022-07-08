::  nft-slim.hoon [UQ| DAO]
::
::  Slimmed down version of the NFT standard.
::  Allows deploying and mint new sets of tokens.
::
  /+  *zig-sys-smart
/=  nft  /lib/zig/contracts/lib/nft-slim
=,  nft
::  TODO could possibly remove accounts for simplicity
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
        %give
      =/  giv=grain  -:~(val by grains.inp)
      ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
      =/  giver=nft-account  ;;(nft-account data.p.germ.giv)
      =/  =item              (~(got by items.giver) item-id.args)
      ?>  transferrable.item  ::  asset item is transferrable
      ?~  account.args
        =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new=grain
          [- me.cart to.args town-id.cart [%& salt.p.germ.giv `nft-account`[metadata.giver ~]]]
        :+  %|
          :+  me.cart  town-id.cart
          [caller.inp `[%give to.args `id.new item-id.args] (silt ~[id.giv]) (silt ~[id.new])]
        [~ (malt ~[[id.new new]]) ~]
      =/  rec=grain  (~(got by owns.cart) u.account.args)
      ?>  &(=(holder.rec to.args) ?=(%& -.germ.rec))
      =/  receiver=nft-account  ;;(nft-account data.p.germ.rec)
      ?>  =(metadata.receiver metadata.giver)
      =:  data.p.germ.giv  giver(items (~(del by items.giver) item-id.args))
          data.p.germ.rec  receiver(items (~(put by items.receiver) item-id.args item))
      ==
      [%& (malt ~[[id.giv giv] [id.rec rec]]) ~ ~]
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
          [- me.cart to.i.mints town-id.cart [%& salt.meta `nft-account`[token.args ~]]]
        %=  $
          mints   t.mints
          issued-rice  (~(put by issued-rice) id.new new)
          next-mints   (~(put in next-mints) [to.i.mints `id.new items.i.mints])
        ==
      ::  have rice, can modify
      =/  =grain  (~(got by owns.cart) u.account.i.mints)
      ?>  &(=(lord.grain me.cart) ?=(%& -.germ.grain))
      =/  acc  ;;(nft-account data.p.germ.grain)
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
          mint-list     t.mint-list
          new-items     (~(put by new-items) -.- -)
          next-item-id  +(next-item-id)
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
        ~(wyt in items.distribution.args)
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
                supply=distribution-total
                ?:(mintable.args `cap.args ~)
                mintable.args
                minters.args
                deployer=caller-id
                salt
        ==  ==
      =+  next-item-id=0
      =/  accounts
        %-  ~(gas by *(map id grain))
        :_  ~
        =/  [=id items=(set item-contents)]  distribution.args
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
        [- me.cart id town-id.cart [%& salt `nft-account`[id.metadata-grain new-items]]]
      [%& ~ (~(put by accounts) id.metadata-grain metadata-grain) ~]
    ==
  --
::
::  TODO 
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
        [%account-data ~]
      ?>  =(1 ~(wyt by owns.cart))
      =/  g=grain  -:~(val by owns.cart)
      ?>  ?=(%& -.germ.g)
      ;;(nft-account data.p.germ.g)
    ==
  --
--
