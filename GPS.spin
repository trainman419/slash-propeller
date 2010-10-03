CON
{{
  Notes on fixed-point math for conputing heading/location

  Need about 27 bits to represent lat/lon to enough precision

  built-in sine table provides 13 bits of input, and 17 bits of output
}}

deg_bits = 90_00_0000 / $0800

VAR
  long Gstack[32] 'a stack for the GPS parser thread
  byte in_buffer[32] ' input serial buffer, for parsing
  byte in_cnt

  long lat
  long lon
  long fix_time
  
  long time
  long fix

  byte b
  byte checksum


OBJ
  Input : "FullDuplexSerial"

PUB Start(p)
  Input.Start(p, -1, 0, 4800)
  cognew(main, @Gstack)

  time := 0
  fix := 0

  lat := 0
  lon := 0
  fix_time := 0


PUB GetLat

return lat

PUB GetLon

return lon

PUB GetFix

return fix

PUB GetTime

return time

PUB GetFixTime

return fix_time

PRI Common_Nav(lat1,lon1, lat2,lon2) : cos_d | l
  ' the calculation that is common to both heading and distance functions
  ' (1): here
  ' (2): there
  l := lon1 - lon2

  ' crazy constants are adjusting the fixed-point numbers to maintain the proper
  '  decimal precision
  ' TODO: add crazy constants here
  cos_d := (sine(lat1)**sine(lat2)) + (cosine(lat1)**cosine(lat2)**cosine(l)) 

  return cos_d
PUB Distance(lat1,lon1, lat2,lon2) : d | cos_d
'' From: http://en.wikipedia.org/wiki/Great-circle_distance
'' Compute the distance between two points
'' (1): here
'' (2): there

  cos_d := Common_Nav(lat1,lon1, lat1,lon2)


PUB Heading(lat1,lon1, lat2,lon2) : h | cos_d
'' From: http://www.ac6v.com/greatcircle.htm
'' compute the heading to get from 1 to 2
'' (1): here
'' (2): there

  cos_d := Common_Nav(lat1,lon1, lat1,lon2)

PRI sine(a) : r | base, z, tmp, diff, d, m, s, s_f
' EEW; converted from the assembly example in the manual
'  I'm guessing that this is a LOT less efficient (10x?)

' improved with interpolation... I think

' convert input from DMS to fractional degrees
  ' degrees
  d := a / 1_00_0000
  ' minutes
  m := (a // 1_00_0000) / 1_0000
  ' seconds
  s := (a // 1_0000) / 100
  ' fractional seconds
  s_f := (a // 100)

  ' convert to fractional
  m := (m * 100_0000) / 60
  s := (s * 1000) / 60

  ' combine into fractional degrees
  a := (d*1_00_0000) + (m * 1_0000) + (s * 100) + s_f 

  base := a / deg_bits ' ~43945

  ' base, range $0000-$1FFF corresponds to 0-359+

  z := 0
  if (base & $1000) <> 0 ' quadrant 3 or 4
    z := 1 ' set flag to negate output (sine > 180 is <0)
    a := 360_00_0000 - a

  if (base & $0800) <> 0 ' quadrant 2 or 4
    base := -base ' mirror input, sine(x>90) == sine(-(x-90))
    a := 180_00_0000 - a

  ' build base address
  'base := base | ($E000 >> 1)

  ' lookup
  r := word[(base << 1) | $E000]

  ' shift up
  r <<= 16

  ' convert back to degrees; compute error and interpolate
  base := base & $0FFF
  
  tmp := base * deg_bits
  if( tmp < a )
    diff := (base-1) * deg_bits
    diff := tmp - diff ' step size corresponding to 16 bits
    diff := $10000 / diff ' bits per degree. TODO: assert >1
    diff := (a - tmp) * diff ' linear error approximation
    r += diff ' correct for error
  else
    diff := (base+1) * deg_bits
    diff := diff - tmp    ' step size for 16 bits
    diff := $10000 / diff ' bits per degree
    diff := (tmp - a) * diff ' linear approximation
    r -= diff                ' correct

  ' if input >180, negate output
  if z
    r := -r

  return r
  

PRI cosine(a)
  a += 90_00_0000
  return sine(a)

PRI arccos(a) : r
  r := arcsin(a)
  r -= 90_00_0000
  return r

PRI arcsin(a) : r | base, diff

  base := $E000 ' base address of sine table
  ' high address is $F001, represents sines from 0 to 90

  ' expect input to be on the same scale as the output of the sine function
  r := $E800 ' middle of table
  diff := $0400 ' difference

  ' binary search
  repeat while diff > 0
    if long[r] > a
      if ||(long[r - diff] - a) < ||(long[r] - a)
        r -= diff

    if long[r] < a
      if ||(long[r + diff] - a) < ||(long[r] - a)
        r += diff
  
    diff >>= 1

  ' convert back to "degrees"
  r := r * (90_00_0000 / $0800)

  return r

PRI main

  repeat
    in_cnt := 0
    ' wait for data

    in_buffer[0] := Input.rx

    repeat while in_buffer[0] <> "$"
      in_buffer[0] := Input.rx    

    checksum := 0
    in_cnt := 1
    repeat while in_cnt < 7
      in_buffer[in_cnt] := read
      in_cnt++

    ' read talker/type
    if in_buffer[1] == "G" and in_buffer[2] == "P"
      ' switch on talker/type, call parse function
      ' the only messages my GPS is transmitting with position data are GGA and RMC
      if strcomp(@in_buffer, string("$GPGGA,"))
        Parse_GPGGA
      elseif strcomp(@in_buffer, string("$GPRMC,"))
        Parse_GPRMC
    ' else, bad message. restart

PRI read

  b := Input.rx
  checksum ^= b

  return b

PRI Parse_Fixed(m) : f | p
{{
  Fixed-point parser intended for latitude/longitude
  m: ensure input is multiplied by 10^m
  ignore any degimal digits after m
}}
m++

b := read
p := 0 ' count of digits past decimal point

f := 0

repeat while b <> "," and b <> "*"
  if b == "."
    p := 1
  else
    if p < m
      f := f*10 + (b - "0")
    if p > 0
      p++
  b := read

repeat while p < m
  f := f * 10
  p++

return f


PRI Parse_Int : i 
{{
  read an int into a long.
  if the input goes over the limits of a long, fail horribly
}}

b := read
i := 0

repeat while b <> "," and b <> "*"
  i := i*10 + (b - "0")
  b := read

return i

PRI Parse_none

b := read

repeat while b <> "," and b <> "*"
  b := read

return

PRI Parse_checksum : ok | c1, c2

'b := Input.rx

ok := 0

'if b == "*"
  c1 := Input.rx
  c2 := Input.rx
  if c1 >= "0" and c1 <= "9"
    c1 -= "0"
  else
    c1 -= "A"
    c1 += 10
  if c2 >= "0" and c2 <= "9"
    c2 -= "0"
  else
    c2 -= "A"
    c2 += 10
  c1 := c1 << 4 | c2
  if c1 == checksum
    ok := 1

return ok 

PRI Parse_GPGGA | time_n, lat_n, lon_n, fix_n

{{ Format:
  $GPGGA,time,lat,N/S,lon,E/W,fix?,#satellites,HDOP,altitude,units,geoid,units,
    age,reference station,*checksum

}}

time_n := Parse_Fixed(3)
lat_n := Parse_Fixed(4)

b := read
if b == "S"
  lat_n := -lat_n
b := read ' ignore; assume a comma

lon_n := Parse_Fixed(4)
b := read
if b == "E" ' non-standard, but I'd like to work in positive coordinates in california
  lon_n := -lon_n
b := read ' ignore; assume a comma

fix_n := Parse_Int

Parse_none ' #satellites used
Parse_none ' HDOP
Parse_none ' altitude
Parse_none ' units
Parse_none ' geoid
Parse_none ' units
Parse_none ' age
Parse_none ' reference station

'Parse_checksum
'if Parse_checksum
  fix := fix_n
  time := time_n
  if fix
    fix_time := time_n
    lat := lat_n
    lon := lon_n

'fix := 10

' don't eat trailing <CR><LR>, let the main loop do that 

PRI Parse_GPRMC | time_n, lat_n, lon_n, fix_n

{{ Format:
  $GPRMC, time, status, lat, N/S, lon, E/W, speed, course, date, magnetic variation, E/W, mode, checksum

}}

time_n := Parse_Fixed(3)

fix_n := 0
b := read
if b == "A"
  fix_n := 1
read ' comma

lat_n := Parse_Fixed(4)

b := read
if b == "S"
  lat_n := -lat_n
read

lon_n := Parse_Fixed(4)

b := read
if b == "E" ' non-standard, but I like to work in positive units while in California
  lon_n := -lon_n
read ' comma

Parse_none ' speed
Parse_none ' course
Parse_none ' Date
Parse_none ' Magnetic variation
Parse_none ' Variation east/west (E/W)
Parse_none ' mode

'if Parse_Checksum
  fix := fix_n
  time := time_n
  if fix
    lat := lat_n
    lon := lon_n
    fix_time := time

' don't eat trailing <CR><LR>, let the main loop do that 

return