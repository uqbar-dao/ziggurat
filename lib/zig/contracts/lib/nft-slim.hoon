::  /+  *zig-sys-smart
|%
++  sur
  |%
  +$  collection-metadata
    $:  name=@t
        symbol=@t
        attributes=(set @t)
        supply=@ud
        cap=(unit @ud)  ::  (~ if mintable is false)
        mintable=?      ::  automatically set to %.n if supply == cap
        minters=(set id)
        deployer=id
        salt=@
    ==
  ::
  +$  account  ::  holds your items from a given collection
    $:  metadata=id
        items=(map @ud item)      :: maps to item ids
        allowances=(jug id @ud)   :: maps to item ids
        full-allowances=(set id)  :: those with permission across all items
    ==
  ::
  ::  item id is # in collection (<=supply)
  +$  item  [id=@ud item-contents]
  +$  item-contents
    $:  data=(set [@t @t])  ::  path (remote scry source)
        desc=@t
        uri=@t
        transferrable=?
    ==
  ::
  +$  mint
    $:  to=id
        account=(unit id)
        items=(set item-contents)
    ==
  +$  arguments
    $%  [%give to=id account=(unit id) item-id=@ud]
        [%mint token=id mints=(set mint)]
        $:  %deploy
            distribution=(jug id item-contents)
            minters=(set id)
            name=@t
            symbol=@t
            attributes=(set @t)
            cap=@ud
            mintable=?
    ==  ==
  --
--
