# Notes

## 1. Introduction

The Firewalker LED light project was inspired by Becky Stern. It uses a small microcontroller called the Gemma M0(add sound?) and a string of multi-colored lights called the *NeoPixel*

At the Chatham Marconi Museum, we decided to use her ideas and parts list to make a set of lights that can be placed on a bike helmet or sewn to the front or back of a coat. 

## 2. Hardware  
### 2.1 Supplies list
  
These instructions were written **FOR:**
1. ONE - Adafruit **GEMMA M0 board**: [https://www.adafruit.com/product/3501](https://www.adafruit.com/product/3501),  
2. TWO to FOUR meters of Adafruit **NeoPixel LED Strip**: [https://www.adafruit.com/product/1138](https://www.adafruit.com/product/1138),  
3. ONE - **Vibration Switch** (FAST): [https://www.adafruit.com/product/1766](https://www.adafruit.com/product/1766),  
4. ONE - 3 x **AAA Battery Holder with On/Off Switch**: [https://www.adafruit.com/product/727](https://www.adafruit.com/product/727),  
5. X - Feet of **Silicone Cover Wire** (26AWG): [https://www.adafruit.com/product/1970](https://www.adafruit.com/product/1970),  
6. ONE - **USB cable** (USB A to Micro-B - 3 foot long): [https://www.adafruit.com/product/592](https://www.adafruit.com/product/592),  
7. One tube of [Silicon Glue](https://www.amazon.com/gp/product/B00ID8EDKY?tag=chtrbr429186-20&th=1),  
8. 3 x [AAA batteries](https://www.amazon.com/AAA-Batteries/b?node=389578011), 
9. Three pronged power connectors, and data cable connectors,  

### 2.2 For Sewing, you need:
1. Needle set: [https://www.adafruit.com/product/615](https://www.adafruit.com/product/615)  
2. [Sewing Thread](https://www.joann.com/p/top-stitch-heavy-duty-thread-33-yards-/2279701.html?gQT=1)  


**NOTE:** For this project, we recommend buying **these three parts** from [AdaFruit.com](https://www.adafruit.com).  

---

  - Go to: https://cdn-learn.adafruit.com/downloads/pdf/adafruit-gemma-m0.pdf
  
- Download the **Adafruit Gemma M0** manual.
- Gemma Overview: https://learn.adafruit.com/adafruit-gemma-m0
- https://cdn-learn.adafruit.com/downloads/pdf/adafruit-gemma-m0.pdf
- 
- Create directions for assembling the Firewalker kit.

## 3. Software  
  - Create directions for installing:
    1. [Thonny](https://thonny.org/) for beginners
      1. See Video, https://www.youtube.com/watch?v=bdvYIumllx8
    3. [PyCharm](https://www.jetbrains.com/pycharm/download/)

## 4. Directions for upgrading the Circuit Python located on the Gemma M0 board. 

  - https://www.youtube.com/@BuildWithProfG/featured
  - www.youtube.com/@BuildWithProfG

## 5. Circuit Python code for Firewalker
  - Latest stable release for the Gemma M0: [https://circuitpython.org/board/gemma_m0/](https://circuitpython.org/board/gemma_m0/)

## 6. Introduction to Circuit Python
  - Commands contained in Firewalker code.
  - [https://circuitpython.org/](https://circuitpython.org/)

  - Import 

## 7. (?) Introduction to Arduino Coding(?)

## 8. Using Linux with a USB thumb drive.


================================


### Circuit Python code for Firewalker
```
# SPDX-FileCopyrightText: 2018 Phillip Burgess for Adafruit Industries
# SPDX-License-Identifier: MIT

# Gemma "Firewalker Lite" sneakers
# Uses the following Adafruit parts (X2 for two shoes):
#    * Gemma M0 3V microcontroller (#3501)
#    * 150 mAh LiPoly battery (#1317) or larger
#    * Medium vibration sensor switch (#2384)
#    * 60/m NeoPixel RGB LED strip (#1138 or #1461)
#    * LiPoly charger such as #1304
#
# Originally written by Phil Burgess for Gemma using Arduino
#    * https://learn.adafruit.com/gemma-led-sneakers

import board
import digitalio
import neopixel

try:
    import urandom as random
except ImportError:
    import random

# Declare a NeoPixel object on led_pin with num_leds as pixels
# No auto-write.

## Start with the Variables
## You need to tell your Gemma board how many LEDs you have and MORE!
led_pin = board.D1  # Which pin your pixels are connected to
num_leds = 40  # How many LEDs you have
circumference = 40  # Shoe circumference, in pixels, may be > NUM_LEDS
frames_per_second = 50  # Animation frames per second
brightness = 0  # Current wave height
strip = neopixel.NeoPixel(led_pin, num_leds, brightness=1, auto_write=False)
offset = 0

# vibration sensor
motion_pin = board.D0  # Pin where vibration switch is connected
pin = digitalio.DigitalInOut(motion_pin)
pin.direction = digitalio.Direction.INPUT
pin.pull = digitalio.Pull.UP
ramping_up = False

center = 0  # Center point of wave in fixed-point space (0 - 255)
speed = 1  # Distance to move between frames (-128 - +127)
width = 2  # Width from peak to bottom of triangle wave (0 - 128)
hue = 3  # Current wave hue (color); see comments later
hue_target = 4  # Final hue we're aiming for
red = 5  # LED RGB color calculated from hue
green = 6  # LED RGB color calculated from hue
blue = 7  # LED RGB color calculated from hue

y = 0
brightness = 0
count = 0

# Gemma can animate 3 of these on 40 LEDs at 50 FPS
# More LEDs and/or more waves will need lower
wave = [0] * 8, [0] * 8, [0] * 8

# Note that the speeds of each wave are different prime numbers.
# This avoids repetition as the waves move around the
# perimeter...if they were even numbers or multiples of each
# other, there'd be obvious repetition in the motion pattern...
# beat frequencies.
n_waves = len(wave)

# 90 distinct hues (0-89) around a color wheel
hue_table = [255, 255, 255, 255, 255, 255, 255, 255, 237, 203,
             169, 135, 101, 67, 33, 0, 0, 0, 0, 0, 0, 0, 0, 0,
             0, 0, 0, 0, 0, 0, 18, 52, 86, 120, 154, 188, 222,
             255, 255, 255, 255, 255, 255, 255, 255]

# Gamma-correction table
gammas = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2,
    2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5,
    5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10,
    10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 16, 16,
    17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 24, 24, 25,
    25, 26, 27, 27, 28, 29, 29, 30, 31, 32, 32, 33, 34, 35, 35, 36,
    37, 38, 39, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 50,
    51, 52, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 66, 67, 68,
    69, 70, 72, 73, 74, 75, 77, 78, 79, 81, 82, 83, 85, 86, 87, 89,
    90, 92, 93, 95, 96, 98, 99, 101, 102, 104, 105, 107, 109, 110,
    112, 114, 115, 117, 119, 120, 122, 124, 126, 127, 129, 131, 133,
    135, 137, 138, 140, 142, 144, 146, 148, 150, 152, 154, 156, 158,
    160, 162, 164, 167, 169, 171, 173, 175, 177, 180, 182, 184, 186,
    189, 191, 193, 196, 198, 200, 203, 205, 208, 210, 213, 215, 218,
    220, 223, 225, 228, 231, 233, 236, 239, 241, 244, 247, 249, 252,
    255
]


def h2rgb(colour_hue):
    colour_hue %= 90
    h = hue_table[colour_hue >> 1]

    if colour_hue & 1:
        ret = h & 15
    else:
        ret = (h >> 4)

    return ret * 17


# pylint: disable=global-statement
def wave_setup():
    global wave

    wave = [[0, 3, 60, 0, 0, 0, 0, 0],
            [0, -5, 45, 0, 0, 0, 0, 0],
            [0, 7, 30, 0, 0, 0, 0, 0]]

    # assign random starting colors to waves
    for wave_index in range(n_waves):
        current_wave = wave[wave_index]
        random_offset = random.randint(0, 90)

        current_wave[hue] = current_wave[hue_target] = 90 + random_offset
        current_wave[red] = h2rgb(current_wave[hue] - 30)
        current_wave[green] = h2rgb(current_wave[hue])
        current_wave[blue] = h2rgb(current_wave[hue] + 30)


def vibration_detector():
    while True:
        if not pin.value:
            return True


while True:

    # wait for the vibration sensor to trigger
    if not ramping_up:
        ramping_up = vibration_detector()
        wave_setup()

    # But it's not just a straight shot that it ramps up.
    # This is a low-pass filter...it makes the brightness
    # value decelerate as it approaches a target (200 in
    # this case).  207 is used here because integers round
    # down on division, and we'd never reach the target;
    # it's an ersatz ceil() function: ((199*7)+200+7)/8 = 200;
    brightness = int(((brightness * 7) + 207) / 8)
    count += 1

    if count == (circumference + num_leds + 5):
        ramping_up = False
        count = 0

    # Wave positions and colors are updated...
    for w in range(n_waves):
        # Move wave; wraps around ends, is OK!
        wave[w][center] += wave[w][speed]

        # Hue not currently changing?
        if wave[w][hue] == wave[w][hue_target]:

            # There's a tiny random chance of picking a new hue...
            if not random.randint(frames_per_second * 4, 255):
                # Within 1/3 color wheel
                wave[w][hue_target] = random.randint(
                    wave[w][hue] - 30, wave[w][hue] + 30)

        # This wave's hue is currently shifting...
        else:

            if wave[w][hue] < wave[w][hue_target]:
                wave[w][hue] += 1  # Move up or
            else:
                wave[w][hue] -= 1  # down as needed

            # Reached destination?
            if wave[w][hue] == wave[w][hue_target]:
                wave[w][hue] = 90 + wave[w][hue] % 90  # Clamp to 90-180 range
                wave[w][hue_target] = wave[w][hue]  # Copy to target

            wave[w][red] = h2rgb(wave[w][hue] - 30)
            wave[w][green] = h2rgb(wave[w][hue])
            wave[w][blue] = h2rgb(wave[w][hue] + 30)

        # Now render the LED strip using the current
        # brightness & wave states.
        # Each LED in strip is visited just once...
        for i in range(num_leds):

            # Transform 'i' (LED number in pixel space) to the
            # equivalent point in 8-bit fixed-point space (0-255)
            # "* 256" because that would be
            # the start of the (N+1)th pixel
            # "+ 127" to get pixel center.
            x = (i * 256 + 127) / circumference

            # LED assumed off, but wave colors will add up here
            r = g = b = 0

            # For each item in wave[] array...
            for w_index in range(n_waves):
                # Calculate the distance from the pixel center to the wave
                # center point, using both signed and unsigned
                # 8-bit integers...
                d1 = int(abs(x - wave[w_index][center]))
                d2 = int(abs(x - wave[w_index][center]))

                # Then take the lesser of the two, resulting in
                # a distance (0-128)
                # that 'wraps around' the ends of the strip as
                # necessary...it's a contiguous ring, and waves
                # can move smoothly across the gap.
                if d2 < d1:
                    d1 = d2  # d1 is pixel-to-wave-center distance

                # d2 distance, relative to wave width, is then
                # proportional to the wave's brightness at this
                # pixel (basic linear y=mx+b stuff).
                # Is distance within the wave's influence?
                # d2 is the opposite; distance to wave's end
                if d1 < wave[w_index][width]:
                    d2 = wave[w_index][width] - d1
                    y = int(brightness * d2 / wave[w_index][width])  # 0 to 200

                    # y is a brightness scale value --
                    # proportional to, but not exactly equal to,
                    # the resulting RGB value.
                    if y < 128:  # Fade black to RGB color
                        # In HSV colorspace, this would be
                        # tweaking 'value'
                        n = int(y * 2 + 1)  # 1-256
                        r += (wave[w_index][red] * n) >> 8  # More fixed-point math
                        # Wave color is scaled by 'n'
                        g += (wave[w_index][green] * n) >> 8
                        b += (wave[w_index][blue] * n) >> 8  # >>8 is equiv to /256
                    else:  # Fade RGB color to white
                        # In HSV colorspace, this tweaks 'saturation'
                        n = int((y - 128) * 2)  # 0-255 affects white level
                        m = 256 * n
                        n = 256 - n  # 1-256 affects RGB level
                        r += (m + wave[w_index][red] * n) >> 8
                        g += (m + wave[w_index][green] * n) >> 8
                        b += (m + wave[w_index][blue] * n) >> 8

            # r,g,b are 16-bit types that accumulate brightness
            # from all waves that affect this pixel; may exceed
            # 255.  Now clip to 0-255 range:
            if r > 255:
                r = 255
            if g > 255:
                g = 255
            if b > 255:
                b = 255

            # Store the resulting RGB values then we're done with this pixel!
            strip[i] = (r, g, b)

        # Once rendering is complete, a second pass is made
        # through pixel data applying gamma correction, for
        # more perceptually linear colors.
        # https://learn.adafruit.com/led-tricks-gamma-correction
        for j in range(num_leds):
            (red_gamma, green_gamma, blue_gamma) = strip[j]
            red_gamma = gammas[red_gamma]
            green_gamma = gammas[green_gamma]
            blue_gamma = gammas[blue_gamma]
            strip[j] = (red_gamma, green_gamma, blue_gamma)

        strip.show()
```

### Arduino Code for Firewalker
```
// 'Firewalker' LED sneakers sketch for Adafruit NeoPixels by Phillip Burgess

#include <Adafruit_NeoPixel.h>

// Gamma correction table for LED brightness
const uint8_t gamma[] PROGMEM = { 
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,
    1,  1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,
    2,  3,  3,  3,  3,  3,  3,  3,  4,  4,  4,  4,  4,  5,  5,  5,
    5,  6,  6,  6,  6,  7,  7,  7,  7,  8,  8,  8,  9,  9,  9, 10,
   10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 16, 16,
   17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 24, 24, 25,
   25, 26, 27, 27, 28, 29, 29, 30, 31, 32, 32, 33, 34, 35, 35, 36,
   37, 38, 39, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 50,
   51, 52, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 66, 67, 68,
   69, 70, 72, 73, 74, 75, 77, 78, 79, 81, 82, 83, 85, 86, 87, 89,
   90, 92, 93, 95, 96, 98, 99,101,102,104,105,107,109,110,112,114,
  115,117,119,120,122,124,126,127,129,131,133,135,137,138,140,142,
  144,146,148,150,152,154,156,158,160,162,164,167,169,171,173,175,
  177,180,182,184,186,189,191,193,196,198,200,203,205,208,210,213,
  215,218,220,223,225,228,231,233,236,239,241,244,247,249,252,255 };

// LEDs go around the full perimeter of the shoe sole, but the step animation
// is mirrored on both the inside and outside faces, while the strip doesn't
// necessarily start and end at the heel or toe.  These constants help configure
// the strip and shoe sizes, and the positions of the front- and rear-most LEDs.
// Becky's shoes: 39 LEDs total, 20 LEDs long, LED #5 at back.
// Phil's shoes: 43 LEDs total, 22 LEDs long, LED #6 at back.
#define N_LEDS        39 // TOTAL number of LEDs in strip
#define SHOE_LEN_LEDS 20 // Number of LEDs down ONE SIDE of shoe
#define SHOE_LED_BACK  5 // Index of REAR-MOST LED on shoe
#define STEP_PIN      A9 // Analog input for footstep
#define LED_PIN        6 // NeoPixel strip is connected here
#define MAXSTEPS       3 // Process (up to) this many concurrent steps

Adafruit_NeoPixel strip = Adafruit_NeoPixel(N_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);

// The readings from the sensors are usually around 250-350 when not being pressed,
// then dip below 100 when the heel is standing on it (for Phil's shoes; Becky's
// don't dip quite as low because she's smaller).
#define STEP_TRIGGER    150  // Reading must be below this to trigger step
#define STEP_HYSTERESIS 200  // After trigger, must return to this level

int
  stepMag[MAXSTEPS],  // Magnitude of steps
  stepX[MAXSTEPS],    // Position of 'step wave' along the strip
  mag[SHOE_LEN_LEDS], // Brightness buffer (one side of the shoe)
  stepFiltered,       // Current filtered pressure reading
  stepCount,          // Number of 'frames' current step has lasted
  stepMin;            // Minimum reading during the current step
uint8_t
  stepNum = 0,        // Current step number in stepMag/stepX tables
  dup[SHOE_LEN_LEDS]; // Inside/outside copy indexes
boolean
  stepping  = false;  // If set, a step was triggered, waiting to release


void setup() {
  pinMode(9, INPUT_PULLUP); // Set internal pullup resistor for sensor pin
  // As previously mentioned, the step animation is mirrored on the inside and
  // outside faces of the shoe.  To avoid a bunch of math and offsets later, the
  // 'dup' array indicates where each pixel on the outside face of the shoe should
  // be copied on the inside.  (255 = don't copy, as on front- or rear-most LEDs).
  // Later, the colors for the outside face of the shoe are calculated and then get
  // copied to the appropriate positions on the inside face.
  memset(dup, 255, sizeof(dup));
  int8_t a, b;
  for(a=1              , b=SHOE_LED_BACK-1            ; b>=0    ;) dup[a++] = b--;
  for(a=SHOE_LEN_LEDS-2, b=SHOE_LED_BACK+SHOE_LEN_LEDS; b<N_LEDS;) dup[a--] = b++;

  // Clear step magnitude and position buffers
  memset(stepMag, 0, sizeof(stepMag));
  memset(stepX  , 0, sizeof(stepX));
  strip.begin();
  stepFiltered = analogRead(STEP_PIN); // Initial input
}

void loop() {
  uint8_t i, j;

  // Read analog input, with a little noise filtering
  stepFiltered = ((stepFiltered * 3) + analogRead(STEP_PIN)) >> 2;

  // The strip doesn't simply display the current pressure reading.  Instead,
  // there's an animated flourish from heel to toe.  This takes time,
  // and during quick foot-tapping, there could be multiple-step animations
  // 'in flight,' so a short list is kept.
  if(stepping) { // If a step was previously triggered...
    if(stepFiltered >= STEP_HYSTERESIS) { // Has step let up?
      stepping = false;                   // Yep! Stop monitoring.
      // Add new step to the step list (may be multiple in flight)
      stepMag[stepNum] = (STEP_HYSTERESIS - stepMin) * 6; // Step intensity
      stepX[stepNum]   = -80; // Position starts behind heel, moves forward
      if(++stepNum >= MAXSTEPS) stepNum = 0; // If many, overwrite oldest
    } else if(stepFiltered < stepMin) stepMin = stepFiltered; // Track min val
  } else if(stepFiltered < STEP_TRIGGER) { // No step yet; watch for trigger
    stepping = true;         // Got one!
    stepMin  = stepFiltered; // Note initial value
  }

  // Render a 'brightness map' for all steps in flight.  It's like
  // a grayscale image; there's no color yet, just intensities.
  int mx1, px1, px2, m;
  memset(mag, 0, sizeof(mag));    // Clear magnitude buffer
  for(i=0; i<MAXSTEPS; i++) {     // For each step...
    if(stepMag[i] <= 0) continue; // Skip if inactive
    for(j=0; j<SHOE_LEN_LEDS; j++) { // For each LED...
      // Each step has sort of a 'wave' that's part of the animation,
      // moving from heel to toe.  The wave position has sub-pixel
      // resolution (4X), up to 80 units (20 pixels) long.
      mx1 = (j << 2) - stepX[i]; // Position of LED along wave
      if((mx1 <= 0) || (mx1 >= 80)) continue; // Out of range
      if(mx1 > 64) { // Rising edge of wave; ramp up fast (4 px)
        m = ((long)stepMag[i] * (long)(80 - mx1)) >> 4;
      } else { // Falling edge of wave; fade slow (16 px)
        m = ((long)stepMag[i] * (long)mx1) >> 6;
      }
      mag[j] += m; // Add magnitude to buffered sum
    }
    stepX[i]++; // Update position of step wave
    if(stepX[i] >= (80 + (SHOE_LEN_LEDS << 2)))
      stepMag[i] = 0; // Off end; disable step wave
    else
      stepMag[i] = ((long)stepMag[i] * 127L) >> 7; // Fade
  }

  // For a little visual interest, some 'sparkle' is added.
  // The cumulative step magnitude is added to one pixel at random.
  long sum = 0;
  for(i=0; i<MAXSTEPS; i++) sum += stepMag[i];
  if(sum > 0) {
    i = random(SHOE_LEN_LEDS);
    mag[i] += sum / 4;
  }

  // Now the grayscale magnitude buffer is remapped to color for the LEDs.
  // The code below uses a blackbody palette, which fades from white to yellow
  // to red to black.  The goal here was specifically a "walking on fire"
  // aesthetic, so the usual ostentatious rainbow of hues seen in most LED
  // projects is purposefully skipped in favor of a more plain effect.
  uint8_t r, g, b;
  int     level;
  for(i=0; i<SHOE_LEN_LEDS; i++) { // For each LED on one side...
    level = mag[i];                // Pixel magnitude (brightness)
    if(level < 255) {              // 0-254 = black to red-1
      r = pgm_read_byte(&gamma[level]);
      g = b = 0;
    } else if(level < 510) {       // 255-509 = red to yellow-1
      r = 255;
      g = pgm_read_byte(&gamma[level - 255]);
      b = 0;
    } else if(level < 765) {       // 510-764 = yellow to white-1
      r = g = 255;
      b = pgm_read_byte(&gamma[level - 510]);
    } else {                       // 765+ = white
      r = g = b = 255;
    }
    // Set R/G/B color along outside of shoe
    strip.setPixelColor(i+SHOE_LED_BACK, r, g, b);
    // Pixels along inside are funny...
    j = dup[i];
    if(j < 255) strip.setPixelColor(j, r, g, b);
  }

  strip.show();
  delayMicroseconds(1500);
}
```
