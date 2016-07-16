from chuck import *
init()

#This program plays the first half of a traditional Irish tune, the Lark on the Strand.
#The Mandolin plays the melody and the StruckBar plays the rhythm, as many of the other instruments had trouble with playing repeated notes distinctly.

wait(1.0)

m = Mandolin()
m.connect()

b = StruckBar()
b.connect()

def playMandolin(freq,volume,beat):
    m.setFrequency(freq)
    m.noteOn(volume)
    wait(beat)

def playBar(freq,volume,beat):
    b.setFrequency(freq)
    b.noteOn(volume)
    wait(beat)
    

def playMelody1(volume,beat):
    playMandolin(440,volume,3.0*beat)
    playMandolin(440,volume,beat)
    playMandolin(392,volume,beat)
    playMandolin(440,volume,beat)
    playMandolin(493.88,volume,beat)
    playMandolin(392,volume,beat)
    playMandolin(329.63,volume,beat)

def playMelody2(volume,beat):
    playMandolin(392,volume,3*beat)
    playMandolin(440,volume,beat)
    playMandolin(493.88,volume,beat)
    playMandolin(440,volume,beat)
    playMandolin(392,volume,beat)
    playMandolin(493.88,volume,beat)
    playMandolin(587.33,volume,beat)
    playMandolin(659.26,volume,beat)
    playMandolin(783.99,volume,beat)
    playMandolin(587.33,volume,beat)
    playMandolin(659.26,volume,beat)
    playMandolin(587.33,volume,beat)
    playMandolin(493.88,volume,beat)

def playMelody3(volume,beat):
    playMandolin(392,volume,2*beat)
    playMandolin(293.66,volume,beat)
    playMandolin(392,volume,beat)
    playMandolin(493.88,volume,beat)
    playMandolin(440,volume,beat)
    playMandolin(392,volume,2*beat)
    playMandolin(493.88,volume,beat)
    playMandolin(587.33,volume,beat)
    playMandolin(493.88,volume,beat)
    playMandolin(392,volume,beat)
    playMandolin(493.88,volume,beat)
    playMandolin(587.33,volume,beat)
    playMandolin(493.88,volume,beat)

def playMandolinLark():
    m.setGain(1.0)
    playMelody1(.5,.25)
    playMelody2(.5,.25)
    playMelody1(.5,.25)
    playMelody3(.5,.25)
    playMandolin(440,.5,.75)

def playRhythm1(freq,volume,beat):
    playBar(freq,volume,3*beat)
    for i in range(3):
        playBar(freq,volume,beat)

def playRhythm2(freq,volume,beat):
    for i in range(2):
        playBar(freq,volume,2*beat)
        playBar(freq,volume,beat)
        
def playBase():
    volume = 8.0
    beat = .25
    playRhythm1(293.66,volume,beat)
    playRhythm2(392,volume,beat)
    playRhythm1(293.66,volume,beat)
    playRhythm2(261.63,volume,beat)
    playRhythm1(293.66,volume,beat)
    playRhythm2(392,volume,beat)
    playRhythm1(392,volume,beat)
    playRhythm2(392,volume,beat)
    b.noteOff(0.0)

def playLark():
    doTogether(playMandolinLark,playBase)

playLark()

