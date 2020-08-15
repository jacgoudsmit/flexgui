'
' charlieplex driver demo
' Connect LED MATRIX accessory board to 12-pin male header marked with P32 through P39.
' Uses objects:
'	charlieplex_test.spin from   flexgui\samples\LED_Matrix 
'	SmartSerial from              flexgui\include\spin
'
CON
  _clkfreq = 180_000_000

obj
  c:   "charlieplex_text"        ' object to control LED matrix
  ser: "spin/SmartSerial"        ' standard serial object from include\spin

pub main | i

    ser.start(63, 62, 0, 230_400)   ' start serial: 230400 baud on pins 63 and 62
    ser.str(string("Charlieplex demo", 13, 10))
 
    i := c.start
    '' print which COG is running the charlieplex code
    ser.str(string("started cog "))
    ser.dec(i-1)
   
    ser.str(string(13, 10, "saying hello...")) ' send to serial
    c.str(string("Hello, world! and:"))        ' send to LED
    ser.str(string(" saying goodbye..."))      ' more for serial
    c.str(string("Goodbye?"))                  ' more for LED
    repeat                                     ' loop forever
