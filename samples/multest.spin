''
'' program to test multiply on P2
''
#ifndef __propeller2__
#error this code only works on the P2
#endif

CON
  _clkfreq = 160_000_000
  
OBJ
  ser: "spin/SmartSerial"
#ifdef USE_COG
  m: "multiply.cog.spin"
#else
  m: "multiply"
#endif

PUB main | a,b
  ser.start(63, 62, 0, 230_400)
#ifdef USE_COG
  m.__cognew
#endif
  ser.str(string("Multiply test...", 13, 10))
  try(1, 1)
  try($7fffffff, $ffffffff)
  try($12345, $ffff)

PUB try(a, b) | t, lo, hi
  (lo,hi,t) := m.swmul(a, b)
  report(string("software mul"), lo, hi, t)
  (lo,hi,t) := m.cordicmul(a, b)
  report(string("cordic"), lo, hi, t)
  (lo,hi,t) := m.hwmul(a, b)
  report(string("mul16"), lo, hi, t)
  ser.tx(13)
  ser.tx(10)
  
PUB report(msg, x, y, t)
  ser.str(msg)
  ser.str(string(" gives "))
  ser.hex(x, 8)
  ser.tx(",")
  ser.hex(y, 8)
  ser.str(string( " in "))
  ser.dec(t)
  ser.str(string(" cycles.", 13, 10))
