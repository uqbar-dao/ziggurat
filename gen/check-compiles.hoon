::  check-compiles: tests the contract for compilation and returns the compiled contract
::
::::
  ::
:-  %say
|=  $:  [now=@da eny=@uvJ [our=ship * *]]
        [[name=@tas ~] ~]
    ==
=/  contract-name=@tas  (scot %tas name)  :: paranoia
=/  pax=path   /(scot %p our)/zig/(scot %da now)/lib/zig/contracts/[contract-name]/hoon
?:  !.^(? %cu pax)
  tang+[leaf+"Error: contract '{<`path`(oust [0 3] `(list @tas)`pax)>}' does not exist." ~]
=/  smart          .^(vase %ca /(scot %p our)/zig/(scot %da now)/lib/zig/sys/smart/hoon)
=/  contract-src   .^(@t %cx pax)
=/  contract
  ~|  "contract {<contract-name>} failed to compile!"
  (slap smart (ream contract-src))
:-  %tang
[leaf+"contract {<contract-name>} compiled succesfully" ~]