::
::  parsing and nest-checking lumps
::
/+  *zig-sys-smart
|%
++  nesting
  |=  [=lumps =action]
  ^-  (unit vase)
  ?~  choice=(~(get by lumps) p.action)  ~
  =/  typ  (make-action p.action u.choice)
  ::  this isn't doing much, since * fits into pretty much everything...
  ?.  (levi -:!>(action) typ)  ~
  `[typ action]
::
++  make-action
  |=  [tag=@tas =lump]
  ^-  type
  [%cell [%atom %tas `tag] (type-lump lump)]
::
++  type-lump
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
      ?(%address %grain)
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
  ::
    ::    %list
    ::  :-  %fork
    ::  %-  silt
    ::  :~  [%atom %n ~]
    ::  ==
  ==
--