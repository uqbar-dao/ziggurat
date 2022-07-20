::  nft.hoon [UQ| DAO]
::
::  NFT standard. Provides abilities similar to ERC-721 tokens, also ability
::  to deploy and mint new sets of tokens.
::
/+  *zig-sys-smart
/=  nft  /lib/zig/contracts/lib/nft
=,  nft
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(arguments:sur u.args.inp) (pin caller.inp))
  ::
  ++  process
    |=  [args=arguments:sur caller-id=id]
    ?-    -.args
        %give
      =/  nft-grain=grain  -:~(val by grains.inp)
      ?>  &(=(lord.nft-grain me.cart) ?=(%& -.germ.nft-grain))  ::  this contract can modify this rice TODO: shouldn't this be verified by mill? That you can't let a wheat modify a rice it isn't lord of?
      =/  nft-item=item:sur  ;;(item:sur data.p.germ.nft-grain)
      ?>  transferrable.nft-item         ::  asset item is transferrable
      ?>  =(holder.nft-grain caller-id)  ::  caller is the holder
      =:  holder.nft-grain     to.args   ::  state changes
          allowance.nft-item   ~
      ==
      [%& (malt ~[[id.nft-grain nft-grain]]) ~ ~]
    ::
        %take
      =/  nft-grain=grain  -:~(val by grains.inp)
      ?>  &(=(lord.nft-grain me.cart) ?=(%& -.germ.nft-grain))  ::  this contract can modify the nft rice
      =/  nft-item=item:sur  ;;(item:sur data.p.germ.nft-grain)
      ?>  transferrable.nft-item                  ::  this asset is transferrable 
      ?^  allowance.nft-item                      ::  assert allowance isn't ~
      ?>  =(u.allowance.nft-item caller.inp)  !!  ::  assert that caller is allowed
      =:  holder.nft-grain     (pin caller.inp)   ::  state changes
          allowance.nft-item   ~
      ==
      [%& (malt ~[[id.nft-grain nft-grain]]) ~ ~]
    ::
        %set-allowance
      =/  nft-grain=grain  -:~(val by grains.inp)
      ?>  &(=(lord.nft-grain me.cart) ?=(%& -.germ.nft-grain))  ::  this contract can modify the nft rice
      =/  nft-item=item:sur  ;;(item:sur data.p.germ.nft-grain)
      ?>  =(holder.nft-grain caller.inp)        ::  caller is the holder
      =:  holder.nft-grain    (pin caller.inp)  ::  state changes
          allowance.nft-item  who.args
      ==
      [%& (malt ~[[id.nft-grain nft-grain]]) ~ ~]
    ::
        %mint
      ::  expects token metadata in owns.cart
      =/  collection=grain  (~(got by owns.cart) collection.args)
      ?>  &(=(lord.collection me.cart) ?=(%& -.germ.collection))
      =/  meta  ;;(collection-metadata:sur data.p.germ.collection)
      ?>  &(mintable.meta ?=(^ cap.meta) !=(~ minters.meta))  ::  first, check if token is mintable
      ?>  (gth u.cap.meta +(supply.meta))                     ::  check if mint will surpass supply cap
      ?>  (~(has in minters.meta) caller-id)
      ::  TODO validate attributes
      ::  cleared to execute!
      =/  new-item=grain
        :*  (fry-rice to.args me.cart town-id.cart salt.meta)
            me.cart
            to.args
            town-id.cart
            :+  %&  salt.meta
            ^-  item:sur
            :*  id.collection
                +(supply.meta)
                ~
                item-contents.args
            ==
        ==
      =.  data.p.germ.collection  meta(supply +(supply.meta))
      [%& (malt ~[[id.collection collection]]) (malt ~[[id.new-item new-item]]) ~]
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
          |=  [@ ics=(set item-contents:sur)]
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
            ^-  collection-metadata:sur
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
      :: all-items = map of grain-id -> new-item-grain (aka newly minted grains)
      :: for ([holder-id items-to-mint] in distribution)  :: holder-id is who the items will be minted to
      ::   for item in items-to-mint
      ::     new-item = make-item-grain(...)
      ::     metadata = update_supply()
      ::     all-items.push(new-item)
      ::
      ::  NOTE: Yeah this recursion is ugly if you know better please fix it.
      =/  all-items=(map id grain)
        =|  all-items=(map id grain)
        =/  next-item-id=@ud  0
        =/  dist  ~(tap by distribution.args)
        |-
        ?~  dist
          all-items
        =/  [=id items=(set item-contents:sur)]  i.dist
        =/  mint-list  ~(tap in items)
        =/  [new-items=(list (pair ^id grain)) current-item-id=@ud]
          =|  new-items=(list (pair ^id grain))
          |-
          ?~  mint-list
            [new-items next-item-id]
          =.  next-item-id  +(next-item-id)
          =/  the-item   `item:sur`[id.metadata-grain next-item-id ~ i.mint-list]
          =/  item-salt  (sham salt item-num.the-item)
          =/  item-id    (fry-rice id me.cart town-id.cart item-salt)
          =/  item-grain=grain
            :*  item-id
                me.cart
                id
                town-id.cart 
                [%& item-salt the-item]
            ==
          %=  $
            mint-list     t.mint-list
            new-items     [[id.item-grain item-grain] new-items]
          ==
        $(dist t.dist, next-item-id current-item-id, all-items (~(gas by all-items) new-items))
      [%& ~ (~(put by all-items) [id.metadata-grain metadata-grain]) ~]
    ==
  --
::
++  read
  |_  args=path
  ++  json
    ^-  ^json
    ?+    args  !!
        [%rice-data ~]
      ?>  =(1 ~(wyt by owns.cart))
      =/  g=grain  -:~(val by owns.cart)
      ?>  ?=(%& -.germ.g)
      ?.  ?=([@ @ ?(~ ^) @ ?(~ [~ @]) ? ?(~ ^) @ @] data.p.germ.g)
        (item:enjs:lib ;;(item:sur data.p.germ.g))
      (collection-metadata:enjs:lib ;;(collection-metadata:sur data.p.germ.g))
    ::
        [%rice-data @ ~]
      =/  data  (cue (slav %ud i.t.args))
      ?.  ?=([@ @ ?(~ ^) @ ?(~ [~ @]) ? ?(~ ^) @ @] data)
        (item:enjs:lib ;;(item:sur data))
      %-  collection-metadata:enjs:lib
      ;;(collection-metadata:sur data)
    ::
        [%egg-args @ ~]
      %-  arguments:enjs:lib
      ;;(arguments:sur (cue (slav %ud i.t.args)))
    ==
  ::
  ++  noun
    ~
  --
--
