# avr-mandelbrot

A small, fractal-involving project created in AVR assembly

## Details

**MCU**: ATmega8 with 8 MHz internal RC clock  
**LCD**: 84x48 px screen with PCD8544 driver  
**Language**: Written purely in **AVR assembly**  
**Non-integer operations**: Calculations are performed on 16-bit fixed-point numbers, in 4.12 and 8.8 formats

## Build output

```
Used memory blocks:
   Data      :  Start = 0x0060, End = 0x0257, Length = 0x01F8
   Code      :  Start = 0x0000, End = 0x022D, Length = 0x022E

Assembly complete with no errors.
Segment usage:
   Code      :       558 words (1116 bytes)
   Data      :       504 bytes
   EEPROM    :         0 bytes
```

## Images

<img src="images/lcd.png">
