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
      ?>  &(mintable.meta ?=(^ cap.meta) ?=(^ minters.meta))  ::  first, check if token is mintable
      ?>  (gth u.cap.meta +(supply.meta))                     ::  check if mint will surpass supply cap
      ::  TODO validate attributes
      ::  cleared to execute!
      =/  new-item=grain
        :*  (fry-rice to.args me.cart town-id.cart salt.meta)
            me.cart
            to.args
            town-id.cart
            :+  %&  salt.meta
            ^-  item:sur
            :+  +(supply.meta)  ::  increase supply by one
              ~
            item-contents.args
        ==
      =.  data.p.germ.collection  meta(supply +(supply.meta))
      :*  %&
          (~(put by *(map id grain)) -.collection collection)
          (~(put by *(map id grain)) -.new-item new-item)
          ~
      ==
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
      ::  TODO distribution
      ::  map from id to set of items
      all-items = map(id item-grain)
      for (id in map)
        for item in (map[id])
          all-items[(fry-rice data)] = contruct-grain

      
      ::  TODO: WIP
      =+  next-item-id=0
      =/  items  :: map of id (fry-rice) to item grains
        %-  ~(gas by *(map id grain))         :: you goal is to create a list of [id grain]
        %+  turn  ~(tap by distribution.args) :: for id in distribution
        |=  [=id items=(set item-contents:sur)]
        =/  mint-list  ~(tap in items)        :: for item in distribution[id]
        =/  new-items=(map @ud item:sur)
          =+  new-items=*(map @ud item:sur)
          |-  ?~  mint-list
            new-items
          =+  [+(next-item-id) i.mint-list]
          %=  $
            mint-list     t.mint-list
            new-items     (~(put by new-items) -.- -)
            next-item-id  +(next-item-id)
          ==
        =+  (fry-rice id me.card town-id.cart salt)
        :-  -
        [- me.cart id town-id.cart [%& id.metadata-grain ~ ]]
      [%& ~ (~(put by *(map id grain)) id.metadata-grain metadata-grain) ~]
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
