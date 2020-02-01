''
'' simple program to blink an LED in BASIC
''
#ifdef __P2__
const ledpin = 56
const _clkfreq = 160_000_000
#else
const ledpin = 16
#endif

'' set the pin to output
direction(ledpin) = output

do
  output(ledpin) = 1
  pausems 500
  output(ledpin) = 0
  pausems 500
loop
