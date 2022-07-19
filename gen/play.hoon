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
  ?-    -.q.lump
      %n
    %void
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
      ==
    [%atom -.q.lump ~]
  ::
      ?(%address %grain-id)
    [%atom %ux ~]
  ::
      %pair
    [%cell $(lump p.+.q.lump) $(lump q.+.q.lump)]
  ::
      %trel
    :+  %cell
      $(lump p.+.q.lump)
    :+  %cell
      $(lump q.+.q.lump)
    $(lump r.+.q.lump)
  ::
      %qual
    :+  %cell
      $(lump p.+.q.lump)
    :+  %cell
      $(lump q.+.q.lump)
    :+  %cell
      $(lump r.+.q.lump)
    $(lump s.+.q.lump)
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