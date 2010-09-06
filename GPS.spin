CON

VAR
  long Gstack[32] 'a stack for the GPS parser thread
  byte in_buffer[32] ' input serial buffer, for parsing
  byte in_cnt

  long lat
  long lon


OBJ
  Input : "FullDuplexSerial"

PUB Start
  Input.Start(8, -1, 0, 4800)


PUB main

  repeat
    in_cnt := 0
    ' wait for data

    repeat while in_buffer[0] <> "$"
      in_buffer[0] := Input.rx    

    in_cnt := 1
    repeat while in_cnt < 7
      in_buffer[in_cnt] := Input.rx
      in_cnt++

    ' read talker/type
    if in_buffer[1] == "G" and in_buffer[2] == "P"
      ' switch on talker/type, call parse function
      case long[@in_buffer + 2]
        "GGA":
          Parse_GPGGA
        "GSA":
          Parse_GPGSA
        "GSV":
          Parse_GPGSV
        "RMC":
          Parse_GPRMC
    ' else, bad message. restart

PUB Parse_GPGGA

{{ Format:
  $GPGGA,time,lat,N/S,lon,E/W,fix?,#satellites,HDOP,altitude,units,geoid,units,
    differential offset,age,reference station,*checksum

}}


PUB Parse_GPGSA

PUB Parse_GPGSV

PUB Parse_GPRMC