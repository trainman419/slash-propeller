{{
┌───────────────────────────────┬───────────────────┬────────────────────┐
│    GPS_Float_Demo.spin v1.0   │ Author: I.Kövesdi │ Rel.: 24. jan 2009 │  
├───────────────────────────────┴───────────────────┴────────────────────┤
│                    Copyright (c) 2009 CompElit Inc.                    │               
│                   See end of file for terms of use.                    │               
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │ 
│  This Parallax Serial Terminal (PST) demo application introduces the   │
│ 'GPS_Str_NMEA.spin v1.0' and the 'GPS_Float.spin v1.0' driver objects. │
│  The 'GPS_Str_NMEA' driver interfaces the Propeller to a GPS receiver. │
│ This NMEA-0183 parser captures and decodes RMC, GGA, GLL, GSV and GSA  │
│ type sentences of the GPS Talker device even at 115.2K baud rate. The  │
│ driver extracts and preprocesses all navigation and satellite data in a│
│ robust way. It counts events for timeout control, checks string buffer │
│ overrun, calculates checksum and guards general data integrity. It     │
│ stores time stamps of valid navigation data and it does not overwrite  │
│ valid data during GPS dropouts. It hands out information to higher     │
│ level objects as pointers to the appropriate strings or as long valued │   
│ counters. These strings are grouped in a data depository section of the│ 
│ DAT area. The user can access the last received NMEA data strings, as  │
│ well. Upon arrival of a not recognized NMEA sentence, the driver       │
│ provides the user the type and data strings of that sentence, too. In  │
│ this way she/he can easily enhance the parser to decode those          │
│ sentences, be any of the proprietary formats.                          │                                 
│  The 'GPS_Float' driver object bridges a SPIN program to the strings   │
│ and longs provided by the basic "GPS_Str_NMEA" driver and translates   │
│ them into descriptive status strings, long and float values and checks │
│ errors wherever appropriate. This driver contains basic algorithms for │
│ calculations in navigation. By using these procedures you can make your│
│ Propeller/GPS combination to be much more useful than just a part of   │
│ the onboard entertainment system of your car, ship or plane.           │
│  Given two locations, where one of them can be a measured position and │
│ the second one a destination, the driver calculates the distance and   │
│ the initial (actual) bearing for the shortest, so called Great-Circle  │
│ route to the second position. Alternatively, it can calculate the      │
│ constant bearing and the somewhat longer distance on that path to reach│
│ the same destination. This second type of navigation, where it is      │
│ easier to steer due to the constant bearing, is known as Rhumb-Line    │
│ navigation. Great-Circle courses where the bearing of the destination  │
│ is changing continuously during travel, are only jokes for a helmsman, │
│ but are quite appropriate for a computerized autopilot. In Rhumb-line  │
│ navigation the driver helps Dead-Reckoning by calculating the          │
│ destination from the known length and course of a leg.                 │                     
│  The driver contains procedures to check the proximity of a third      │
│ location while en-route from a first to a second point. For Great-     │
│ Circle routes it can calculate the Cross-Track distance of a given     │
│ off-track location and the Along-Track distance, which is the distance │
│ from the current position to the closest point on the path to that     │
│ third location. For Rhumb-Line navigation the driver calculates        │
│ Closest Point of Approach (CPA) related quantities, such as Time for   │
│ CPA (TCPA) and distance from object at CPA (DCPA), where the object is │
│ given by its Latitude, Longitude (and by its constant course and speed,│
│ if known) and we are cruising on a measured stable course with measured│
│ constant speed.                                                        │         
│                                                                        │  
├────────────────────────────────────────────────────────────────────────┤
│ Background and Detail:                                                 │
│   NMEA is an acronym for the "National Marine Electronics Association" │
│ that devise, control and publish a set of universal standards for      │
│ navigation instruments' communication. These standards are available in│
│ a few different versions, NMEA-0183 is the most prevalent, and any     │
│ marine and GPS instrument manufactured after about 1990 should be      │
│ compatible with NMEA-0183.                                             │
│  NMEA-2000 is a newer version of this standard that has simplified the │
│ interconnectivity requirements for instruments. While NMEA-0183 is only│
│ a single-Talker multi-Listener serial data inerterface, NMEA-2000 is a │
│ a multi-Talker, multi-Listener, no single Controller 'Open' network    │
│ system. It provides a stable high-speed communication protocol using   │
│ Controller Area Network (CAN) bus technology, especially  adapted for  │
│ the marine environment. To date very few NMEA-2000 devices, in         │
│ comparison with NMEA-0183 devices, exist. Of course over the ensuing   │
│ years, NMEA-2000 will eventually replace NMEA-0183, although existing  │
│ NMEA-0183 devices will remain installed and in-use for decades to come!│                                                 
│  Navigation and satellite information come from an NMEA-0183 GPS Talker│                                                                 
│ device in various formats usually with much useful redundancy. GPS     │
│ units usually send 3 to 6 sentences per second at 4_800 baud. Time and │
│ navigation data is contained at least in one or two of them, although  │
│ you may wait for a particular sentence sometimes for a couple of       │
│ seconds. The  currently released drivers are designed to capture and   │
│ merge all information from all recognized NMEA sentences. For example, │
│ UTC time, latitude and longitude data arrive in RMC, GGA and GLL       │
│ sentences, as well. To use only one sentence type for a given piece of │
│ data would be an unnecessary waste of already available resources, The │
│ position, speed and all other information is stored/merged at a common │
│ DAT place. This collection of data is refreshed partially, but always, │
│ from each of these sentences, meanwhile time stamps of the time of last│
│ reception is recorded with the critical and valid navigation data. By  │
│ this, the  responsiveness of the drivers is at the maximum and you can │
│ fully exploit the capabilities of your GPS.                            │     
│                                                                        │ 
├────────────────────────────────────────────────────────────────────────┤
│ Note:                                                                  │
│  These drivers have 'Lite' version, too. The 'Lite' versions are in    │
│ the 'GPS_Float_Lite_Demo' application released simultaneously with this│
│ one.                                                                   │
│  Please take care that all of the Closest Point of Approach (CPA) and  │
│ Dead-Reckoning (DR) calculations in Rhumb-Line navigation, if used     │
│ en-route, should be done only after the speed of ownship, or of        │
│ anything that carries the GPS antenna, is stabilized for a few seconds.│  
│                                                                        │ 
└────────────────────────────────────────────────────────────────────────┘  
}}


CON

_CLKMODE         = XTAL1 + PLL16x
_XINFREQ         = 5_000_000

_MAX_NMEA_SIZE   = 82      'Including '$',<CR>, <LF> (NMEA-0183 protocol)

'Units
_RAD             = 0       
_DEG             = 1
_KM              = 2
_MI              = 3
_NM              = 4
_M               = 5
_MPS             = 6
_KPH             = 7
_KNOT            = 8
_MPH             = 9 
_MIN             = 10
_HOUR            = 11  

   
VAR

LONG    nmeaC1, nmeaC2, nmeaCC      'NMEA sentence counter variables. They
                                    'are used in timeout tests.
  
  
  
OBJ

DBG            : "FullDuplexSerialPlus"
GPS            : "GPS_Float"
FS             : "FloatString"
  


PUB Init | oK1, oK2
'-------------------------------------------------------------------------
'-----------------------------------┌──────┐------------------------------
'-----------------------------------│ Init │------------------------------
'-----------------------------------└──────┘------------------------------
'-------------------------------------------------------------------------
''     Action: -Starts those drivers that will launch a COG directly or
''              implicitly
''             -Checks for a succesfull start
''             -If so : Calls demo procedures
'' Parameters: None                                 
''    Results: None                     
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerialPlus-------->DBG.Start                      
''             GPS_Float------------------->GPS.Init                         
''             Do_The_Job                                                                     
'-------------------------------------------------------------------------

WAITCNT(CLKFREQ * 6 + CNT)

'Start FullDuplexSerialPlus Driver for debug. The Driver will launch a
'COG for serial communication with Parallax Serial Terminal
oK1 := DBG.Start(31, 30, 0, 57600)

DBG.Str(STRING(16, 1, 10, 13))
DBG.Str(STRING("  GPS Float Demo v 1.0 started...", 10, 13))

WAITCNT(CLKFREQ * 2 + CNT)

'Start GPS_Float object
oK2 := GPS.Init             'Connection pins are defined in the driver

IF NOT (oK1 AND oK2)        'Some error occured
  IF oK1                    'We have at least the debug terminal
    DBG.Str(STRING(10, 13))
    DBG.Str(STRING("Some error occurred. Check System!", 10, 13))
    DBG.Stop
  IF oK2
    GPS.Stop
    
  REPEAT                    'Until Power Off or Reset
  
Do_The_Job
'-------------------------------------------------------------------------


PRI Do_The_Job
'-------------------------------------------------------------------------
'-------------------------------┌────────────┐----------------------------
'-------------------------------│ Do_The_Job │----------------------------
'-------------------------------└────────────┘----------------------------
'-------------------------------------------------------------------------
'     Action: Calls demo procedures                                   
' Parameters: None                                 
'    Results: None                     
'+Reads/Uses: None                                               
'    +Writes: None                                    
'      Calls: Receive_GPS_Data, Do_Some_Nav_Calculation  
'-------------------------------------------------------------------------

REPEAT
  Receive_GPS_Data(120)            'For about 2 minutes
  Do_Some_Nav_Calculation
'-------------------------------------------------------------------------


PRI Receive_GPS_Data(t) | kb, i, j, k, l, fv, sp, b, cc, rmc1, rmc2, rmc3
'-------------------------------------------------------------------------
'----------------------------┌──────────────────┐-------------------------
'----------------------------│ Receive_GPS_Data │-------------------------
'----------------------------└──────────────────┘-------------------------
'-------------------------------------------------------------------------
'     Action: Receives and displays GPS data                                                   
' Parameters: Number of repetitions (Approx. duration in seconds)
'    Results: None                     
'+Reads/Uses: None                                               
'    +Writes: None                                    
'      Calls: GPS_Str_NMEA----------->GPS.(most of the procedures)
'             FullDuplexSerialPlus--->DBG.Str
'                                     DBG.Dec
'             FloatString------------>FS.FloatToString   
'-------------------------------------------------------------------------

'Wait for established communication with GPS Talker
REPEAT WHILE NOT GPS.Communication
  DBG.Str(STRING(16, 1))
  DBG.Str(STRING("Communication with GPS Talker not established!",10,13))
  DBG.Str(STRING("Check hardware(OFF?), baud rate, polarity, etc..."))
  DBG.Str(STRING(10, 13))
  WAITCNT(CLKFREQ + CNT)

'Initialise sentence counters 
nmeaC1~                  
nmeaC2~
nmeaCC~

REPEAT  t                          'for approx. t seconds

  kb := DBG.Rxcheck
  IF kb > -1
    QUIT
  nmeaC2 := nmeaC1
  nmeaC1 := GPS.Long_NMEA_Counters(0)
  'The following test is configured for at least 1 sentence /sec rate
  'Some GPS Talkers can be configure to send data at even less rate
  IF nmeaC1 == nmeaC2
    nmeaCC++
    IF (nmeaCC < 6) AND (nmeaCC <> 1)  '2..5 seconds dropout
      DBG.Str(STRING(16, 1))
      DBG.Str(STRING("NMEA communication compromised!", 10, 13))
    ELSEIF (nmeaCC > 6)                'More than 5 seconds dropout
      DBG.Str(STRING(16, 1))
      DBG.Str(STRING("NMEA communication ceased!", 10, 13))
        
  ELSE
    nmeaCC~                      'NMEA Data is coming in at expected pace
    i := GPS.Long_Data_Status
    CASE i
      -1,1,2:
        DBG.Str(STRING(16, 1))
        DBG.Str(STRING("Rec.:"))
        DBG.Dec(GPS.Long_NMEA_Counters(0))
        DBG.Str(STRING(" Ver.:"))
        DBG.Dec(GPS.Long_NMEA_Counters(1))
        DBG.Str(STRING(" Fail:"))
        DBG.Dec(GPS.Long_NMEA_Counters(2))
        DBG.Str(STRING(" (Decoded RMC:"))
        rmc1 := GPS.Long_NMEA_Counters(3)
        DBG.Dec(rmc1)
        DBG.Str(STRING(" GGA:"))
        DBG.Dec(GPS.Long_NMEA_Counters(4))
        DBG.Str(STRING(" GLL:"))
        DBG.Dec(GPS.Long_NMEA_Counters(5))
        DBG.Str(STRING(" GSV:"))
        DBG.Dec(GPS.Long_NMEA_Counters(6))
        DBG.Str(STRING(" GSA:"))
        DBG.Dec(GPS.Long_NMEA_Counters(7))
        'DBG.Str(STRING(" LastCks:"))
        'DBG.Dec(GPS.Long_NMEA_Counters(8))
        'DBG.Str(STRING(" "))
        'DBG.Dec(GPS.Long_NMEA_Counters(9))        
        DBG.Str(STRING(")", 10, 13)) 
        DBG.Str(STRING("  Last decoded NMEA sentence : "))
        DBG.Str(GPS.Str_Last_Decoded_Type(0))
        sp := GPS.Str_Last_Decoded_Type(1)
        IF STRSIZE(sp)
          DBG.Str(STRING(" (Last not recognised : "))
          DBG.Str(GPS.Str_Last_Decoded_Type(1))
          DBG.Str(STRING(")"))
        DBG.Str(STRING(10, 13))  
        DBG.Str(STRING("             GPS Data Status : "))
        DBG.Str(GPS.Str_Data_Status) 
        DBG.Str(STRING(10, 13))
        DBG.Str(STRING("         GPS Navigation Mode : "))
        DBG.Str(GPS.Str_GPS_Mode) 
        DBG.Str(STRING(10, 13))
        DBG.Str(STRING("        Position Fix Quality : "))
        DBG.Str(GPS.Str_Fix_Quality) 
        DBG.Str(STRING(10, 13))
        DBG.Str(STRING("  Positioning Mode Selection : "))
        DBG.Str(GPS.Str_Pos_Mode_Selection)
        DBG.Str(STRING(10, 13))
        DBG.Str(STRING("     Actual Positioning mode : "))
        DBG.Str(GPS.Str_Actual_Pos_Mode) 
        DBG.Str(STRING(10, 13))
        
        j := GPS.Long_SatID_In_View(0)       'No. of Sats in view                              
        DBG.Str(STRING("    ID of Satellites in View : "))
        REPEAT k FROM 1 TO j
          l :=  GPS.Long_SatID_In_View(k)
          IF (l > 0) AND (l < 50)
            IF (l < 10)
              DBG.Str(STRING("   "))
            ELSE
              DBG.Str(STRING("  ")) 
            DBG.Dec(l)             
        DBG.Str(STRING(10, 13))
        DBG.Str(STRING("                   Elevation : "))
        REPEAT k FROM 1 TO j
          l :=  GPS.Long_Sat_Elevation(k)
          IF (l > 0) AND (l < 91)
            IF (l < 10)
              DBG.Str(STRING("   "))
            ELSE
              DBG.Str(STRING("  ")) 
            DBG.Dec(l)             
        DBG.Str(STRING(10, 13))
        DBG.Str(STRING("                     Azimuth : "))
        REPEAT k FROM 1 TO j
          l :=  GPS.Long_Sat_Azimuth(k)
          IF (l > 0) AND (l < 360)
            IF (l > 99)
              DBG.Str(STRING(" "))
            ELSEIF (l > 9)
              DBG.Str(STRING("  "))
            ELSE
              DBG.Str(STRING("   "))   
            DBG.Dec(l)
        DBG.Str(STRING(10, 13))                 
        DBG.Str(STRING("             Signal Strength : "))
        REPEAT k FROM 1 TO j
          l :=  GPS.Long_Sat_SNR(k)
          IF (l < 100)
            IF (l < 10)AND(l > 0)
              DBG.Str(STRING("   "))
            ELSE
              DBG.Str(STRING("  "))
            IF (l > 0)  
              DBG.Dec(l)
            ELSE
              DBG.Str(STRING("--"))          
        DBG.Str(STRING(10, 13))
        
        j := GPS.Long_SatID_In_Fix(0)   'No. of Sats in Fix
        DBG.Str(STRING("ID of Satellites Used in Fix : "))
        REPEAT k FROM 1 TO j
          l :=  GPS.Long_SatID_In_Fix(k)
          IF (l > 0) AND (l < 50)
            IF (l < 10)
              DBG.Str(STRING("   "))
            ELSE
              DBG.Str(STRING("  ")) 
            DBG.Dec(l)     
        DBG.Str(STRING(10, 13))
        
        'DOP Data of the solution Fix with these satellites
        DBG.Str(STRING("            PDOP, HDOP, VDOP :   "))
        DBG.Str(GPS.Str_DOP(0)) 
        DBG.Str(STRING("  "))
        DBG.Str(GPS.Str_DOP(1)) 
        DBG.Str(STRING("  "))
        DBG.Str(GPS.Str_DOP(2))      
        DBG.Str(STRING(10, 13))

        DBG.Str(STRING(10, 13))
        i := GPS.Long_Day
        j := GPS.Long_Month
        k := GPS.Long_Year
        IF (i<>-1) AND (j<>-1) AND (k<>-1)
          DBG.Str(STRING(" Day Month Year(AD) as LONGs : "))
          DBG.Dec(i) 
          DBG.Str(STRING("  ")) 
          DBG.Dec(j) 
          DBG.Str(STRING("  "))
          DBG.Dec(k) 
          DBG.Str(STRING(10, 13))
        i := GPS.Long_Hour
        j := GPS.Long_Minute
        k := GPS.Long_Second
        IF (i<>-1) AND (j<>-1) AND (k<>-1)    
          DBG.Str(STRING(" UTC Hour Min. Sec. as LONGs : "))
          DBG.Dec(i) 
          DBG.Str(STRING("  ")) 
          DBG.Dec(j) 
          DBG.Str(STRING("  "))
          DBG.Dec(k) 
          DBG.Str(STRING(10, 13))

        FS.SetPrecision(7)

        DBG.Str(STRING(" Latitude in degres as FLOAT : "))
        fv := GPS.Float_Latitude_Deg
        IF fv <> floatNaN
          DBG.Str(FS.FloatToString(fv))   
        ELSE
          DBG.Str(STRING("--.----"))  
        DBG.Str(STRING(10, 13))
          
        DBG.Str(STRING("Longitude in degres as FLOAT : "))
        fv := GPS.Float_Longitude_Deg
        IF fv <> floatNaN
          DBG.Str(FS.FloatToString(fv))   
        ELSE
          DBG.Str(STRING("---.----"))  
        DBG.Str(STRING(10, 13))

        FS.SetPrecision(5)

        DBG.Str(STRING("Speed Over Gnd [knots] FLOAT : "))
        fv := GPS.Float_Speed_Over_Ground
        IF fv <> floatNaN
          DBG.Str(FS.FloatToString(fv))   
        ELSE
          DBG.Str(STRING("---.--"))  
        DBG.Str(STRING(10, 13))
          
        DBG.Str(STRING("Course Over Gnd [degs] FLOAT : "))
        fv := GPS.Float_Course_Over_Ground
        IF fv <> floatNaN
          DBG.Str(FS.FloatToString(fv))   
        ELSE
          DBG.Str(STRING("---.--"))  
        DBG.Str(STRING(10, 13))
                    
        DBG.Str(STRING("Magn. Variation [degs] FLOAT : "))
        fv := GPS.Float_Mag_Var_Deg
        IF fv <> floatNaN
          DBG.Str(FS.FloatToString(fv))
        ELSE
          DBG.Str(STRING("--.-"))  
        DBG.Str(STRING(10, 13))
           
        DBG.Str(STRING("Alt. at Mean Sea Lev.  FLOAT : "))
        fv := GPS.Float_Altitude_Above_MSL
        IF fv <> floatNaN
          DBG.Str(FS.FloatToString(fv))
          DBG.Str(STRING(" "))
          DBG.Str(GPS.Str_Altitude_Unit)
        ELSE
          DBG.Str(STRING("-----.--"))  
        DBG.Str(STRING(10, 13))

        DBG.Str(STRING(" MSL relative to WGS84 FLOAT : "))
        fv := GPS.Float_Geoid_Height
        IF fv <> floatNaN
          DBG.Str(FS.FloatToString(fv))
          DBG.Str(STRING(" "))
          DBG.Str(GPS.Str_Geoid_Height_U)
        ELSE
          DBG.Str(STRING("---.-"))  
        DBG.Str(STRING(10, 13))

        CASE GPS.Long_Data_Status
          1:
            DBG.Str(STRING("W A R N I N G : Ageing Data! "))
            DBG.Str(STRING(10, 13))
          -1:
            DBG.Str(STRING("W A R N I N G : "))
            DBG.Str(STRING("No GPS Data Status received yet!")) 
            DBG.Str(STRING(10, 13))     

    'Print NMEA data in buffer   
    sp := GPS.Str_Data_Strings
    j := STRSIZE(sp) 
  
    IF j                        'Not a null string
      DBG.Str(STRING(10, 13))
      DBG.Str(STRING("  Actual NMEA Data in Buffer :"))
      DBG.Str(STRING(10, 13))
      'The buffer is ended with space filling zeroes, and it contains
      'other string terminating zeroes between the data strings. We just
      'can't print the whole buffer directly. Let us find the first
      'nonzero character from behind
      l := _MAX_NMEA_SIZE
      REPEAT _MAX_NMEA_SIZE
        b :=  BYTE[sp][--l]
        IF b
          QUIT
           
      'Print the buffer up to this character with replacing the zeroes
      'with (the original) commas 
      k~                       
      REPEAT (l + 1)
        b := BYTE[sp][k++]
        IF b                  
          DBG.Tx(b)
        ELSE
          DBG.Str(STRING(","))
                  
      DBG.Str(STRING(10, 13))
   
  WAITCNT(CLKFREQ / 2 + CLKFREQ / 4 + CNT)         'Main loop delay
  'During this time some RMC sentences should arrive
  'Check the refresh of the RMC sentences, to prevent freezing valid state
  rmc3 := rmc2
  rmc2 := rmc1
  rmc1 := GPS.Long_NMEA_Counters(3)
  IF rmc1 == rmc3                       'No RMC for 2 secs
    GPS.Reset_NMEA_Parser 
'-------------------------------------------------------------------------


PRI Do_Some_Nav_Calculation | d, b, i, j, k, l, kb
'-------------------------------------------------------------------------
'----------------------┌─────────────────────────┐------------------------
'----------------------│ Do_Some_Nav_Calculation │------------------------
'----------------------└─────────────────────────┘------------------------
'-------------------------------------------------------------------------
'     Action: Makes some navigation calculations                                                   
' Parameters: None
'    Results: None                     
'+Reads/Uses: None                                               
'    +Writes: None                                    
'      Calls: GPS_Float-------------->GPS.(nav. calc. procedures)
'             FullDuplexSerialPlus--->DBG.Str   
'             FloatString------------>FS.FloatToString          
'-------------------------------------------------------------------------

FS.SetPrecision(5)
DBG.Str(STRING(16, 1))
DBG.Str(STRING("A ship is about to depart from one position to another."))
DBG.Str(STRING(10, 13))
DBG.Str(STRING("The navigator wishes to use the great circle route from A"))
DBG.Str(STRING(10, 13))
DBG.Str(STRING("latitude 35.00N, longitude 121.00E to B, latitude 46.66N,"))
DBG.Str(STRING(10, 13))
DBG.Str(STRING("longitude 142.65E at 25 knots. What is the distance and"))
DBG.Str(STRING(10, 13))
DBG.Str(STRING("initial bearing? The ship is steered with autopilot."))
DBG.Str(STRING(10, 13))
WAITCNT(4 * CLKFREQ + CNT)
d := GPS.Float_GreatC_Dist(_DEG,35.0,121.0,46.66,142.65,_NM)
DBG.Str(STRING("        Distance to  B on Great-Circle course = "))
DBG.Str(FS.FloatToString(d))                             
DBG.Str(STRING(" nm", 10, 13))
b := GPS.Float_GreatC_Init_Brg(_DEG,35.0,121.0,46.66,142.65,_DEG)
DBG.Str(STRING("  Initial Bearing of B on Great-Circle course = "))
FS.SetPrecision(4)
DBG.Str(FS.FloatToString(b))                             
DBG.Str(STRING(" deg", 10, 13, 13))
WAITCNT(4 * CLKFREQ + CNT)

DBG.Str(STRING("The navigator is told that the autopilot is under repair."))
DBG.Str(STRING(10, 13))
DBG.Str(STRING("He chooses then a Rhumb-Line course from A to B. What"))
DBG.Str(STRING(10, 13))
DBG.Str(STRING("is the distance and constant bearing on that course?"))
DBG.Str(STRING(10, 13))
WAITCNT(4 * CLKFREQ + CNT)
d := GPS.Float_RhumbL_Dist(_DEG,35.0,121.0,46.66,142.65,_NM)
DBG.Str(STRING("           Distance to B on Rhumb-Line course = "))
DBG.Str(FS.FloatToString(d))                             
DBG.Str(STRING(" nm", 10, 13))
b := GPS. Float_RhumbL_Const_Brg(_DEG,35.0,121.0,46.66,142.65,_DEG)
DBG.Str(STRING("   Constant Bearing of B on Rhumb-line course = "))
FS.SetPrecision(4)
DBG.Str(FS.FloatToString(b))                             
DBG.Str(STRING(" deg", 10, 13, 13))
WAITCNT(4 * CLKFREQ + CNT)

DBG.Str(STRING("The distance is not too much longer but the bearing"))
DBG.Str(STRING(10, 13))
DBG.Str(STRING("at departure is quite different. There is a small"))
DBG.Str(STRING(10, 13))
DBG.Str(STRING("island about half-way between A and B. The Captain"))
DBG.Str(STRING(10, 13))
DBG.Str(STRING("wants to know the DCPA to that island on the new course."))
DBG.Str(STRING(10, 13))
DBG.Str(STRING("The island is at latitude 40.85, longitude 131.8."))
DBG.Str(STRING(10, 13))
'First calculate a close point on path to the island with Dead Reconing 
GPS.RhumbL_Dead_Recon(_DEG,35.0,121.0,_NM,600.00,_DEG,b,@i,@j,_DEG)
'Then calculate DCPA
GPS.RhumbL_CPA(_DEG,i,j,_DEG,b,_KNOT,25.0,40.85,131.8,0.0,0.0,@k,_NM,@l,_HOUR)
WAITCNT(4 * CLKFREQ + CNT)
DBG.Str(STRING("        Distance at Closest Point of Approach = "))
DBG.Str(FS.FloatToString(k))
DBG.Str(STRING(" nm (Portside)"))
DBG.Str(STRING(10, 13, 13))
WAITCNT(4 * CLKFREQ + CNT)

DBG.Str(STRING("That's too close. The Captain orders to depart on Great-Circle"))
DBG.Str(STRING(10, 13))
DBG.Str(STRING("course and to repair that autopilot very quickly. What will be the"))
DBG.Str(STRING(10, 13))
DBG.Str(STRING("Cross-Track distance of that island from the Great-Circle course?"))
DBG.Str(STRING(10, 13))

d := GPS.Float_GreatC_CrossTr_Dist(_DEG,35.0,121.0,46.66,142.65,40.85,131.8,_NM)
WAITCNT(4 * CLKFREQ + CNT)
DBG.Str(STRING("  Cross-Track distance on Great-Circle course = "))
DBG.Str(FS.FloatToString(d))
DBG.Str(STRING(" nm (Starboard)"))
DBG.Str(STRING(10, 13, 13))

REPEAT 30
  WAITCNT(CLKFREQ + CNT)
  kb := DBG.RxCheck
  IF kb > -1
    QUIT
'-------------------------------------------------------------------------                                                          


DAT

floatNaN       LONG $7FFF_FFFF                 'NaN code


{{
┌────────────────────────────────────────────────────────────────────────┐
│                        TERMS OF USE: MIT License                       │                                                            
├────────────────────────────────────────────────────────────────────────┤
│  Permission is hereby granted, free of charge, to any person obtaining │
│ a copy of this software and associated documentation files (the        │ 
│ "Software"), to deal in the Software without restriction, including    │
│ without limitation the rights to use, copy, modify, merge, publish,    │
│ distribute, sublicense, and/or sell copies of the Software, and to     │
│ permit persons to whom the Software is furnished to do so, subject to  │
│ the following conditions:                                              │
│                                                                        │
│  The above copyright notice and this permission notice shall be        │
│ included in all copies or substantial portions of the Software.        │  
│                                                                        │
│  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND        │
│ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     │
│ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. │
│ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   │
│ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   │
│ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      │
│ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 │
└────────────────────────────────────────────────────────────────────────┘
}}                      