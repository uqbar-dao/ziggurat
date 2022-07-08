  /+  *zig-sys-smart
|%
+$  collection-metadata
  $:  name=@t
      symbol=@t
      supply=@ud
      cap=(unit @ud)  ::  (~ if mintable is false)
      mintable=?      ::  automatically set to %.n if supply == cap
      minters=(set id)
      deployer=id
      salt=@          ::  is this the same as the grain salt? what does it do
  ==
::
::  The NFT type
+$  item  [meta=id item-num=@ud item-contents]
+$  item-contents
  $:  data=(set [@t @t])  ::  do we need this?
      desc=@t
      uri=@t
      transferrable=?
  ==
::
+$  mint
  $:  to=id  :: what if we just minted directly to ourselves and only thru caller was the nft ever changed
      items=(set item-contents)
  ==
::
+$  action
  $%  [%give to=id]
      [%mint meta=id mints=(set mint)]
      $:  %deploy
          minters=(set id)
          name=@t
          symbol=@t
          cap=@ud
          mintable=?
  ==  ==
--
