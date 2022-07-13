::  mill-tester.hoon [UQ| DAO]
::
::  Contract purpose-built to probe specific failure modes in mill.hoon.
::
::  Used in /tests/lib/mill.hoon
::  ID is 0xeeee.eeee
::  Used with dummy grain:
::  :*  0x9999
::      0xeeee.eeee
::      holder-1:zigs
::      town-id
::      [%& `@`'some-salt' ['some' 'random' 'data']]
::  ==
::
::  /+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  =/  grain-id=id
    (fry-rice id.from.cart me.cart town-id.cart 'salt')
  =/  new-grain=grain
    =+  [%& 'salt' 'data']
    [grain-id me.cart id.from.cart town-id.cart -]
  ?+    -.action.inp  !!
      %change-nonexistent
    (result [new-grain ~] ~ ~ ~)
  ::
      %change-type
    =.  germ.new-grain  [%| ~ ~]
    (result [new-grain ~] ~ ~ ~)
  ::
      %change-id
    ::  call with dummy grain
    =/  dummy=grain  +.-:grains.inp
    =.  id.dummy     0x8888
    (result [dummy ~] ~ ~ ~)
  ::
      %change-salt
    ::  call with dummy grain
    =/  dummy=grain  +.-:grains.inp
    ?>  ?=(%& -.germ.dummy)
    =.  salt.p.germ.dummy  `@`'some-new-salt'
    (result [dummy ~] ~ ~ ~)
  ::
      %change-lord
    ::  call with dummy grain
    =/  dummy=grain  +.-:grains.inp
    ::  try to make sneaky grain
    =.  lord.dummy  zigs-wheat-id
    (result [dummy ~] ~ ~ ~)
  ::
      %changed-issued-overlap
    (result [new-grain ~] [new-grain ~] ~ ~)
  ::
      %change-without-provenance
    ::  call with zigs account in grains.inp
    =/  not-mine=grain  +.-:grains.inp
    ?>  ?=(%& -.germ.not-mine)
    =.  data.p.germ.not-mine  ['new' 'data']
    (result [not-mine ~] ~ ~ ~)
  ::
      %issue-non-matching-id
    =.  id.new-grain  0x7864.8957
    [%& ~ (malt ~[[grain-id new-grain]]) ~ ~]
  ::
      %issue-bad-rice-id
    =.  id.new-grain  0x7864.8957
    (result ~ [new-grain ~] ~ ~)
  ::
      %issue-bad-wheat-id
    =.  germ.new-grain
      [%| ~ ~]
    (result ~ [new-grain ~] ~ ~)
  ::
      %issue-without-provenance
    =.  lord.new-grain  0xabcd.efef
    (result ~ [new-grain ~] ~ ~)
  ::
      %issue-already-existing
    ::  call with zigs account in grains.inp
    =/  not-mine=grain  +.-:grains.inp
    =.  lord.not-mine   me.cart
    (result ~ [not-mine ~] ~ ~)
  ::
      %burn-nonexistent
    (result ~ ~ [new-grain ~] ~)
  ::
      %burn-non-matching-id
    ::  call with dummy grain
    =/  dummy=grain  +.-:grains.inp
    =/  old-id  id.dummy
    =.  id.dummy  0x7864.8957
    [%& ~ ~ (malt ~[[old-id dummy]]) ~]
  ::
      %burn-changed-overlap
    ::  call with dummy grain
    =/  dummy=grain  +.-:grains.inp
    (result [dummy ~] ~ [dummy ~] ~)
  ::
      %burn-issued-overlap
    (result ~ [new-grain ~] [new-grain ~] ~)
  ::
      %burn-without-provenance
    ::  call with zigs account in grains.inp
    =/  not-mine=grain  +.-:grains.inp
    (result ~ ~ [not-mine ~] ~)
  ::
      %burn-change-lord
    ::  call with dummy grain
    =/  dummy=grain  +.-:grains.inp
    ::  try to make sneaky grain
    =.  lord.dummy  zigs-wheat-id
    (result ~ ~ [dummy ~] ~)
  ::
      %germinate-test
    ::  call with dummy grain and a non-lord grain,
    ::  make an event for each grain in owns.cart
    =/  =crow
      %+  turn  ~(tap by owns.cart)
      |=  [=id =grain]
      [%id [%s (scot %ux id)]]
    ::  crow should only have dummy grain
    (result ~ ~ ~ crow)
  ::
      %fertilize-test
    ::  call as non-holder of dummy grain,
    ::  make an event for each grain in grains.inp
    =/  =crow
      %+  turn  ~(tap by grains.inp)
      |=  [=id =grain]
      [%id [%s (scot %ux id)]]
    ::  crow should be empty
    (result ~ ~ ~ crow)
  ==
::
++  read
  |_  =path
  ++  json
    ~
  ::
  ++  noun
    ~
  --
--
