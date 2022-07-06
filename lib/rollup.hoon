/-  *rollup
|%
::
::  +allowed-participant: grades whether a ship is permitted to participate
::  in UQ| sequencing. currently using hardcoded whitelist
::
++  allowed-participant
  |=  [=ship our=ship now=@da]
  ^-  ?
  (~(has in whitelist) ship)
++  whitelist
  ^-  (set ship)
  %-  ~(gas in *(set ship))
  :~  ::  fakeships for localhost testnets
      ~zod  ~bus  ~nec  ~wet  ~rys
      ::  hodzod's testing moons
      ~watryp-loplyd-dozzod-bacrys
      ::  hosted's testing moons
      ~ricmun-lasfer-hosted-fornet
      ::  ~littel-wolfur's
      ~harden-ripped-littel-wolfur
      ~mipber
      ::  ~roslug-fampet's testing moons
      ~hosdex-hodsud-roslug-fampet
  ==
--
