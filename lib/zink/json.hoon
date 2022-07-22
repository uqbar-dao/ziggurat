/-  *zink
|%
++  enjs
  |%
  ++  hints
    |=  h=^hints
    ^-  json
    a+(turn h en-hint)
  ::
  ++  en-hint
    |=  hin=cairo-hint
    ^-  json
    :-  %a
    ^-  (list json)
    ?-  -.hin
        %0
      :~  s+'0'
          s+(num axis.hin)
          s+(num leaf.hin)
          a+(turn path.hin |=(p=phash s+(num p)))
      ==
    ::
        %1
      ~[s+'1' s+(num res.hin)]
    ::
        %2
      ~[s+'2' s+(num subf1.hin) s+(num subf2.hin)]
    ::
        %3
    ::  if atom, head and tail are 0
    ::
      :+  s+'3'
        s+(num subf.hin)
      ?-  -.subf-res.hin
          %atom
        ~[s+(num +.subf-res.hin) s+'0' s+'0']
      ::
          %cell
        :~  s+'0'
            s+(num head.subf-res.hin)
            s+(num tail.subf-res.hin)
        ==
      ==
    ::
        %4
      ~[s+'4' s+(num subf.hin) s+(num atom.hin)]
    ::
        %5
      ~[s+'5' s+(num subf1.hin) s+(num subf2.hin)]
    ::
        %6
      ~[s+'6' s+(num subf1.hin) s+(num subf2.hin) s+(num subf3.hin)]
    ::
        %7
      ~[s+'7' s+(num subf1.hin) s+(num subf2.hin)]
    ::
        %8
      ~[s+'8' s+(num subf1.hin) s+(num subf2.hin)]
    ::
        %9
      :~  s+'9'
          s+(num axis.hin)
          s+(num subf1.hin)
          s+(num leaf.hin)
          a+(turn path.hin |=(p=phash s+(num p)))
      ==
    ::
        %10
      :~  s+'10'
          s+(num axis.hin)
          s+(num subf1.hin)
          s+(num subf2.hin)
          s+(num oldleaf.hin)
          a+(turn path.hin |=(p=phash s+(num p)))
      ==
    ::
        %12
      !!
    ::
        %cons
      ~[s+'cons' s+(num subf1.hin) s+(num subf2.hin)]
    ==
  ::
  ++  num
    |=  n=@ud
    `cord`(rsh [3 2] (scot %ui n))
  --
--
