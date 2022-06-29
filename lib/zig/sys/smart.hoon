|%
::
::  smart contract functions
::
::  +fry: hash lord+town+germ to make contract grain pubkey
::
++  fry-contract
  |=  [lord=id town-id=id bat=*]
  ^-  id
  =+  (jam bat)
  `@ux`(sham (cat 3 lord (cat 3 town-id -)))
::
++  fry-rice
  |=  [holder=id lord=id town-id=id salt=@]
  ::  TODO remove town from this possibly, for cross-town transfers
  ^-  id
  ^-  @ux
  %^  cat  3
    (end [3 8] (sham holder))
  (end [3 8] (sham (cat 3 town-id (cat 3 lord salt))))
::
::  +pin: get ID from caller
::
++  pin
  |=  =caller
  ^-  id
  ?:(?=(@ux caller) caller id.caller)
::
::  smart contract types
::
+$  id             @ux                    ::  pubkey
+$  address        @ux                    ::  42-char hex address, ETH compatible
+$  sig            [v=@ r=@ s=@]          ::  ETH compatible ECDSA signature
+$  typed-message  [domain=id message=*]  ::  message should be typed according to some mold specified by the wheat. Do we include the mold in the hash here or not?
++  zigs-wheat-id  `@ux`'zigs-contract'   ::  hardcoded "native" token contract
::
+$  account    [=id nonce=@ud zigs=id]
+$  caller     $@(id account)
::  currently only using ecdsa [v r s]
::  +$  signature  [r=@ux s=@ux type=?(%schnorr %ecdsa)]
::
::  a grain holds either rice (data) or wheat (functions)
::
+$  grain  [=id lord=id holder=id town-id=id =germ]
+$  germ   (each rice wheat)
::
+$  rice   [salt=@ data=*]
::  contract contains itself and every imported library in pay
+$  wheat  [cont=(unit [bat=* pay=*]) owns=(set id)]
+$  crop   [cont=[bat=* pay=*] owns=(map id grain)]  ::  wheat that's been processed by mill.hoon
::
::  cart: state accessible by contract
::
+$  cart
  $:  me=id
      now=@da
      town-id=id
      owns=(map id grain)
  ==
::
::  contract definition
::
+$  contract
  $_  ^|
  |_  cart
  ++  write
    |~  embryo
    *chick
  ::
  ++  read
    ^|  |_  path
    ++  json
      *^json
    ++  noun
      *^noun
    --
  --
::  transaction types, fed into contract
::
::  egg error codes:
::  code can be anything upon submission,
::  gets set for chunk inclusion in +mill
::  NOTE: continuation calls generate their own eggs, which
::  could potentially fail at one of these error points too.
::  currently keeping this simple, but could try to differentiate
::  between first-call and continuation-call errors later
::
+$  errorcode
  $%  %0  ::  0: successfully performed
      %1  ::  1: submitted with raw id / no account info
      %2  ::  2: bad signature
      %3  ::  3: incorrect nonce
      %4  ::  4: lack zigs to fulfill budget
      %5  ::  5: couldn't find contract
      %6  ::  6: crash in contract execution
      %7  ::  7: validation of changed/issued rice failed
      %8  ::  8: ran out of gas while executing
  ==
::
+$  egg  (pair shell yolk)
+$  shell
  $:  from=caller
      =sig               ::  sig on either hash of yolk or eth-hash
      eth-hash=(unit @)  ::  if transaction signed with eth wallet, use this to verify signature
      to=id
      rate=@ud
      budget=@ud
      town-id=id
      status=@ud  ::  error code
  ==
+$  yolk
  $:  =caller  ::  TODO remove, redundant
      args=(unit *)
      my-grains=(set id)
      cont-grains=(set id)
  ==
::  yolk that's been "fertilized" with data by execution engine
+$  embryo
  $:  =caller
      args=(unit *)
      grains=(map id grain)
  ==
::
+$  chick    (each rooster hen)
+$  crow     (list [@tas json])
::
+$  rooster  [changed=(map id grain) issued=(map id grain) =crow]
+$  hen      [next=[to=id town-id=id args=yolk] roost=rooster]
::
::  JSON, from lull.hoon and zuse.hoon
::  allows read arm of contracts to perform enjs operations
::
+$  ship  @p
+$  json                                                ::  normal json value
  $@  ~                                                 ::  null
  $%  [%a p=(list json)]                                ::  array
      [%b p=?]                                          ::  boolean
      [%o p=(map @t json)]                              ::  object
      [%n p=@ta]                                        ::  number
      [%s p=@t]                                         ::  string
  ==
++  format  ^?
  |%
  ++  enjs  ^?                                          ::  json encoders
    |%
    ::                                                  ::  ++frond:enjs:format
    ++  frond                                           ::  object from k-v pair
      |=  [p=@t q=json]
      ^-  json
      [%o [[p q] ~ ~]]
    ::                                                  ::  ++pairs:enjs:format
    ++  pairs                                           ::  object from k-v list
      |=  a=(list [p=@t q=json])
      ^-  json
      [%o (~(gas by *(map @t json)) a)]
    ::                                                  ::  ++tape:enjs:format
    ++  tape                                            ::  string from tape
      |=  a=^tape
      ^-  json
      [%s (crip a)]
    ::                                                  ::  ++ship:enjs:format
    ++  ship                                            ::  string from ship
      |=  a=^ship
      ^-  json
      [%n (rap 3 '"' (rsh [3 1] (scot %p a)) '"' ~)]
    ::                                                  ::  ++numb:enjs:format
    ++  numb                                            ::  number from unsigned
      |=  a=@u
      ^-  json
      :-  %n
      ?:  =(0 a)  '0'
      %-  crip
      %-  flop
      |-  ^-  ^tape
      ?:(=(0 a) ~ [(add '0' (mod a 10)) $(a (div a 10))])
    ::                                                  ::  ++path:enjs:format
    ++  path                                            ::  string from path
      |=  a=^path
      ^-  json
      [%s (spat a)]
    ::                                                  ::  ++tank:enjs:format
    ++  tank                                            ::  tank as string arr
      |=  a=^tank
      ^-  json
      [%a (turn (wash [0 80] a) tape)]
    --  ::enjs
  --
--
