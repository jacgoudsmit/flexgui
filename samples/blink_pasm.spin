' blink_pasm.spin
' assembly language blink program

con
  pin = 56
  freq = 160_000_000
  mode = $010007f8
  delay = freq / 10

dat
    org

    ' set up clock
    hubset #0
    hubset ##mode  ' initialize oscillator
    waitx ##20_000_000/100 ' wait for it to settle down
    hubset ##mode + %11   ' enable it

    ' now loop forever blinking the pin
    rep @done, #0
    drvnot #pin
    waitx ##delay
done
