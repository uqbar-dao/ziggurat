/-  *sequencer
/+  *zink-zink, *zig-sys-smart, ethereum
|_  [library=vase zink-cax=(map * @) check-sigs=?]
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
  ::  All eggs must be run through mill in parallel -- they should all operate against the
  ::  same starting state passed through `land` at the beginning. Each run of mill should
  ::  create a (validated) diff set, which can then be compared with an accumulated set of
  ::  diffs. If there is overlap, that egg should be discarded or pushed into the next
  ::  parallel "pass", depending on sequencer parameters.
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
      [final(land land) pending]
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
    ?.  ?:(check-sigs (verify-sig egg) %.y)
      ~&  >>>  "mill: signature mismatch"
      [0 [~ q.land] ~ %2 ~ ~]  ::  signed tx doesn't match account
    ::
    ?.  =(nonce.from.p.egg +((~(gut by q.land) id.from.p.egg 0)))
      ~&  >>>  "mill: tx rejected; bad nonce"
      ~&  >>  "expected {<+((~(gut by q.land) id.from.p.egg 0))>}, got {<nonce.from.p.egg>}"
      [0 [~ q.land] ~ %3 ~ ~]  ::  bad nonce
    ::
    =/  [valid=? updated-zigs-action=(unit *)]
      (~(audit tax p.land) egg)
    ?.  valid
      ~&  >>>  "mill: tx rejected; account balance less than budget"
      [0 [~ q.land] ~ %4 ~ ~]  ::  can't afford gas
    =?  action.q.egg  ?=(^ updated-zigs-action)
      updated-zigs-action
    ::
    =/  res  (~(work farm p.land) egg)
    =/  fee=@ud
      %+  mul  rate.p.egg
      (sub budget.p.egg rem.res)
    =/  new-land
      :_  (~(put by q.land) id.from.p.egg nonce.from.p.egg)
      ::  charge gas fee by including their designated zigs grain inside the diff
      ?:  =(0 fee)  ~
      %-  ~(put by (fall diff.res ~))
      (~(charge tax p.land) (fall diff.res ~) from.p.egg fee)
    [fee new-land [burned errorcode hits crow]:res]
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
    ++  audit
      |=  =egg
      ^-  [? action=(unit *)]
      ?.  ?=(account from.p.egg)                    [%.n ~]
      ?~  zigs=(~(get by granary) zigs.from.p.egg)  [%.n ~]
      ?.  =(id.from.p.egg holder.u.zigs)            [%.n ~]
      ?.  =(zigs-wheat-id lord.u.zigs)              [%.n ~]
      ?.  ?=(%& -.germ.u.zigs)                      [%.n ~]
      =/  acc     (hole token-account data.p.germ.u.zigs)
      ::  maximum possible charge is full budget * rate
      =/  max  (mul budget.p.egg rate.p.egg)
      =/  enough  (gth balance.acc max)
      ?.  =(zigs-wheat-id to.p.egg)  [enough ~]
      ::  if egg contains a %give via the zigs contract,
      ::  we insert budget at the beginning of the action. this is
      ::  to prevent zigs transactions from spoofing correct budget.
      =*  a  action.q.egg
      ?~  a  [%.n ~]
      ?.  ?=(%give -.u.a)  [enough ~]
      [enough `[-.u.a max +.u.a]]
    ::  +charge: extract gas fee from caller's zigs balance
    ::  returns a single modified grain to be inserted into a diff
    ::  cannot crash after audit, as long as zigs contract adequately
    ::  validates balance >= budget+amount.
    ++  charge
      |=  [diff=^granary payee=account fee=@ud]
      ^-  [id grain]
      =/  zigs=grain
        ::  find grain in diff, or fall back to full state
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
      ?~  zigs=(~(get by granary) zigs.miller)
        ::  create a new account rice for the sequencer
        ::
        =/  =token-account  [total ~ `@ux`'zigs-metadata']
        =/  =id  (fry-rice id.miller zigs-wheat-id town-id `@`'zigs')
        %+  ~(put by granary)  id
        [id zigs-wheat-id id.miller town-id [%& `@`'zigs' token-account]]
      ::  use existing account
      ::
      ?.  ?=(%& -.germ.u.zigs)                  granary
      =/  acc  (hole token-account data.p.germ.u.zigs)
      ?.  =(`@ux`'zigs-metadata' metadata.acc)  granary
      =.  balance.acc  (add balance.acc total)
      =.  data.p.germ.u.zigs  acc
      (~(put by granary) zigs.miller u.zigs)
    --
  ::
  ::  +farm: execute a call to a contract
  ::
  ++  farm
    |_  =granary
    ::  +work: take egg and return diff granary, remaining budget, and errorcode (0=success)
    ++  work
      |=  =egg
      ^-  [hits=(list hints) diff=(unit ^granary) burned=^granary =crow rem=@ud =errorcode]
      =/  hatchling
        (incubate egg ~ ~)
      hatchling(hits (flop hits.hatchling))
    ::  +incubate: fertilize and germinate, then grow
    ++  incubate
      |=  [=egg hits=(list hints) burned=^granary]
      ^-  [hits=(list hints) diff=(unit ^granary) burned=^granary =crow rem=@ud =errorcode]
      |^
      =/  from=[=id nonce=@ud]
        ?:  ?=(@ux from.p.egg)  [from.p.egg 0]
        [id.from.p.egg nonce.from.p.egg]
      =/  =embryo  (fertilize id.from q.egg)
      ?~  stalk=(germinate to.p.egg cont-grains.q.egg)
        ~&  >>>  "mill: failed to germinate"
        [~ ~ ~ ~ budget.p.egg %5]
      (grow from u.stalk embryo egg hits burned)
      ::  +fertilize: take yolk (contract arguments) and populate with granary data
      ++  fertilize
        |=  [from=id =yolk]
        ^-  embryo
        :-  action.yolk
        %-  ~(gas by *(map id grain))
        %+  murn  ~(tap in my-grains.yolk)
        |=  =id
        ?~  res=(~(get by granary) id)  ~
        ?.  =(holder.u.res from)        ~
        ?.  =(town-id.u.res town-id)    ~
        `[id u.res]
      ::  +germinate: take contract-owned grains in egg and populate with granary data
      ++  germinate
        |=  [find=id grains=(set id)]
        ^-  (unit crop)
        ?~  gra=(~(get by granary) find)  ~
        ?.  ?=(%| -.germ.u.gra)           ~
        ?~  cont.p.germ.u.gra             ~
        :+  ~
          u.cont.p.germ.u.gra
        %-  ~(gas by *(map id grain))
        %+  murn  ~(tap in grains)
        |=  =id
        ?~  res=(~(get by granary) id)  ~
        ?.  =(lord.u.res find)          ~
        ?.  =(town-id.u.res town-id)    ~
        `[id u.res]
      --
    ::  +grow: recursively apply any calls stemming from egg, return on rooster or failure
    ++  grow
      |=  [from=[=id nonce=@ud] =crop =embryo =egg hits=(list hints) burned=^granary]
      ^-  [(list hints) diff=(unit ^granary) burned=^granary =crow rem=@ud =errorcode]
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
        ::
        [hits `all-diffs all-burns (weld crows crow.rooster.p.u.chick) rem %0]
      ::  continue continuing
      ::
      =/  inter
        %+  ~(incubate farm (~(dif by (~(uni by granary) all-diffs)) all-burns))
          egg(from.p to.p.egg, to.p to.i.next, budget.p rem, q yolk.i.next)
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
        =/  =cart  [to from now town-id owns.crop]
        =/  payload   .*(q.library pay.cont.crop)
        =/  battery   .*([q.library payload] bat.cont.crop)
        =/  dor=vase  [-:!>(*contract) battery]
        =/  res
          (mule |.(;;(chick q:(shut dor %write !>(cart) !>(embryo)))))^(sub budget 7)
        ?:  ?=(%| -.-.res)
          ::  error in contract execution
          [~ ~ +.res %6]
        [~ `p.-.res +.res %0]
      --
    ::
    ::  +harvest: take a completed execution and validate all changes and additions to granary state
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
              ?:  ?=(%& -.germ.grain)
                =(id (fry-rice holder.grain lord.grain town-id.grain salt.p.germ.grain))
              =(id (fry-contract lord.grain town-id.grain cont.p.germ.grain))
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
