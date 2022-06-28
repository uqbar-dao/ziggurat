/+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(action u.args.inp) (pin caller.inp))
  ::
  +$  value  number=@ud
  +$  action
    $%  [%make-value initial=@ud]
        [%add amount=@ud]
        [%sub amount=@ud]
        [%giv who=id]
    ==
  ++  process
    |=  [=action caller-id=id]
    ^-  chick
    ?:  ?=(%make-value -.action)
      =/  salt=@           `@`'math'
      =/  value-germ=germ  [%& salt [number=initial.action]]
      =/  value-id=id      (fry-rice caller-id me.cart town-id.cart salt)
      =/  val=grain  
        [value-id lord=me.cart holder=caller-id town-id.cart value-germ]
      [%& changed=~ issued=(malt ~[[id.val val]]) crow=~]
    =/  val=grain  (snag 0 ~(val by owns.cart))
    ::  only the holder of the grain or this contract can modify it
    ?>  ?|(=(caller-id holder.val) =(caller-id me.cart))
    ?>  ?=(%& -.germ.val)
    =/  value  ;;(number=@ud data.p.germ.val)
    ?-    -.action
        %add
      =*  amount           amount.action
      =.  number.value     (add amount number.value)
      =.  data.p.germ.val  value  
      [%& changed=(malt ~[[id.val val]]) ~ ~]
    ::
        %giv
      [%& changed=(malt ~[[id.val val(holder who.action)]]) ~ ~]
    ::
        %sub
      ::  TODO recursive addition
      =*  amount           amount.action
      ?>  (gte number.value amount.action)  :: prevent subtraction underflow from causing a crash
      =.  number.value     (sub number.value amount.action)
      =.  data.p.germ.val  value
      [%& changed=(malt ~[[id.val val]]) ~ ~]
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
      =/  val=grain   (snag 0 ~(val by owns.cart))
      =/  value  ;;(number=@ud ?>(?=(%& -.germ.val) data.p.germ.val))
      =(1 (mod number.value 2))
    ==
  --
--
