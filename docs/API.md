## Getting started

Before you can write programs in chuck, you need to have a chuck server running.

Now import the Myro and ChucK modules:

```python
from chuck import *
```

Next, set up the communication and synthesis framework with this initialization function:

```python
init()
 ```

Now test the set-up by writing some sound-generating code in the Python shell: 

```python
s = SineWave()
s.connect()
```

The first line above creates a SineWave generator and assigns it to the variable **s**. 

The second line connects **s** to your computer's sound output device (speakers or headphones). 

NOTE: under Windows, a window may ask you for permission to connect. You only need to select ```unblock``` once.

As a result of making the connection, you hear a sine tone playing on and on. It sounds a little like the Myro beep(), except that it keeps going until you make it stop. How do you make it stop? By disconnecting it from your sound output device.

```python
s.disconnect()
```

Besides connecting and disconnecting the SineWave generator, you can also modify it in some ways. For example, try:

```python
s.connect() # connect it again first, to hear it
s.setGain(1.0)
wait(0.5)
s.setGain(0.0)
wait(0.5)
s.setGain(0.5)
```

What would you expect this to do? What does it do?

The ```setGain()``` function changes the sound's **gain**, which is closely related to its loudness. A higher gain results in a louder sound. A lower gain results in a softer sound. A 0.0 gain results in silence even though **s** has not been disconnected -- it has been muted.

Another way to modify the sound is to change its frequency... while the sound is playing!

```python
s.setFrequency(200)
wait(1.0)
s.setFrequency(400)
wait(1.0)
s.setFrequency(444.5)
```

The ```setFrequency()``` function takes a frequency in Hertz and modifies **s** to have that frequency. This leads to plenty of fun. For example, what does this code do?

```python
freq = 100.0
while timeRemaining(30):
  s.setFrequency(freq)
  wait(0.2)
  freq = freq * 1.01
```

Listen to the result of this while loop and think of ways to modify it. How can you make it change the frequency more often? By greater amounts? Write some code that randomly changes the frequency of the SineWave 10 times per second (i.e. once every 0.1 seconds).

## More instruments

Because the SineWave generates sound, we think of it as a type of instrument. But we have many other instruments too. Each of them lets you ```setFrequency()``` and ```setGain()```, but many allow further changes more suitable to the specific instrument. For example, a mandolin can be plucked, or a saxophone can be blown into. Try this:

```python
m = Mandolin()
m.connect()
 ```

This creates a virtual mandolin, assigns it to the variable **m**, and connects it to the sound output device. But unlike with the SineWave, at this point you still don't hear anything. This is because a mandolin won't make sound until you do something to it -- specifically, you can pluck it:

```python
m.pluck(0.2)
wait(1)
m.pluck(1.0)
```

The ```pluck()``` function works for mandolins or other pluckable instruments. It takes a value between 0.0 and 1.0, which represents how hard you are plucking the string. 

Because many instruments don't make sound until you do something to them, we have two more functions that work for ```all instruments```: 
* ```noteOn()```: start playing a note
* ```noteOff()```: stop playing a note
Each of these takes an argument between 0.0 and 1.0, representing the strength or velocity of the noteOn or noteOff operation. For example, try:

```python
x = Saxophone()
x.connect()
x.noteOn(0.8)
wait(1.0)
x.noteOff(0.2)
```
Try this also with other values in place of 0.8 and 0.2.

To summarize, here is a list of operations that work for any instrument: 

### Operations for all instruments

All of the following functions can be called by preceding them with the name of the instrument and a dot. For example:

```python
man = Mandolin()
man.connect()
man.disconnect()
```

* ```connect()```: connect to sound output device
* ```disconnect()```: disconnect from sound output device
* ```noteOn(**velocity**)```: start playing a note / making sound (0.0 <= **velocity** <= 1.0)
* ```noteOff(**velocity**)```: stop playing a note / making sound (0.0 <= **velocity** <= 1.0)
* ```setGain(**gain**)```: set gain to the given value (**gain** >= 0.0)
* ```setFrequency(**freq**)```: set frequency to the given value (**freq** is in Hertz)

These are enough to get you started on any of the available instruments. (Currently available: SineWave, Mandolin, FMVoices, Voice, PluckedString, Sitar, Shakers, Saxophone, MoogSynthesizer, StruckBar, BlowBottle, BlowHole, and Bowed.) 

But in case you want even more control on how the result sounds, many instruments allow more specific operations **in addition to** the six operations listed above. The additional operations for each instrument are included in the list below.

### List of instruments + more specific operations
These are the instruments currently available, and the additional operations they allow. 

Note that some parameters are best understood by trying them out with different values and listening to the result. They are fun to play with, even without having a clear theoretical idea of what they mean. So, have fun!

#### SineWave
A sinusoidal oscillator or sine-wave generator (**SinOsc** in ChucK)

* No additional operations

Example:

```python
sw = SineWave()
sw.connect()
```

#### Mandolin
A mandolin

* ```pluck(**strength**)```: pluck the mandolin (0.0 <= **strength** <= 1.0)

Example:

```python
m = Mandolin()
m.connect()
m.pluck(1)
```

#### FMVoices
A voice synthesizer

* ```setVowel(**vowel**)```: set the vowel given a numerical value (0.0 <= **vowel** <= 1.0)
* ```setSpectralTilt(**spectralTilt**)```: set spectral tilt (related to loudness) (0.0 <= **spectralTilt** <= 1.0)
* ```setAdsrTarget(**target**)```: set ADSR targets (related to how the sound changes over time) (0.0 <= **target** <= 1.0)

Example:

```python
fmv = FMVoices()
fmv.connect()
fmv.setVowel(0.5)
```
#### Voice
Another voice synthesizer (**VoicForm** in ChucK)

* ```setPhoneme(**phoneme**)```: set the phoneme to the given string value (**phoneme** in ["eee", "ihh", "ehh", "aaa", "ahh", "aww", "ohh", "uhh", "uuu", "ooo", "rrr", "lll", "mmm", "nnn", "nng", "ngg", "fff", "sss", "thh", "shh", "xxx", "hee", "hoo", "hah", "bbb", "ddd", "jjj", "ggg"])
* ```setPhonemeNumber(**number**)```: set the phoneme given a number value (0 <= **number <= 128)
* ```sing(**floatValue**)```: re-start singing (0.0 <= **floatValue** <= 1.0)
* ```quiet(**floatValue**)```: stop singing (0.0 <= **floatValue** <= 1.0)
* ```setVoiced(**mix**)```: set mix for voiced component of the sound (0.0 <= **mix** <= 1.0)
* ```setUnvoiced(**mix**)```: set mix for unvoiced component of the sound (0.0 <= **mix** <= 1.0)
* ```setVoiceMix(**mix**)```: set voiced/unvoiced mix together (0.0 <= **mix** <= 1.0)
* ```setPitchSweepRate(**rate**)```: set pitch sweep (0.0 <= **rate** <= 1.0)
* ```setVibrato(**freq**, **gain**)```: set frequency and gain of vibrato (**frequency** in Hertz, 0.0 <= **gain** <= 1.0)
* ```setLoudness(**loudness**)```: set the perceived loudness (0.0 <= **loudness** <= 1.0)

#### PluckedString
A Karplus-Strong plucked string model (**StifKarp** in ChucK)

* ```setPickupPosition(**position**)```: set pickup position (0.0 <= **position** <= 1.0)
* ```setSustain(**sustain**)```: set the string's sustain (0.0 <= **sustain** <= 1.0)
* ```setStretch(**stretch**)```: set the string's stretch (0.0 <= **stretch** <= 1.0)
* ```pluck(**strength**)```: pluck the string (0.0 <= **strength** <= 1.0)
* ```setBaseLoopGain(**gain**)```: set "base loop gain" (0.0 <= **gain** <= 1.0)

#### Sitar
A sitar

* ```pluck(**strength**)```: pluck the string (0.0 <= **strength** <= 1.0)

#### Shakers
Collisions of multiple independent sound-producing objects

* ```setEnergy(**shakeEnergy**)```: set shake energy (0.0 <= **shakeEnergy** <= 1.0)
* ```setDecay(**decay**)```: set system decay (0.0 <= **decay** <= 1.0)
* ```setObjects(**numObjects**)```: set number of objects (0 <= **numObjects** <= 128)
* ```preset(**number**)```: change the settings to a preset instrument by number (0 <= **number** <= 22). Below is a list of preset instruments and what number to use for each: 
** Maraca = 0
** Cabasa = 1
** Sekere = 2
** Guiro = 3
** Water Drops = 4
** Bamboo Chimes = 5
** Tambourine = 6
** Sleigh Bells = 7
** Sticks = 8
** Crunch = 9
** Wrench = 10
** Sand Paper = 11
** Coke Can = 12
** Next Mug = 13
** Penny + Mug = 14
** Nickle + Mug = 15
** Dime + Mug = 16
** Quarter + Mug = 17
** Franc + Mug = 18
** Peso + Mug = 19
** Big Rocks = 20
** Little Rocks = 21
** Tuned Bamboo Chimes = 22

#### Saxophone
A saxophone or similar wind instrument (**Saxofony** in ChucK)

* ```setStiffness(**stiffness**)```: set reed stiffness (0.0 <= **stiffness** <= 1.0)
* ```setAperture(**aperture**)```: set reed aperture (0.0 <= **aperture** <= 1.0)
* ```setPressure(**pressure**)```: set pressure / volume (0.0 <= **pressure** <= 1.0)
* ```setVibrato(**vibratoFreq**, **vibratoGain**, **noiseGain**)```: set frequency and gain of vibrato, and gain of noise component (**vibratoFreq** in Hertz, 0.0 <= **vibratoGain** <= 1.0, 0.0 <= **noiseGain** <= 1.0)
* ```setBlowPosition(**position**)```: set blow position / lip stiffness (0.0 <= **position** <= 1.0)
* ```startBlowing(**strength**)```: start blowing (0.0 <= **strength** <= 1.0)
* ```stopBlowing(**strength**)```: stop blowing (0.0 <= **strength** <= 1.0)
* ```setAttackRate(**seconds**)```: set rate of attack (sound's beginning) in seconds

#### MoogSynthesizer
A Moog synthesizer (**Moog** in ChucK)

* ```setFilterQ(**floatValue**)```: set filter's Q value (0.0 <= **floatValue** <= 1.0)
* ```setFilterSweepRate(**rate**)```: set filter sweep rate (0.0 <= **rate** <= 1.0)
* ```setVibrato(**freq**, **gain**)```: set frequency and gain of vibrato (**freq** in Hertz, 0.0 <= **gain** <= 1.0)
* ```setAfterTouch(**afterTouch**)```: set aftertouch (0.0 <= **afterTouch** <= 1.0)

#### StruckBar
Struck bar instruments (**ModalBar** in ChucK)

* ```setStickHardness(**hardness**)```: set stick hardness (0.0 <= **hardness** <= 1.0)
* ```setStrikePosition(**position**)```: set strike position (0.0 <= **position** <= 1.0)
* ```setVibrato(**freq**, **gain**)```: set frequency and gain of vibrato (**freq** in Hertz, 0.0 <= **gain** <= 1.0)
* ```setDirectGain(**gain**)```: set direct gain (0.0 <= **gain** <= 1.0)
* ```setMasterGain(**gain**)```: set master gain (0.0 <= **gain** <= 1.0)
* ```setVolume(**volume**)```: set volume (0.0 <= **volume** <= 1.0)
* ```strike(**strength**)```: strike the bar (0.0 <= **strength** <= 1.0)
* ```damp(**amount**)```: damp the bar (0.0 <= **amount** <= 1.0)
* ```setMode(**mode**, **ratio**, **radius**, **gain**)```: set mode info (**mode** is 0 or 1, **ratio** >= 0.0, 0.0 <= **radius** <= 1.0, 0.0 <= **gain** <= 1.0)
* ```preset(**instrumentNumber**)```: change the settings to a preset instrument by number (0 <= **instrumentNumber** <= 8). Below is a list of preset instruments and what number to use for each:
** Marimba = 0
** Vibraphone = 1
** Agogo = 2
** Wood1 = 3
** Reso = 4
** Wood2 = 5
** Beats = 6
** Two Fixed = 7
** Clump = 8

### BlowBottle
A blown bottle (**BlowBotl** in ChucK)

* ```setVibrato(**vibratoFreq**, **vibratoGain**, **noiseGain**)```: set vibrato frequency and gain, and noise component gain (**vibratoFreq** in Hertz, 0.0 <= **vibratoGain** <= 1.0, 0.0 <= **noiseGain** <= 1.0)
* ```setVolume(**volume**)```: set volume (0.0 <= **volume** <= 1.0)
* ```setAttackRate(**seconds**)```: set rate of attack in seconds (**seconds** >= 0.0)
* ```startBlowing(**strength**)```: start blowing (0.0 <= **strength** <= 1.0)
* ```stopBlowing(**floatValue**)```: stop blowing (0.0 <= **floatValue** <= 1.0)

### BlowHole
An instrument with a blow-hole 

* ```setReedStiffness(**stiffness**)```: set reed stiffness (0.0 <= **stiffness** <= 1.0)
* ```setNoiseGain(**gain**)```: set noise component's gain (0.0 <= **gain** <= 1.0)
* ```setToneHoleSize(**size**)```: set tonehole size (0.0 <= **size** <= 1.0)
* ```setVent(**vent**)```: set vent frequency (0.0 <= **vent** <= 1.0)
* ```setPressure(**pressure**)```: set pressure (0.0 <= **pressure** <= 1.0)
* ```startBlowing(**strength**)```: start blowing (0.0 <= **strength** <= 1.0)
* ```stopBlowing(**floatValue**)```: stop blowing (0.0 <= **floatValue** <= 1.0)
* ```setAttackRate(**seconds**)```: set rate of attack in seconds (**secodns** >= 0.0)

### Bowed
An instrument with a bowed string

* ```setBow(**pressure**, **position**)```: set bow pressure and position (0.0 <= **pressure** <= 1.0, 0.0 <= **position** <= 1.0)
* ```setVibrato(**freq**, **gain**)```: set frequency and gain of vibrato (**freq** in Hertz, 0.0 <= **gain** <= 1.0)
* ```setVolume(**volume**)```: set instrument volume (0.0 <= **volume** <= 1.0)
* ```startBowing(**floatValue**)```: start bowing (0.0 <= **floatValue** <= 1.0)
* ```stopBowing(**floatValue**)```: stop bowing (0.0 <= **floatValue** <= 1.0)

## Orchestrating

After you get familiar with a single instrument, then you might want to try putting together instruments. To make this easier, you can make individual functions, each responsible for a single instrument. 

<pre>
from myro import *
from myro.chuck import *

initChuck()

def playSaxophone():
   sax = Saxophone()
   sax.connect()
   sax.startBlowing(1)
   wait(1)
   sax.stopBlowing(1)

def playMandolin():
   mandolin = Mandolin()
   mandolin.connect()
   mandolin.pluck(1)
   wait(1)
</pre>

You can test each one of those independently by simply running it:

 playSaxophone()

Once you have more than one intrument function written, you can then play them together with the doTogether() function:

<pre>
doTogether(playSaxophone, playMandolin)
</pre>

NOTE: currently, you can only use one of each type of instrument.

## Examples

This is a space to add examples as we go along. 

###Sensors to Sound

Values from the robot and fluke sensors can be mapped to sound, for artistic or informational purposes. 

This example was very loosely inspired by the Theremin. It uses the fluke's obstacle sensors to change the sound based on how far away your hand (or a sheet of paper) is.

 # normalize obstacle sensor values to be between 0.0 and 1.0
 def normalizeObstacle(v):
    # assume the highest sensor value is around 1100.
    maxObstacle = 1100.0
    if v > maxObstacle:
        v = maxObstacle
    # normalize so that the result is between 0 and 1,
    # with nearer obstacles returning values closer to 0
    return 1.0 - v / maxObstacle
 
 # set up an instrument
 m = MoogSynthesizer()
 m.connect()
 m.noteOn(1.0)
 
 # in a loop, get new obstacle values and update the sound
 while timeRemaining(30):
    # get obstacle values
    L, C, R = getObstacle()
    # connect right value to frequency (and get a freq between 0.0 and 500.0)
    freq = normalizeObstacle(R) * 500 
    m.setFrequency(freq)
    # connect left value to another parameter (between 0.0 and 1.0)
    rate = normalizeObstacle(L) 
    m.setFilterSweepRate(rate)
 
 # turn off instrument when done
 m.noteOff(1.0)

### More Orchestrating

This example uses **doTogether** to make rhythmic sounds. It has three instruments, which start at different times and end together. 

```python
# helper function to play one sound / note
def playOnce(instrument, time, strength):
   instrument.noteOn(strength)
   wait(time)

def playShakers():
   shakers = Shakers()
   shakers.connect()
   beat = 0.4
   for i in range(7):
       playOnce(shakers, beat, 1)
       playOnce(shakers, beat/2, .8)
       playOnce(shakers, beat/2, .8)
       playOnce(shakers, beat, 1)        
   shakers.noteOn(1)

def playBar():
   bar = StruckBar()
   bar.connect()
   beat = 0.4
   wait(beat * 6) # wait for 2 measures / loop iterations
   for i in range(5):
       playOnce(bar, beat/2, .8)        
       playOnce(bar, beat/2, .8)
       playOnce(bar, beat, 1)
       playOnce(bar, beat, 1)
   bar.noteOn(1)

def playMandolin():
   m = Mandolin()
   m.connect()
   m.setGain(0.3)
   beat = 0.4
   wait(beat * 12) # wait for 4 measures / loop iterations
   for i in range(3):
       playOnce(m, beat, 1)
       playOnce(m, beat, 1)
       playOnce(m, beat/2, .8)
       playOnce(m, beat/2, .8)
   m.noteOn(1)

doTogether(playShakers, playBar, playMandolin)
```
