/-  r=resource,
    seq=sequencer
/+  smart=zig-sys-smart
::
|%
+$  query-type
  $?  %batch
      %egg
      %from
      %grain
      %grain-eggs
      %holder
      %lord
      %slot
      %to
      %town
      %hash
  ==
::
+$  query-payload
  ?(item-hash=@ux [town-id=@ux item-hash=@ux] location)
::
+$  location
  $?  second-order-location
      town-location
      batch-location
      egg-location
  ==
+$  second-order-location  id:smart
+$  town-location  id:smart
+$  batch-location
  [town-id=id:smart batch-root=id:smart]
+$  egg-location
  [town-id=id:smart batch-root=id:smart egg-num=@ud]
::
+$  batches-by-town
  (map town-id=id:smart [=batches =batch-order])
+$  batches
  (map id:smart [timestamp=@da =batch])
+$  batch-order
  (list id:smart)  ::  0-index -> most recent batch
+$  batch
  [transactions=(list [@ux egg:smart]) town:seq]
::
+$  town-update-queue  (jug town-id=@ux batch-id=@ux)
+$  sequencer-update-queue
  %+  map  town-id=@ux
  %+  map  batch-id=@ux
  [eggs=(list [@ux egg:smart]) =town:seq]
::
+$  update
  $@  ~
  $%  [%batch batches=(map batch-id=id:smart [timestamp=@da location=town-location =batch])]
      [%egg eggs=(map egg-id=id:smart [timestamp=@da location=egg-location =egg:smart])]
      [%grain grains=(jar grain-id=id:smart [timestamp=@da location=batch-location =grain:smart])]
      $:  %hash
          batches=(map batch-id=id:smart [timestamp=@da location=town-location =batch])
          eggs=(map egg-id=id:smart [timestamp=@da location=egg-location =egg:smart])
          grains=(jar grain-id=id:smart [timestamp=@da location=batch-location =grain:smart])
      ==
  ==
--
