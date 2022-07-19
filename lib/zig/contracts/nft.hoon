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
  =/  action     ;;(arguments:sur action.inp)
  =*  caller-id  id.from.cart
  ?-    -.action
      %give
    =/  giv=grain  -:~(val by grains.inp)
    ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
    =/  giver=account:sur  ;;(account:sur data.p.germ.giv)
    =/  =item:sur  (~(got by items.giver) item-id.action)
    ?>  transferrable.item  ::  asset item is transferrable
    ?~  account.action
      =+  (fry-rice me.cart to.action town-id.cart salt.p.germ.giv)
      =/  new=grain
        [- me.cart to.action town-id.cart [%& salt.p.germ.giv %account [metadata.giver ~ ~ ~]]]
      =/  yol=yolk
        [`[%give to.action `id.new item-id.action] (silt ~[id.giv]) (silt ~[id.new])]
      (continuation [me.cart town-id.cart yol]~ (result ~ new^~ ~ ~))
    =/  rec=grain  (~(got by owns.cart) u.account.action)
    ?>  &(=(holder.rec to.action) ?=(%& -.germ.rec))
    =/  receiver=account:sur  ;;(account:sur data.p.germ.rec)
    ?>  =(metadata.receiver metadata.giver)
    =:  data.p.germ.giv  giver(items (~(del by items.giver) item-id.action))
        data.p.germ.rec  receiver(items (~(put by items.receiver) item-id.action item))
    ==
    (result ~[giv rec] ~ ~ ~)
  ::
      %take
    =/  giv=grain  (~(got by owns.cart) from-rice.action)
    ?>  ?=(%& -.germ.giv)
    =/  giver=account:sur  ;;(account:sur data.p.germ.giv)
    ?>  ?|  (~(has in full-allowances.giver) caller-id)
            (~(has ju allowances.giver) caller-id item-id.action)
        ==
    =/  =item:sur  (~(got by items.giver) item-id.action)
    ?~  account.action
      =+  (fry-rice me.cart to.action town-id.cart salt.p.germ.giv)
      =/  new=grain
        [- me.cart to.action town-id.cart [%& salt.p.germ.giv %account [metadata.giver ~ ~ ~]]]
      =/  yol=yolk  [`[%take to.action `id.new id.giv item-id.action] ~ (silt ~[id.giv id.new])]
      (continuation [me.cart town-id.cart yol]~ (result new^~ ~ ~ ~))
    =/  rec=grain  (~(got by owns.cart) u.account.action)
    ?>  &(=(holder.rec to.action) ?=(%& -.germ.rec))
    =/  receiver=account:sur  ;;(account:sur data.p.germ.rec)
    ?>  =(metadata.receiver metadata.giver)
    =:  data.p.germ.rec  receiver(items (~(put by items.receiver) item-id.action item))
        data.p.germ.giv
      %=  giver
        items       (~(del by items.giver) item-id.action)
        allowances  (~(del ju allowances.giver) caller-id item-id.action)
      == 
    ==
    (result ~ ~[giv rec] ~ ~)
  ::
      %set-allowance
    =/  acc=grain  -:~(val by grains.inp)
    ?>  !=(who.action holder.acc)
    ?>  &(=(lord.acc me.cart) ?=(%& -.germ.acc))
    =/  =account:sur  ;;(account:sur data.p.germ.acc)
    ?:  full-set.action
      ::  give full permission
      =.  data.p.germ.acc
        account(full-allowances (~(put in full-allowances.account) who.action))
      (result acc^~ ~ ~ ~)
    ::  loop through items.action and set individual permissions
    =/  items=(list [@ud ?])  ~(tap by items.action)
    |-
    ?~  items
      ::  revoke full permission
      =.  full-allowances.account  (~(del in full-allowances.account) who.action)
      (result ~[acc(data.p.germ account)] ~ ~ ~)
    %=  $
      items  t.items
      ::
        allowances.account
      ?:  +.i.items
        (~(put ju allowances.account) who.action -.i.items)
      (~(del ju allowances.account) who.action -.i.items)
    ==
  ::
      %mint
    ::  expects token metadata in owns.cart
    =/  tok=grain  (~(got by owns.cart) token.action)
    ?>  &(=(lord.tok me.cart) ?=(%& -.germ.tok))
    =/  meta  ;;(collection-metadata:sur data.p.germ.tok)
    ::  first, check if token is mintable
    ?>  &(mintable.meta ?=(^ cap.meta) ?=(^ minters.meta))
    ::  check if mint will surpass supply cap
    ?>  (gth u.cap.meta (add supply.meta ~(wyt in mints.action)))
    ::  TODO validate attributes
    ::  cleared to execute!
    =/  next-item-id  supply.meta
    ::  for accounts which we know rice of, find in owns.cart
    ::  and alter. for others, generate id and add to c-call
    =/  changed-rice  (malt ~[[id.tok tok]])
    =/  issued-rice   *(map id grain)
    =/  mints         ~(tap in mints.action)
    =/  next-mints    *(set mint:sur)
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
        [%& changed-rice ~ ~ ~]
      ::  finished but need to mint to newly-issued rices
      =/  call-grains=(set id)
        ~(key by `(map id grain)`issued-rice)
      =/  yol=yolk  [`[%mint token.action next-mints] ~ call-grains]
      %+  continuation
        [me.cart town-id.cart yol]~
      [%& changed-rice issued-rice ~ ~]
    ::
    ?~  account.i.mints
      ::  need to issue
      =+  (fry-rice me.cart to.i.mints town-id.cart salt.meta)
      =/  new=grain
        [- me.cart to.i.mints town-id.cart [%& salt.meta %account [token.action ~ ~ ~]]]
      %=  $
        mints   t.mints
        issued-rice  (~(put by issued-rice) id.new new)
        next-mints   (~(put in next-mints) [to.i.mints `id.new items.i.mints])
      ==
    ::  have rice, can modify
    =/  =grain  (~(got by owns.cart) u.account.i.mints)
    ?>  &(=(lord.grain me.cart) ?=(%& -.germ.grain))
    =/  acc  ;;(account:sur data.p.germ.grain)
    ?>  =(metadata.acc token.action)
    ::  create map of items in this mint to unify with accounts
    =/  mint-list  ~(tap in items.i.mints)
    =/  new-items=(map @ud item:sur)
      =+  new-items=*(map @ud item:sur)
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
    ?>  ?:(mintable.action ?=(^ minters.action) %.y)
    ::  if !mintable, enforce distribution adds up to cap
    ::  otherwise, enforce distribution < cap
    =/  distribution-total=@ud
      %+  roll
        %+  turn  ~(tap by distribution.action)
        |=  [@ ics=(set item-contents:sur)]
        ~(wyt in ics)
      add
    ?>  ?:  mintable.action
          (gth cap.action distribution-total)
        =(cap.action distribution-total)
    ::  generate salt
    =/  salt  (sham (cat 3 caller-id symbol.action))
    ::  generate metadata
    =/  metadata-grain  ^-  grain
      :*  (fry-rice me.cart me.cart town-id.cart salt)
          me.cart
          me.cart
          town-id.cart
          :^  %&  salt  %collection
          ^-  collection-metadata:sur
          :*  name.action
              symbol.action
              attributes.action
              supply=distribution-total
              ?:(mintable.action `cap.action ~)
              mintable.action
              minters.action
              deployer=caller-id
              salt
      ==  ==
    ::  generate accounts
    =+  next-item-id=0
    =/  accounts
      %-  ~(gas by *(map id grain))
      %+  turn  ~(tap by distribution.action)
      |=  [=id items=(set item-contents:sur)]
      =/  mint-list  ~(tap in items)
      =/  new-items=(map @ud item:sur)
        =+  new-items=*(map @ud item:sur)
        |-
        ?~  mint-list
          new-items
        =+  [+(next-item-id) i.mint-list]
        %=  $
          mint-list  t.mint-list
          new-items      (~(put by new-items) -.- -)
          next-item-id   +(next-item-id)
        ==
      =+  (fry-rice me.cart id town-id.cart salt)
      :-  -
      [- me.cart id town-id.cart [%& salt %account [id.metadata-grain new-items ~ ~]]]
    ::  big ol issued map
    [%& ~ (~(put by accounts) id.metadata-grain metadata-grain) ~ ~]
  ==
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
        (account:enjs:lib ;;(account:sur data.p.germ.g))
      (collection-metadata:enjs:lib ;;(collection-metadata:sur data.p.germ.g))
    ::
        [%rice-data @ ~]
      =/  data  (cue (slav %ud i.t.args))
      ?.  ?=([@ @ ?(~ ^) @ ?(~ [~ @]) ? ?(~ ^) @ @] data)
        (account:enjs:lib ;;(account:sur data))
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
