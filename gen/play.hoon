/+  *zig-sys-smart
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] ~ ~]
::
::  from (map @tas lump) to $%
::
|^
=/  =lump
  [%amount [%ud 100.000]]
::  =/  gat  $-(* (get-type lump))
?>  (levi -:!>((get-raw lump)) (get-type lump))
:-  %noun
::  (levi -:!>((get-raw lump)) (get-type lump))
^-  vase
[p=(get-type lump) q=(get-raw lump)]
::
++  get-type
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
++  get-raw
  |=  =lump
  ^-  *
  ?@  q.lump  q.lump
  ?+    -.q.lump  !!
      %ud
    +.q.lump
  ==
--