  /+  *zig-sys-smart
|%
+$  collection
  $:  name=@t
      symbol=@t
      supply=@ud
      cap=@ud
      minters=(set id)
      deployer=id
  ==
::
+$  item  [collection=id item-num=@ud item-contents]
+$  item-contents
  $:  data=(map @t @t)
      desc=@t
      uri=@t
      transferrable=?
  ==
::
+$  action
  $%  [%deploy name=@t symbol=@t cap=@ud minters=(set id)]  ::  expects no grains
      [%mint items=(list item-contents)]                     ::  expects collection grain in owns.cart  / cont-grains
      [%give to=id]                                         ::  expects the item grain in grains.inp / my-grains 
  ==
--
