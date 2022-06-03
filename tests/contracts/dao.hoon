::  Tests for dao.hoon (token contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/-  d=dao,
    r=resource
/+  *test,
    cont=zig-contracts-dao,
    smart=zig-sys-smart
=>  ::  test data
    |%
    ::
    ++  dao-contract-id
      ^-  id:smart
      0xda0
    ::
    ++  town-id
      ^-  @ud
      1
    ::
    ++  make-placeholder-dao-comms-rid
      ::  This is used cavalierly below.
      ::  In a real context, users should have %read/%write
      ::  permissions to graphs, not the DAO comms "group".
      ^-  resource:r
      [~zod %dao-comms-placeholder]
    ::
    ++  make-dao-into-grain
      |=  [dao-salt=@ =dao:d]
      ^-  grain:smart
      =/  dao-id=id:smart  (make-dao-id dao-salt)
      :*  id=dao-id
          lord=dao-contract-id
          holder=dao-contract-id
          town-id=town-id
          germ=(make-dao-germ dao-salt dao)
      ==
    ::
    ++  make-dao-id
      |=  dao-salt=@
      ^-  id:smart
      %:  fry-rice:smart
          dao-contract-id
          dao-contract-id
          town-id
          dao-salt
      ==
    ::
    ++  make-dao-germ
      |=  [dao-salt=@ =dao:d]
      ^-  germ:smart
      :-  %&
      [salt=dao-salt data=dao]
    ::
    ++  make-id-grain-map
      |=  [dao-salt=@ =dao:d]
      ^-  (map id:smart grain:smart)
      =/  dao-id=id:smart
        (make-dao-id dao-salt)
      %+  %~  put  by  *(map id:smart grain:smart)
        dao-id
      (make-dao-into-grain dao-salt dao)
    ::
    ++  make-cart
      |=  owns=(map id:smart grain:smart)
      ^-  cart:smart
      :*  mem=~
          me=dao-contract-id
          block=0
          town-id=town-id
          owns=owns
      ==
    ::
    ++  make-permissions
      |=  dao-id=id:smart
      ^-  permissions:d
      %-  %~  gas  by  *permissions:d
      :+  :-  name=%write
          %-  %~  gas  ju  *(jug address:d role:d)
          :+  [dao-id %owner]
            [make-placeholder-dao-comms-rid %pleb]
          ~
      ::
        :-  name=%read
        %-  %~  gas  ju  *(jug address:d role:d)
        :+  [make-placeholder-dao-comms-rid %owner]
          [make-placeholder-dao-comms-rid %pleb]
        ~
      ::
      ~
    ::
    ++  make-id-to-ship
      |=  id-ship-pairs=(list (pair id:smart ship))
      ^-  id-to-ship:d
      (~(gas by *id-to-ship:d) id-ship-pairs)
    ::
    ++  make-ship-to-id
      |=  ship-id-pairs=(list (pair ship id:smart))
      ^-  ship-to-id:d
      (~(gas by *ship-to-id:d) ship-id-pairs)
    ::
    ++  make-add-jannie-read-permission-update
      ^-  on-chain-update:d
      :-  %add-permissions
      :^    megacorp-dao-id
          %read
        make-placeholder-dao-comms-rid
      (~(put in *(set role:d)) %jannie)
    ::
    ++  make-add-comms-host-permissions-and-role-updates
      ^-  (list on-chain-update:d)
      :+  :-  %add-permissions
          :^    megacorp-dao-id
              %host
            make-placeholder-dao-comms-rid
          (~(put in *(set role:d)) %comms-host)
        :-  %add-roles
        :+  megacorp-dao-id
          (~(put in *(set role:d)) %comms-host)
        megacorp-ceo-id
      ~
    ::
    ++  make-megacorp-ceo-vote-zygote
      |=  proposal-id=id:smart
      ^-  zygote:smart
      =/  args
        :^    ~
            %vote
          dao-id=megacorp-dao-id
        proposal-id=proposal-id
      ::
      :+  caller=[id=megacorp-ceo-id nonce=0 zigs=0xd0.11a5]
        args=args
      grains=~
    ::
    ++  startup-dao-salt
      ^-  id:smart
      0xfa57
    ::
    ++  startup-dao-id
      ^-  id:smart
      (make-dao-id startup-dao-salt)
    ::
    ++  startup-ceo-id
      ^-  id:smart
      0xb055
    ::
    ++  startup-ceo-ship
      ^-  ship
      ~wes
    ::
    ++  startup-dao
      |^  ^-  dao:d
      :*  name='scrappy startup'
          permissions=(make-permissions startup-dao-id)
          members=make-members
          id-to-ship=make-startup-id-to-ship
          ship-to-id=make-startup-ship-to-id
          subdaos=~
          threshold=1
          proposals=~
      ==
      ::
      ++  make-members
        ^-  members:d
        %+  %~  put  ju  *members:d
        startup-ceo-id  %owner
      ::
      ++  make-startup-id-to-ship
        ^-  id-to-ship:d
        %-  make-id-to-ship
        :-  [startup-ceo-id startup-ceo-ship]
        ~
      ::
      ++  make-startup-ship-to-id
        ^-  ship-to-id:d
        %-  make-ship-to-id
        :-  [startup-ceo-ship startup-ceo-id]
        ~
      ::
      --
    ::
    ++  megacorp-dao-salt
      ^-  id:smart
      0xb16
    ::
    ++  megacorp-dao-id
      ^-  id:smart
      (make-dao-id megacorp-dao-salt)
    ::
    ++  megacorp-ceo-id
      ^-  id:smart
      0xce0
    ::
    ++  megacorp-ceo-ship
      ^-  ship
      ~zod
    ::
    ++  megacorp-cmo-id
      ^-  id:smart
      0x5e.11e2
    ::
    ++  megacorp-cmo-ship
      ^-  ship
      ~nec
    ::
    ++  megacorp-pleb-id
      ^-  id:smart
      0x1.100b
    ::
    ++  megacorp-pleb-ship
      ^-  ship
      ~bud
    ::
    ++  marketing-dao-salt
      ^-  id:smart
      0x5e11
    ::
    ++  marketing-dao-id
      ^-  id:smart
      (make-dao-id marketing-dao-salt)
    ::
    ++  marketing-dao
      |^  ^-  dao:d
      :*  name='megacorp marketing'
          permissions=(make-permissions marketing-dao-id)
          members=make-members
          id-to-ship=make-marketing-id-to-ship
          ship-to-id=make-marketing-ship-to-id
          subdaos=~
          threshold=1
          proposals=~
      ==
      ::
      ++  make-members
        ^-  members:d
        %-  %~  gas  ju  *members:d
        :+  [megacorp-cmo-id %owner]
          [megacorp-pleb-id %pleb]
        ~
      ::
      ++  make-marketing-id-to-ship
        ^-  id-to-ship:d
        %-  make-id-to-ship
        :+  [megacorp-cmo-id megacorp-cmo-ship]
          [megacorp-pleb-id megacorp-pleb-ship]
        ~
      ::
      ++  make-marketing-ship-to-id
        ^-  ship-to-id:d
        %-  make-ship-to-id
        :+  [megacorp-cmo-ship megacorp-cmo-id]
          [megacorp-pleb-ship megacorp-pleb-id]
        ~
      ::
      --
    ::
    ++  megacorp-dao
      |^  ^-  dao:d
      :*  name='megacorp'
          permissions=(make-permissions megacorp-dao-id)
          members=make-members
          id-to-ship=make-megacorp-id-to-ship
          ship-to-id=make-megacorp-ship-to-id
          subdaos=(~(put in *(set id:smart)) marketing-dao-id)
          threshold=2
          proposals=make-proposals
      ==
      ::
      ++  make-members
        ^-  members:d
        %-  %~  gas  ju  *members:d
        :^    [megacorp-ceo-id %owner]
            [megacorp-cmo-id %owner]
          [megacorp-pleb-id %pleb]
        ~
      ::
      ++  make-megacorp-id-to-ship
        ^-  id-to-ship:d
        %-  make-id-to-ship
        :^    [megacorp-ceo-id megacorp-ceo-ship]
            [megacorp-cmo-id megacorp-cmo-ship]
          [megacorp-pleb-id megacorp-pleb-ship]
        ~
      ::
      ++  make-megacorp-ship-to-id
        ^-  ship-to-id:d
        %-  make-ship-to-id
        :^    [megacorp-ceo-ship megacorp-ceo-id]
            [megacorp-cmo-ship megacorp-cmo-id]
          [megacorp-pleb-ship megacorp-pleb-id]
        ~
      ::
      ++  make-proposals
        ^-  (map @ux [updates=(list on-chain-update:d) votes=(set id:smart)])
        %-  %~  gas  by
          *(map @ux [updates=(list on-chain-update:d) votes=(set id:smart)])
        :~  :+  0xde0  ::  for test-vote-valid-proposal-non-final-vote
              :_  ~
              :-  %add-member
              :^  megacorp-dao-id
                  (~(put in *(set role:d)) %pleb)
                startup-ceo-id
              startup-ceo-ship
            ~
        ::
            :+  0xde1  ::  for test-execute-final-vote-add-member
              :_  ~
              :-  %add-member
              :^    megacorp-dao-id
                  (~(put in *(set role:d)) %pleb)
                startup-ceo-id
              startup-ceo-ship
            make-cmo-vote-set
        ::
            :+  0xde2  ::  for test-execute-final-vote-remove-member
              :_  ~
              :-  %remove-member
              :-  megacorp-dao-id
              megacorp-pleb-id
            make-cmo-vote-set
        ::
            :+  0xde3  ::  for test-execute-final-vote-add-permissions
              :_  ~
              :-  %add-permissions
              :^    megacorp-dao-id
                  %host
                make-placeholder-dao-comms-rid
              (~(put in *(set role:d)) %comms-host)
            make-cmo-vote-set
        ::
            :+  0xde4  ::  for test-execute-final-vote-remove-permissions
              :_  ~
              :-  %remove-permissions
              :^  megacorp-dao-id
                  %write
                make-placeholder-dao-comms-rid
              (~(put in *(set role:d)) %pleb)
            make-cmo-vote-set
        ::
            :+  0xde5  ::  for test-execute-final-vote-add-subdao
              :_  ~
              :-  %add-subdao
              :-  megacorp-dao-id
              startup-dao-id
            make-cmo-vote-set
        ::
            :+  0xde6  ::  for test-execute-final-vote-remove-subdao
              :_  ~
              :-  %remove-subdao
              :-  megacorp-dao-id
              marketing-dao-id
            make-cmo-vote-set
        ::
            :+  0xde7  ::  for test-execute-final-vote-add-roles
              :_  ~
              :-  %add-roles
              :+  megacorp-dao-id
                (~(put in *(set role:d)) %owner)
              megacorp-pleb-id
            make-cmo-vote-set
        ::
            :+  0xde8  ::  for test-execute-final-vote-remove-roles
              :_  ~
              :-  %remove-roles
              :+  megacorp-dao-id
                (~(put in *(set role:d)) %owner)
              megacorp-cmo-id
            make-cmo-vote-set
        ::
            :+  (mug (jam ~[make-add-jannie-read-permission-update]))
              :_  ~
              make-add-jannie-read-permission-update
            ~
        ::
            :+  (mug (jam make-add-comms-host-permissions-and-role-updates))
              make-add-comms-host-permissions-and-role-updates
            make-cmo-vote-set
        ::
        ==
      ::
      ++  make-cmo-vote-set
        ^-  (set id:smart)
        (~(put in *(set id:smart)) megacorp-cmo-id)
      ::
      --
    ::
    --
::  testing arms
|%
++  test-matches-type
  =+  [is-success chick]=(mule |.(;;(contract:smart cont)))
  %+  expect-eq
    !>  %.y
    !>  is-success
::
::  tests for %add-dao
::
++  test-add-dao-new-id
  |^
  =/  expected-chick=chick:smart  make-expected-chick
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart               make-zygote
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  weld
    %+  expect-eq
      !>  %.y
      !>  is-success
    %+  expect-eq
      !>  expected-chick
      !>  chick
  ::
  ++  new-dao-salt
    0xda.0da0
  ::
  ++  make-new-salt-and-dao
    ^-  [salt=@ =dao:d]
    [salt=new-dao-salt data=startup-dao]
  ::
  ++  make-expected-chick
    |^  ^-  chick:smart
    :-  %&
    :+  ~
      %+  %~  put  by  *(map id:smart grain:smart)
        (make-dao-id new-dao-salt)
      make-new-dao-grain
    ~
    ::
    ++  make-new-dao-grain
      ^-  grain:smart
      :*  id=(make-dao-id new-dao-salt)
          lord=dao-contract-id
          holder=dao-contract-id
          town-id=town-id
          ::  reuse startup-dao
          germ=(make-dao-germ new-dao-salt startup-dao)
      ==
    ::
    --
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    ~
  ::
  ++  make-zygote
    ^-  zygote:smart
    :+  caller=[id=startup-ceo-id nonce=0 zigs=0xd0.11a5]
      args=`[%add-dao make-new-salt-and-dao]
    grains=~
  ::
  --
::
:: ++  test-add-dao-existing-id
::   ::  this must happen at mill level (i.e. cannot have `issued`
::   ::  grains that already exist)
::
:: ++  test-add-dao-unchangeable
::   ::  TODO: contract should fail to create an unchangeable DAO
::
::  tests for %vote
::
++  test-vote-valid-proposal-non-final-vote
  |^
  =/  expected-chick=chick:smart  make-expected-chick
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart               make-zygote
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  weld
    %+  expect-eq
      !>  %.y
      !>  is-success
    %+  expect-eq
      !>  expected-chick
      !>  chick
  ::
  ++  make-expected-chick
    ^-  chick:smart
    =/  =dao:d  megacorp-dao
    :-  %&
    :+  %+  make-id-grain-map  megacorp-dao-salt
        %=  dao
            proposals
          %+  %~  jab  by  proposals.dao
            0xde0
          |=  [updates=(list on-chain-update:d) votes=(set id:smart)]
          :-  updates
          (~(put in votes) megacorp-ceo-id)
        ==
      ~
    ~
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  ++  make-zygote
    ^-  zygote:smart
    :+  caller=[id=megacorp-ceo-id nonce=0 zigs=0xd0.11a5]
      args=`[%vote dao-id=megacorp-dao-id proposal-id=0xde0]
    grains=~
  ::
  --
::
++  test-vote-non-existent-proposal
  |^
  =/  =cart:smart    make-test-cart
  =/  =zygote:smart  make-zygote
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  expect-eq
    !>  %.n
    !>  is-success
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  ++  make-zygote
    ^-  zygote:smart
    :+  caller=[id=megacorp-ceo-id nonce=0 zigs=0xd0.11a5]
      args=`[%vote dao-id=megacorp-dao-id proposal-id=0xde.1234]
    grains=~
  ::
  --
::
++  test-vote-not-owner
  |^
  =/  =cart:smart    make-test-cart
  =/  =zygote:smart  make-zygote
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  expect-eq
    !>  %.n
    !>  is-success
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  ++  make-zygote
    ^-  zygote:smart
    :+  caller=[id=megacorp-pleb-id nonce=0 zigs=0xd0.11a5]
      args=`[%vote dao-id=megacorp-dao-id proposal-id=0xde0]
    grains=~
  ::
  --
::
++  test-vote-wrong-dao
  ::  TODO: can this test be more useful?
  |^
  =/  =cart:smart    make-test-cart
  =/  =zygote:smart  make-zygote
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  expect-eq
    !>  %.n
    !>  is-success
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map startup-dao-salt startup-dao)
  ::
  ++  make-zygote
    ^-  zygote:smart
    :+  caller=[id=megacorp-ceo-id nonce=0 zigs=0xd0.11a5]
      args=`[%vote dao-id=megacorp-dao-id proposal-id=0xde0]
    grains=~
  ::
  --
::
:: ++  test-vote-non-existent-dao
::
::  tests for %propose
::
++  test-propose-valid-proposal
  |^
  =/  expected-chick=chick:smart  make-expected-chick
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart               make-zygote
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  weld
    %+  expect-eq
      !>  %.y
      !>  is-success
    %+  expect-eq
      !>  expected-chick
      !>  chick
  ::
  ++  make-expected-chick
    ^-  chick:smart
    =/  =dao:d  megacorp-dao
    =/  updates=(list on-chain-update:d)
      ~[make-on-chain-update]
    :-  %&
    :+  %+  make-id-grain-map  megacorp-dao-salt
        %=  dao
            proposals
          %+  %~  put  by  proposals.dao
            (mug (jam updates))
          [updates=updates votes=~]
        ==
      ~
    ~
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  ++  make-zygote
    ^-  zygote:smart
    =/  args
      :^    ~
          %propose
        dao-id=megacorp-dao-id
      updates=~[make-on-chain-update]
    ::
    :+  caller=[id=megacorp-ceo-id nonce=0 zigs=0xd0.11a5]
      args=args
    grains=~
  ::
  ++  make-on-chain-update
    ^-  on-chain-update:d
    :-  %add-permissions
    :^    megacorp-dao-id
        %write
      make-placeholder-dao-comms-rid
    (~(put in *(set role:d)) %jannie)
  ::
  --
::
++  test-propose-valid-proposal-multiple-updates
  |^
  =/  expected-chick=chick:smart  make-expected-chick
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart               make-zygote
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  weld
    %+  expect-eq
      !>  %.y
      !>  is-success
    %+  expect-eq
      !>  expected-chick
      !>  chick
  ::
  ++  make-expected-chick
    ^-  chick:smart
    =/  =dao:d  megacorp-dao
    =/  updates=(list on-chain-update:d)
      make-on-chain-updates
    :-  %&
    :+  %+  make-id-grain-map  megacorp-dao-salt
        %=  dao
            proposals
          %+  %~  put  by  proposals.dao
            (mug (jam updates))
          [updates=updates votes=~]
        ==
      ~
    ~
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  ++  make-zygote
    ^-  zygote:smart
    =/  args
      :^    ~
          %propose
        dao-id=megacorp-dao-id
      updates=make-on-chain-updates
    ::
    :+  caller=[id=megacorp-ceo-id nonce=0 zigs=0xd0.11a5]
      args=args
    grains=~
  ::
  ++  make-on-chain-updates
    ^-  (list on-chain-update:d)
    :^    :-  %add-roles
          :+  megacorp-dao-id
            (~(put in *(set role:d)) %owner)
          megacorp-pleb-id
        :-  %add-roles
        :+  megacorp-dao-id
          (~(put in *(set role:d)) %pleb)
        megacorp-cmo-id
      :-  %remove-roles
      :+  megacorp-dao-id
        (~(put in *(set role:d)) %owner)
      megacorp-cmo-id
    ~
  ::
  --
::
++  test-propose-existing-proposal
  |^
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart               make-zygote
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  expect-eq
    !>  %.n
    !>  is-success
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  ++  make-zygote
    ^-  zygote:smart
    =/  args
      :^    ~
          %propose
        dao-id=megacorp-dao-id
      updates=~[make-add-jannie-read-permission-update]
    ::
    :+  caller=[id=megacorp-ceo-id nonce=0 zigs=0xd0.11a5]
      args=args
    grains=~
  ::
  --
::
++  test-propose-not-owner
  |^
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart               make-zygote
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  expect-eq
    !>  %.n
    !>  is-success
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  ++  make-zygote
    ^-  zygote:smart
    =/  args
      :^    ~
          %propose
        dao-id=megacorp-dao-id
      updates=~[make-on-chain-update]
    ::
    :+  caller=[id=megacorp-pleb-id nonce=0 zigs=0xd0.11a5]
      args=args
    grains=~
  ::
  ++  make-on-chain-update
    ^-  on-chain-update:d
    :-  %add-permissions
    :^    megacorp-dao-id
        %write
      make-placeholder-dao-comms-rid
    (~(put in *(set role:d)) %jannie)
  ::
  --
::
++  test-propose-length-zero-update
  |^
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart               make-zygote
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  expect-eq
    !>  %.n
    !>  is-success
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  ++  make-zygote
    ^-  zygote:smart
    =/  args
      :^    ~
          %propose
        dao-id=megacorp-dao-id
      updates=~
    ::
    :+  caller=[id=megacorp-ceo-id nonce=0 zigs=0xd0.11a5]
      args=args
    grains=~
  ::
  --
::
:: ++  test-propose-wrong-dao
:: ::
:: ++  test-propose-non-existent-dao
::
::  tests for %execute
::
++  test-execute-user-cant-call
  |^
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart               make-zygote
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  expect-eq
    !>  %.n
    !>  is-success
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  ++  make-zygote
    ^-  zygote:smart
    =/  args
      :^    ~
          %execute
        dao-id=megacorp-dao-id
      updates=~[make-on-chain-update]
    ::
    :+  caller=[id=megacorp-ceo-id nonce=0 zigs=0xd0.11a5]
      args=args
    grains=~
  ::
  ++  make-on-chain-update
    ^-  on-chain-update:d
    :-  %add-permissions
    :^    megacorp-dao-id
        %write
      make-placeholder-dao-comms-rid
    (~(put in *(set role:d)) %jannie)
  ::
  --
::
++  test-execute-final-vote-add-member
  |^
  =/  expected-chick=chick:smart  make-expected-chick
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart
    (make-megacorp-ceo-vote-zygote make-proposal-id)
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  weld
    %+  expect-eq
      !>  %.y
      !>  is-success
    %+  expect-eq
      !>  expected-chick
      !>  chick
  ::
  ++  make-proposal-id
    ^-  id:smart
    0xde1
  ::
  ++  make-expected-chick
    ^-  chick:smart
    =/  =dao:d  megacorp-dao
    :-  %&
    :+  %+  make-id-grain-map  megacorp-dao-salt
        %=  dao
            members
          %+  %~  put  ju  members.dao
          startup-ceo-id  %pleb
        ::
            id-to-ship
          %+  %~  put  by  id-to-ship.dao
          startup-ceo-id  startup-ceo-ship
        ::
            ship-to-id
          %+  %~  put  by  ship-to-id.dao
          startup-ceo-ship  startup-ceo-id
        ::
            proposals
          (~(del by proposals.dao) make-proposal-id)
        ::
        ==
      ~
    ~
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  --
::
++  test-execute-final-vote-remove-member
  |^
  =/  expected-chick=chick:smart  make-expected-chick
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart
    (make-megacorp-ceo-vote-zygote make-proposal-id)
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  weld
    %+  expect-eq
      !>  %.y
      !>  is-success
    %+  expect-eq
      !>  expected-chick
      !>  chick
  ::
  ++  make-proposal-id
    ^-  id:smart
    0xde2
  ::
  ++  make-expected-chick
    ^-  chick:smart
    =/  =dao:d  megacorp-dao
    :-  %&
    :+  %+  make-id-grain-map  megacorp-dao-salt
        %=  dao
            members
          %+  %~  del  ju  members.dao
          megacorp-pleb-id  %pleb
        ::
            id-to-ship
          %-  %~  del  by  id-to-ship.dao
          megacorp-pleb-id
        ::
            ship-to-id
          %-  %~  del  by  ship-to-id.dao
          megacorp-pleb-ship
        ::
            proposals
          (~(del by proposals.dao) make-proposal-id)
        ::
        ==
      ~
    ~
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  --
::
++  test-execute-final-vote-add-permissions
  |^
  =/  expected-chick=chick:smart  make-expected-chick
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart
    (make-megacorp-ceo-vote-zygote make-proposal-id)
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  weld
    %+  expect-eq
      !>  %.y
      !>  is-success
    %+  expect-eq
      !>  expected-chick
      !>  chick
  ::
  ++  make-proposal-id
    ^-  id:smart
    0xde3
  ::
  ++  make-expected-chick
    ^-  chick:smart
    =/  =dao:d  megacorp-dao
    :-  %&
    :+  %+  make-id-grain-map  megacorp-dao-salt
        %=  dao
            permissions
          %+  %~  put  by  permissions.dao
            name=%host
          %+  %~  put  ju  *(jug address:d role:d)
          make-placeholder-dao-comms-rid  %comms-host
        ::
            proposals
          (~(del by proposals.dao) make-proposal-id)
        ::
        ==
      ~
    ~
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  --
::
++  test-execute-final-vote-remove-permissions
  |^
  =/  expected-chick=chick:smart  make-expected-chick
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart
    (make-megacorp-ceo-vote-zygote make-proposal-id)
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  weld
    %+  expect-eq
      !>  %.y
      !>  is-success
    %+  expect-eq
      !>  expected-chick
      !>  chick
  ::
  ++  make-proposal-id
    ^-  id:smart
    0xde4
  ::
  ++  make-expected-chick
    ^-  chick:smart
    =/  =dao:d  megacorp-dao
    :-  %&
    :+  %+  make-id-grain-map  megacorp-dao-salt
        %=  dao
            permissions
          %+  %~  jab  by  permissions.dao
            name=%write
          |=  write-perms=(jug address:d role:d)
          %+  %~  del  ju  write-perms
          make-placeholder-dao-comms-rid  %pleb
        ::
            proposals
          (~(del by proposals.dao) make-proposal-id)
        ::
        ==
      ~
    ~
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  --
::
++  test-execute-final-vote-add-subdao
  |^
  =/  expected-chick=chick:smart  make-expected-chick
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart
    (make-megacorp-ceo-vote-zygote make-proposal-id)
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  weld
    %+  expect-eq
      !>  %.y
      !>  is-success
    %+  expect-eq
      !>  expected-chick
      !>  chick
  ::
  ++  make-proposal-id
    ^-  id:smart
    0xde5
  ::
  ++  make-expected-chick
    ^-  chick:smart
    =/  =dao:d  megacorp-dao
    :-  %&
    :+  %+  make-id-grain-map  megacorp-dao-salt
        %=  dao
            subdaos
          %-  %~  put  in  subdaos.dao
          startup-dao-id
        ::
            proposals
          (~(del by proposals.dao) make-proposal-id)
        ::
        ==
      ~
    ~
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  --
::
++  test-execute-final-vote-remove-subdao
  |^
  =/  expected-chick=chick:smart  make-expected-chick
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart
    (make-megacorp-ceo-vote-zygote make-proposal-id)
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  weld
    %+  expect-eq
      !>  %.y
      !>  is-success
    %+  expect-eq
      !>  expected-chick
      !>  chick
  ::
  ++  make-proposal-id
    ^-  id:smart
    0xde6
  ::
  ++  make-expected-chick
    ^-  chick:smart
    =/  =dao:d  megacorp-dao
    :-  %&
    :+  %+  make-id-grain-map  megacorp-dao-salt
        %=  dao
            subdaos
          %-  %~  del  in  subdaos.dao
          marketing-dao-id
        ::
            proposals
          (~(del by proposals.dao) make-proposal-id)
        ::
        ==
      ~
    ~
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  --
::
++  test-execute-final-vote-add-roles
  |^
  =/  expected-chick=chick:smart  make-expected-chick
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart
    (make-megacorp-ceo-vote-zygote make-proposal-id)
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  weld
    %+  expect-eq
      !>  %.y
      !>  is-success
    %+  expect-eq
      !>  expected-chick
      !>  chick
  ::
  ++  make-proposal-id
    ^-  id:smart
    0xde7
  ::
  ++  make-expected-chick
    ^-  chick:smart
    =/  =dao:d  megacorp-dao
    :-  %&
    :+  %+  make-id-grain-map  megacorp-dao-salt
        %=  dao
            members
          %+  %~  put  ju  members.dao
          megacorp-pleb-id  %owner
        ::
            proposals
          (~(del by proposals.dao) make-proposal-id)
        ::
        ==
      ~
    ~
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  --
::
++  test-execute-final-vote-remove-roles
  |^
  =/  expected-chick=chick:smart  make-expected-chick
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart
    (make-megacorp-ceo-vote-zygote make-proposal-id)
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  weld
    %+  expect-eq
      !>  %.y
      !>  is-success
    %+  expect-eq
      !>  expected-chick
      !>  chick
  ::
  ++  make-proposal-id
    ^-  id:smart
    0xde8
  ::
  ++  make-expected-chick
    ^-  chick:smart
    =/  =dao:d  megacorp-dao
    :-  %&
    :+  %+  make-id-grain-map  megacorp-dao-salt
        %=  dao
            members
          %+  %~  del  ju  members.dao
          megacorp-cmo-id  %owner
        ::
            proposals
          (~(del by proposals.dao) make-proposal-id)
        ::
        ==
      ~
    ~
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  --
::
++  test-execute-final-vote-multiple-updates
  |^
  =/  expected-chick=chick:smart  make-expected-chick
  =/  =cart:smart                 make-test-cart
  =/  =zygote:smart
    (make-megacorp-ceo-vote-zygote make-proposal-id)
  =+  [is-success chick]=(mule |.((~(write cont cart) zygote)))
  %+  weld
    %+  expect-eq
      !>  %.y
      !>  is-success
    %+  expect-eq
      !>  expected-chick
      !>  chick
  ::
  ++  make-proposal-id
    ^-  id:smart
    %-  mug
    %-  jam
    make-add-comms-host-permissions-and-role-updates
  ::
  ++  make-expected-chick
    ^-  chick:smart
    =/  =dao:d  megacorp-dao
    :-  %&
    :+  %+  make-id-grain-map  megacorp-dao-salt
        %=  dao
            members
          %+  %~  put  ju  members.dao
          megacorp-ceo-id  %comms-host
        ::
            permissions
          %+  %~  put  by  permissions.dao
            name=%host
          %+  %~  put  ju  *(jug address:d role:d)
          make-placeholder-dao-comms-rid  %comms-host
        ::
            proposals
          (~(del by proposals.dao) make-proposal-id)
        ::
        ==
      ~
    ~
  ::
  ++  make-test-cart
    ^-  cart:smart
    %-  make-cart
    (make-id-grain-map megacorp-dao-salt megacorp-dao)
  ::
  --
::
--
