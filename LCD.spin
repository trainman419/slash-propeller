VAR

   byte e_pin
   byte rw_pin
   byte rs_pin

   byte d7_pin
   byte d0_pin

PUB start(e, rw, rs, d0, d7)
   e_pin := e
   rw_pin := rw
   rs_pin := rs
   d7_pin := d7
   d0_pin := d0

   ' set things as output
   DIRA[d0_pin..d7_pin] := $FF
   DIRA[e_pin] := 1
   DIRA[rw_pin] := 1
   DIRA[rs_pin] := 1

   OUTA[e_pin] := 0
   OUTA[rw_pin] := 0
   OUTA[rs_pin] := 0

   waitcnt( clkfreq + cnt) ' wait for LCD to initialize

   OUTA[d7_pin..d0_pin] := $30
   repeat 3
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 1
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 0
      
   OUTA[d7_pin..d0_pin] := $3C      
   repeat 1
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 1
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 0
      
   OUTA[d7_pin..d0_pin] := $02      
   repeat 1
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 1
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 0
      
   OUTA[d7_pin..d0_pin] := $0C      
   repeat 1
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 1
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 0

PUB clear
   OUTA[rs_pin] := 0

   OUTA[d7_pin..d0_pin] := $01
      
   repeat 1
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 1
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 0

   OUTA[d7_pin..d0_pin] := $02
      
   repeat 1
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 1
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 0


PUB out(b)
   OUTA[rs_pin] := 1

   OUTA[d7_pin..d0_pin] := b & $FF
      
   repeat 1
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 1
      waitcnt( clkfreq/1000 + cnt)
      OUTA[e_pin] := 0

PUB str(stringptr)

'' Print a zero-terminated string

  repeat strsize(stringptr)
    out(byte[stringptr++])
