::  dao:
::
::  Store DAOs of ships
::
::    %dao stores DAOs and keeps them updated to
::    the latest chain state, so that resources
::    and other apps can be associated with a DAO.
::
::
::    ## Scry paths
::
::    /y/daos:
::      A listing of current DAO id:rid pairs
::    /x/daos/[id]:
::      The DAO itself
::    /x/daos/[resource]:
::      The DAO itself
::
::    ## Subscription paths (TODO)
::
::    /daos:
::      A stream of the current updates to the state, sending the initial state
::      upon subscribe.
::
::    ##  Pokes
::
::    %dao-update:
::      Update the DAO. Further documented in /sur/dao.hoon
::
::
/-  push-hook,
    d=dao,
    res=resource,
    ui=indexer
/+  agentio,
    dbug,
    default-agent,
    verb,
    daol=dao,
    reslib=resource,
    smart=zig-sys-smart
::
|%
+$  card  card:agent:gall
::
+$  versioned-state
  $%  state-zero
  ==
::
+$  state-zero
  $:  %0
      =daos:d
      =dao-id-to-rid:d
      =dao-rid-to-id:d
      indexer=(unit dock) ::  TODO: indexer should be set of indexers?
      is-host-change-in-progress=?
  ==
++  dao-contract-id  ::  TODO: remove hardcode
  `@ux`'dao'
++  dao-town-id  ::  TODO: remove hardcode
  0x1
--
::
=|  state-zero
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this      .
      dao-core  +>
      dao-lib   ~(. daol bowl)
      dc        ~(. dao-core bowl)
      def       ~(. (default-agent this %|) bowl)
      io        ~(. agentio bowl)
  ::
  ++  on-init
    `this(is-host-change-in-progress %.n)
  ++  on-save  !>(state)
  ++  on-load
    |=  =old=vase
    =/  old  !<(versioned-state old-vase)
    ?-  -.old
      %0  `this(state old)
    ==
  ::
  ++  on-poke  ::  on-poke:def
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  (team:title our.bowl src.bowl)
    =^  cards  state
      ?+    mark  (on-poke:def mark vase)
      ::
          %dao-update
        (dao-update:dc !<(off-chain-update:d vase))
      ::
      ::     %send-to-chain
      ::   =+  !<(rid=resource:res vase)
      ::   ?~  dao=(has-write-dao-permissions:dc rid)  !!
      ::   %+  %~  poke-our  pass:io  /send-to-chain
      ::     %wallet
      ::   :-  %zig-wallet-poke
      ::   !>  ^-  wallet-poke:zig
      ::   :*  %submit
      ::       sequencer=~
      ::       to=dao-contract-id
      ::       town=dao-town-id
      ::       gas=[rate=1 bud=1]
      ::       args=~
      ::       my-grains=(~(put in *(set @ux)) dao-id.dao)
      ::       cont-grains=~
      ::   ==
      ::
          %set-indexer
        (set-indexer:dc !<(dock vase))
      ::
      ==
    [cards this]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ?+    path  (on-watch:def path)
    ::
        [%dao-host-change @ @ @ @ ~]
      =/  dao-id=id:smart  (slav %ux i.t.path)
      =/  new-host=ship    (slav %p i.t.t.t.path)
      ?>  =(our.bowl new-host)
      ?~  dao=(~(get by daos) dao-id)  !!
      ?>  (~(has by ship-to-id.u.dao) src.bowl)  :: member?
      ::  +get-host will return ~ if our ship has not yet
      ::  registered the change to DAO state, in which case
      ::  allow watch so can send success later
      ::  TODO: can we handle this case less hackily?
      ?~  dao-host=(get-host dao-id dao)  `this
      ?>  =(our.bowl (~(got by id-to-ship.u.dao) u.dao-host))
      ::  if we have not yet completed host change, send
      ::  success once done; else, send success immediately
      :_  this
      ?:  is-host-change-in-progress  ~
      :_  ~
      (fact:io [%uqbar-dao-host-change-success !>(`?`%.y)] ~)
    ::
    ==
  ::
  ++  on-leave
    |=  =path
    ^-  (quip card _this)
    ?+    path  (on-leave:def path)
    ::
        [%dao-host-change @ @ @ @ ~]
      `this
    ::
    ==
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+    path  (on-peek:def path)
        [%y %daos ~]
      ``noun+!>(`dao-id-to-rid:d`dao-id-to-rid)
    ::
        [%x %daos @ ~]
      =/  dao-id=id:smart  (slav %ux i.t.t.path)
      ``noun+!>(`(unit dao:d)`(peek-dao:dc dao-id))
    ::
        [%x %daos %ship @ @ ~]
      =/  rid=(unit resource:res)
        (de-path-soft:reslib t.t.path)
      ?~  rid   ~
      ``noun+!>(`(unit dao:d)`(peek-dao:dc u.rid))
    ::
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    |^
    ?+    wire  (on-agent:def wire sign)
    ::
        [%dao-host-change @ @ @ @ ~]
      =/  dao-id=id:smart  (slav %ux i.t.wire)
      =/  old-host=(unit ship)
        ?:  =('~' i.t.t.wire)  ~
        `(slav %p i.t.t.wire)
      =/  new-host=ship  (slav %p i.t.t.t.wire)
      =/  rid-name=@tas  (slav %tas i.t.t.t.t.wire)
      ?+    -.sign  (on-agent:def wire sign)
      ::
          %kick
        :_  this
        :_  ~
        %+  %~  watch  pass:io  wire
        [new-host %dao]  wire
      ::
          %fact
        ?>  ?=(%uqbar-dao-host-change-success p.cage.sign)
        =+  !<(success=? q.cage.sign)
        ~&  >  "dao: got success {<success>} from new host"
        :_  this
        ?.  success
          :_  ~
          %+  %~  leave-path  pass:io  (weld /leave `^wire`wire)
          [new-host %dao]  wire
        =/  old-dao-rid=(unit resource:res)
          ?~  old-host  ~
          `[u.old-host rid-name]
        =/  new-dao-rid=resource:res
          [new-host rid-name]
        =/  tid=@ta  (cat 3 'thread_' (scot %uv (sham eny.bowl)))
        :+  %+  %~  watch-our  pass:io
                (weld `^wire`/thread `^wire`wire)
            %spider  /thread-result/[tid]
          %:  start-host-change-ted
              old-dao-rid
              new-dao-rid
              wire
              tid
          ==
        ~
      ::
      ==
    ::
        [%dao-update @ ~]
      =/  dao-id=id:smart  (slav %ux i.t.wire)
      ?+    -.sign  (on-agent:def wire sign)
      ::
          %kick
        :_  this
        ?~  (peek-dao dao-id)  ~
        ?~  wi=(watch-indexer dao-id)  ~
        ~[u.wi]
      ::
          %fact
        =+  !<(=update:ui q.cage.sign)
        =/  [dao-id=id:smart new-dao=dao:d]
          (get-dao-from-update update)
        ?~  (peek-dao dao-id)
          `this(daos (~(put by daos) dao-id new-dao))
        =/  old-host-id=(unit id:smart)  (get-host dao-id ~)
        =/  new-host-id=(unit id:smart)  (get-host dao-id `new-dao)
        =/  new-host=(unit ship)
          ?~  new-host-id  ~
          (~(get by id-to-ship.new-dao) u.new-host-id)
        =/  old-rid=(unit resource:res)
          (~(get by dao-id-to-rid) dao-id)
        =/  new-rid=(unit resource:res)
          ?:  =(old-host-id new-host-id)  ~
          ?~  old-rid   ~
          ?~  new-host  old-rid
          `[u.new-host name.u.old-rid]
        =/  cards=(list card)
          ?:  =(old-host-id new-host-id)  ~
          %-  zing
          :+  ?~  new-host  ~
              (make-host-change-cards dao-id new-dao u.new-host)
            ?~  old-rid  ~
            ?.  =(our.bowl entity.u.old-rid)  ~
            (remove-push-hooks u.old-rid)
          ~
        :-  cards
        %=  this
            daos  (~(put by daos) dao-id new-dao)  :: TODO: instead walk through and make minimal change to existing structure?
            is-host-change-in-progress
          ?~(new-host %.n =(our.bowl u.new-host))
        ::
            dao-id-to-rid
          ?~  new-rid  dao-id-to-rid
          (~(put by dao-id-to-rid) dao-id u.new-rid)
        ::
            dao-rid-to-id
          ?~  new-rid  dao-rid-to-id
          %+  %~  put  by
            ?~  old-rid  dao-rid-to-id
            (~(del by dao-rid-to-id) u.old-rid)
          u.new-rid  dao-id
        ::
        ==
      ::
      ==
    ::
        [%thread %dao-host-change @ @ @ @ ~]
      =*  sub-path=path  t.wire
      =/  new-host=ship  (slav %p i.t.t.t.t.wire)
      ?+    -.sign  (on-agent:def wire sign)
          %poke-ack  ::  TODO: can we do better here?
        :_  this
        ?~  p.sign  ~
        ~&  >>>  "dao: host change thread failed to start"
        (make-dao-host-change-success new-host sub-path %.n)
      ::
          %fact
        ?+    p.cage.sign  (on-agent:def wire sign)
            %thread-fail  ::  TODO: can we do better here?
          ~&  >>>  "dao: host change thread failed during run"
          :_  this
          (make-dao-host-change-success new-host sub-path %.n)
        ::
            %thread-done
          ~&  >  "dao: host change thread succeeded"
          :_  this(is-host-change-in-progress %.n)
          (make-dao-host-change-success new-host sub-path %.y)
        ::
        ==
      ::
      ==
    ::
    ==
    ::
    ++  remove-push-hooks
      |=  remove-rid=resource:res
      =/  remove-wire=^wire
        /remove/(scot %p entity.remove-rid)/[name.remove-rid]
      |^  ^-  (list card)
      :+  (remove-push-hook 'graph')
        (remove-push-hook 'metadata')
      ~
      ::
      ++  remove-push-hook
        |=  app-infix=@ta
        ^-  card
        =/  full-app-name=@tas
          (rap 3 %dao '-' app-infix '-' %push-hook ~)
        %^  ~(poke-our pass:io (weld remove-wire /[app-infix]))
          full-app-name  %push-hook-action
        !>(`action:push-hook`[%remove remove-rid])
      ::
      --
    ::
    ++  make-dao-host-change-success
      |=  [new-host=ship sub-path=path success=?]
      ^-  (list card)
      :_  ~
      ?:  =(our.bowl new-host)
        (fact:io [%uqbar-dao-host-change-success !>(`?`success)] ~[sub-path])
      %+  %~  leave-path  pass:io  (weld /leave sub-path)
      [new-host %dao]  sub-path
    ::
    ++  get-dao-from-update
      |=  =update:ui
      ^-  [id:smart dao:d]
      ?>  ?=(%grain -.update)
      =/  grains=(list [@da batch-location:ui grain:smart])
        (zing ~(val by grains.update))
      ?>  =(1 (lent grains))
      =/  [@ * dao-grain=grain:smart]  (snag 0 grains)
      ?>  ?=(%& -.germ.dao-grain)
      [id.dao-grain ;;(dao:d data.p.germ.dao-grain)]
    ::
    ++  start-host-change-ted
      |=  $:  old-dao-rid=(unit resource:res)
              new-dao-rid=resource:res
              watch-path=path
              tid=@ta
          ==
      ^-  card
      =/  start-args
        :-  ~
        :^  `tid  byk.bowl(r da+now.bowl)  %on-host-change-dao
        !>  ^-  (unit (pair (unit resource:res) resource:res))
        `[old-dao-rid new-dao-rid]
      %^  %~  poke-our  pass:io  (weld /thread watch-path)
      %spider  %spider-start  !>(start-args)
    ::
    ++  make-host-change-cards
      |=  $:  dao-id=id:smart
              new-dao=dao:d
              new-host=ship
          ==
      ^-  (list card)
      =/  old-dao-rid=(unit resource:res)
        (~(get by dao-id-to-rid) dao-id)
      =/  rid-name=@tas
        ?~  old-dao-rid  `@tas`name.new-dao  :: TODO: do better here; will get spaces etc
        name.u.old-dao-rid
      =/  watch-path=path
        :~  %dao-host-change
            (scot %ux dao-id)
            ?~(old-dao-rid '~' (scot %p entity.u.old-dao-rid))
            (scot %p new-host)
            rid-name
        ==
      ?:  =(our.bowl new-host)
        ::  if we are new host, start ted to
        ::  change host and sub to it for result
        =/  tid=@ta  (cat 3 'thread_' (scot %uv (sham eny.bowl)))
        =/  new-dao-rid=resource:res  [new-host rid-name]
        :+  %+  %~  watch-our  pass:io
                (weld /thread watch-path)
            %spider  /thread-result/[tid]
          %:  start-host-change-ted
              old-dao-rid
              new-dao-rid
              watch-path
              tid
          ==
        ~
      ::  if we are not, subscribe to new host to wait
      ::  for them to complete host change
      :_  ~
      %+  %~  watch  pass:io  watch-path
      [new-host %dao]  watch-path
    ::
    --
  ++  on-arvo  on-arvo:def
  ++  on-fail  on-fail:def
  ::
  --
::
|_  =bowl:gall
+*  dao-lib  ~(. daol bowl)
    io       ~(. agentio bowl)
::
++  address-to-id
  |=  =address:d
  ^-  (unit id:smart)
  ?:  ?=(id:smart address)  `address
  (~(get by dao-rid-to-id) address)
::
++  address-to-resource
  |=  =address:d
  ^-  (unit resource:res)
  ?:  ?=(resource:res address)  `address
  (~(get by dao-id-to-rid) address)
::
++  peek-dao
  |=  identifier=address:d
  ^-  (unit dao:d)
  ?~  id=(address-to-id identifier)  ~
  (~(get by daos) u.id)
::
++  get-host
  |=  [dao-id=id:smart dao=(unit dao:d)]
  ^-  (unit id:smart)
  =.  dao
    ?:  ?=(^ dao)  dao
    (~(get by daos) dao-id)
  ?~  dao                                                  ~
  ?~  address-to-host=(~(get by permissions.u.dao) %host)  ~
  ?~  dao-rid=(~(get by dao-id-to-rid) dao-id)             ~
  ?~  host-roles=(~(get ju u.address-to-host) dao-id)      ~
  =/  members=(list [=id:smart roles=(set role:d)])
    ~(tap by members.u.dao)
  |-
  ?~  members  ~
  =*  member-id     id.i.members
  =*  member-roles  roles.i.members
  ?:  %-  %~  any  in  `(set role:d)`host-roles
      |=  host-role=role:d
      (~(has in member-roles) host-role)
    `member-id
  $(members t.members)
::
++  watch-indexer
  |=  dao-id=id:smart
  ^-  (unit card)
  ?~  indexer  ~
  :-  ~
  %+  %~  watch  pass:io
      /dao-update/(scot %ux dao-id)
  u.indexer  /grain/(scot %ux dao-id)
::
++  leave-indexer
  |=  dao-id=id:smart
  ^-  (unit card)
  ?~  indexer  ~
  :-  ~
  %-  %~  leave  pass:io
      /dao-update/(scot %ux dao-id)
  u.indexer
::
++  set-indexer  :: TODO: is this properly generalized?
  |=  indexer-dock=dock
  ^-  (quip card _state)
  :_  state(indexer `indexer-dock)
  ?:  =(0 ~(wyt by daos))  ~
  %+  murn  ~(tap by daos)
  |=  [dao-id=id:smart =dao:d]
  (watch-indexer dao-id)
::
++  has-write-dao-permissions
  |=  identifier=address:d
  ^-  (unit dao:d)
  ?~  id=(address-to-id identifier)  ~
  ?~  dao=(peek-dao u.id)  ~
  ?.  %:  is-allowed:dao-lib
          [%| src.bowl]
          u.id
          %write
          [%& u.dao]
      ==
    ~
  dao
::
++  remove-dao
  |=  dao-id=id:smart
  ^-  (quip card _state)
  ?~  (peek-dao dao-id)  `state
  =.  daos
    (~(del by daos) dao-id)
  ::  TODO: also remove-comms if entry exists
  :_  state
  :-  (send-diff %remove-dao dao-id)
  ?~  li=(leave-indexer dao-id)  ~  [u.li ~]
::  +dao-update: update DAO
::
::    no-op if DAO does not exist
::    or if user does not have %write
::    permissions for DAO
::
++  dao-update
  |=  =off-chain-update:d
  ^-  (quip card _state)
  |^
  ?-  -.off-chain-update
      %add-comms           (add-comms +.off-chain-update)
      %remove-comms        (remove-comms +.off-chain-update)
      %add-dao             (add-dao +.off-chain-update)
      %remove-dao          (remove-dao +.off-chain-update)
      %add-member          (add-member +.off-chain-update)
      %remove-member       (remove-member +.off-chain-update)
      %add-permissions     (add-permissions +.off-chain-update)
      %remove-permissions  (remove-permissions +.off-chain-update)
      %add-roles           (add-roles +.off-chain-update)
      %remove-roles        (remove-roles +.off-chain-update)
      %add-subdao          (add-subdao +.off-chain-update)
      %remove-subdao       (remove-subdao +.off-chain-update)
    :: =*  dao-id  dao-id.off-chain-update
    :: =*  update  update.off-chain-update
    :: ?-  -.update
    ::     %add-dao             (add-dao dao-id +.update)
    ::     %remove-dao          (remove-dao dao-id)
    ::     %add-member          (add-member dao-id +.update)
    ::     %remove-member       (remove-member dao-id +.update)
    ::     %add-permissions     (add-permissions dao-id +.update)
    ::     %remove-permissions  (remove-permissions dao-id +.update)
    ::     %add-roles           (add-roles dao-id +.update)
    ::     %remove-roles        (remove-roles dao-id +.update)
    ::     %add-subdao          (add-subdao dao-id +.update)
    ::     %remove-subdao       (remove-subdao dao-id +.update)
    :: ==
  ==
  ::
  ++  add-comms
    |=  [dao-id=id:smart rid=resource:res]
    ^-  (quip card _state)
    :: ?~  (has-write-dao-permissions dao-id)  `state
    =.  dao-id-to-rid  (~(put by dao-id-to-rid) dao-id rid)
    =.  dao-rid-to-id  (~(put by dao-rid-to-id) rid dao-id)
    :_  state
    ~[(send-diff %add-comms dao-id rid)]
  ::
  ++  remove-comms
    |=  dao-id=id:smart
    ^-  (quip card _state)
    ?~  rid=(~(get by dao-id-to-rid) dao-id)  `state
    ?~  (~(get by dao-rid-to-id) u.rid)  `state
    =.  dao-id-to-rid  (~(del by dao-id-to-rid) dao-id)
    =.  dao-rid-to-id  (~(del by dao-rid-to-id) u.rid)
    :_  state
    ~[(send-diff %remove-comms dao-id)]
  ::
  ++  add-dao
    |=  [salt=@ dao=(unit dao:d)]
    ^-  (quip card _state)
    =/  dao-id=id:smart
      %:  fry-rice:smart
          dao-contract-id
          dao-contract-id
          dao-town-id
          salt
      ==
    ?:  ?=(^ (peek-dao dao-id))  `state
    =.  daos
      ?~  dao  daos
      (~(put by daos) dao-id u.dao)
    :_  state
    :-  (send-diff %add-dao salt dao)
    ?~  wi=(watch-indexer dao-id)  ~  [u.wi ~]
  ::
  ++  add-member
    |=  [dao-id=id:smart roles=(set role:d) =id:smart him=ship]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  =dao:d
      (~(add-member update:dao-lib dao) roles id him)
    :_  state
    ~[(send-diff %add-member dao-id roles id him)]
  ::
  ++  remove-member
    |=  [dao-id=id:smart =id:smart]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  =dao:d
      (~(remove-member update:dao-lib dao) id)
    :_  state
    ~[(send-diff %remove-member dao-id id)]
  ::
  ++  add-permissions
    |=  [dao-id=id:smart name=@tas =address:d roles=(set role:d)]
    ^-  (quip card _state)
    ?~  (has-write-dao-permissions dao-id)  `state
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  =dao:d
      (~(add-permissions update:dao-lib dao) name address roles)
    :_  state
    ~[(send-diff %add-permissions dao-id name address roles)]
  ::
  ++  remove-permissions
    |=  [dao-id=id:smart name=@tas =address:d roles=(set role:d)]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  =dao:d
      %^  %~  remove-permissions  update:dao-lib  dao
      name  address  roles
    :_  state
    ~[(send-diff %remove-permissions dao-id name address roles)]
  ::
  ++  add-subdao
    |=  [dao-id=id:smart subdao-id=id:smart]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  =dao:d
      (~(add-subdao update:dao-lib dao) subdao-id)
    :_  state
    ~[(send-diff %add-subdao dao-id subdao-id)]
  ::
  ++  remove-subdao
    |=  [dao-id=id:smart subdao-id=id:smart]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  =dao:d
      (~(remove-subdao update:dao-lib dao) subdao-id)
    :_  state
    ~[(send-diff %remove-subdao dao-id subdao-id)]
  ::  +add-roles: add roles to members
  ::
  ::    crash if member id is not in DAO
  ::
  ++  add-roles
    |=  [dao-id=id:smart roles=(set role:d) =id:smart]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  =dao:d
      (~(add-roles update:dao-lib dao) roles id)
    :_  state
    ~[(send-diff %add-roles dao-id roles id)]
  ::  +remove-roles: remove roles from members
  ::
  ::    crash if member id is not in DAO
  ::    TODO: crash if role does not exist?
  ::
  ++  remove-roles
    |=  [dao-id=id:smart roles=(set role:d) =id:smart]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    ?~  (~(get ju members.u.dao) id)  !!
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  =dao:d
      (~(remove-roles update:dao-lib dao) roles id)
    :_  state
    ~[(send-diff %remove-roles dao-id roles id)]
  ::
  --
::  +send-diff: update subscribers of new state
::
::    We only allow subscriptions on /daos
::    so just give the fact there.
::
++  send-diff
  |=  update=off-chain-update:d
  ^-  card
  [%give %fact ~[/daos] %dao-update !>(update)]
::
--
