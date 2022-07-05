/-  *sequencer
/+  *zink-zink, *zig-sys-smart, ethereum
|_  [library=vase zink-cax=(map * @)]
::
++  verify-sig
  |=  [=address hash=@ =sig eth=?]
  ^-  ?
  =?  v.sig  (gte v.sig 27)  (sub v.sig 27)
  =+  %+  ecdsa-raw-recover:secp256k1:secp:crypto
      hash  sig
  .=  address
  ?.  eth
    (compress-point:secp256k1:secp:crypto -)
  %-  address-from-pub:key:ethereum
  (serialize-point:secp256k1:secp:crypto -)
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
    |=  [=land basket=(list [@ux =egg]) passes=@ud]
    ^-  state-transition
    ::
    ::  TODOs:
    ::  -  add multiple sequential passes
    ::  -  implement burns for cross-town txns
    ::
    =/  pending
      %+  sort  basket
      |=  [a=[@ux =egg] b=[@ux =egg]]
      (gth rate.p.egg.a rate.p.egg.b)
    ::
    =|  processed=(list [@ux egg])
    =|  all-diffs=granary
    =|  lis-hits=(list (list hints))
    =|  crows=(list crow)
    =|  reward=@ud
    |-
    ?~  pending
      ~&  >>  "total batch reward: {<reward>}"
      ::  create final state transition
      :*  [(~(pay tax (~(uni by p.land) all-diffs)) reward) q.land]
          processed
          (flop lis-hits)
          all-diffs
          crows
          burns=*granary  ::  TODO implement
      ==
    ::
    =/  [[diff=granary nonces=populace] fee=@ud =errorcode hits=(list hints) =crow]
      (mill land egg.i.pending)
    ?^  overlap=(~(int by all-diffs) diff)
      ::  diff contains collision, reject
      ::
      ~&  >>>  "mill: rejecting egg due to diff overlap"
      %=  $
        pending    t.pending
        processed  [i.pending(status.p.egg %9) processed]
      ==
    ::  diff is isolated, proceed
    ::
    %=  $
      pending    t.pending
      processed  [i.pending(status.p.egg errorcode) processed]
      q.land     nonces
      reward     (add reward fee)
      lis-hits   [hits lis-hits]
      crows      [crow crows]
      all-diffs  (~(uni by all-diffs) diff)
    ==
  ::
  ::  +mill: processes a single egg and returns map of modified grains + updated nonce
  ::
  ++  mill
    |=  [=land =egg]
    ^-  [^land fee=@ud =errorcode hits=(list hints) =crow]
    ?.  ?=(account from.p.egg)  [land 0 %1 ~ ~]
    ::  validate transaction signature
    =+  ?~(eth-hash.p.egg (sham (jam q.egg)) u.eth-hash.p.egg)
    ::  all addresses should be ETH-style, but might not be signed ETH-style.
    ?.  (verify-sig id.from.p.egg - sig.p.egg %.y)
      ~&  >>>  "mill: signature mismatch"
      [land 0 %2 ~ ~]  ::  signed tx doesn't match account
    ::
    ?.  =(nonce.from.p.egg +((~(gut by q.land) id.from.p.egg 0)))
      ~&  >>>  "mill: tx rejected; bad nonce"
      [land 0 %3 ~ ~]  ::  bad nonce
    ::
    =/  [valid=? updated-zigs-action=(unit *)]
      (~(audit tax p.land) egg)
    ?.  valid
      ~&  >>>  "mill: tx rejected; not enough budget"
      [land 0 %4 ~ ~]  ::  can't afford gas
    =?  action.q.egg  ?=(^ updated-zigs-action)
      updated-zigs-action
    ::
    =/  res  (~(work farm p.land) egg)
    ~&  res
    =/  fee=@ud  (sub budget.p.egg rem.res) 
    :_  [fee errorcode.res hits.res crow.res]
    :_  (~(put by q.land) id.from.p.egg nonce.from.p.egg)
    ::  charge gas fee by including their designated zigs grain inside the diff
    %-  ~(put by (fall diff.res ~))
    (~(charge tax p.land) (fall diff.res ~) from.p.egg fee)
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
      ?.  =(zigs-wheat-id lord.u.zigs)              [%.n ~]
      ?.  ?=(%& -.germ.u.zigs)                      [%.n ~]
      =/  acc     (hole token-account data.p.germ.u.zigs)
      =/  enough  (gth balance.acc budget.p.egg)
      ?.  =(zigs-wheat-id to.p.egg)  [enough ~]
      ::  if egg contains a %give via the zigs contract,
      ::  we insert budget at the beginning of the action. this is
      ::  to prevent zigs transactions from spoofing correct budget.
      =*  a  action.q.egg
      ?~  a  [%.n ~]
      ?.  ?=(%give -.u.a)  [enough ~]
      [enough `[-.u.a budget.p.egg +.u.a]]
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
      ^-  [hits=(list hints) diff=(unit ^granary) =crow rem=@ud =errorcode]
      =/  hatchling
        (incubate egg(budget.p (div budget.p.egg rate.p.egg)) ~)
      hatchling(hits (flop hits.hatchling))
    ::  +incubate: fertilize and germinate, then grow
    ++  incubate
      |=  [=egg hits=(list hints)]
      ^-  [hits=(list hints) diff=(unit ^granary) =crow rem=@ud =errorcode]
      |^
      =/  from=[=id nonce=@ud]
        ?:  ?=(@ux from.p.egg)  [from.p.egg 0]
        [id.from.p.egg nonce.from.p.egg]
      =/  =embryo  (fertilize id.from q.egg)
      ?~  stalk=(germinate to.p.egg cont-grains.q.egg)
        ~&  >>>  "mill: failed to germinate"
        [~ ~ ~ budget.p.egg %5]
      (grow from u.stalk embryo egg hits)
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
      |=  [from=[=id nonce=@ud] =crop =embryo =egg hits=(list hints)]
      ^-  [(list hints) diff=(unit ^granary) =crow rem=@ud =errorcode]
      |^
      =+  [hit chick rem err]=(weed to.p.egg budget.p.egg)
      ?~  chick  [hit^hits ~ ~ rem err]
      ?:  ?=(%& -.u.chick)
        ::  rooster result, finished growing
        ?~  diff=(harvest p.u.chick to.p.egg from.p.egg)
          [hit^hits ~ ~ rem %7]
        [hit^hits diff crow.p.u.chick rem err]
      ::  hen result, continuation
      =|  crows=crow
      =|  all-diffs=^granary
      =*  next  next.p.u.chick
      =.  hits  hit^hits
      =/  last-diff  (harvest rooster.p.u.chick to.p.egg from.p.egg)
      |-
      ?~  last-diff
        ::  diff from last call failed validation
        [hits ~ ~ rem %7]
      =.  all-diffs  (~(uni by all-diffs) u.last-diff)
      ?~  next
        ::  all continuations complete
        ::
        [hits `all-diffs (weld crows crow.rooster.p.u.chick) rem %0]
      ::  continue continuing
      ::
      =/  inter
        %+  ~(incubate farm (~(uni by granary) all-diffs))
          egg(from.p to.p.egg, to.p to.i.next, budget.p rem, q yolk.i.next)
        hits
      ?.  =(%0 errorcode.inter)
        [(weld hits.inter hits) ~ ~ rem.inter errorcode.inter]
      %=  $
        next       t.next
        rem        rem.inter
        last-diff  diff.inter
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
        =/  gun
          (ajar dor %write !>(cart) !>(embryo))
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
    ::  +harvest: take a completed execution and validate all changes and additions to granary state
    ::
    ++  harvest
      |=  [res=rooster lord=id from=caller]
      ^-  (unit ^granary)
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
          ::  no changed grains may also have been issued at same time AND
          ::  only grains that proclaim us lord may be changed
          =/  old  (~(get by granary) id)
          ?&  ?=(^ old)
              ?:  ?=(%& -.germ.u.old)
                &(?=(%& -.germ.grain) =(salt.p.germ.u.old salt.p.germ.grain))
              =(%| -.germ.grain)
              =(id id.grain)
              !(~(has by issued.res) id)
              =(lord lord.u.old)
          ==
        ::
          %-  ~(all in issued.res)
          |=  [=id =grain]
          ::  id in issued map must be equal to id in grain AND
          ::  all newly issued grains must have properly-hashed id AND
          ::  lord of grain must be contract issuing it AND
          ::  grain must not yet exist at that id AND
          ::  grain IDs must match defined hashing functions
          ?&  =(id id.grain)
              =(lord lord.grain)
              !(~(has by granary) id.grain)
              ?:  ?=(%& -.germ.grain)
                =(id (fry-rice holder.grain lord.grain town-id.grain salt.p.germ.grain))
              =(id (fry-contract lord.grain town-id.grain bat:(need cont.p.germ.grain)))
      ==  ==
    --
  --
--
