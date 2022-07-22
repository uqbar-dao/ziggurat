|%
+$  granary-scry
  $-  ^
  (unit [path=(list phash) product=*])
::
+$  child  *
+$  parent  *
+$  phash  @                     ::  Pedersen hash
+$  hash-req
  $%  [%cell head=phash tail=phash]
      [%atom val=@]
  ==
::
+$  cairo-hint
  $%  [%0 axis=@ leaf=phash path=(list phash)]
      [%1 res=phash]
      [%2 subf1=phash subf2=phash]
      ::  encodes to
      ::   [3 subf-hash atom 0] if atom
      ::   [3 subf-hash 0 cell-hash cell-hash] if cell
      ::
      $:  %3
          subf=phash
          $=  subf-res
          $%  [%atom @]
              [%cell head=phash tail=phash]
          ==
      ==
      [%4 subf=phash atom=@]
      [%5 subf1=phash subf2=phash]
      [%6 subf1=phash subf2=phash subf3=phash]
      [%7 subf1=phash subf2=phash]
      [%8 subf1=phash subf2=phash]
      [%9 axis=@ subf1=phash leaf=phash path=(list phash)]
      [%10 axis=@ subf1=phash subf2=phash oldleaf=phash path=(list phash)]
      [%12 grain-id=@ leaf=phash path=(list phash)]  ::  leaf should be hash of grain-id, path is through granary
      [%cons subf1=phash subf2=phash]
      ::[%jet core=phash sample=* jet=@t]
  ==
:: subject -> formula -> hint
::+$  hints  (mip phash phash cairo-hint)
+$  hints  (list cairo-hint)
::  map of a noun's merkle children. root -> [left right]
+$  merk-tree  (map phash [phash phash])
::  map from axis to jet name
+$  jetmap  (map @ @tas)
::  Axis map of jets in stdlib
++  jets
  %-  ~(gas by *jetmap)
  :~  [2.398 %dec]
  ==
--
