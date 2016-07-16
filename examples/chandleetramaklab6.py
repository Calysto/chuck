#Rama Kirloskar and Chandlee Taylor
#Assignment 6
#Functions to play four instruments
#uses doTogether function to play all four instruments simultaneously.

from chuck import *

init()

def playOnce(instrument, time, strength):
   instrument.noteOn(strength)
   wait(time)

def playShakers():
   shakers = Shakers()
   shakers.connect()
   beat = 0.4
   for i in range(7):
       playOnce(shakers, beat, 1)
       playOnce(shakers, beat/2, .7)
       playOnce(shakers, beat/2, .9)
       playOnce(shakers, beat, 1)        
   shakers.noteOn(1)

def playBar():
   bar = StruckBar()
   bar.connect()
   beat = 0.4
   wait(beat * 6)
   for i in range(5):
       playOnce(bar, beat/2, .4)        
       playOnce(bar, beat/2, .8)
       playOnce(bar, beat, 1)
       playOnce(bar, beat, 1)
   bar.noteOn(1)

def playMandolin():
   m = Mandolin()
   m.connect()
   m.setGain(0.6)
   beat = 0.4
   wait(beat * 6) 
   for i in range(3):
       playOnce(m, beat, 1)
       playOnce(m, beat, 1)
       playOnce(m, beat/2, .8)
       playOnce(m, beat/2, .8)
   m.noteOn(1)


def playSaxophone():
    sax=Saxophone()
    sax.connect()
    sax.startBlowing(0.3)
    wait(1)
    sax.stopBlowing(1)
    beat = 0.4
    wait(beat * 6) 
    for i in range (4):
       playOnce(sax, beat, .3)
       playOnce(sax, beat, .3)
       playOnce(sax, beat/2, .8)
       playOnce(sax, beat/2, .8)
    sax.noteOn(0.3)
    sax.noteOff(1)
    
 


doTogether(playShakers, playBar, playMandolin, playSaxophone)


