CON

VAR
  long Gstack[32] 'a stack for the GPS parser thread
  byte in_buffer[32] ' input serial buffer, for parsing
  byte in_cnt

  long lat
  long lon
  long time
  long fix

  byte b
  byte checksum


OBJ
  Input : "FullDuplexSerial"

PUB Start
  Input.Start(8, -1, 0, 4800)


PRI main

  repeat
    in_cnt := 0
    ' wait for data

    repeat while in_buffer[0] <> "$"
      in_buffer[0] := Input.rx    

    checksum := 0
    in_cnt := 1
    repeat while in_cnt < 7
      in_buffer[in_cnt] := Input.rx
      checksum ^= in_buffer[in_cnt]
      in_cnt++

    ' read talker/type
    if in_buffer[1] == "G" and in_buffer[2] == "P"
      ' switch on talker/type, call parse function
      case long[@in_buffer + 2]
        (((((","<<8)|"A")<<8)|"G")<<8)|"G": ' "GGA,"
          Parse_GPGGA
        (((((","<<8)|"A")<<8)|"S")<<8)|"G": ' "GSA,"
          Parse_GPGSA
        (((((","<<8)|"V")<<8)|"S")<<8)|"G": ' "GSV,"
          Parse_GPGSV
        (((((","<<8)|"C")<<8)|"M")<<8)|"R": ' "RMC,"
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

b := read
p := 0 ' flag for decimal point

f := 0

repeat while b <> ","
  if b == "."
    p := 1
  else
    if p < m
      f := f*10 + (b - "0") '
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

repeat while b <> ","
  i := i*10 + (b - "0")
  b := read

return i

PRI Parse_none

b := read

repeat while b <> ","
  b := read

return

PRI Parse_checksum : ok | c1, c2

b := Input.rx

ok := 0

if b == "*"
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
if b == "W"
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

if Parse_checksum
  fix := fix_n
  if fix
    time := time_n
    lat := lat_n
    lon := lon_n

' don't eat trailing <CR><LR>, let the main loop do that 


PRI Parse_GPGSA

PRI Parse_GPGSV

PRI Parse_GPRMC