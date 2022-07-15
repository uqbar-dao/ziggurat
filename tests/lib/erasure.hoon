/+  *test, *erasure
::
::  Tests for encoding/decoding arms in erasure.hoon
::  Preparing for jetting of $encode-piece and $decode-piece
::
|%
++  short-msg  'abcdefghijklmnop'
++  msg-125  'this is an exactly 125 byte atom. this atom is 125 bytes long. jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj125'
++  msg-256  'this is an exactly 256 byte atom. this atom is 256 bytes long. jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj256'
++  long-msg  'This is a long message (~2kB): Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Volutpat est velit egestas dui id ornare arcu odio ut. Sodales ut eu sem integer vitae justo. Elementum facilisis leo vel fringilla est ullamcorper eget nulla. Consectetur purus ut faucibus pulvinar. Sed elementum tempus egestas sed sed risus pretium. Pulvinar etiam non quam lacus suspendisse faucibus interdum posuere lorem. Senectus et netus et malesuada fames ac turpis. Non curabitur gravida arcu ac tortor dignissim. Convallis aenean et tortor at. Tellus in metus vulputate eu scelerisque felis imperdiet proin. A arcu cursus vitae congue mauris rhoncus aenean vel elit. Egestas integer eget aliquet nibh praesent tristique magna. Metus dictum at tempor commodo. At lectus urna duis convallis convallis. Mauris in aliquam sem fringilla ut. Leo a diam sollicitudin tempor id. Lectus nulla at volutpat diam ut. Tristique senectus et netus et malesuada fames. Mi in nulla posuere sollicitudin aliquam ultrices. Purus sit amet luctus venenatis lectus magna fringilla urna. Auctor elit sed vulputate mi sit amet mauris commodo. Sit amet justo donec enim diam vulputate ut. Quam lacus suspendisse faucibus interdum posuere lorem ipsum dolor. Id aliquet lectus proin nibh nisl condimentum id venenatis a. Sed arcu non odio euismod lacinia at quis risus. Bibendum arcu vitae elementum curabituralesuada fames. Mi in nulla posuere sollicitudin aliquam ultrices. Purus sit amet luctus venenatis lectus magna fringilla urna. Auctor elit sed vulputate mi sit amet mauris commodo. Sit amet justo donec enim diam vulputate ut. Quam lacus suspendisse faucibus interdum posuere lorem ipsum dolor. Id aliquet lectus proin nibh nisl condimentum id venenatis a. Sed arcu non odio euismod lacinia at quis risus. Bibendum arcu vitae elementum curabiturmi sit amet mauris commodo. Sit amet justo donec enim diam vulputate ut.ghggggggggggggggggggggggggggggggggggggz'
::  larger than this is quite slow, even to generate
++  msg-16000  `@t`(fil 3 16.000 %j)
::  TODO
++  generate-random-atom  ~
++  test-encode-decode-1
  =/  nchunks  12
  ::  very circular, but difficult to create proper testing parameters
  =/  encoded  (encode msg-256 nchunks)
  =/  to-erase  `(list @ud)`~[0 1 2 3]
  =.  chunks.encoded
    =<  q
    %^    spin
        to-erase
      chunks.encoded
    |=  [i=@ud chunks=(list @)]
    [i (snap chunks i 0)]
  =.  missing.encoded
    to-erase
  (expect-eq !>(msg-256) !>(`@t`(decode encoded)))
++  test-encode-decode-2
  =/  nchunks  36
  ::  very circular, but difficult to create proper testing parameters
  =/  encoded  (encode long-msg nchunks)
  ::  try decoding with many combinations of erased chunks
  ::  total # of erasures it can handle == nsym.encoded
  %+  expect-eq
    !>(%.y)
  !>
  %+  levy
    ^-  (list (list @ud))
    :~
      ~[0 1 2 3 4 5]
      ~[0 2 4 6 8 10]
      ~[1 3 5 7 9 11]
      ~[34 33 32 31 30]
      ~[0 34 2 32 4 30]
      (gulf 1 nsym.encoded)
      (gulf 5 (add nsym.encoded 4))
    ==
  |=  to-erase=(list @ud)
  =.  chunks.encoded
    =<  q
    %^    spin
        to-erase
      chunks.encoded
    |=  [i=@ud chunks=(list @)]
    [i (snap chunks i 0)]
  =.  missing.encoded
    to-erase  
  .=(long-msg (decode encoded))
++  test-encode-decode-3
  =/  nchunks  255 ::maximum
  =/  encoded  (encode long-msg nchunks)
  %+  expect-eq
    !>(%.y)
  !>
  %+  levy
    ^-  (list (list @ud))
    :~
      ~[0 1 2 3 4 5]
      ~[0 2 4 6 8 10]
      ~[1 3 5 7 9 11]
      ~[34 33 32 31 30]
      ~[0 34 2 32 4 30]
      (gulf 1 nsym.encoded)
      (gulf 5 (add nsym.encoded 4))
    ==
  |=  to-erase=(list @ud)
  =.  chunks.encoded
    =<  q
    %^    spin
        to-erase
      chunks.encoded
    |=  [i=@ud chunks=(list @)]
    [i (snap chunks i 0)]
  =.  missing.encoded
    to-erase
  .=(long-msg `@t`(decode encoded))
--
