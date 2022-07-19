::/+  *zig-sys-smart
|%
::  XX potentially add [%remove-tx tx-hash=@ux] if it makes sense?
::  XX potentially add expired txs?
+$  tx-hash   @uvH
+$  proposal  [=egg votes=(set id)]
+$  multisig-state
  $:  members=(set id)
      threshold=@ud
      pending=(map tx-hash proposal)  :: if map already hashes the key type, then this could be (map egg votes)
  ::  submitted=(set tx-hash) could add this if it makes sense. could let off chain index this and save on chain space
  ==
::
::::  XX could use the following in proposal instead of egg
::+$  partial-egg  (pair partial-shell partial-yolk)
::+$  partial-shell
::  $:  to=id
::      town-id=@ud
::  ==    
::+$  partial-yolk 
::  $:  args=(unit *)
::      my-grains=(set id)
::      cont-grains=(set id)
::  ==
::::
+$  action
  $%
    ::  any id can call the following, and requires no grains
    ::
    [%create-multisig init-thresh=@ud members=(set id)]
    ::  All of the following expect the grain of the deployed multisig
    ::  to be the first and only argument to `cont-grains`
    :: 
    ::::  the following can be called by anyone in `members`
      ::
    [%vote =tx-hash]
    [%submit-tx =egg]
      ::
      ::  the following must be sent by the contract
      ::  which means that they can only be executed by a passing vote
    [%add-member =id]
    [%remove-member =id]
    [%set-threshold new-thresh=@ud]
  ==
::
+$  event
  $%
    ::  we need multisig=id for each event to disambiguate between each multisig that exists
    [%new-vote =tx-hash voter=id multisig=id]
    [%new-tx =tx-hash multisig=id]
    [%vote-passed =tx-hash votes=(set id) multisig=id]
    [%threshold-changed threshold=@ud multisig=id]
    [%member-added new-member=id multisig=id]
    [%member-removed removed=id multisig=id]
  ==
::
::
++  sham-ids
  |=  ids=(set id)
  ^-  @uvH
  =<  q
  %^  spin  ~(tap in ids)
    0v0
  |=  [=id hash=@uvH]
  [~ (sham (cat 3 hash (sham id)))]
++  sham-egg
  |=  [=egg from=_from:*cart block=@ud]
  ^-  @uvH
  ::  blocknum + town-id + caller-id + nonce (if avail)
  ;:  (cury cat 3)
    (sham block)
    (sham town-id.p.egg)
    (sham id.from)
    (sham nonce.from)
  ==
++  event-to-json
  |=  [=event]
  ^-  [@tas json]
  ::  TODO implement
  =/  tag  -.event
  =/  jon  *json
    ::%-  pairs:enjs:format
    :::~  s+'eventName'  s+[`@t`tag]
    ::==
  [tag jon]
--