|_  =cart
++  write
  |=  [%give amount=@ud my-account=[%grain =id]]
  ^-  chick
  =/  mine=grain  (~(got by grains.cart) id.my-account)
  ?>  ?=(%& -.mine)
  ?>  =(holder.p.mine id.from.cart)
  (result ~ ~ ~ [[%hello [%n (scot %ud (dec amount))]] ~])
++  read
  |_  =path
  ++  json
    ~
  ++  noun
    ~
  --
--
