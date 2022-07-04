:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [town-id=@ux to=@ux amt=@ud ~] ~]
=+  .^(keys=(set @ux) %gx /(scot %p p.bek)/wallet/(scot %da now)/keys/noun)
?>  !=(~ keys)
:-  %zig-wallet-poke
:*  %submit
    (head keys)
    `@ux`'zigs-contract'
    town-id
    [1 10.000]
    [%give `@ux`'zigs' to amt]
==
