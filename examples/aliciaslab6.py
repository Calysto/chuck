#Name: Alicia Steinmetz
#File: music.py
#Purpose: To use the doTogether function to create music for three instruments.
# This is my own creation....

from chuck import *

init()

def base():
    bar = StruckBar()
    bar.connect()
    wait(4)
    while timeRemaining(16):
        bar.setFrequency(330)
        bar.strike(1.0)
        wait(1.0)
        bar.setFrequency(659)
        bar.strike(1.0)
        wait(1.0)

def bells():
    s = Shakers()
    s.connect()
    s.preset(7)
    s.setEnergy(1.0)
    while timeRemaining(20):
        s.setFrequency(494)
        s.noteOn(1.0)
        wait(.5)
        s.setFrequency(988)
        s.noteOn(1.0)
        wait(.5)


def melo():
    m = Mandolin()
    m.connect()
    wait(8)
    while timeRemaining(12):
        m.setFrequency(392)
        m.noteOn(.5)
        wait(1.0)
        m.setFrequency(494)
        m.noteOn(.5)
        wait(.5)
        m.setFrequency(370)
        m.noteOn(.5)
        wait(.25)
        m.setFrequency(330)
        m.noteOn(.5)
        wait(.5)
        m.setFrequency(330)
        m.noteOn(.5)
        wait(.5)
        m.setFrequency(330)
        m.noteOn(.5)
        wait(.25)
        

doTogether(bells, base, melo)
