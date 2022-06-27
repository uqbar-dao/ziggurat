/-  ui=indexer,
    zig=ziggurat,
    seq=sequencer
/+  smart=zig-sys-smart
::
|_  =bowl:gall
++  scry-contract-read-arm-agent
  |=  $:  scry-dock=[host=@p agent=?(%sequencer %ziggurat)]
          to=id:smart
          query-type=?(%egg-args %rice-data)  ::  TODO: generalize to @tas?
          query-arg=@ta
      ==
  .^  json
      %gx
      %-  zing
      :^    /(scot %p host.scry-dock)/[agent.scry-dock]
          /(scot %da now.bowl)/wheat/(scot %ux to)/json
        ?:  ?=(%egg-args query-type)
          /egg-args/[query-arg]/~/noun
        /rice-data/~/[query-arg]/noun
      ~
  ==
++  scry-contract-read-arm
  |=  $:  scry-host=@p
          to=id:smart
          query-type=?(%egg-args %rice-data)  ::  TODO: generalize to @tas?
          query-arg=@ta
      ==
  =/  from-sequencer=json
    %:  scry-contract-read-arm-agent
        [scry-host %sequencer]
        to
        query-type
        query-arg
    ==
  ?.  ?=(~ from-sequencer)
    from-sequencer
  %:  scry-contract-read-arm-agent
      [scry-host %ziggurat]
      to
      query-type
      query-arg
  ==
::
++  enjs
  =,  enjs:format
  |%
  ++  update
    |=  =update:ui
    ^-  json
    ?~  update  ~
    ?-    -.update
    ::
        %chunk
      %+  frond  %chunk
      %-  pairs
      :^    [%timestamp (time timestamp.update)]
          [%location (town-location location.update)]
        [%chunk (chunk chunk.update)]
      ~
    ::
        %egg
      (frond %egg (eggs eggs.update))
    ::
        %grain
      (frond %grain (grains grains.update))
    ::
        %hash
      %+  frond  %hash
      %-  pairs
      :^    [%eggs (eggs eggs.update)]
          [%grains (grains grains.update)]
        [%slots (slots slots.update)]
      ~
    ::
        %slot
      (frond %slots (slots slots.update))
    ::
    ==
  ::
  ++  block-location
    |=  =block-location:ui
    ^-  json
    %-  pairs
    :+  [%epoch-num (numb epoch-num.block-location)]
      [%block-num (numb block-num.block-location)]
    ~
  ::
  ++  town-location
    |=  =town-location:ui
    ^-  json
    %-  pairs
    :^    [%epoch-num (numb epoch-num.town-location)]
        [%block-num (numb block-num.town-location)]
      [%town-id (numb town-id.town-location)]
    ~
  ::
  ++  egg-location
    |=  =egg-location:ui
    ^-  json
    %-  pairs
    :~  [%epoch-num (numb epoch-num.egg-location)]
        [%block-num (numb block-num.egg-location)]
        [%town-id (numb town-id.egg-location)]
        [%egg-num (numb egg-num.egg-location)]
    ==
  ::
  ++  chunks
    |=  =chunks:zig
    ^-  json
    %-  pairs
    %+  turn  ~(tap by chunks)
    |=  [town-id=@ud c=chunk:zig]
    [(scot %ud town-id) (chunk c)]
  ::
  ++  chunk
    |=  =chunk:zig
    ^-  json
    %-  pairs
    :+  [%transactions (transactions -.chunk)]
      [%town (town +.chunk)]
    ~
  ::
  ++  transactions
    |=  transactions=(list [@ux egg:smart])
    ^-  json
    :-  %a
    %+  turn  transactions
    |=  [hash=@ux e=egg:smart]
    %-  pairs
    :+  [%hash %s (scot %ux hash)]
      [%egg (egg e)]
    ~
  ::
  ++  eggs
    |=  eggs=(map egg-id=id:smart [@da location=egg-location:ui =egg:smart])
    ^-  json
    %-  pairs
    %+  turn  ~(tap by eggs)
    |=  [=id:smart timestamp=@da location=egg-location:ui e=egg:smart]
    :-  (scot %ux id)
    %-  pairs
    :^    [%timestamp (time timestamp)]
        [%location (egg-location location)]
      [%egg (egg e)]
    ~
  ::
  ++  egg
    |=  =egg:smart
    ^-  json
    %-  pairs
    :+  [%shell (shell p.egg)]
      [%yolk (yolk egg)]
    ~
  ::
  ++  shell
    |=  =shell:smart
    ^-  json
    ?>  ?=(account:smart from.shell)
    %-  pairs
    :~  [%from (account from.shell)]
        [%sig (signature sig.shell)]
        [%eth-hash (eth-hash eth-hash.shell)]
        [%to %s (scot %ux to.shell)]
        [%rate (numb rate.shell)]
        [%budget (numb budget.shell)]
        [%town-id (numb town-id.shell)]
        [%status (numb status.shell)]
    ==
  ::
  ++  yolk
    |=  [=shell:smart =yolk:smart]
    ^-  json
    =/  action=json
      ?~  action.yolk  ~
      %:  scry-contract-read-arm
          our.bowl
          to.shell
          %egg-args
          (scot %ud (jam u.action.yolk))
      ==
    %-  pairs
    :~  [%action action]
        [%my-grains (ids my-grains.yolk)]
        [%cont-grains (ids cont-grains.yolk)]
    ==
  ::
  ++  account
    |=  =account:smart
    ^-  json
    %-  pairs
    :^    [%id %s (scot %ux id.account)]
        [%nonce (numb nonce.account)]
      [%zigs (numb zigs.account)]
    ~
  ::
  ++  signature  ::  TODO: use signature:zig or signature:smart?
    |=  =signature:zig
    ^-  json
    %-  pairs
    :^    [%hash %s (scot %ux p.signature)]
        [%ship %s (scot %p q.signature)]
      [%life (numb r.signature)]
    ~
  ::
  ++  eth-hash
    |=  eth-hash=(unit @ud)
    ^-  json
    ?~  eth-hash  ~
    (numb u.eth-hash)
  ::
  ++  ids
    |=  ids=(set id:smart)
    ^-  json
    :-  %a
    %+  turn  ~(tap in ids)
    |=  =id:smart
    [%s (scot %ux id)]
  ::
  ++  grains
    |=  grains=(map grain-id=id:smart [@da location=town-location:ui =grain:smart])
    ^-  json
    %-  pairs
    %+  turn  ~(tap by grains)
    |=  [=id:smart timestamp=@da location=town-location:ui g=grain:smart]
    :-  (scot %ux id)
    %-  pairs
    :^    [%timestamp (time timestamp)]
        [%location (town-location location)]
      [%grain (grain g)]
    ~
  ::
  ++  grain
    |=  =grain:smart
    ^-  json
    %-  pairs
    :~  [%id %s (scot %ux id.grain)]
        [%lord %s (scot %ux lord.grain)]
        [%holder %s (scot %ux holder.grain)]
        [%town-id (numb town-id.grain)]
        [%germ (germ germ.grain lord.grain id.grain)]
    ==
  ::
  ++  germ
    |=  [=germ:smart wheat-id=id:smart rice-id=id:smart]
    ^-  json
    ?:  ?=(%& -.germ)
      =/  data=json
        %:  scry-contract-read-arm
            our.bowl
            wheat-id
            %rice-data
            (scot %ux rice-id)
        ==
      %-  pairs
      :^    [%is-rice %b %&]
          [%salt (numb salt.p.germ)]
        [%data data]
      ~
    %-  pairs
    :^    [%is-rice %b %|]
        [%cont ~]  ::  TODO
        :: [%cont .^(json %gx /=sequencer=/wheat/[wheat-id]/json/[read-arg]/[rice-list])]
      [%owns (ids owns.p.germ)]
    ~
  ::
  ++  slots
    |=  slots=(map slot-id=id:smart [@da location=block-location:ui =slot:zig])
    ^-  json
    %-  pairs
    %+  turn  ~(tap by slots)
    |=  [=id:smart timestamp=@da location=block-location:ui s=slot:zig]
    :-  (scot %ux id)
    %-  pairs
    :^    [%timestamp (time timestamp)]
        [%location (block-location location)]
      [%slot (slot s)]
    ~
  ::
  ++  slot
    |=  =slot:zig
    ^-  json
    %-  pairs
    :+  [%header (block-header p.slot)]
      [%block (block q.slot)]
    ~
  ::
  ++  block-header
    |=  =block-header:zig
    ^-  json
    %-  pairs
    :^    [%num (numb num.block-header)]
        :+  %prev-header-hash  %s
        (scot %ux prev-header-hash.block-header)
      [%data-hash %s (scot %ux data-hash.block-header)]
    ~
  ::
  ++  block
    |=  block=(unit block:zig)
    ^-  json
    ?~  block  ~
    %-  pairs
    :^    [%height (numb height.u.block)]
        [%signature (signature signature.u.block)]
      [%chunks (chunks chunks.u.block)]
    ~
  ::
  ++  town
    |=  =land:seq
    ^-  json
    %-  pairs
    :+  [%granary (granary p.land)]
      [%populace (populace q.land)]
    ~
  ::
  ++  granary
    |=  =granary:seq
    ^-  json
    %-  pairs
    %+  turn  ~(tap by granary)
    |=  [=id:smart g=grain:smart]
    [(scot %ux id) (grain g)]
  ::
  ++  populace
    |=  =populace:seq
    ^-  json
    %-  pairs
    %+  turn  ~(tap by populace)
    |=  [=id:smart nonce=@ud]
    [(scot %ux id) (numb nonce)]
  ::
  ++  headers
    |=  headers=(list [epoch-num=@ud bh=block-header:zig])
    ^-  json
    %-  pairs
    :_  ~
    :-  %headers
    :-  %a
    %+  turn  headers
    |=  [epoch-num=@ud bh=block-header:zig]
    %-  pairs
    :+  [%epoch-num (numb epoch-num)]
      [%block-header (block-header bh)]
    ~
  ::
  --
++  dejs
  =,  dejs:format
  |%
  ++  update
    |=  jon=json
    ^-  update:ui
    ?~  jon  ~
    %.  jon
    %-  of
    :~  [%chunk (ot ~[[%timestamp di] [%location town-location] [%chunk chunk]])]
        [%egg eggs]
        [%grain grains]
        [%hash (ot ~[[%eggs eggs] [%grains grains] [%slots slots]])]
        [%slot slots]
    ==
  ::
  ++  block-location
    ^-  $-(json block-location:ui)
    %-  ot
    :+  [%epoch-num ni]
      [%block-num ni]
    ~
  ::
  ++  town-location
    ^-  $-(json town-location:ui)
    %-  ot
    :^    [%epoch-num ni]
        [%block-num ni]
      [%town-id ni]
    ~
  ::
  ++  egg-location
    ^-  $-(json egg-location:ui)
    %-  ot
    :~  [%epoch-num ni]
        [%block-num ni]
        [%town-id ni]
        [%egg-num ni]
    ==
  ::
  ++  chunks
    ^-  $-(json chunks:zig)
    (op dem chunk)
  ::
  ++  chunk
    ^-  $-(json chunk:zig)
    %-  ot
    :+  [%transactions transactions]
      [%town town]
    ~
  ::
  ++  transactions
    ^-  $-(json (list [@ux egg:smart]))
    %-  ar
    (at ~[nu egg])
  ::
  ++  eggs
    ^-  $-(json (map egg-id=id:smart [@da location=egg-location:ui =egg:smart]))
    %+  op  hex
    %-  ot
    :^    [%timestamp di]
        [%location egg-location]
      [%egg egg]
    ~
  ::
  ++  egg
    ^-  $-(json egg:smart)
    %-  ot
    :+  [%shell shell]
      [%yolk yolk]
    ~
  ::
  ++  shell
    ^-  $-(json shell:smart)
    %-  ot
    :~  [%from account]  :: always account?
        [%sig signature]
        [%eth-hash eth-hash]
        [%to nu]
        [%rate ni]
        [%budget ni]
        [%town-id ni]
        [%status ni]
    ==
  ::
  ++  yolk
    |=  jon=json
    ^-  yolk:smart
    :-  ~    :: TODO: rewrite when can mold args
    %.  jon
    %-  ot
    :+  [%my-grains ids]
      [%cont-grains ids]
    ~
  ::
  ++  account
    ^-  $-(json account:smart)
    %-  ot
    :^    [%id nu]
        [%nonce ni]
      [%zigs ni]
    ~
  ::
  ++  signature  ::  TODO: use signature:zig or signature:smart?
    ^-  $-(json signature:zig)
    %-  ot
    :^    [%hash nu]
        [%ship nu]
      [%life ni]
    ~
  ::
  ++  eth-hash
    |=  jon=json
    ^-  (unit @ud)
    ?~  jon  ~
    :-  ~
    %.  jon
    ni
  ::
  ++  ids
    ^-  $-(json (set id:smart))
    (as nu)
  ::
  ++  grains
    ^-  $-(json (map grain-id=id:smart [@da location=town-location:ui =grain:smart]))
    %+  op  hex
    %-  ot
    :^    [%timestamp di]
        [%location town-location]
      [%grain grain]
    ~
  ::
  ++  grain
    ^-  $-(json grain:smart)
    %-  ot
    :~  [%id nu]
        [%lord nu]
        [%holder nu]
        [%town-id ni]
        [%germ germ]
    ==
  ::
  ++  germ
    ::  TODO: rewrite when can get data/cont molds
    |=  jon=json
    ^-  germ:smart
    ?>  ?=(%o -.jon)
    =/  is-rice  (~(got by p.jon) %is-rice)
    ?<  ?=(~ is-rice)
    ?>  ?=(%b -.is-rice)
    ?:  p.is-rice
      :+  %&
        %.  jon
        %-  ot
        :-  [%salt ni]
        ~
      `*`0
    ::  is wheat
    :+  %|
      ~
    %.  jon
    %-  ot
    :-  [%owns ids]
    ~
  ::
  ++  slots
    ^-  $-(json (map slot-id=id:smart [@da location=block-location:ui =slot:zig]))
    %+  op  hex
    %-  ot
    :^    [%timestamp di]
        [%location block-location]
      [%slot slot]
    ~
  ::
  ++  slot
    ^-  $-(json slot:zig)
    %-  ot
    :+  [%header block-header]
      [%block block]
    ~
  ::
  ++  block-header
    ^-  $-(json block-header:zig)
    %-  ot
    :^    [%num ni]
        [%prev-header-hash nu]
      [%data-hash nu]
    ~
  ::
  ++  block
    |=  jon=json
    ^-  (unit block:zig)
    ?~  jon  ~
    :-  ~
    %.  jon
    %-  ot
    :^    [%height ni]
        [%signature signature]
      [%chunks chunks]
    ~
  ::
  ++  town
    ^-  $-(json land:seq)
    %-  ot
    :+  [%granary granary]
      [%populace populace]
    ~
  ::
  ++  granary
    ^-  $-(json granary:seq)
    (op hex grain)
  ::
  ++  populace
    ^-  $-(json populace:seq)
    (op hex ni)
  ::
  --
--
