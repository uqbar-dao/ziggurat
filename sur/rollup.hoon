::  testnet rollup
::
::  rollup app: run on ONE ship, receive moves from sequencer apps.
::
/-  sequencer
/+  smart=zig-sys-smart
|%
+$  action
  $%  [%activate ~]
      [%launch-town from=address:smart =sig:smart town:sequencer]
      [%bridge-assets town-id=id:smart assets=(map id:smart grain:smart)]
      [%receive-batch from=address:smart batch:sequencer]
  ==
--
