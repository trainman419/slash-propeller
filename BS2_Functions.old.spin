{{
  *************************************************
  *  BS2 Functions Library Object                 *
  *  Version 1.5.1                                *
  *  Copyright (c) 2007, Martin Hebel             *
  *  See end of file for terms of use.            *               
  *************************************************
  *  Functional Equivalents of many BS2 Commands  *
  *                                               *
  *                  12/18/07                     *
  *         Primary Author: Martin Hebel          *
  *       Electronic Systems Technologies         *
  *   Southern Illinois University Carbondale     *
  *            www.siu.edu/~isat/est              *
  *                                               *
  *   Additional Code from:                       *
  *     Andy Lindsay, Parallax                    *
  *     Paul B. Voss, Smith College               *
  *           www.science.smith.edu/cmet/         *     
  *                                               *
  * Questions? Please post on the Propeller forum *
  *       http://forums.parallax.com/forums/      *
  *************************************************


    To use include in code:
  ------------------------------------------------
CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
                     
OBJ
    BS2 : "BS2_Functions"    ' Create BS2 Object

PUB Start 
    BS2.start (31,30)        ' Initialize BS2 Object timing, Rx and Tx pins for DEBUG
' **************************************************************************************
' *    NOTE: YOU MUST START THE OBJECT as it sets up the timing for many functions     *
' **************************************************************************************
  ------------------------------------------------

    Use Functions as:
       BS2.FREQOUT(pin,duration,frequency)
       or
       MyVariable := BS2.PULSIN(pin,state)

       See comments for each specific function for use.    
  ________________________________________________________________________

  Note: SHIFTIN/OUT, DEBUG/IN and SERIN/OUT are only recommended at 80MHz
        Maximum Baud Rate is 9600.
        For more options, use the"FullDuplexSerial" Library.

Revision History:
3/14/06 - Initial release
3/30/06 - Modified RCTime function due to math errors with large values
        - Made modifications to documentation notes for various functions
8/27/06 - Made adjustments to SERIN_Str function
        - Added SERIN_Wait function to wait for a character.
        - Corrected problems in SERIN_DEC/DEBUG_DEC for single characters and added error checking
1/25/07 - Set DEBUG pin directions and states to limit glitches on 1st use
3/12/07 - Made a big note about having to start() the function

10/21/07 - Beta release of 1.4.9

11/23/07 - Added additional functions and a small correction

        Added functions for:
                FREQOUT_SetB(Pin, Freq)
                      To sound a second tone on the defined pin continuously

                High(pin)
                       To set the !/O to be output high

                Low(pin)
                       To set the I/O to be an output low

                In(pin)
                       To set the I/O to be an input 

        
        Continuous Counter:
                Count_Start(pin)
                       To start counting on specified pin

                Count_Read
                       To read current count value

                Count_Stop
                       To stop counting

                Count_StartB(pin)
                Count_ReadB
                Count_Stop
                       Same using counter B
        
          EEPROM Access:
                Read(Addr,size) where size is number of bytes (1 for byte, 2 for word ,4 for long) 
                       Read EEPROM in code space, from top (32767) to bottom (0)
                       myVar := Read(0,4) ' long, 4 bytes
                       
                Read_HighMem(Addr,size) where size is number of bytes (1 for byte, 2 for word ,4 for long)
                       Read upper 32K of 64K EEPROM
                       myVar := Read_HighMem(3,4) ' read a long, 4 bytes
                       
                Read_CodeMem(Addr,size) where size is number of bytes (1 for byte, 2 for word ,4 for long)
                       Read from direct code memory
                       No coding required, variable or stack will have last value saved

                Write(Addr,Value, size) where size is number of bytes (1 for byte, 2 for word ,4 for long) 
                       Write to EEPROM in code space, from top (32767) to bottom (0)
                       where 0 = top of memory
                       Write(0, myData,4)   ' write long myData to top of memory
                       See precautions in method comments
                       
                Write_HighMem(Addr,Value, size) where size is number of bytes (1 for byte, 2 for word ,4 for long)
                       Write to upper 32K of 64K EEPROM
                       Write_HighMem(0,myVal,2) ' write byte variable myVal to upper 32K lowest address
                       See precautions in method comments
                       
                Write_CodeMem(Addr,Value, size) where size is number of bytes (1 for byte, 2 for word ,4 for long)
                       Write to direct code memory
                       Useful in having a variable survive a reset
                       Write_I2C(@myData,myData,4)
                       See precautions in method comments
           PWM:
                PWM_Set(Pin, Duty, Resolution)
                       Sets continuous PWM on pin specified for value and bit resolution specified
                       PWM_Set(Pin, Duty, resolution)
                       PWM_Set(2,500,10)  ' 10 bit resolution, 0 to 1023 Duty
                       
                PWM_SetB(Pin, Duty, Resolution)  
                       Sets continuous PWM on pin specified for value and bit resolution specified
                       PWM_SetB(Pin, Duty, resolution)
                       PWM_SetB(2,100,8)  ' 8 bit resolution, 0 to 255 Duty

                PWM and PWM_100 functions have been adapted to use PWM_SetB.

          DEBUG:
                DEBUG_CR
                        Sends a Carraige return for DEBUG (CR - ASCII 13) 

        Note: The following use counters, the versions that are continous and can be interrupted
              if another command using the same counter is executed unless another cog is started:

              COUNT             Momentary               Counter A
              FREQOUT           Momentary               Counter A
              PWM               Momentary               Counter A
              FREQIN            Momentary               Counter A
              PULSIN            Momentary               Counter A 

              Count_Start,
              Count_Read,
              Count_Stop        Continuous              Counter A

              Count_StartB,
              Count_ReadB,
              Count_StopB       Continuous              Counter B

              PWM_SET           Continuous              Counter A
              PWM_SETB          Continuous              Counter B   

              FREQOUT_SET       Continuous              Counter A
              FREQOUT_SETB      Continuous              Counter B



        Bug Fix:
             Actually inverted the data on SERIN when #INV mode is declared!! Thanks Glenn Tarbox!
             ... Hope I did it correctly, not tested!

}}

var
  long s, ms, us,Last_Freq,Last_FreqB
  Byte DataIn[50],DEBUG_PIN,DEBUGIN_PIN    
  
con
  ' SHIFTIN Constants
  MSBPRE   = 0
  LSBPRE   = 1
  MSBPOST  = 2
  LSBPOST  = 3
  OnClock  = 4   ' Used for I2C
  
  ' SHIFTOUT Constants
  LSBFIRST = 0
  MSBFIRST = 1
  ' SEROUT/SERIN Constants
  NInv     = 1
  Inv      = 0

  cntMin     = 400      ' Minimum waitcnt value to prevent lock-up
  DEBUG_BAUD = 9600     ' DEBUG Serial speed - maximum!
  DEBUG_MODE = 1        ' Non-Inverted

  SCL = 28
  SDA = 29


PUB Start (Debug_rx, Debug_tx)
'' Initialize variables and pins for DEBUGIN and DEBUG
'' AND TIMING FOR MANY FUNCTION, typically:
'' BS2.Start(31,30)

  Debug_Pin := Debug_tx                     ' DEBUG Tx Pin
  DebugIn_Pin := Debug_rx                   ' DEBUG Rx Pin
  dira[debug_Pin]~~
  outa[debug_Pin]~~
  dira[debugIn_Pin]~
  s:= clkfreq                               ' Clock cycles for 1 s
  ms:= clkfreq / 1_000                      ' Clock cycles for 1 ms
  us:= clkfreq / 1_000_000                  ' Clock cycles for 1 us 
  Last_Freq := 0                            ' Holds last setting for FREQOUT_SET

PUB COUNT (Pin, Duration) : Value
{{
  Counts rising-edge pulses on Pin for Duration in mS
  Maximum count is around 30MHz
  Example Code:
    x := BS2.count(5,100)                ' Measure count for 100 mSec
    BS2.Debug_Dec(x)                     ' DEBUG value
    BS2.Debug_Char(13)                   ' CR
}}

       dira[PIN]~                                          ' Set as input
       ctra := 0                                           ' Clear any value in ctrb
                                                           ' set up counter, pos edge trigger
       ctra := (%01010 << 26 ) | (%001 << 23) | (0 << 9) | (PIN)  
       frqa := 1                                           ' 1 count/trigger
       phsa := 0                                           ' Clear phase - holds accumulated count
       pause(duration)                                     ' Allow to count for duration in mS
       Value := phsa                                       ' Return total count
       ctra := 0                                           ' clear counter mode
       
PUB COUNT_Start (Pin) : Value
{{
  Counts rising-edge pulses on Pin continuously
  Maximum count is around 30MHz
  Example Code:
    BS2.count_start(5)                    ' Start reading counts
    ' some time later                    
    x := BS2.Count_read                  ' read value of counter
    BS2.Debug_Dec(x)                     ' DEBUG value
    BS2.Debug_CR                         ' CR
}}

       dira[PIN]~                                          ' Set as input
       ctra := 0                                           ' Clear any value in ctra
                                                           ' set up counter, pos edge trigger
       ctra := (%01010 << 26 ) | (%001 << 23) | (0 << 9) | (PIN)  
       frqa := 1                                           ' 1 count/trigger
       phsa := 0                                           ' Clear phase - holds accumulated count


Pub Count_Read
{{
  Read the current accumulated count
  x := bs2.Count_Read
}}
    Return phsa

Pub Count_Stop
{{
    Stops the counter
    bs2.Count_Stop
}}
    ctra := 0

PUB COUNT_StartB (Pin) : Value
{{
  Counts rising-edge pulses on Pin continuously
  Maximum count is around 30MHz
  Example Code:
    BS2.count_startB(5)                    ' Start reading counts
    ' some time later                    
    x := BS2.Count_read                  ' read value of counter
    BS2.Debug_Dec(x)                     ' DEBUG value
    BS2.Debug_CR                         ' CR
}}

       dira[PIN]~                                          ' Set as input
       ctrb := 0                                           ' Clear any value in ctrb
                                                           ' set up counter, pos edge trigger
       ctrb := (%01010 << 26 ) | (%001 << 23) | (0 << 9) | (PIN)  
       frqb := 1                                           ' 1 count/trigger
       phsb := 0                                           ' Clear phase - holds accumulated count


Pub Count_ReadB
{{
  Read the current accumulated count
  x := bs2.Count_ReadB
}}
    Return phsb

Pub Count_StopB
{{
    Stops the counter
    bs2.Count_StopB
}}
    ctrb := 0
    
PUB Debug_CR
    {{ Sends a carriage return}}
    Debug_char(13)
   
PUB DEBUG_CHAR(Char) 
{{ 
  Sends chracter (byte) data at 9600 Baud to DEBUG TX pin.
    BS2.Debug_Char(13)  ' CR
    BS2.Debug_Char(65)  ' Letter A
    BS2.Debug_Char("A") ' Letter A 
 }}

   SEROUT_CHAR(Debug_Pin,char,DEBUG_Baud,DEBUG_MODE,8)     ' Send character using SEROUT

PUB DEBUG_BIN(value, Digits)
{{
  Sends value as binary value without %, for up to 32 Digits
    BS2.DEBUG_BIN(x,16)
      Code adapted from "FullDuplexSerial"
}}
  value <<= 32 - digits                                    ' Shift bits for number of digits
  repeat digits                                            ' Repeat for number of digital
    DEBUG_CHAR((value <-= 1) & 1 + "0")                    ' Shift value and test each for 1 + 0 ASCII
    
PUB DEBUG_DEC(Value) 
{{
  Sends value as decimal value.
    BS2.DEBUG_DEC(x)     
}}

  SEROUT_DEC(Debug_Pin,Value,Debug_Baud,DEBUG_MODE,8)      ' Send using SEROUT_DEC code
   
PUB DEBUG_HEX(value, digits)
{{
  Sends value as binary value without $ for number of digits defined
    BS2.DEBUG_HEX(x,4)
      Code adapted from "FullDuplexSerial"
}}
  value <<= (8 - digits) << 2                              ' Shiftover for number of hex digits
  repeat digits                                            ' lookup ASCII for nibble, sub and shift
     Debug_CHAR(lookupz((value <-= 4) & $F : "0".."9", "A".."F")) 

PUB DEBUG_STR(stringPtr)
{{
  Sends a string for DEBUGing
    BS2.Debug_Str(string("Spin-Up World!",13))
    BS2.Debug_Str(@myStr)

}}                                                         
    SEROUT_Str(Debug_Pin,stringPtr,Debug_Baud,DEBUG_MODE,8)' send using serout_str        


PUB DEBUG_IBIN(value, digits)
{{
  Sends value as binary value with %, for up to 32 Digits
    BS2.DEBUG_IBIN(x,16)
}} 
    debug_CHAR("%")                                        ' Send leading %
    DEBUG_BIN(value,digits)                                ' Send value as binary


PUB DEBUG_IHEX(Value,Digits)
{{
  Sends value as binary value without $ for number of digits defined
    BS2.Debug_IHEX(x,4)
}}
    DEBUG_CHAR("$")                                        ' Send leading $        
    DEBUG_HEX(value,digits)                                ' Send value as Hex  


PUB DEBUGIN_CHAR : ByteVal
{{
  Accepts a single serial character (byte) on DEBUGIN_Pin at 9600 Baud
  Will cause cog-lockup while waiting without a cog-watchdog (see example)
    x := BS2.DEBUGIN_Char
    BS2.DEBUG_Char(x)
}}
    ByteVal := SERIN_CHAR(DEBUGIN_PIN,DEBUG_BAUD,DEBUG_MODE,8)' Send character using SEROUT_Char

       
PUB DEBUGIN_DEC : Value
{{
  Accepts a decimal value on DEBUGIN_Pin at 9600 Baud, up through a CR
  Will cause cog-lockup while waiting without a cog-watchdog (see example)
  Values may be +/-, no error checking for garbage.
    x := BS2.DEBUGIN_Dec
    BS2.DEBUG_Dec(x)
}}
   Value := SERIN_DEC(DEBUGIN_PIN,DEBUG_BAUD,DEBUG_MODE,8)    ' Get using Serin_DEC

PUB DEBUGIN_STR (stringptr)
{{
  Accepts a character string on DEBUGIN_Pin at 9600 Baud, up through a CR
  Maximum is 49 character, such as "abc, 123, you and me!" 
  Will cause cog-lockup while waiting without a cog-watchdog (see example)
  NOTE: There is NO buffer overflow protection!
  
VAR
    Byte myString[50]  

    Repeat
        BS2.DebugIn_Str(@myString)   ' Accept string passing pointer for variable
        BS2.Debug_Str(@myString)     ' display string at pointer
        BS2.Debug_Char(13)           ' CR
        BS2.Debug_Char(myString[5])  ' show 5th character

}}           
    
   SERIN_Str(DEBUGIN_Pin, stringPtr, DEBUG_Baud, DEBUG_MODE, 8)   ' Get using SERIN_Str
   
PUB FREQOUT(Pin,Duration, Frequency) 
{{
  Plays frequency defines on pin for duration in mS, does NOT support dual frequencies.
    BS2.Freqout(5,500,2500)    ' Produces 2500Hz on Pin 5 for 500 mSec
}}
   Update(Pin,Frequency,0)                                 ' Set tone using FREQOUT_Set
   Pause(Duration)                                         ' duration pause
   Update(Pin,0,0)                                         ' stop tone


PUB FREQOUT_Set(Pin, Frequency) 
{{
   Plays frequency defined on pin INDEFINATELY does NOT support dual frequencies.
   Use Frequency of 0 to stop.
     BS2.FREQOUT_Set(5, 2500)  ' Produces 2500Hz on Pin 5 forever
     BS2.FREQOUT_Set(5,0)      ' Turns off frequency     
}}
   If Frequency <> Last_Freq                               ' Check to see if freq change
      Update(Pin,Frequency,0)                              ' update tone 
      Last_Freq := Frequency                               ' save last

PUB FREQOUT_SetB(Pin, Frequency) 
{{
   Plays frequency defined on pin INDEFINATELY does NOT support dual frequencies.
   Use Frequency of 0 to stop.
     BS2.FREQOUT_Set(5, 2500)  ' Produces 2500Hz on Pin 5 forever
     BS2.FREQOUT_Set(5,0)      ' Turns off frequency     
}}
   If Frequency <> Last_FreqB                               ' Check to see if freq change
      Update(Pin,Frequency,1)                              ' update tone 
      Last_FreqB := Frequency                               ' save last

PUB FREQIN (pin, duration) : Frequency 
{{
  Measure frequency on pin defined for duration defined.
  Positive edge triggered
    x:= BS2.FreqIn(5)
}}
  dira[PIN]~                 
       ctra := 0                                           ' Clear ctra settings
                                                           ' trigger to count rising edge on pin
       ctra := (%01010 << 26 ) | (%001 << 23) | (0 << 9) | (PIN)  
       frqa := 1000                                        ' count 1000 each trigger
         phsa:=0                                           ' clear accumulated value
         pause(duration)                                   ' pause for duration
         Frequency := phsa / duration                      ' calculate freq based on duration

PUB HIGH (pin)
{{
  Sets the specified I/O to be a high
  BS2.High(15)
}}

  dira[pin]~~
  outa[pin]~~


PUB IN (pin)
{{
  Sets the specified I/O to be an input, returns the value
  x:=BS2.In(15)
}}

  dira[pin]~
  outa[pin]~
  return ina[pin]

PUB LOW (pin)
{{
  Sets the specified I/O to be a low
  BS2.low(15)
}}

  dira[pin]~~
  outa[pin]~
    
PUB PAUSE(Duration) | clkCycles
{{
   Causes a pause for the duration in mS
   Smallest value is 2 at clkfreq = 5Mhz, higher frequencies may use 1
   Largest value is around 50 seconds at 80Mhz.
     BS2.Pause(1000)   ' 1 second pause
}}

   clkCycles := Duration * ms-2300 #> cntMin               ' duration * clk cycles for ms
                                                           ' - inst. time, min cntMin
   waitcnt( clkCycles + cnt )                              ' wait until clk gets there


PUB PAUSE_uS(Duration) | clkCycles
{{
   Causes a pause for the duration in uS
   Smallest value is 20 at clkfreq = 80Mhz
   Largest value is around 50 seconds at 80Mhz.
     BS2.Pause_uS(1000)   ' 1 mS pause
}}
   clkCycles := Duration * uS #> cntMin                    ' duration * clk cycles for us
                                                           ' - inst. time, min cntMin 
   waitcnt(clkcycles + cnt)                                ' wait until clk gets there                             
    

PUB PULSOUT(Pin,Duration)  | clkcycles
{{
   Produces an opposite pulse on the pin for the duration in 2uS increments
   Smallest value is 10 at clkfreq = 80Mhz
   Largest value is around 50 seconds at 80Mhz.
     BS2.Pulsout(500)   ' 1 mS pulse
}}
  ClkCycles := (Duration * us * 2 - 1250) #> cntMin        ' duration * clk cycles for 2us
                                                           ' - inst. time, min cntMin
  dira[pin]~~                                              ' Set to output                                         
  !outa[pin]                                               ' set to opposite state
  waitcnt(clkcycles + cnt)                                 ' wait until clk gets there 
  !outa[pin]                                               ' return to orig. state
PUB PULSOUT_uS(Pin,Duration) | ClkCycles
{{
   Produces an opposite pulse on the pin for the duration in 1uS increments
   Smallest value is 10 at clkfreq = 80Mhz
   Largest value is around 50 seconds at 80Mhz.
     BS2.Pulsout_uS(500)   ' 0.5 mS pulse
}}
  ClkCycles := (Duration * us-1050) #> cntMin              ' duration * clk cycles for us
                                                           ' - inst. time, min cntMin
  dira[pin]~~                                              ' Set to output                                         
  !outa[pin]                                               ' set to opposite state                                 
  waitcnt(clkcycles + cnt)                                 ' wait until clk gets there                             
  !outa[pin]                                               ' return to orig. state                                 
   
  
PUB PULSIN (Pin, State) : Duration 
{{
  Reads duration of Pulse on pin defined for state, returns duration in 2uS resolution
  Shortest measureable pulse is around 20uS
  Note: Absence of pulse can cause cog lockup if watchdog is not used - See distributed example
    x := BS2.Pulsin(5,1)
    BS2.Debug_Dec(x)
}}

   Duration := PULSIN_Clk(Pin, State) / us / 2 + 1         ' Use PulsinClk and calc for 2uS increments
  
   
PUB PULSIN_uS (Pin, State) : Duration | ClkStart, clkStop, timeout
{{
  Reads duration of Pulse on pin defined for state, returns duration in 1uS resolution
  Note: Absence of pulse can cause cog lockup if watchdog is not used - See distributed example
    x := BS2.Pulsin_uS(5,1)
    BS2.Debug_Dec(x)
}}
 
   Duration := PULSIN_Clk(Pin, State) / us + 1             ' Use PulsinClk and calc for 1uS increments
    
PUB PULSIN_Clk(Pin, State) : Duration 
{{
  Reads duration of Pulse on pin defined for state, returns duration in 1/clkFreq increments - 12.5nS at 80MHz
  Note: Absence of pulse can cause cog lockup if watchdog is not used - See distributed example
    x := BS2.Pulsin_Clk(5,1)
    BS2.Debug_Dec(x)
}}

  DIRA[pin]~
  ctra := 0
  if state == 1
    ctra := (%11010 << 26 ) | (%001 << 23) | (0 << 9) | (PIN) ' set up counter, A level count
  else
    ctra := (%10101 << 26 ) | (%001 << 23) | (0 << 9) | (PIN) ' set up counter, !A level count
  frqa := 1
  waitpne(State << pin, |< Pin, 0)                         ' Wait for opposite state ready
  phsa:=0                                                  ' Clear count
  waitpeq(State << pin, |< Pin, 0)                         ' wait for pulse
  waitpne(State << pin, |< Pin, 0)                         ' Wait for pulse to end
  Duration := phsa                                         ' Return duration as counts
  ctra :=0                                                 ' stop counter
  
PUB PWM(Pin, Duty, Duration) | htime, ltime, Loop_Dur
{{
   Produces PWM on pin at 0-255 for duration in mS
   BS2.PWM(5,128,1000)
}}
  PWM_Set(Pin, Duty, 8)
  Pause(Duration)
  PWM_Set(Pin, 0, 8)     
      

PUB PWM_100(Pin, Duty, Duration) | htime, ltime, Loop_Dur
{{
   Produces PWM on pin at 0-100 for duration in mS
   BS2.PWM(5,128,1000)
}}
  PWM_Set(Pin, Duty * 11 <# 1023, 10)
  Pause(Duration )
  PWM_Set(Pin, 0, 8)                       
                                                                                                  
Pub PWM_Set(Pin, Duty, Resolution) | Scale
{{
   Produces constant PWM on the specified pin.
   PWM_SetB may be used to produce a second PWM on another pin.
   Resolution is the bit of resolution desired, for 0 to 2n-1
      4, duty is 0 to 15
      8,  duty is 0 to 255
      10, duty is 0 to 1024
      etc

   Repeat x from 0 to 1023
      BS2.PWM_Set(2,x,10)  ' pin 2, x value, 10-bit
      BS2.Pause(10)

   adapted from Andy Lindsay's PEK Labs 
}}

  if duty == 0                                         ' freq = 0 turns off square wave
     ctra := 0                                          ' Set CTRA/B to 0
     dira[pin]~                                         ' Make pin input
  else
     Scale := 2_147_483_647 / (1<< (Resolution-1))  ' Calculate scale
      ctra[30..26] := %00110      ' Set ctra to DUTY mode
      ctra[5..0] := pin           ' Set ctra's APIN
      frqa := duty * scale        ' Set frqa register
      dira[pin]~~                 ' set direction
       
Pub PWM_SetB(Pin, Duty, Resolution) | Scale
{{
   Produces constant PWM on the specified pin.
   PWM_Set may be used to produce a second PWM on another pin.
   Resolution is the bit of resolution desired, for 0 to 2n-1
      4, duty is 0 to 15
      8,  duty is 0 to 255
      10, duty is 0 to 1024
      etc

   Repeat x from 0 to 1023
      BS2.PWM_SetB(2,x,10)  ' pin 2, x value, 10-bit
      BS2.Pause(10)

   adapted from Andy Lindsay's PEK Labs  
}}
  if duty == 0                                         ' freq = 0 turns off square wave
     ctrb := 0                                          ' Set CTRA/B to 0
     dira[pin]~                                         ' Make pin input
  else
    Scale := 2_147_483_647 / (1<< (Resolution-1))  ' Calculate scale
    ctrb[30..26] := %00110      ' Set ctra to DUTY mode
    ctrb[5..0] := pin           ' Set ctra's APIN
    frqb := duty * scale        ' Set frqa register
    dira[pin]~~                 ' set direction
     
Pub Read(address, size)
{{
Read EEPROM in the 32K code memory space, from top of memory down
address 0 = top of memory and work down from there
  
Address = 0 to 32767 (Really uses memory 32767 to 0)
Size = size of EEPROM memory to use, 1 (Byte), 2 (word) or 4 (long)

  TemperatureSetting := BS2.Read(0, 2)   ' Read data as 2 bytes - Word  
}}
    address := $7fff - address
    return Read_I2C(address-size+1, size,-1)

Pub Read_HighMem(address, size)
{{
Read EEPROM in the upper 32K of EEPROM space when available.
This memory will survive a download.
  
Address = 0 to 32767
Size = size of EEPROM memory to use, 1 (Byte), 2 (word) or 4 (long)

     TemperatureSetting := BS2.Read_HighMem(0, 2)   ' Read data as 2 bytes - Word 

}}

    address := address + $8000
    return Read_I2C(address, size,1)

Pub Read_CodeMem(address, size)
{{
Reads EEPROM in the 32K code memory space.
  
Address = 0 to 32767
Size = size of EEPROM memory to use, 1 (Byte), 2 (word) or 4 (long)

   Value := BS2.Read_CodeMem(@stack,2)   ' Read a word from a defined stack area in EEPROM

   Typically, when variables are saved using write, the code will simply have that value when the
   Propeller reloads form code memory, so no addition code is required.
}}

    return Read_I2C(address, size,1)

PUB RCTIME (Pin,State):Duration | ClkStart, ClkStop
{{
   Reads RCTime on Pin starting at State, returns discharge time, returns in 1uS units
     dira[5]~~                 ' Set as output
     outa[5]:=1                ' Set high
     BS2.Pause(10)             ' Allow to charge
     x := RCTime(5,1)          ' Measure RCTime
     BS2.DEBUG_DEC(x)          ' Display
}}

   DIRA[Pin]~
   ClkStart := cnt                                         ' Save counter for start time
   waitpne(State << pin, |< Pin, 0)                        ' Wait for opposite state to end
   clkStop := cnt                                          ' Save stop time
   Duration := (clkStop - ClkStart)/uS                     ' calculate in 1us resolution


PUB SERIN_CHAR(pin, Baud, Mode, Bits) : ByteVal | x, BR
{{
  Accepts asynchronous character (byte) on defined pin, at Baud, in Mode for #bits
  Mode: 0 = Inverted - Normally low        Constant: BS2#Inv
        1 = Non-Inverted - Normally High   Constant: BS2#NInv
    x:= BS2.SERIN_Char(5,DEBUG_Baud,BS2#NInv,8)
    BS2.Debug_Char(x)
    BS2.Debug_DEC(x)
}}
    BR := 1_000_000 / Baud                                 ' Calculate bit rate
    dira[PIN]~                                             ' Set as input
    waitpeq(Mode << PIN, |< PIN, 0)                        ' Wait for idle
    waitpne(Mode << PIN, |< PIN, 0)                        ' WAit for Start bit
    pause_us(BR*100/90)                                    ' Pause to be centered in 1st bit time
    byteVal := ina[Pin]                                    ' Read LSB
    If Mode == 1
      Repeat x from 1 to Bits-1                              ' Number of bits - 1
          pause_us(BR-70)                                    ' Wait until center of next bit
          ByteVal := ByteVal | (ina[Pin] << x)               ' Read next bit, shift and store
    else
      Repeat x from 1 to Bits-1                              ' Number of bits - 1
          pause_us(BR-70)                                    ' Wait until center of next bit
          ByteVal := ByteVal | ((ina[Pin]^1)<< x)               ' Read next bit, shift and store 

PUB SERIN_DEC (Pin,Baud,Mode,Bits) : value | ByteIn, ptr, x, place
{{
  Accepts asynchronous decimal value (-1234) on defined pin, at Baud, in Mode for #bits/character
  Does not check for garbage (123A!5)
  Mode: 0 = Inverted - Normally low        Constant: BS2#Inv
        1 = Non-Inverted - Normally High   Constant: BS2#NInv
    x := SERIN_Char(5,9600,1,8)
    BS2.Debug_Char(x)
    BS2.Debug_DEC(x)
}}
    place := 1                                             ' Set place to 1's 
    ptr := 0
    value :=0                                               ' ptr to -1 to advance to 0 in loop
    dataIn[ptr] := SERIN_CHAR(Pin, Baud, Mode, Bits)        ' get 1st character
    ptr++
    repeat while DataIn[ptr-1] <> 13                        ' repeat until CR was last
       dataIn[ptr] := SERIN_CHAR(Pin, Baud, Mode, Bits)    ' Store character in string
       ptr++
    if ptr > 2 
      repeat x from (ptr-2) to 1                             ' Count down from last in to first in
        if (dataIn[x] > ("0"-1)) and (datain[x] < ("9"+1))
          value := value + ((DataIn[x]-"0") * place)         ' Get value by subtracting ASCII 0 x place
          place := place * 10                                 ' next place
    if (dataIn[0] > ("0"-1)) and (datain[0] < ("9"+1)) or (dataIn[0] == "-") or (dataIn[0] =="+")
      if dataIn[0] == "-"                                    ' Check if - sign
         value := value * -1
      elseif dataIn[0] == "+"                                ' check if + sign
         value := value 
      else
         value := value + (DataIn[0]-48) * place             ' if neither + or -, use value
       
PUB SERIN_STR (Pin,stringptr,Baud,Mode,Bits) | ptr
{{
  Accepts a character string on defnined Pin at Baud for bits/char, up through a CR (13)
  Maximum is 49 character, such as "abc, 123, you and me!" 
  Will cause cog-lockup while waiting without a cog-watchdog (see distributed example)
  NOTE: There is NO buffer overflow protection.
  
VAR
    Byte myString[50]  

    Repeat
        BS2.Serin_Str(5,@myString,9600,1,8)   ' Accept string passing pointer for variable
        BS2.Debug_Str(@myString)              ' display string at pointer
        BS2.Debug_Char(13)                    ' CR
        BS2.Debug_Char(myString[5])           ' show 6th character
}}
    ptr:=0
    dira[pin]~                                             ' Set pin to input
    bytefill(@dataIn,0,49)                                 ' Fill string memory with 0's (null)
   dataIn[ptr] := SERIN_CHAR(Pin, Baud, Mode, Bits)        ' get 1st character
   ptr++                                                   ' increment pointer
   repeat while DataIn[ptr-1] <> 13                        ' repeat until CR was last
       dataIn[ptr] := SERIN_CHAR(Pin, Baud, Mode, Bits)    ' Store character in string
       ptr++
   dataIn[ptr]:=0                                         ' set last character to null
   byteMove(stringptr,@datain,50)                         ' move into string pointer position
   
PUB SERIN_WAIT (Pin,stringptr,char,Baud,Mode,Bits) | ptr,x
{{
  Wait for the defined character, then
  accepts a character string on defnined Pin at Baud for bits/char, up through a CR (13)
  Maximum is 49 character, such as "abc, 123, you and me!" 
  Will cause cog-lockup while waiting without a cog-watchdog (see distributed example)
  NOTE: There is NO buffer overflow protection.
  
VAR
    Byte myString[50]  

    Repeat
        BS2.Serin_Wait(5,@myString,"j",9600,1,8)   ' Accept string passing pointer for variable,
                                                    wait for character j
        BS2.Debug_Str(@myString)              ' display string at pointer
        BS2.Debug_Char(13)                    ' CR
        BS2.Debug_Char(myString[5])           ' show 6th character
}} 
   dira[pin]~                                 ' Set pin to input
   ptr:=0
   bytefill(@dataIn,0,49)                     ' Fill string memory with 0's (null)     
                                 
   repeat while dataIn[0] <> char                         ' accept character until wait character
       dataIn[0] := SERIN_CHAR(Pin, Baud, Mode, Bits)    
   dataIn[0] := SERIN_CHAR(Pin, Baud, Mode, Bits)          ' get 1st character                        
   ptr++                                                   ' increment pointer                        
   repeat while DataIn[ptr-1] <> 13                        ' repeat until CR was last                
       dataIn[ptr] := SERIN_CHAR(Pin, Baud, Mode, Bits)    ' Store character in string                
       ptr++                                                                                          
   dataIn[ptr]:=0                                         ' set last character to null                
   byteMove(stringptr,@datain,50)                         ' move into string pointer position         


PUB SEROUT_CHAR(Pin, char, Baud, Mode, Bits ) | x, BR
{{
  Send asynchronous character (byte) on defined pin, at Baud, in Mode for #bits
  Mode: 0 = Inverted - Normally low        Constant: BS2#Inv
        1 = Non-Inverted - Normally High   Constant: BS2#NInv
    BS2.Serout_Char(5,"A",9600,BS2#NInv,8)
}}
        BR := 1_000_000 / (Baud)                           ' Determine Baud rate
        char := ((1 << Bits ) + char) << 2                 ' Set up string with start & stop bit
        dira[pin]~~                                        ' set as output
        if MODE == 0                                       ' If mode 0, invert
                char:= !char
        pause_us(BR * 2 )                                  ' Hold for 2 bits
        Repeat x From 1 to (Bits + 2)                      ' Send each bit based on baud rate
          char := char >> 1
          outa[Pin] := char
          pause_us(BR - 65)
        return
PUB SEROUT_DEC(Pin, Value, Baud, Mode, Bits) | i
{{
  Send asynchronous decimal value (-1234) on defined pin, at Baud, in Mode for #bits/Char
  Mode: 0 = Inverted - Normally low        Constant: BS2#Inv
        1 = Non-Inverted - Normally High   Constant: BS2#NInv
    BS2.SEROUT_dec(5,-1234,9600,1,8)   ' Tx -1234
    BS2.SEROUT_Char(5,13,9600,1,8)     ' CR to end
}}
'' Print a decimal number

  if value < 0                                             ' Send - sign if < 0               
    -value                                                                                    
    SEROUT_CHAR(Pin, "-", Baud, Mode,Bits)                                                    
                                                                                              
  i := 1_000_000_000                                                                          
                                                                                              
  repeat 10                                                ' test each 10's place             
    if value => i                                          ' send character based on ASCII 0  
      SEROUT_CHAR(Pin, value / i + "0", Baud, Mode,Bits)   ' Take modulus of i                
      value //= i                                                                             
      result~~                                                                                
    elseif result or i == 1                                                                   
      SEROUT_CHAR(Pin, "0", Baud, Mode,Bits)               ' Divide i for next place          
    i /= 10                                                                                           


PUB SEROUT_STR(Pin, stringptr, Baud, Mode, bits)
{{
  Sends a string for serout
    BS2.Serout_Str(5,string("Spin-Up World!",13),9600,1,8)
    BS2.Serout_Str(5,@myStr,9600,1,8)
      Code adapted from "FullDuplexSerial"
}}

    repeat strsize(stringptr)
      SEROUT_CHAR(Pin,byte[stringptr++],Baud, Mode, bits)  ' Send each character in string

PUB SHIFTIN (Dpin, Cpin, Mode, Bits) : Value | InBit
{{
   Shift data in, master clock, for mode use BS2#MSBPRE, #MSBPOST, #LSBPRE, #LSBPOST
   Clock rate is ~16Kbps.  Use at 80MHz only is recommended.
     X := BS2.SHIFTIN(5,6,BS2#MSBPOST,8)
}}
    dira[Dpin]~                                            ' Set data pin to input
    outa[Cpin]:=0                                          ' Set clock low 
    dira[Cpin]~~                                           ' Set clock pin to output 
                                                
    If Mode == MSBPRE                                      ' Mode - MSB, before clock
       Value:=0
       REPEAT Bits                                         ' for number of bits
          InBit:= ina[Dpin]                                ' get bit value
          Value := (Value << 1) + InBit                    ' Add to  value shifted by position
          !outa[Cpin]                                      ' cycle clock
          !outa[Cpin]
          waitcnt(1000 + cnt)                              ' time delay

    elseif Mode == MSBPOST                                 ' Mode - MSB, after clock              
       Value:=0                                                          
       REPEAT Bits                                         ' for number of bits                    
          !outa[Cpin]                                      ' cycle clock                         
          !outa[Cpin]                                         
          InBit:= ina[Dpin]                                ' get bit value                          
          Value := (Value << 1) + InBit                    ' Add to  value shifted by position                                         
          waitcnt(1000 + cnt)                              ' time delay                            
                                                                 
    elseif Mode == LSBPOST                                 ' Mode - LSB, after clock                    
       Value:=0                                                                                         
       REPEAT Bits                                         ' for number of bits                         
          !outa[Cpin]                                      ' cycle clock                          
          !outa[Cpin]                                                                             
          InBit:= ina[Dpin]                                ' get bit value                        
          Value := (InBit << (bits-1)) + (Value >> 1)      ' Add to  value shifted by position    
          waitcnt(1000 + cnt)                              ' time delay                           

    elseif Mode == LSBPRE                                  ' Mode - LSB, before clock             
       Value:=0                                                                                   
       REPEAT Bits                                         ' for number of bits                   
          InBit:= ina[Dpin]                                ' get bit value                        
          Value := (Value >> 1) + (InBit << (bits-1))      ' Add to  value shifted by position    
          !outa[Cpin]                                      ' cycle clock                          
          !outa[Cpin]                                                                             
          waitcnt(1000 + cnt)                              ' time delay

    elseif Mode == OnClock                                            
       Value:=0
       REPEAT Bits                                         ' for number of bits
                                        
          !outa[Cpin]                                      ' cycle clock
          waitcnt(500 + cnt)                               ' get bit value
          InBit:= ina[Dpin]                               ' time delay
          Value := (Value << 1) + InBit                    ' Add to  value shifted by position
          !outa[Cpin]
          waitcnt(500 + cnt)                           
     

PUB SHIFTIN_SLV (Dpin, Cpin, Mode, Bits) : Value | InBit
{{
  Shift data in, SLAVE clock (other device clocks),
  For mode use BS2#MSBPRE, #MSBPOST, #LSBPRE, #LSBPOST
  Clock rate above 16Kbps is not recommended.  Use at 80MHz only is recommended.
  Can cause cog lockup awaiting clock pulses.
    X := BS2.SHIFTIN_SLV(5,6,BS2#MSBPOST,8)
    BS2.DEBUG_DEC(x)   
}}                                                   
    dira[Dpin]~                                            ' Same as SHIFTIN, but clock       
    dira[Cpin]~                                            '  acts as input (slave)
    outa[Cpin]:=0
    If Mode == MSBPRE                                        
       Value:=0
       REPEAT Bits
          InBit:= ina[Dpin]
          Value := (Value << 1) + InBit
          waitpeq(1<< Cpin,|< Cpin, 0)                      ' wait on clock
          waitpne(1<< Cpin,|< Cpin, 0)
    elseif Mode == MSBPOST
       Value:=0
       REPEAT Bits
          waitpeq(1<< Cpin,|< Cpin, 0)
          waitpne(1<< Cpin,|< Cpin, 0)
          InBit:= ina[Dpin]
          Value := (Value << 1) + InBit
  
    elseif Mode == LSBPOST
       Value:=0
       REPEAT Bits
          waitpeq(1<< Cpin,|< Cpin, 0)
          waitpne(1<< Cpin,|< Cpin, 0)
          InBit:= ina[Dpin]
          Value := (InBit << (bits-1)) + (Value >> 1) 

    elseif Mode == LSBPRE
       Value:=0
       REPEAT Bits
          InBit:= ina[Dpin]
          Value := (Value >> 1) + (InBit << (bits-1))
          waitpeq(1<< Cpin,|< Cpin, 0)
          waitpne(1<< Cpin,|< Cpin, 0)
        dira[Dpin]~                                            ' Set data pin to input



     

PUB SHIFTOUT (Dpin, Cpin, Value, Mode, Bits)| bitNum
{{
   Shift data out, master clock, for mode use ObjName#LSBFIRST, #MSBFIRST
   Clock rate is ~16Kbps.  Use at 80MHz only is recommended.
     BS2.SHIFTOUT(5,6,"B",BS2#LSBFIRST,8)
}}
    outa[Dpin]:=0                                          ' Data pin = 0
    dira[Dpin]~~                                           ' Set data as output
    outa[Cpin]:=0
    dira[Cpin]~~

    If Mode == LSBFIRST                                    ' Send LSB first    
       REPEAT Bits
          outa[Dpin] := Value                              ' Set output
          Value := Value >> 1                              ' Shift value right
          !outa[Cpin]                                      ' cycle clock
          !outa[Cpin]
          waitcnt(1000 + cnt)                              ' delay

    elseIf Mode == MSBFIRST                                ' Send MSB first               
       REPEAT Bits                                                                
          outa[Dpin] := Value >> (bits-1)                  ' Set output           
          Value := Value << 1                              ' Shift value right    
          !outa[Cpin]                                      ' cycle clock          
          !outa[Cpin]                                                             
          waitcnt(1000 + cnt)                              ' delay                
    outa[Dpin]~                                            ' Set data to low
     
PUB SHIFTOUT_SLV (Dpin, Cpin, Value, Mode,  Bits) | bitNum
{{
  Shift data out, SLAVE clock (other device clocks).
  For mode use ObjName#LSBFIRST, #MSBFIRST
    Clock rates above 16Kbps is not recommended.  Use at 80MHz only is recommended.
}}
    outa[Dpin]:=0                                          ' Same as above, but acts as slave
    dira[Dpin]~~
    dira[Cpin]~

    If Mode == LSBFIRST                                        
       REPEAT Bits 
          outa[Dpin] := Value
          Value := Value >> 1
          waitpeq(1 << Cpin,|< Cpin, 0)                    ' wait for clock
          waitpne(1 << Cpin,|< Cpin, 0)          
 
    elseIf Mode == MSBFIRST                                        
       REPEAT Bits
          outa[Dpin] := Value >> (Bits-1)
          Value := Value << 1
          waitpeq(1<< Cpin,|< Cpin, 0)
          waitpne(1<< Cpin,|< Cpin, 0)
 
    outa[Dpin]:=0
     
Pub Write(address, value, size)
{{
Writes to EEPROM in the 32K code memory space, from top of memory down
address 0 = top of memory and work down from there
It is up to the user to ensure important code /variable/stack memory is not over written
WARNING! Writing to EEPROM continuosly in a loop will cause it to 'wear out'.
  
Address = 0 to 32767 (Really uses memory 32767 to 0)
Value = byte, word or long value
Size = size of EEPROM memory to use, 1 (Byte), 2 (word) or 4 (long)

  BS2.Write(0, TemperatureSetting,2)   ' Store data as 2 bytes 

}}
  address := $7fff - address 
  Write_I2C(address-size+1,value, size,-1)


Pub Write_HighMem(address, value, size)
{{
Writes to EEPROM in the upper 32K of EEPROM space when available.
This memory will survive a download.

WARNING! Writing to EEPROM continuosly in a loop will cause it to 'wear out'.
  
Address = 0 to 32767
Value = byte, word or long value
Size = size of EEPROM memory to use, 1 (Byte), 2 (word) or 4 (long)

     BS2.Write_HighMem(0,TemperatureSetting,2)   ' Store data as 2 bytes 

}}
    address := address + $8000
    Write_I2C(address,value, size,1)

Pub Write_CodeMem(address, value, size)
{{
Writes to EEPROM in the 32K code memory space.
It is up to the user to ensure important code /variable/stack memory is not over written
WARNING! Writing to EEPROM continuosly in a loop will cause it to 'wear out'.
  
Address = 0 to 32767
Value = byte, word or long value
Size = size of EEPROM memory to use, 1 (Byte), 2 (word) or 4 (long)

This can be used to save a value to a variable so on next relead of code from EEPROM
it can be read again.

VAR
   Word LastSetting 

Pub Update
   BS2.Write(@Setting,Setting,2)   ' Store variable passing pointer and using 2 bytes for Word
   ' when Propeller is reset, the variable LastSetting will automatically hold the value saved

This may also be used to write data to a specified stack/array area to be available on reload
VAR
   byte DataStack[10]

  Pub Update | x
    Repeat x from 0 to 9
     BS2.Write_CodeMem(@stack+x,somedata,1)   ' Store variable passing pointer and using 2 bytes for Word
     ' when Propeller is reset, the stack will automatically hold the value saved


}}
    Write_I2C(address,value, size,1)

Pri Write_I2C(address, value, size,inc) | ack, i

{
Thanks to:
Paul B. Voss
Assistant Professor
Picker Engineering Program
Smtih College  
}
    size--
      repeat i from 0 to size     
          outa[SCL]~~
          dira[SCL]~~
          dira[SDA]~
          outa[SDA]~
          dira[SDA]~~
          shiftout(SDA, SCL, %10100000, MSBFIRST, 8)
          dira[SDA]~
          ack := shiftin(SDA, SCL,OnClock,1)
          shiftout(SDA, SCL, address >> 8, MSBFIRST, 8)
          dira[SDA]~
          ack := shiftin(SDA, SCL,OnClock, 1)
          shiftout(SDA, SCL, address, MSBFIRST, 8)
          dira[SDA]~
          ack := shiftin(SDA, SCL,OnClock,1)
           
          shiftout(SDA, SCL, value >> (i*8), MSBFIRST, 8)
          dira[SDA]~
          ack := shiftin(SDA, SCL,OnClock, 1)
          outa[SDA]~
          dira[SDA]~~
          outa[SCL]~~
          dira[SDA]~
          address += inc
          waitcnt(clkfreq/200 + cnt)
           

PRI update(pin, freq, ch) | temp

{updates either the A or B counter modules.

  Parameters:
    pin  - I/O pin to transmit the square wave
    freq - The frequency in Hz
    ch   - 0 for counter module A, or 1 for counter module B
  Returns:
    The value of cnt at the start of the signal
    Adapted from Code by Andy Lindsay
}

      if freq == 0                                         ' freq = 0 turns off square wave
        waitpeq(0, |< pin, 0)                              ' Wait for low signal
        dira[pin]~ 
        if ch==0
          ctra := 0                                          ' Set CTRA/B to 0
        else
          ctrb := 0                                          ' Set CTRA/B to 0

         
      temp := pin                                          ' CTRA/B[8..0] := pin
      temp += (%00100 << 26)                               ' CTRA/B[30..26] := %00100
    if ch==0 
      ctra := temp                                         ' Copy temp to CTRA/B
      frqa := calcFrq(freq)                                ' Set FRQA/B
      phsa := 0                                            ' Clear PHSA/B (start cycle low)
    else
      ctrb := temp                                         ' Copy temp to CTRA/B
      frqb := calcFrq(freq)                                ' Set FRQA/B
      phsb := 0                                            ' Clear PHSA/B (start cycle low)
    dira[pin]~~                                          ' Make pin output
    result := cnt                                        ' Return the start time

PRI CalcFrq(freq)

  {Solve FRQA/B = frequency * (2^32) / clkfreq with binary long
  division (Thanks Chip!- signed Andy).
  
  Note: My version of this method relied on the FloatMath object.
  Not surprisingly, Chip's solution takes a fraction program space,
  memory, and time.  It's the binary long-division approach, which
  implements with the binary
  long division approach - Andy Lindsay, Parallax }  

  repeat 33                                    
    result <<= 1
    if freq => clkfreq
      freq -= clkfreq
      result++        
    freq <<= 1



Pri Read_I2C(address, size, inc) : value | ack, i, temp
{
 Thanks to:
 Paul B. Voss
 Assistant Professor
 Picker Engineering Program
 Smith College
}
      size--
      value~
    repeat i from 0 to size
      dira[SCL]~~
      outa[SCL]~~
      dira[SDA]~
      outa[SDA]~
      dira[SDA]~~
      shiftout(SDA, SCL, %10100000, MSBFIRST, 8)
      dira[SDA]~
      ack := shiftin(SDA, SCL, LSBPRE, 1)
      shiftout(SDA, SCL, address >> 8, MSBFIRST, 8)
      dira[SDA]~
      ack := shiftin(SDA, SCL, LSBPRE, 1)
      shiftout(SDA, SCL, address, MSBFIRST, 8)
      dira[SDA]~
      ack := shiftin(SDA, SCL, LSBPRE, 1)

      dira[SCL]~~
      outa[SCL]~~
      dira[SDA]~
      outa[SDA]~
      dira[SDA]~~
       
      shiftout(SDA, SCL, %10100001, MSBFIRST, 8)
      dira[SDA]~
      ack := shiftin(SDA, SCL, LSBPRE, 1)
      dira[SDA]~
      temp := shiftin(SDA, SCL, MSBPRE, 8)
      value := value + (temp << (i*8))
      ack := shiftin(SDA, SCL, LSBPRE, 1)
      outa[SDA]~
      dira[SDA]~~
      outa[SCL]~~
      dira[SDA]~
      address += inc

{{

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}      
       