/+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(action u.args.inp) (pin caller.inp))
  ::
  +$  variable  number=@ud
  +$  action
    $%  [%make-variable initial=@ud]
        [%add amount=@ud]
        [%sub amount=@ud]
        [%giv who=id]
    ==
  ::
  ++  process
    |=  [=action caller-id=id]
    ^-  chick
    ?:  ?=(%make-variable -.action)
      =/  salt=@           `@`'math'
      =/  variable-germ=germ  [%& salt [number=initial.action]]
      =/  variable-id=id      (fry-rice caller-id me.cart town-id.cart salt)
      =/  var=grain  
        [variable-id lord=me.cart holder=caller-id town-id.cart variable-germ]
      [%& changed=~ issued=(malt ~[[id.var var]]) crow=~]
    =/  var=grain  (snag 0 ~(val by owns.cart))
    ::  only the holder of the grain or this contract can modify it
    ?>  ?|(=(caller-id holder.var) =(caller-id me.cart))
    ?>  ?=(%& -.germ.var)
    =/  variable  ;;(number=@ud data.p.germ.var)
    ?-    -.action
        %add
      =*  amount           amount.action
      =.  number.variable  (add amount number.variable)
      =.  data.p.germ.var  variable  
      [%& changed=(malt ~[[id.var var]]) ~ ~]
    ::
        %giv
      [%& changed=(malt ~[[id.var var(holder who.action)]]) ~ ~]
    ::
        %sub
      =*  amount  amount.action
      ?>  (gte number.variable amount)  :: prevent subtraction underflow from causing a crash
      ?:  =(0 amount)
        [%& ~ ~ ~]
      =/  =yolk
        :*  caller
            `[%sub (dec amount)]
            my-grains=~
            cont-grains=(silt ~[id.var])
        ==
      =.  number.variable  (dec number.variable)
      =.  data.p.germ.var  variable
      [%| next=[to=me.cart town-id.cart yolk] roost=[changed=(malt ~[[id.var var]]) ~ ~]]
    ==
  --
++  read
  |_  =path
  ++  json
    ~
  ++  noun
    ?+    path  !!
        [%is-odd ~]
      ^-  ?
      =/  var=grain   (snag 0 ~(val by owns.cart))
      =/  variable  ;;(number=@ud ?>(?=(%& -.germ.var) data.p.germ.var))
      =(1 (mod number.variable 2))
    ==
  --
--
