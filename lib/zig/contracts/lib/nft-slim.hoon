::  TODO rename collection-metadata to something shorter? collection-data, nft-metadata
::  TODO rename item to nft? nft-item?
::
  /+  *zig-sys-smart
|%
+$  collection-metadata
  $:  name=@t
      symbol=@t
      supply=@ud
      cap=@ud
      minters=(set id)
      deployer=id
  ==
::
+$  item  [meta=id item-num=@ud item-contents]
+$  item-contents
  $:  data=(set [@t @t])
      desc=@t
      uri=@t
      transferrable=?
  ==
::
+$  action
  $%  [%deploy name=@t symbol=@t cap=@ud minters=(set id)]  ::  expects no grains
      [%mint items=(set item-contents)]                     ::  expects metadata grain in owns.cart  / cont-grains
      [%give to=id]                                         ::  expects the item grain in grains.inp / my-grains 
  ==
--
