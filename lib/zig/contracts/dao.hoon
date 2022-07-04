::  dao.hoon  [UQ| DAO]
::
::  Provides the entire on-chain backend for an EScape DAO.
::  Holds a recording of members along with their roles. This
::  contract can serve unlimited DAOs, who simply store their
::  structure as rice held and ruled by this contract on-chain.
::
::  /+  *zig-sys-smart
/=  dao  /lib/zig/contracts/lib/dao
=,  dao
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(arguments:sur u.args.inp) (pin caller.inp))
  ::
  ++  process
    |=  [args=arguments:sur caller-id=id]
    ?-    -.args
    ::
        %add-dao
      ?>  ?=(^ dao.args)
      =/  new-dao-germ=germ  [%& salt.args u.dao.args]
      =/  new-dao-id=id
        (fry-rice me.cart me.cart town-id.cart salt.args)
      =-  [%& ~ (malt ~[[new-dao-id -]]) ~]
      :*  id=new-dao-id
          lord=me.cart
          holder=me.cart
          town-id=town-id.cart
          germ=new-dao-germ
      ==
    ::
        %vote
      =*  dao-id       dao-id.args
      =*  proposal-id  proposal-id.args
      =/  [dao-grain=grain =dao:sur]
        (get-grain-and-dao:lib cart dao-id)
      ?>  ?=(%& -.germ.dao-grain)
      ?>  %:  is-allowed:lib
              [%& caller-id]
              dao-id
              %write
              [%& dao]
          ==
      =/  prop  (~(got by proposals.dao) proposal-id)
      =.  prop  prop(votes (~(put in votes.prop) caller-id))
      ?:  (gth threshold.dao ~(wyt in votes.prop))
        ::  if threshold is higher than current # of votes,
        ::  just register vote and update rice
        =.  dao  dao(proposals (~(put by proposals.dao) proposal-id prop))
        [%& (malt ~[[id.dao-grain dao-grain(data.p.germ dao)]]) ~ ~]
      ::  otherwise execute proposal and remove from rice
      =.  data.p.germ.dao-grain
        dao(proposals (~(del by proposals.dao) proposal-id))
      %=  $
          args       [%execute dao-id update.prop]
          caller-id  me.cart
          owns.cart
        (~(put by owns.cart) dao-id dao-grain)
      ==
    ::
        %propose
      =*  dao-id  dao-id.args
      =*  update  on-chain-update.args
      =/  [dao-grain=grain =dao:sur]
        (get-grain-and-dao:lib cart dao-id)
      ?>  ?=(%& -.germ.dao-grain)
      ?>  %:  is-allowed:lib
              [%& caller-id]
              dao-id
              %write
              [%& dao]
          ==
      ?<  |(?=(%add-dao -.update) ?=(%remove-dao -.update))
      =/  proposal-id=@ux  (mug update)
      ?<  (~(has by proposals.dao) proposal-id)
      =.  proposals.dao
        %+  ~(put by proposals.dao)
          proposal-id
        [update=update votes=~]
      [%& (malt ~[[id.dao-grain dao-grain(data.p.germ dao)]]) ~ ~]
    ::
        %execute
      ?>  =(me.cart caller-id)
      =*  dao-id  dao-id.args
      =*  update  on-chain-update.args
      =/  [dao-grain=grain =dao:sur]
        (get-grain-and-dao:lib cart dao-id)
      ?>  ?=(%& -.germ.dao-grain)
      =.  dao
        ?+    -.update  !!
            %add-member
          (~(add-member update:lib dao) +.+.update)
        ::
            %remove-member
          (~(remove-member update:lib dao) +.+.update)
        ::
            %add-permissions
          (~(add-permissions update:lib dao) +.+.update)
        ::
            %remove-permissions
          (~(remove-permissions update:lib dao) +.+.update)
        ::
            %add-subdao
          (~(add-subdao update:lib dao) +.+.update)
        ::
            %remove-subdao
          (~(remove-subdao update:lib dao) +.+.update)
        ::
            %add-roles
          (~(add-roles update:lib dao) +.+.update)
        ::
            %remove-roles
          (~(remove-roles update:lib dao) +.+.update)
        ==
      [%& (malt ~[[id.dao-grain dao-grain(data.p.germ dao)]]) ~ ~]
    ==
  --
::
++  read
  |_  args=path
  ++  json
    ^-  ^json
    ?+    args  !!
        [%rice-data ~]
      ?>  =(1 ~(wyt by owns.cart))
      =/  g=grain  -:~(val by owns.cart)
      ?>  ?=(%& -.germ.g)
      (dao:enjs:lib ;;(dao:sur data.p.germ.g))
    ::
        [%rice-data @ ~]
      %-  dao:enjs:lib
      ;;(dao:sur (cue (slav %ud i.t.args)))
    ::
        [%egg-args @ ~]
      %-  arguments:enjs:lib
      ;;(arguments:sur (cue (slav %ud i.t.args)))
    ==
  ::
  ++  noun
    ~
  --
--
