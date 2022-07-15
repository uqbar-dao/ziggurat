/+  erasure
=,  erasure
:-  %say
|=  [[now=@da eny=@uv *] *]
=/  short-msg  'abcdefghijklmnop'
=/  msg-125  'this is an exactly 125 byte atom. this atom is 125 bytes long. jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj125'
=/  msg-256  'this is an exactly 256 byte atom. this atom is 256 bytes long. jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj256'
=/  long-msg  'This is a long message (~2kB): Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Volutpat est velit egestas dui id ornare arcu odio ut. Sodales ut eu sem integer vitae justo. Elementum facilisis leo vel fringilla est ullamcorper eget nulla. Consectetur purus ut faucibus pulvinar. Sed elementum tempus egestas sed sed risus pretium. Pulvinar etiam non quam lacus suspendisse faucibus interdum posuere lorem. Senectus et netus et malesuada fames ac turpis. Non curabitur gravida arcu ac tortor dignissim. Convallis aenean et tortor at. Tellus in metus vulputate eu scelerisque felis imperdiet proin. A arcu cursus vitae congue mauris rhoncus aenean vel elit. Egestas integer eget aliquet nibh praesent tristique magna. Metus dictum at tempor commodo. At lectus urna duis convallis convallis. Mauris in aliquam sem fringilla ut. Leo a diam sollicitudin tempor id. Lectus nulla at volutpat diam ut. Tristique senectus et netus et malesuada fames. Mi in nulla posuere sollicitudin aliquam ultrices. Purus sit amet luctus venenatis lectus magna fringilla urna. Auctor elit sed vulputate mi sit amet mauris commodo. Sit amet justo donec enim diam vulputate ut. Quam lacus suspendisse faucibus interdum posuere lorem ipsum dolor. Id aliquet lectus proin nibh nisl condimentum id venenatis a. Sed arcu non odio euismod lacinia at quis risus. Bibendum arcu vitae elementum curabituralesuada fames. Mi in nulla posuere sollicitudin aliquam ultrices. Purus sit amet luctus venenatis lectus magna fringilla urna. Auctor elit sed vulputate mi sit amet mauris commodo. Sit amet justo donec enim diam vulputate ut. Quam lacus suspendisse faucibus interdum posuere lorem ipsum dolor. Id aliquet lectus proin nibh nisl condimentum id venenatis a. Sed arcu non odio euismod lacinia at quis risus. Bibendum arcu vitae elementum curabiturmi sit amet mauris commodo. Sit amet justo donec enim diam vulputate ut.ghggggggggggggggggggggggggggggggggggggz'
::  these are quite slow, even to generate
=/  msg-16000  `@t`(fil 3 16.000 %j)
::  =/  msg-32000  `@t`(fil 3 32.000 %j)
::  =/  msg-64000  `@t`(fil 3 64.000 %j)
::  possible problem: empty bytes in middle of atom
::  can be truncated and cause missing empty bytes
::  in encoded-decoded form. example:
=/  empty-bytes  0x2000.0000.0004.0000.0000.0000.0000.0001.0000
::  =/  nsym  10
::  =/  f  (generate-field 256)
::  =/  gen  (~(rs-generator-poly gf-math f) nsym)
::  =/  encoded  (encode-piece empty-bytes nsym f gen)
::  ~&  >>  `@ux`encoded
::  =/  decoded  (decode-piece encoded f nsym ~[0])
::  ~&  >>  `@ux`decoded
::  full chunk dispersion testing
::  GF(256) can only handle up to 255 validators!
::
=/  nchunks  20
=/  data  empty-bytes
~&  >  "Input size: {<(met 3 data)>} bytes"
~&  >>>  "encoding"
=/  encoded  (encode data nchunks)
:: can erase up to nsym.encoded pieces
=.  chunks.encoded
  (snap chunks.encoded 1 0)
=.  chunks.encoded
  (snap chunks.encoded 3 0)
=.  chunks.encoded
  (snap chunks.encoded 5 0)
=.  chunks.encoded
  (snap chunks.encoded 6 0)
=.  missing.encoded
  ~[1 3 5 6]
~&  >>>  "decoding"
=/  corrected
  (decode encoded)
:-  %noun
?:  ?!  =(data corrected)
  "Repairs were NOT successful. Decoded: {<`@ux`corrected>} Actual: {<data>}"
"Repairs were successful."
