::
::
::  DAO management contract
::
::  Provides the entire on-chain backend for an EScape DAO.
::  Holds a recording of members along with their roles. This
::  contract can serve unlimited DAOs, who simply store their
::  structure as rice held and ruled by this contract on-chain.
::
:: /+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process (hole arguments u.args.inp) (pin caller.inp))
  ::
  +$  arguments
    $%  [%add-dao salt=@ =dao:d]
        [%vote dao-id=id proposal-id=id]
        [%propose dao-id=id updates=(list on-chain-update:d)]
        [%execute dao-id=id updates=(list on-chain-update:d)]  ::  called only by this contract
    ==
  ::
  ++  get-grain-and-dao
    |=  dao-id=id
    ^-  [grain dao:d]
    =/  dao-grain=grain  (~(got by owns.cart) dao-id)
    ?>  =(lord.dao-grain me.cart)
    ?>  ?=(%& -.germ.dao-grain)
    :-  dao-grain
    (hole dao:d data.p.germ.dao-grain)
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
    ::
        %add-dao
      =/  new-dao-germ=germ  [%& +.args]
      =/  new-dao-id=id
        (fry-rice me.cart me.cart town-id.cart salt.args)
      =-  [%& ~ (malt ~[[new-dao-id -]]) ~]
      :*  id=new-dao-id
          lord=me.cart
          holder=me.cart
          town-id=town-id.cart
          germ=new-dao-germ
      ==
    ::
        %vote
      =*  dao-id       dao-id.args
      =*  proposal-id  proposal-id.args
      =/  [dao-grain=grain =dao:d]  (get-grain-and-dao dao-id)
      ?>  ?=(%& -.germ.dao-grain)
      ?>  %:  is-allowed:dao-lib
              [%& caller-id]
              dao-id
              %write
              [%& dao]
          ==
      =/  prop  (~(got by proposals.dao) proposal-id)
      =.  prop  prop(votes (~(put in votes.prop) caller-id))
      ?:  (gth threshold.dao ~(wyt in votes.prop))
        ::  if threshold is higher than current # of votes,
        ::  just register vote and update rice
        =.  dao  dao(proposals (~(put by proposals.dao) proposal-id prop))
        [%& (malt ~[[id.dao-grain dao-grain(data.p.germ dao)]]) ~ ~]
      ::  otherwise execute proposal and remove from rice
      =.  data.p.germ.dao-grain
        dao(proposals (~(del by proposals.dao) proposal-id))
      %=  $
          args       [%execute dao-id updates.prop]
          caller-id  me.cart
          owns.cart
        (~(put by owns.cart) dao-id dao-grain)
      ==
    ::
        %propose
      =*  dao-id   dao-id.args
      =*  updates  updates.args
      ?<  =(0 (lent updates))
      =/  [dao-grain=grain =dao:d]  (get-grain-and-dao dao-id)
      ?>  ?=(%& -.germ.dao-grain)
      ?>  %:  is-allowed:dao-lib
              [%& caller-id]
              dao-id
              %write
              [%& dao]
          ==
      :: ?<  |(?=(%add-dao -.update) ?=(%remove-dao -.update))
      =/  proposal-id=@ux  (mug (jam updates))
      ?<  (~(has by proposals.dao) proposal-id)
      =.  proposals.dao
        %+  ~(put by proposals.dao)
          proposal-id
        [updates=updates votes=~]
      [%& (malt ~[[id.dao-grain dao-grain(data.p.germ dao)]]) ~ ~]
    ::
        %execute
      ?>  =(me.cart caller-id)
      =*  dao-id  dao-id.args
      =/  [dao-grain=grain =dao:d]  (get-grain-and-dao dao-id)
      ?>  ?=(%& -.germ.dao-grain)
      |-
      ?~  updates.args
        [%& (malt ~[[id.dao-grain dao-grain(data.p.germ dao)]]) ~ ~]
      =*  update  i.updates.args
      %=  $
          updates.args  t.updates.args
          dao
        ?+    -.update  !!
            %add-member
          (~(add-member update:dao-lib dao) +.+.update)
        ::
            %remove-member
          (~(remove-member update:dao-lib dao) +.+.update)
        ::
            %add-permissions
          (~(add-permissions update:dao-lib dao) +.+.update)
        ::
            %remove-permissions
          (~(remove-permissions update:dao-lib dao) +.+.update)
        ::
            %add-subdao
          (~(add-subdao update:dao-lib dao) +.+.update)
        ::
            %remove-subdao
          (~(remove-subdao update:dao-lib dao) +.+.update)
        ::
            %add-roles
          (~(add-roles update:dao-lib dao) +.+.update)
        ::
            %remove-roles
          (~(remove-roles update:dao-lib dao) +.+.update)
        ::
        ==
      ::
      ==
    ::
    ==
  ::
  ++  gall  ^?  ::  arvo/sys/lull/hoon (excerpt)
    |%
    +$  bitt  (map duct (pair ship path))                 ::  incoming subs
    +$  boat                                              ::  outgoing subs
      %+  map  [=wire =ship =term]                        ::
      [acked=? =path]                                     ::
    +$  bowl                                              ::  standard app state
            $:  $:  our=ship                              ::  host
                    src=ship                              ::  guest
                    dap=term                              ::  agent
                ==                                        ::
                $:  wex=boat                              ::  outgoing subs
                    sup=bitt                              ::  incoming subs
                ==                                        ::
                $:  act=@ud                               ::  change number
                    eny=@uvJ                              ::  entropy
                    now=@da                               ::  current time
                    byk=beak                              ::  load source
            ==  ==                                        ::
    ::  additional types required to compile
    ::  (from arvo/sys/arvo/hoon and arvo/sys/lull/hoon)
    +$  beak  [p=ship q=desk r=case]                      ::  path prefix
    +$  wire  path
    +$  duct  (list wire)
    +$  desk  @tas
    +$  case
      $%  ::  %da:  date
          ::  %tas: label
          ::  %ud:  sequence
          ::
          [%da p=@da]
          [%tas p=@tas]
          [%ud p=@ud]
      ==
    --
  ::
  ++  r  ::  landscape/sur/resource/hoon
    ^?
    |%
    +$  resource   [=entity name=term]
    +$  resources  (set resource)
    ::
    +$  entity
      $@  ship
      $%  !!
      ==
    --
  ::
  ++  rl  ::  landscape/lib/resource/hoon
    =<  resource
    |%
    +$  resource  resource:r
    ++  en-path
      |=  =resource
      ^-  path
      ~[%ship (scot %p entity.resource) name.resource]
    ::
    ++  de-path
      |=  =path
      ^-  resource
      (need (de-path-soft path))
    ::
    ++  de-path-soft
      |=  =path
      ^-  (unit resource)
      ?.  ?=([%ship @ @ *] path)
        ~
      =/  ship
        (slaw %p i.t.path)
      ?~  ship
        ~
      `[u.ship i.t.t.path]
    ::
    --
  ::
  ++  d  ::  ziggurat/sur/dao/hoon
    |%
    +$  role     @tas  ::  E.g. %marketing, %development
    +$  address  ?(id resource:r)  ::  [chain=@tas id] for other chains?
    +$  member   (each id ship)
    ::  name might be, e.g., %read or %write for a graph;
    ::  %spend for treasury/rice
    +$  permissions  (map name=@tas (jug address role))
    +$  members      (jug id role)
    +$  id-to-ship   (map id ship)
    +$  ship-to-id   (map ship id)
    +$  dao
      $:  name=@t
          =permissions
          =members
          =id-to-ship
          =ship-to-id
          subdaos=(set id)
          :: owners=(set id)  ::  ? or have this in permissions?
          threshold=@ud
          proposals=(map @ux [updates=(list on-chain-update) votes=(set id)])
      ==
    ::
    +$  on-chain-update
      $%  [%add-dao salt=@ =dao]
          [%remove-dao dao-id=id]
          [%add-member dao-id=id roles=(set role) =id him=ship]
          [%remove-member dao-id=id =id]
          [%add-permissions dao-id=id name=@tas =address roles=(set role)]
          [%remove-permissions dao-id=id name=@tas =address roles=(set role)]
          [%add-subdao dao-id=id subdao-id=id]
          [%remove-subdao dao-id=id subdao-id=id]
          [%add-roles dao-id=id roles=(set role) =id]
          [%remove-roles dao-id=id roles=(set role) =id]
      ==
    ::  off-chain
    ::
    +$  off-chain-update
      $%  on-chain-update
          [%add-comms dao-id=id rid=resource:r]
          [%remove-comms dao-id=id]
      ==
    ::
    +$  dao-identifier  (each dao address)
    +$  daos            (map id dao)
    +$  dao-id-to-rid   (map id resource:r)
    +$  dao-rid-to-id   (map resource:r id)
    --
  ::
  ++  agentio  ::  base-dev/lib/agentio/hoon
    |_  =bowl:gall
    ++  scry
      |=  [desk=@tas =path]
      %+  weld
        /(scot %p our.bowl)/[desk]/(scot %da now.bowl)
      path
    ::  rest of agentio/hoon elided
    --
  ::
  ++  dao-lib  ::  ziggurat/lib/dao/hoon
    |_  =bowl:gall
    +*  io  ~(. agentio bowl)
    ::
    ++  get-members-and-permissions
      |=  =dao-identifier:d
      ^-  (unit [=members:d =permissions:d])
      ?~  dao=(get-dao dao-identifier)  ~
      `[members.u.dao permissions.u.dao]
    ::
    ++  get-id-to-ship
      |=  =dao-identifier:d
      ^-  (unit id-to-ship:d)
      ?~  dao=(get-dao dao-identifier)  ~
      `id-to-ship.u.dao
    ::
    ++  get-ship-to-id
      |=  =dao-identifier:d
      ^-  (unit ship-to-id:d)
      ?~  dao=(get-dao dao-identifier)  ~
      `ship-to-id.u.dao
    ::
    ++  member-to-id
      |=  [=member:d =dao-identifier:d]
      ^-  (unit id)
      ?:  ?=(%& -.member)  `p.member
      ?~  dao=(get-dao dao-identifier)  ~
      (~(get by ship-to-id.u.dao) p.member)
    ::
    ++  member-to-ship
      |=  [=member:d =dao-identifier:d]
      ^-  (unit ship)
      ?:  ?=(%| -.member)  `p.member
      ?~  dao=(get-dao dao-identifier)  ~
      (~(get by id-to-ship.u.dao) p.member)
    ::
    ++  get-dao
      |=  =dao-identifier:d
      ^-  (unit dao:d)
      ?:  ?=(%& -.dao-identifier)  `p.dao-identifier
      !!
    ::
    ++  is-allowed
      |=  $:  =member:d
              =address:d
              permission-name=@tas
              =dao-identifier:d
          ==
      ^-  ?
      ?~  dao=(get-dao dao-identifier)                                %.n
      ?~  permissioned=(~(get by permissions.u.dao) permission-name)  %.n
      ?~  roles-with-access=(~(get ju u.permissioned) address)        %.n
      ?~  user-id=(member-to-id member [%& u.dao])                    %.n
      ?~  ship-roles=(~(get ju members.u.dao) u.user-id)              %.n
      ?!  .=  0
      %~  wyt  in
      %-  ~(int in `(set role:d)`ship-roles)
      `(set role:d)`roles-with-access
    ::
    ++  is-allowed-admin-write-read
      |=  $:  =member:d
              =address:d
              =dao-identifier:d
          ==
      ^-  [? ? ?]
      ?~  dao=(get-dao dao-identifier)  [%.n %.n %.n]
      :+  (is-allowed member address %admin [%& u.dao])
        (is-allowed member address %write [%& u.dao])
      (is-allowed member address %read [%& u.dao])
    ::
    ++  is-allowed-write
      |=  $:  =member:d
              =address:d
              =dao-identifier:d
          ==
      ^-  ?
      (is-allowed member address %write dao-identifier)
    ::
    ++  is-allowed-read
      |=  $:  =member:d
              =address:d
              =dao-identifier:d
          ==
      ^-  ?
      (is-allowed member address %read dao-identifier)
    ::
    ++  is-allowed-admin
      |=  $:  =member:d
              =address:d
              =dao-identifier:d
          ==
      ^-  ?
      (is-allowed member address %admin dao-identifier)
    ::
    ++  is-allowed-host
      |=  $:  =member:d
              =address:d
              =dao-identifier:d
          ==
      ^-  ?
      (is-allowed member address %host dao-identifier)
    ::
    ++  update
      |_  =dao:d
      ::
      ++  add-member
        |=  [roles=(set role:d) =id him=ship]
        ^-  dao:d
        =/  existing-ship=(unit ship)
          (~(get by id-to-ship.dao) id)
        ?:  ?=(^ existing-ship)
          ?:  =(him u.existing-ship)  dao
          !!
        =/  existing-id=(unit ^id)
          (~(get by ship-to-id.dao) him)
        ?:  ?=(^ existing-id)
          ?:  =(id u.existing-id)  dao
          !!
        ::
        %=  dao
          id-to-ship  (~(put by id-to-ship.dao) id him)
          ship-to-id  (~(put by ship-to-id.dao) him id)
          members
            %-  ~(gas ju members.dao)
            (make-noun-role-pairs id roles)
        ==
      ::
      ++  remove-member
        |=  [=id]
        ^-  dao:d
        ?~  him=(~(get by id-to-ship.dao) id)
          !!
        ?~  existing-id=(~(get by ship-to-id.dao) u.him)
          !!
        ?>  =(id u.existing-id)
        ?~  roles=(~(get ju members.dao) id)  !!
        %=  dao
          id-to-ship  (~(del by id-to-ship.dao) id)
          ship-to-id  (~(del by ship-to-id.dao) u.him)
          members
            (remove-roles-helper members.dao roles id)
        ==
      ::
      ++  add-permissions
        |=  [name=@tas =address:d roles=(set role:d)]
        ^-  dao:d
        %=  dao
          permissions
            %:  add-permissions-helper
                name
                permissions.dao
                roles
                address
        ==  ==
      ::
      ++  remove-permissions
        |=  [name=@tas =address:d roles=(set role:d)]
        ^-  dao:d
            %=  dao
              permissions
                %:  remove-permissions-helper
                    name
                    permissions.dao
                    roles
                    address
            ==  ==
      ::
      ++  add-subdao
        |=  subdao-id=id
        ^-  dao:d
        dao(subdaos (~(put in subdaos.dao) subdao-id))
      ::
      ++  remove-subdao
        |=  subdao-id=id
        ^-  dao:d
        dao(subdaos (~(del in subdaos.dao) subdao-id))
      ::
      ++  add-roles
        |=  [roles=(set role:d) =id]
        ^-  dao:d
        ?~  (~(get ju members.dao) id)
          !!
        %=  dao
          members
            %-  ~(gas ju members.dao)
            (make-noun-role-pairs id roles)
        ==
      ::
      ++  remove-roles
        |=  [roles=(set role:d) =id]
        ^-  dao:d
        ?~  (~(get ju members.dao) id)
          !!
        dao(members (remove-roles-helper members.dao roles id))
      ::
      ++  add-permissions-helper
        |=  [name=@tas =permissions:d roles=(set role:d) =address:d]
        ^-  permissions:d
        =/  permission=(unit (jug address:d role:d))
          (~(get by permissions) name)
        =/  pairs=(list (pair address:d role:d))
          (make-noun-role-pairs address roles)
        %+  %~  put  by  permissions
          name
        %-  %~  gas  ju
          ?~  permission
            *(jug address:d role:d)
          u.permission
        pairs
      ::
      ++  remove-permissions-helper
        |=  [name=@tas =permissions:d roles=(set role:d) =address:d]
        ^-  permissions:d
        ?~  permission=(~(get by permissions) name)  permissions
        =/  pairs=(list (pair address:d role:d))
          (make-noun-role-pairs address roles)
        |-
        ?~  pairs  (~(put by permissions) name u.permission)
        =.  u.permission  (~(del ju u.permission) i.pairs)
        $(pairs t.pairs)
      ::
      ++  remove-roles-helper
        |=  [=members:d roles=(set role:d) =id]
        ^-  members:d
        =/  pairs=(list (pair ^id role:d))
          (make-noun-role-pairs id roles)
        |-
        ?~  pairs  members
        =.  members  (~(del ju members) i.pairs)
        $(pairs t.pairs)
      ::
      ++  make-noun-role-pairs
        |*  [noun=* roles=(set role:d)]
        ^-  (list (pair _noun role:d))
        ::  cast in tap to avoid crash if passed `~`
        %+  turn  ~(tap in `(set role:d)`roles)
        |=  =role:d
        [p=noun q=role]
      ::
      --
    ::
    --
  ::
  --
::
++  read
  |=  inp=path
  ^-  *
  "TBD"
--
