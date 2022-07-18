/-  *sequencer
/+  *zink-zink, *zig-sys-smart, ethereum
|_  [library=vase zink-cax=(map * @) test-mode=?]
::
++  verify-sig
  |=  =egg
  ^-  ?
  ?>  ?=(account from.p.egg)
  =/  hash=@
    ?~(eth-hash.p.egg (sham q.egg) u.eth-hash.p.egg)
  =?  v.sig.p.egg  (gte v.sig.p.egg 27)  (sub v.sig.p.egg 27)
  .=  id.from.p.egg
  %-  address-from-pub:key:ethereum
  %-  serialize-point:secp256k1:secp:crypto
  %+  ecdsa-raw-recover:secp256k1:secp:crypto
  hash  sig.p.egg
::
++  shut                                               ::  slam a door
  |=  [dor=vase arm=@tas dor-sam=vase arm-sam=vase]
  ^-  vase
  %+  slap
    (slop dor (slop dor-sam arm-sam))
  ^-  hoon
  :-  %cnsg
  :^    [%$ ~]
      [%cnsg [arm ~] [%$ 2] [%$ 6] ~]  ::  replace sample
    [%$ 7]
  ~
::
++  ajar                                               ::  partial shut
  |=  [dor=vase arm=@tas dor-sam=vase arm-sam=vase]
  ^-  (pair)
  =/  typ=type
    [%cell p.dor [%cell p.dor-sam p.arm-sam]]
  =/  gen=hoon
    :-  %cnsg
    :^    [%$ ~]
        [%cnsg [arm ~] [%$ 2] [%$ 6] ~]
      [%$ 7]
    ~
  =/  gun  (~(mint ut typ) %noun gen)
  [[q.dor [q.dor-sam q.arm-sam]] q.gun]
::
::  parsing and nest-checking lumps
::
::  from [type *] to (unit vase)
++  nesting
  |=  [typ=type raw=*]
  ^-  (unit vase)
  ?.  (levi -:!>(raw) typ)  ~
  `[typ raw]
::
++  get-raw
  |=  =lump
  ^-  *
  ?@  q.lump  q.lump
  ?+    -.q.lump  !!
      %n
    ~
  ::
      $?  %ub  %uc  %ud  %ui
          %ux  %uv  %uw
          %sb  %sc  %sd  %si
          %sx  %sv  %sw
          %da  %dr
          %f
          %if  %is
          %t   %ta
          %p   %q
          %rs  %rd  %rh  %rq
          %address  %grain-id
      ==
    +.q.lump
  ::
      %list
    [(get-raw )]
  ==
::
++  type-lump
  |=  =lump
  ^-  type
  :+  %face  p.lump
  ?@  q.lump  [%atom %tas ~]
  ?+    -.q.lump  !!
      $?  %ud  %ux
      ==
    [%atom -.q.lump ~]
  ==
::
::  +hole: vase-checks your types for you
::
++  hole
  |*  [typ=mold val=*]
  ^-  typ
  !<(typ [-:!>(*typ) val])
::
++  mill
  |_  [miller=account town-id=id now=@da]
  ::
  ::  +mill-all
  ::
  ::  All eggs must be run through mill in parallel -- they should all operate against
  ::  the same starting state passed through `land` at the beginning. Each run of mill
  ::  should create a (validated) diff set, which can then be compared with an
  ::  accumulated set of diffs. If there is overlap, that egg should be discarded or
  ::  pushed into the next parallel "pass", depending on sequencer parameters.
  ::
  ++  mill-all
    |=  [=land =basket passes=@ud]
    ^-  [state-transition rejected=carton]
    |^
    ::
    =/  pending
      ::  sort in REVERSE since each pass will reconstruct by appending
      ::  rejected to front, so need to +flop before each pass
      %+  sort  ~(tap in basket)
      |=  [a=[@ux =egg] b=[@ux =egg]]
      (lth rate.p.egg.a rate.p.egg.b)
    ::
    =|  final=state-transition
    =|  reward=@ud
    |-
    ?:  ?|  ?=(~ pending)
            =(0 passes)
        ==
      ::  create final state transition
      ::  mark any remaining eggs as rejected
      :-  final(land land)
      %+  turn  pending
      |=  [h=@ux =egg]
      [h egg(status.p %9)]
    ::  otherwise, perform a pass
    =/  [passed=state-transition rejected=carton]
      (pass land (flop pending))
    %=  $
      land             land.passed
      pending          rejected
      processed.final  (weld processed.passed processed.final)
      hits.final       (weld hits.passed hits.final)
      diff.final       (~(uni by diff.final) diff.passed)
      crows.final      (weld crows.passed crows.final)
      burns.final      (~(uni by burns.final) burns.passed)
    ==
    ::
    ++  pass
      |=  [=^land pending=carton]
      ^-  [state-transition rejected=carton]
      =|  callers=(set id)  ::  so that we immediately send repeat callers to next pass
      =|  processed=carton
      =|  rejected=carton
      =|  all-diffs=granary
      =|  lis-hits=(list (list hints))
      =|  crows=(list crow)
      =|  all-burns=granary
      =|  reward=@ud
      |-
      ?~  pending
        :_  rejected
        :*  [(~(pay tax (~(uni by p.land) all-diffs)) reward) q.land]
            processed
            (flop lis-hits)
            all-diffs
            crows
            all-burns
        ==
      ::
      =/  caller-id  (pin from.p.egg.i.pending)
      ?:  (~(has in callers) caller-id)
        %=  $
          pending   t.pending
          rejected  [i.pending rejected]
        ==
      ::
      =/  [fee=@ud [diff=granary nonces=populace] burned=granary =errorcode hits=(list hints) =crow]
        (mill land egg.i.pending)
      =/  diff-and-burned  (~(uni by diff) burned)
      ?.  ?&  ?=(~ (~(int by all-diffs) diff-and-burned))
              ?=(~ (~(int by all-burns) diff-and-burned))
          ==
        ?.  =(%0 errorcode)
          ::  invalid egg -- do not send to next pass,
          ::  but do increment nonce
          %=  $
            pending    t.pending
            processed  [i.pending(status.p.egg errorcode) processed]
            q.land     nonces
            callers    (~(put in callers) caller-id)
            reward     (add reward fee)
            lis-hits   [hits lis-hits]
          ==
        ::  valid, but diff or burned contains collision. re-mill in next pass
        ::
        %=  $
          pending   t.pending
          rejected  [i.pending rejected]
        ==
      ::  diff is isolated, proceed
      ::  increment nonce
      ::
      %=  $
        pending    t.pending
        processed  [i.pending(status.p.egg errorcode) processed]
        q.land     nonces
        reward     (add reward fee)
        lis-hits   [hits lis-hits]
        crows      [crow crows]
        callers    (~(put in callers) caller-id)
        all-diffs  (~(uni by all-diffs) diff)
        all-burns  (~(uni by all-burns) burned)
      ==
    --
  ::
  ::  +mill: processes a single egg and returns map of modified grains + updated nonce
  ::
  ++  mill
    |=  [=land =egg]
    ^-  [fee=@ud ^land burned=granary =errorcode hits=(list hints) =crow]
    ?.  ?=(account from.p.egg)  [0 [~ q.land] ~ %1 ~ ~]
    ::  validate transaction signature
    ?.  ?:(!test-mode (verify-sig egg) %.y)
      ~&  >>>  "mill: signature mismatch"
      [0 [~ q.land] ~ %2 ~ ~]  ::  signed tx doesn't match account
    ::
    =/  expected-nonce  +((~(gut by q.land) id.from.p.egg 0))
    ?.  =(nonce.from.p.egg expected-nonce)
      ~&  >>>  "mill: expected nonce={<expected-nonce>}, got {<nonce.from.p.egg>}"
      [0 [~ q.land] ~ %3 ~ ~]  ::  bad nonce
    ::
    ?.  (~(audit tax p.land) egg)
      ~&  >>>  "mill: tx rejected; account balance less than budget"
      [0 [~ q.land] ~ %4 ~ ~]  ::  can't afford gas
    ::
    =/  res      (~(work farm p.land) egg)
    =/  fee=@ud  (sub budget.p.egg rem.res)
    :+  fee
      :_  (~(put by q.land) id.from.p.egg nonce.from.p.egg)
      ::  charge gas fee by including their designated zigs grain inside the diff
      ?:  =(0 fee)  ~
      %-  ~(put by (fall diff.res ~))
      (~(charge tax p.land) (fall diff.res ~) from.p.egg fee)
    [burned errorcode hits crow]:res
  ::
  ::  +tax: manage payment for egg in zigs
  ::
  ++  tax
    |_  =granary
    +$  token-account
      $:  balance=@ud
          allowances=(map sender=id @ud)
          metadata=id
      ==
    ::  +audit: evaluate whether a caller can afford gas,
    ::  and appropriately set budget for any zigs transactions
    ::  maximum possible charge is full budget * rate
    ++  audit
      |=  =egg
      ^-  ?
      ?.  ?=(account from.p.egg)                    %.n
      ?~  zigs=(~(get by granary) zigs.from.p.egg)  %.n
      ?.  =(id.from.p.egg holder.u.zigs)            %.n
      ?.  =(zigs-wheat-id lord.u.zigs)              %.n
      ?.  ?=(%& -.germ.u.zigs)                      %.n
      =/  acc  (hole token-account data.p.germ.u.zigs)
      (gte balance.acc (mul budget.p.egg rate.p.egg))
    ::  +charge: extract gas fee from caller's zigs balance
    ::  returns a single modified grain to be inserted into a diff
    ::  cannot crash after audit, as long as zigs contract adequately
    ::  validates balance >= budget+amount.
    ++  charge
      |=  [diff=^granary payee=account fee=@ud]
      ^-  [id grain]
      =/  zigs=grain
        ::  find grain in diff, or fall back to full state
        ::  got will never crash since +audit proved existence
        %+  ~(gut by diff)  zigs.payee
        (~(got by granary) zigs.payee)
      ?>  ?=(%& -.germ.zigs)
      =/  acc  (hole token-account data.p.germ.zigs)
      =.  balance.acc  (sub balance.acc fee)
      [zigs.payee zigs(data.p.germ acc)]
    ::  +pay: give fees from eggs to miller
    ++  pay
      |=  total=@ud
      ^-  ^granary
      =/  acc=grain
        %+  ~(gut by granary)  zigs.miller
        ::  create a new account rice for the sequencer if needed
        =/  =token-account  [total ~ `@ux`'zigs-metadata']
        =/  =id  (fry-rice zigs-wheat-id id.miller town-id `@`'zigs')
        [id zigs-wheat-id id.miller town-id [%& 'zigs' %account token-account]]
      ?.  ?=(%& -.germ.acc)  granary
      =/  account  (hole token-account data.p.germ.acc)
      ?.  =(`@ux`'zigs-metadata' metadata.account)  granary
      =.  balance.account  (add balance.account total)
      =.  data.p.germ.acc  account
      (~(put by granary) id.acc acc)
    --
  ::
  ::  +farm: execute a call to a contract
  ::
  ++  farm
    |_  =granary
    +$  hatchling
      $:  hits=(list hints)
          diff=(unit ^granary)
          burned=^granary
          =crow
          rem=@ud
          =errorcode
      ==     
    ::  +work: take egg and return diff granary, remaining budget,
    ::  and errorcode (0=success)
    ++  work
      |=  =egg
      ^-  hatchling
      =/  res  (incubate egg ~ ~)
      res(hits (flop hits.res))
    ::  +incubate: fertilize and germinate, then grow
    ++  incubate
      |=  [=egg hits=(list hints) burned=^granary]
      ^-  hatchling
      =/  from=[=id nonce=@ud]
        ?:  ?=(@ux from.p.egg)  [from.p.egg 0]
        [id.from.p.egg nonce.from.p.egg]
      ?~  gra=(~(get by granary) find)  [~ ~ ~ ~ budget.p.egg %5]
      ?.  ?=(%| -.germ.u.gra)           [~ ~ ~ ~ budget.p.egg %5]
      (grow p.germ.u.gra egg hits burned)
    ::  +grow: recursively apply any calls stemming from egg,
    ::  return on rooster or failure
    ++  grow
      |=  [from=[=id nonce=@ud] =wheat =egg hits=(list hints) burned=^granary]
      ^-  hatchling
      |^
      =+  [hit chick rem err]=(weed to.p.egg budget.p.egg)
      ?~  chick  [hit^hits ~ ~ ~ rem err]
      ?:  ?=(%& -.u.chick)
        ::  rooster result, finished growing
        ?~  diff=(harvest p.u.chick to.p.egg from.p.egg)
          ::  failed validation
          [hit^hits ~ ~ ~ rem %7]
        ::  harvest passed
        [hit^hits diff burned.p.u.chick crow.p.u.chick rem err]
      ::  hen result, continuation
      =|  crows=crow
      =|  all-diffs=^granary
      =/  all-burns  burned.rooster.p.u.chick
      =*  next  next.p.u.chick
      =.  hits  hit^hits
      =/  last-diff  (harvest rooster.p.u.chick to.p.egg from.p.egg)
      |-
      ?~  last-diff
        ::  diff from last call failed validation
        [hits ~ ~ ~ rem %7]
      =.  all-diffs  (~(uni by all-diffs) u.last-diff)
      ?~  next
        ::  all continuations complete
        [hits `all-diffs all-burns (weld crows crow.rooster.p.u.chick) rem %0]
      ::  continue continuing
      =/  inter
        %+  ~(incubate farm (~(dif by (~(uni by granary) all-diffs)) all-burns))
          egg(from.p to.p.egg, to.p to.i.next, budget.p rem, q action.i.next)
        [hits all-burns]
      ?.  =(%0 errorcode.inter)
        [(weld hits.inter hits) ~ ~ ~ rem.inter errorcode.inter]
      %=  $
        next       t.next
        rem        rem.inter
        last-diff  diff.inter
        all-burns  (~(uni by all-burns) burned.inter)
        hits       (weld hits.inter hits)
        crows      (weld crows crow.inter)
      ==
      ::
      ::  +weed: run contract formula with arguments and memory, bounded by bud
      ::
      ++  weed
        |=  [to=id budget=@ud]
        ^-  [hints (unit chick) rem=@ud =errorcode]
        ~>  %bout
        ?~  cont.wheat  [~ ~ budget %6]
        =/  =cart  [to from now town-id]
        =/  payload   .*(q.library pay.u.cont.wheat)
        =/  battery   .*([q.library payload] bat.u.cont.wheat)
        =/  dor=vase  [-:!>(*contract) battery]
        ::
        ::  take action from egg
        =/  raw=*  (get-raw q.q.egg)  ::  from lump to *
        ::  validate that action nests
        ?~  find=(~(get by interface.wheat) p.q.egg)
          ~&  >>>  "mill:error: action {<p.q.egg>} not found in {<interface.wheat>}"
          [~ ~ budget %6]
        ?~  wrapped=(nesting (type-lump u.find) raw)
          ~&  >>>  "mill:error: action {<q.egg>} doesn't nest in {<u.find>}"
          [~ ~ budget %6]
        ::
        ?:  test-mode
          ::  run without zebra
          =/  res
            :-  (mule |.(;;(chick q:(shut dor %write !>(cart) u.wrapped))))
            (sub budget (mul rate.p.egg 7))
          ?:  ?=(%| -.-.res)
            ::  error in contract execution
            [~ ~ +.res %6]
          [~ `p.-.res +.res %0]
        ::  generate ZK-proof hints with zebra
        =/  gun
          (ajar dor %write !>(cart) u.wrapped)
        =/  =book
          (zebra budget zink-cax gun)
        ~&  >>  p.book  ::  chick+(hole (unit chick) p.p.book)
        :-  hit.q.book
        ?:  ?=(%| -.p.book)
          ::  error in contract execution
          ~&  p.book
          [~ bud.q.book %6]
        ::  chick result
        ?~  p.p.book
          ~&  >>>  "mill: ran out of gas"
          [~ 0 %8]
        [(hole (unit chick) p.p.book) bud.q.book %0]
      --
    ::
    ::  +harvest: take a completed execution and validate all changes 
    ::  and additions to granary state
    ::
    ++  harvest
      |=  [res=rooster lord=id from=caller]
      ^-  (unit ^granary)
      ?>  ?=(account from)
      =-  ?.  -
            ~&  >>>  "harvest checks failed"
            ~
          `(~(uni by changed.res) issued.res)
      ?&  %-  ~(all in changed.res)
          |=  [=id =grain]
          ::  all changed grains must already exist AND
          ::  new grain must be same type as old grain AND
          ::  id in changed map must be equal to id in grain AND
          ::  if rice, salt must not change AND
          ::  only grains that proclaim us lord may be changed
          =/  old  (~(get by granary) id)
          ?&  ?=(^ old)
              ?:  ?=(%& -.germ.u.old)
                &(?=(%& -.germ.grain) =(salt.p.germ.u.old salt.p.germ.grain))
              =(%| -.germ.grain)
              =(id id.grain)
              =(lord.grain lord.u.old)
              =(lord lord.u.old)
          ==
        ::
          %-  ~(all in issued.res)
          |=  [=id =grain]
          ::  id in issued map must be equal to id in grain AND
          ::  lord of grain must be contract issuing it AND
          ::  grain must not yet exist at that id AND
          ::  grain IDs must match defined hashing functions
          ?&  =(id id.grain)
              =(lord lord.grain)
              !(~(has by granary) id.grain)
              ?:  ?=(%| -.germ.grain)
                =(id (fry-contract lord town-id.grain cont.p.germ.grain))
              =(id (fry-rice lord holder.grain town-id.grain salt.p.germ.grain))
          ==
        ::
          %-  ~(all in burned.res)
          |=  [=id =grain]
          ::  all burned grains must already exist AND
          ::  id in burned map must be equal to id in grain AND
          ::  no burned grains may also have been changed at same time AND
          ::  only grains that proclaim us lord may be burned AND
          ::  burned cannot contain grain used to pay for gas
          ::
          ::  NOTE: you *CAN* modify a grain in-contract before burning it.
          =/  old  (~(get by granary) id)
          ?&  ?=(^ old)
              =(id id.grain)
              !(~(has by changed.res) id)
              =(lord.grain lord.u.old)
              =(lord lord.u.old)
              !=(zigs.from id)
          ==
      ==
    --
  --
--
