/+  smart=zig-sys-smart
|%
::  managing the uqbar
::
+$  action
  $%  [%set-sources rollup-host=ship indexers=(list [town-id=id:smart (list dock)])]
      [%add-source town-id=id:smart =dock]  ::  added to end of priority list
      [%remove-source town-id=id:smart =dock]
  ==
::  ++  on-peek
::  reading info from indexer
::
+$  read
  $%  [%contract =id:smart town-id=id:smart args=^ grains=(list id:smart)]  ::  perform read direct from sequencer
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
      [%receipt egg-hash=@ux ship-sig=[p=@ux q=ship r=life] uqbar-sig=sig:smart]
  ==
+$  write-result
  $%  [%sent ~]
      [%receipt egg-hash=@ux ship-sig=[p=@ux q=ship r=life] uqbar-sig=sig:smart]
      [%rejected ~]
      [%executed result=errorcode:smart]
      [%nonce value=@ud]
  ==
--
