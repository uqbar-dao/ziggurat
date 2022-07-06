/-  *sequencer
/+  smart=zig-sys-smart
|%
++  epoch-interval  ~s30
++  relay-town-id   0
::
::  epoch >> slot >> block >> chunk
::
+$  epoch   [num=@ud =start=time order=(list ship) =slots]
+$  epochs  ((mop @ud epoch) gth)
++  poc     ((on @ud epoch) gth)
::
+$  slot   (pair block-header (unit block))
+$  slots  ((mop @ud slot) gth)
++  sot    ((on @ud slot) gth)
::
+$  height        @ud  ::  block height
+$  block         [=height =signature =chunks]
+$  block-header  [num=@ud prev-header-hash=@uvH data-hash=@uvH]
::
+$  chunks  (map town-id=@ud =chunk)
+$  chunk   [(list [@ux egg:smart]) land]
::
+$  signature   [p=@ux q=ship r=life]
::
+$  update
  $%  [%epochs-catchup =epochs]
      [%blocks-catchup epoch-num=@ud =slots]
      [%new-block epoch-num=@ud header=block-header =block]
      [%saw-block epoch-num=@ud header=block-header]
      [%indexer-block epoch-num=@ud epoch-start-time=time header=block-header blk=(unit block)]
  ==
--
