::  /+  *zig-sys-smart
|%
++  sur
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
        proposals=(map @ux [update=on-chain-update votes=(set id)])
    ==
  ::
  +$  on-chain-update
    $%  [%add-dao salt=@ dao=(unit dao)]
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
  ::
  +$  arguments
    $%  [%add-dao salt=@ dao=(unit dao)]
        [%vote dao-id=id proposal-id=id]
        [%propose dao-id=id =on-chain-update]
        [%execute dao-id=id =on-chain-update]  ::  called only by this contract
    ==
  --
::
++  lib
  |%
  ++  get-grain-and-dao
    |=  [=cart dao-id=id]
    ^-  [grain dao:sur]
    =/  dao-grain=grain  (~(got by owns.cart) dao-id)
    ?>  =(lord.dao-grain me.cart)
    ?>  ?=(%& -.germ.dao-grain)
    :-  dao-grain
    ;;(dao:sur data.p.germ.dao-grain)
  ::  ziggurat/lib/dao/hoon
  ::
  ++  get-members-and-permissions
    |=  =dao-identifier:sur
    ^-  (unit [=members:sur =permissions:sur])
    ?~  dao=(get-dao dao-identifier)  ~
    `[members.u.dao permissions.u.dao]
  ::
  ++  get-id-to-ship
    |=  =dao-identifier:sur
    ^-  (unit id-to-ship:sur)
    ?~  dao=(get-dao dao-identifier)  ~
    `id-to-ship.u.dao
  ::
  ++  get-ship-to-id
    |=  =dao-identifier:sur
    ^-  (unit ship-to-id:sur)
    ?~  dao=(get-dao dao-identifier)  ~
    `ship-to-id.u.dao
  ::
  ++  member-to-id
    |=  [=member:sur =dao-identifier:sur]
    ^-  (unit id)
    ?:  ?=(%& -.member)  `p.member
    ?~  dao=(get-dao dao-identifier)  ~
    (~(get by ship-to-id.u.dao) p.member)
  ::
  ++  member-to-ship
    |=  [=member:sur =dao-identifier:sur]
    ^-  (unit ship)
    ?:  ?=(%| -.member)  `p.member
    ?~  dao=(get-dao dao-identifier)  ~
    (~(get by id-to-ship.u.dao) p.member)
  ::
  ++  get-dao
    |=  =dao-identifier:sur
    ^-  (unit dao:sur)
    ?:  ?=(%& -.dao-identifier)  `p.dao-identifier
    !!
  ::
  ++  is-allowed
    |=  $:  =member:sur
            =address:sur
            permission-name=@tas
            =dao-identifier:sur
        ==
    ^-  ?
    ?~  dao=(get-dao dao-identifier)                                %.n
    ?~  permissioned=(~(get by permissions.u.dao) permission-name)  %.n
    ?~  roles-with-access=(~(get ju u.permissioned) address)        %.n
    ?~  user-id=(member-to-id member [%& u.dao])                    %.n
    ?~  ship-roles=(~(get ju members.u.dao) u.user-id)              %.n
    ?!  .=  0
    %~  wyt  in
    %-  ~(int in `(set role:sur)`ship-roles)
    `(set role:sur)`roles-with-access
  ::
  ++  is-allowed-admin-write-read
    |=  $:  =member:sur
            =address:sur
            =dao-identifier:sur
        ==
    ^-  [? ? ?]
    ?~  dao=(get-dao dao-identifier)  [%.n %.n %.n]
    :+  (is-allowed member address %admin [%& u.dao])
      (is-allowed member address %write [%& u.dao])
    (is-allowed member address %read [%& u.dao])
  ::
  ++  is-allowed-write
    |=  $:  =member:sur
            =address:sur
            =dao-identifier:sur
        ==
    ^-  ?
    (is-allowed member address %write dao-identifier)
  ::
  ++  is-allowed-read
    |=  $:  =member:sur
            =address:sur
            =dao-identifier:sur
        ==
    ^-  ?
    (is-allowed member address %read dao-identifier)
  ::
  ++  is-allowed-admin
    |=  $:  =member:sur
            =address:sur
            =dao-identifier:sur
        ==
    ^-  ?
    (is-allowed member address %admin dao-identifier)
  ::
  ++  is-allowed-host
    |=  $:  =member:sur
            =address:sur
            =dao-identifier:sur
        ==
    ^-  ?
    (is-allowed member address %host dao-identifier)
  ::
  ++  update
    |_  =dao:sur
    ::
    ++  add-member
      |=  [roles=(set role:sur) =id him=ship]
      ^-  dao:sur
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
      ^-  dao:sur
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
      |=  [name=@tas =address:sur roles=(set role:sur)]
      ^-  dao:sur
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
      |=  [name=@tas =address:sur roles=(set role:sur)]
      ^-  dao:sur
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
      ^-  dao:sur
      dao(subdaos (~(put in subdaos.dao) subdao-id))
    ::
    ++  remove-subdao
      |=  subdao-id=id
      ^-  dao:sur
      dao(subdaos (~(del in subdaos.dao) subdao-id))
    ::
    ++  add-roles
      |=  [roles=(set role:sur) =id]
      ^-  dao:sur
      ?~  (~(get ju members.dao) id)
        !!
      %=  dao
        members
          %-  ~(gas ju members.dao)
          (make-noun-role-pairs id roles)
      ==
    ::
    ++  remove-roles
      |=  [roles=(set role:sur) =id]
      ^-  dao:sur
      ?~  (~(get ju members.dao) id)
        !!
      dao(members (remove-roles-helper members.dao roles id))
    ::
    ++  add-permissions-helper
      |=  [name=@tas =permissions:sur roles=(set role:sur) =address:sur]
      ^-  permissions:sur
      =/  permission=(unit (jug address:sur role:sur))
        (~(get by permissions) name)
      =/  pairs=(list (pair address:sur role:sur))
        (make-noun-role-pairs address roles)
      %+  %~  put  by  permissions
        name
      %-  %~  gas  ju
        ?~  permission
          *(jug address:sur role:sur)
        u.permission
      pairs
    ::
    ++  remove-permissions-helper
      |=  [name=@tas =permissions:sur roles=(set role:sur) =address:sur]
      ^-  permissions:sur
      ?~  permission=(~(get by permissions) name)  permissions
      =/  pairs=(list (pair address:sur role:sur))
        (make-noun-role-pairs address roles)
      |-
      ?~  pairs  (~(put by permissions) name u.permission)
      =.  u.permission  (~(del ju u.permission) i.pairs)
      $(pairs t.pairs)
    ::
    ++  remove-roles-helper
      |=  [=members:sur roles=(set role:sur) =id]
      ^-  members:sur
      =/  pairs=(list (pair ^id role:sur))
        (make-noun-role-pairs id roles)
      |-
      ?~  pairs  members
      =.  members  (~(del ju members) i.pairs)
      $(pairs t.pairs)
    ::
    ++  make-noun-role-pairs
      |*  [noun=* roles=(set role:sur)]
      ^-  (list (pair _noun role:sur))
      ::  cast in tap to avoid crash if passed `~`
      %+  turn  ~(tap in `(set role:sur)`roles)
      |=  =role:sur
      [p=noun q=role]
    --
  ::
  ++  enjs
    =,  enjs:format
    |%
    ++  dao
      |^
      |=  =dao:sur
      ^-  json
      %-  pairs
      :~  [%name %s name.dao]
          [%permissions (permissions permissions.dao)]
          [%members (members members.dao)]
          [%id-to-ship (id-to-ship id-to-ship.dao)]
          [%ship-to-id (ship-to-id ship-to-id.dao)]
          [%subdaos (subdaos subdaos.dao)]
          [%threshold (numb threshold.dao)]
          [%proposals (proposals proposals.dao)]
      ==
      ::
      ++  permissions
        |=  =permissions:sur
        ^-  json
        %-  pairs
        %+  turn  ~(tap by permissions)
        |=  [name=@tas p=(jug address:sur role:sur)]
        [name (permission p)]
      ::
      ++  permission
        |=  permission=(jug address:sur role:sur)
        ^-  json
        %-  pairs
        %+  turn  ~(tap by permission)
        |=  [=address:sur rs=(set role:sur)]
        [(address-key address) (roles rs)]
      ::
      ++  members
        |=  =members:sur
        ^-  json
        %-  pairs
        %+  turn  ~(tap by members)
        |=  [i=id rs=(set role:sur)]
        [(scot %ux i) (roles rs)]
      ::
      ++  id-to-ship
        |=  =id-to-ship:sur
        ^-  json
        %-  pairs
        %+  turn  ~(tap by id-to-ship)
        |=  [i=id s=@p]
        [(scot %ux i) [%s (scot %p s)]]
      ::
      ++  ship-to-id
        |=  =ship-to-id:sur
        ^-  json
        %-  pairs
        %+  turn  ~(tap by ship-to-id)
        |=  [s=@p i=id]
        [(scot %p s) [%s (scot %ux i)]]
      ::
      ++  proposals
        |=  proposals=(map id [on-chain-update:sur (set id)])
        ^-  json
        %-  pairs
        %+  turn  ~(tap by proposals)
        |=  [proposal-id=id update=on-chain-update:sur v=(set id)]
        :-  (scot %ux proposal-id)
        %-  pairs
        :+  [%update (on-chain-update update)]
          [%votes (votes v)]
        ~
      ::
      ++  subdaos
        set-id
      ::
      ++  votes
        set-id
      ::
      ++  set-id
        |=  set-id=(set id)
        ^-  json
        :-  %a
        %+  turn  ~(tap in set-id)
        |=  i=id
        [%s (scot %ux i)]
      --
    ::
    ++  arguments
      |=  a=arguments:sur
      %+  frond  -.a
      ^-  json
      ?-    -.a
      ::
          %add-dao
        ?>  ?=(^ dao.a)
        %-  pairs
        :+  [%salt (numb salt.a)]
          [%dao (dao u.dao.a)]
        ~
      ::
          %vote
        %-  pairs
        :+  [%dao-id %s (scot %ux dao-id.a)]
          [%proposal-id %s (scot %ux proposal-id.a)]
        ~
      ::
          %propose
        %-  pairs
        :+  [%dao-id %s (scot %ux dao-id.a)]
          [%on-chain-update (on-chain-update on-chain-update.a)]
        ~
      ::
          %execute
        %-  pairs
        :+  [%dao-id %s (scot %ux dao-id.a)]
          [%on-chain-update (on-chain-update on-chain-update.a)]
        ~
      ==
    ::
    ++  on-chain-update
      |=  update=on-chain-update:sur
      ^-  json
      ?-    -.update
      ::
          %add-dao
        ?>  ?=(^ dao.update)
        %+  frond  %add-dao
        %-  pairs
        :+  [%salt (numb salt.update)]
          [%dao (dao u.dao.update)]
        ~
      ::
          %remove-dao
        %+  frond  %remove-dao
        %+  frond
        %dao-id  [%s (scot %ux dao-id.update)]
      ::
          %add-member
        %+  frond  %add-member
        %-  pairs
        :~  [%dao-id %s (scot %ux dao-id.update)]
            [%roles (roles roles.update)]
            [%id %s (scot %ux id.update)]
            [%him %s (scot %p him.update)]
        ==
      ::
          %remove-member
        %+  frond  %remove-member
        %-  pairs
        :+  [%dao-id %s (scot %ux dao-id.update)]
          [%id %s (scot %ux id.update)]
        ~
      ::
          ?(%add-permissions %remove-permissions)
        %+  frond  -.update
        %-  pairs
        :~  [%dao-id %s (scot %ux dao-id.update)]
            [%name %s name.update]
            [%address [%s (address-key address.update)]]
            [%roles (roles roles.update)]
        ==
      ::
          ?(%add-subdao %remove-subdao)
        %+  frond  -.update
        %-  pairs
        :+  [%dao-id %s (scot %ux dao-id.update)]
          [%subdao-id %s (scot %ux subdao-id.update)]
        ~
      ::
          ?(%add-roles %remove-roles)
        %+  frond  -.update
        %-  pairs
        :^    [%dao-id %s (scot %ux dao-id.update)]
            [%roles (roles roles.update)]
          [%id %s (scot %ux dao-id.update)]
        ~
      ==
    ::
    ++  address-key
      |=  =address:sur
      ^-  @ta
      ?:  ?=(id address)
        (scot %ux address)
      (enjs-path:rl address)
    ::
    ++  roles
      |=  roles=(set role:sur)
      ^-  json
      :-  %a
      %+  turn  ~(tap in roles)
      |=  =role:sur
      [%s role]
    --
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
  ++  enjs
    |=  =resource
    ^-  json
    %-  pairs:enjs:format
    :~  ship+(ship:enjs:format entity.resource)
        name+s+name.resource
    ==
  ::
  ++  enjs-path
    |=  =resource
    %-  spat
    (en-path resource)
  --
--
