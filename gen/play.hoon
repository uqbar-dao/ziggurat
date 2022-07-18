/+  *zig-sys-smart
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] ~ ~]
::  ideally need to convert this:
::  =/  =action [%give (malt ~[[%to [%address 0xbeef]] [%amount [%ud 10.000]]])]
::  to this:
::  [%give to=0xbeef amount=10.000]
|^
=/  =action
  :-  %give
  %-  ~(gas by *(map @tas lump))
  ~[[%to [%address 0xbeef]] [%amount [%ud 10.000]]]
:-  %noun
(convert action)
::
++  convert
  |=  =action
  =/  stuff=(list [@tas lump])  ~(tap by args.action)
  `hoon`[%cltr stuff]
--