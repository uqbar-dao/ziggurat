/+  smart=zig-sys-smart
|%
::  managing the zane
::
+$  action
  $%  [%set-sources indexers=(list [=ship town=id:smart])]
      [%add-source =ship]  ::  added to end of priority list
      [%remove-source =ship]
  ==
::  ++  on-peek
::  reading info from indexer
::
+$  read
  $%  [%contract =id:smart town=id:smart args=^ grains=(list id:smart)]  ::  perform read direct from sequencer
      [%grain =id:smart]           ::  get from indexer, once
      [%transaction =id:smart]
  ==
::  ++  on-watch
::  establish subscription for a data source from indexer
::  all take in town id, then id of data object
::
+$  watch
  $%  [%id @ @ ~]
      [%grain @ @ ~]
      [%holder @ @ ~]
      [%lord @ @ ~]
  ==
::  ++  on-poke
::  sending transactions to sequencer
::
+$  write
  $%  [%submit =egg:smart]
      [%submit-many eggs=(list egg:smart)]
  ==
--
