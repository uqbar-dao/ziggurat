|_  =cart
++  write
  |=  [%give amount=@ud my-account=id]
  ^-  chick
  =/  mine=grain
    .^(grain /my-account)
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
