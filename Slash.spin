{
NOTES:
   sonar minimum range is 6 inches. anything closer than 6in reads as 6in

   Sending output data seems to cause the next input to be read incorrectly
   LESSON: Don't send serial data with Simple_Serial

   LESSON: set up the clock; if you don't, you get a really slow clock.

}
CON
  ' setting the clock mode ensures that the clock runs fast enough
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
VAR
   'Globals
   long distance[6]
   long bar

   'Sonar locals
   byte sonarCnt
   byte inCnt
   byte buffer[5]
   long Sstack[32] 'stack for Sonar

   'lightbar locals
   long Bstack[16] 'stack for lightbar
   byte outCnt

   'Process_Input locals
   long Pstack[32] 'stack for Process_Input
   byte speed
   byte dir

   'Main locals                 
   byte barDir

OBJ
   'Serin :  "Simple_Serial"
   Serin :  "FullDuplexSerial"
   Servo :  "Servo32v3"
   Polybot: "FullDuplexSerial"
   LCD    : "LCD"

PUB Main
   'LCD.start( 0, 1, 2, 24, 31)
   'LCD.out($)                ' clear screen
   'LCD.str(string("Austin's Robot"))

   cognew(Sonar, @Sstack)    ' 1 cog
   cognew(lightbar, @Bstack) 'uses a second cog for input processing
   Polybot.start(15, 14, 0, 10000) 'mode 0: don't invert, don't ignore echo

   'bar := 1
   bar := |< 16 | |<15
   'bar := |< 0 | |<31
   'bar := |<15
   
   barDir := 1
   repeat
      barDir := 0
   repeat
      'LCD.clear
      'LCD.str(string("1: "))
      'LCD.out(distance[0]) 
      'LCD.str(string(" 2: "))
      'LCD.out(distance[1]) 
      'LCD.str(string(" 3: "))
      'LCD.out(distance[2]) 
      'LCD.str(string(" 4: "))
      'LCD.out(distance[3]) 
      'LCD.str(string(" 5: "))
      'LCD.out(distance[4]) 
      'moving light
      'if bar == |< 31
      '   barDir := 0
      'if bar == |< 0
      '   barDir := 1
      'if barDir
      '   bar <<= 1
      'else
      '   bar >>= 1

      ' grows, shrinks from center
      if bar & 1
         barDir := 0
      if (bar & |< 14) == 0
         barDir := 1
      if barDir
         bar := bar << 1 | bar >> 1
      else
         bar := bar >> 1 & bar << 1

      'grows, shrinks from outside
      'if bar == |<0 | |<31
      '   barDir := 0
      'if bar & |< 15 <> 0
      '   barDir := 1
      'if barDir
      '   bar := ((bar & $0000FFFF) >> 1) | ((bar & $FFFF0000) << 1)
      'else
      '   bar := bar << 1 | bar >> 1 | |<0 | |<31

      'grows left, then right
      'if bar & 1
      '   barDir := 0
      'if bar & |<31
      '   barDir := 1
      'if barDir
      '   'shriking towards lower bits
      '   if bar & |<16
      '      bar := bar >> 1 & $FFFF0000
      '   else
      '      bar := |<15 | bar >> 1
      'else
      '   'shrinking towards higher bits
      '   if bar & |<15
      '      bar := bar << 1 & $FFFF
      '   else
      '      bar := bar << 1 | |<16
      waitcnt( clkfreq/100 * 3 + cnt)
      
CON
   DIST_H = 2
   SPEED_C = 2
   STEER_C = 2
PUB Process_Input
   'old imput processing, supplanted by light show
   'bar := distance[0] + distance[1] << 8 + distance[2] << 16 + distance[3] << 24

   if distance[0] < 12 or distance[1] < 12 or distance[2] < 12 'stop if we get too close to something
      speed := 0
      dir := 0
   elseif distance[0] < (distance[1] <# distance[2]) - DIST_H
      speed := (distance[0] - 8) * SPEED_C        'some constant times the amount of free distance
      dir := (distance[0] - distance[1]) * STEER_C 'some constant times the difference
   elseif distance[2] < (distance[0] <# distance[1]) - DIST_H
      speed := (distance[0] - 8) * SPEED_C
      dir := (distance[1] - distance[2]) * STEER_C
   else
      speed := (distance[1] - 8) * SPEED_C
      dir := 0

   Polybot.tx(0)
   Polybot.tx(speed)
   Polybot.tx(dir)

   
PUB Sonar
   DIRA[9] := 1
   DIRA[10] := 1
   DIRA[11] := 1
   DIRA[12] := 1
   DIRA[13] := 1
   
   OUTA[9] := 0
   OUTA[10] := 0
   OUTA[11] := 0
   OUTA[12] := 0
   OUTA[13] := 0
   
   distance[0] := 0
   distance[1] := 0
   distance[2] := 0
   distance[3] := 0
   distance[4] := 0

   distance[5] := 0

   sonarCnt := 0

   'Serin.init(8,-1,-9600)
   Serin.start(8, -1, 1, 9600)

   waitcnt( clkfreq + cnt ) 'wait 1 sec for sonars to settle down
   
   OUTA[sonarCnt + 9] := 1
   waitcnt( clkfreq/1000 + cnt) ' wiat 1ms
   OUTA[sonarCnt + 9] := 0

   repeat                                                                                                  
      repeat inCnt from 0 to 4
         buffer[inCnt] := Serin.rxtime(40) ' wait 40ms for data before giving up
                                           '  value determined by experimentation

      'most bit errors will cause one of these conditions to fail
      if buffer[0] == 82 and buffer[1] < 58 and buffer[1] > 47 and buffer[2] < 58 and buffer[2] > 47 and buffer[3] < 58 and buffer[3] > 47 and buffer[4] == 13
        distance[sonarCnt] := (buffer[1]-48)*100 + (buffer[2]-48)*10 + (buffer[3]-48)

        cognew(Process_Input, @Pstack)

        sonarCnt++
        if sonarCnt > 4
          sonarCnt := 0
         
        'bar := bar >> 1
        'if bar == 0
        '  bar := |< 31
      else
        'bar := bar << 1
        'if bar == 0
        '  bar := 1
        Serin.rxflush

      bar := |< sonarCnt
      
      OUTA[sonarCnt+9] := 1

      waitcnt( clkfreq/40000 * 10 + cnt) 'wait 250 us

      OUTA[sonarCnt+9] := 0

      waitcnt( clkfreq/40000 * 100 + cnt) 'wait 2.5 ms for sensor to start returning data

      'if sonarCnt == 0
      '   Servo.Set(7, 1000 + distance[sonarCnt]*4)
      'Servo.Set(7,1000 + sonarCnt*250)

PUB lightbar
   'refresh rate of about 1.5 KHz

   DIRA[16] := 1 'data
   DIRA[17] := 1 'transfer clock
   DIRA[18] := 1 'data clock

   OUTA[16] := 0 'data
   OUTA[17] := 0 'transfer clock
   OUTA[18] := 0 'data clock

   outCnt := 0

   repeat
      OUTA[16] := bar & (|< outCnt ) <> 0
      OUTA[18] := 1
      waitcnt( clkfreq/100000 + cnt) 'wait 10 us (expreimentation says 1 us doens't work here)
      OUTA[18] := 0
      waitcnt( clkfreq/100000 + cnt) 'wait 10 us
      outCnt++
      if outCnt > 31
         outCnt := 0
         OUTA[17] := 1
         waitcnt( clkfreq/100000 + cnt) 'wait 10 us
         OUTA[17] := 0
         waitcnt( clkfreq/100000 + cnt) 'wait 10 us