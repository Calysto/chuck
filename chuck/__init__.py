from __future__ import division, print_function

# chuck - a music creation library
#
# Copyright (c) 2016 Douglas S. Blank <dblank@cs.brynmawr.edu>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor,
# Boston, MA 02110-1301  USA

__version__ = "0.0.1"

from . import osc 
import os
import time
import random
import threading
import traceback

# ChucK unit generator documentation at
# http://chuck.cs.princeton.edu/doc/program/ugen_full.html

# initialize osc once

def init():
    # init osc
    osc.init()
    #directory, filename = os.path.split(__file__)
    #chuck_ck = os.path.abspath(
    #    os.path.join(directory, "osc", "oscrecv.ck"))
    # start chuck
    #if os.name in ['nt', 'dos', 'os2']:
    #    os.system("start chuck --port:9000 \"%s\" " % chuck_ck)
    #elif os.name in ['posix']:
    #    os.system("/home/dblank/chuck/chuck-1.3.5.2/src/chuck --port:9000 \"%s\" &" % chuck_ck)
    #else:
    #    raise AttributeError("your operating system (%s) is not currently supported" % os.name)

# base instrument class (not to be instantiated)
class Instrument:
    name = "none"

    # connect to output
    def connect(self):
        osc.sendMsg("/inst/" + self.name + "/connect", ["dac",1])

    # disconnect from output
    def disconnect(self):
        osc.sendMsg("/inst/" + self.name + "/connect", ["dac",0])
        
    # change gain [0.0-1.0]
    def setGain(self, gain):
        if gain >= 0: # and gain <= 1:
            osc.sendMsg("/inst/" + self.name + "/gain", [gain * 1.0])

    # change frequency
    def setFrequency(self, freq):
        osc.sendMsg("/inst/" + self.name + "/freq", [freq * 1.0])

    # "note on"
    def noteOn(self, velocity):
        if self.name == "sinosc" or self.name == "sndbuf":
            osc.sendMsg("/inst/" + self.name + "/gain", [velocity * 1.0])
        else:
            osc.sendMsg("/inst/" + self.name + "/noteOn", [velocity * 1.0])

    # "note off"
    def noteOff(self, velocity):
        if self.name == "sinosc" or self.name == "sndbuf":
            osc.sendMsg("/inst/" + self.name + "/gain", [0.0])
        else:
            osc.sendMsg("/inst/" + self.name + "/noteOff", [velocity * 1.0])


# derived classes for specific instruments

# Sinusoidal oscillator (SinOsc)
class SineWave(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so. 
    def __init__(self):
        self.name = "sinosc"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)


# Mandolin
class Mandolin(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so. 
    def __init__(self):
        self.name = "mandolin"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)
    
    # pluck the mandolin [0.0-1.0]
    def pluck(self, strength):
        if strength >= 0 and strength <= 1:
            osc.sendMsg("/inst/mandolin/pluck", [strength * 1.0])


# FM Voices
class FMVoices(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so. 
    def __init__(self):
        self.name = "fmvoices"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)

    # set vowel [0.0-1.0]
    def setVowel(self, vowel):
        if vowel >= 0 and vowel <= 1:
            osc.sendMsg("/inst/fmvoices/vowel", [vowel * 1.0])

    # set spectral tilt [0.0-1.0] (related to loudness?)
    def setSpectralTilt(self, spectralTilt):
        if spectralTilt >= 0 and spectralTilt <= 1:
            osc.sendMsg("/inst/fmvoices/spectralTilt", [spectralTilt * 1.0])

    # set ADSR targets [0.0-1.0]
    def setAdsrTarget(self, target):
        if target >= 0 and target <= 1:
            osc.sendMsg("/inst/fmvoices/adsrTarget", [target * 1.0])


# More singing synthesis (VoicForm)
class Voice(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so. 
    def __init__(self):
        self.name = "voicform"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)

    # select phoneme via one of these strings
    #"eee"  "ihh"  "ehh"  "aaa" 
    #"ahh"  "aww"  "ohh"  "uhh" 
    #"uuu"  "ooo"  "rrr"  "lll" 
    #"mmm"  "nnn"  "nng"  "ngg" 
    #"fff"  "sss"  "thh"  "shh" 
    #"xxx"  "hee"  "hoo"  "hah" 
    #"bbb"  "ddd"  "jjj"  "ggg" 
    #"vvv"  "zzz"  "thz"  "zhh"
    def setPhoneme(self, phoneme):
        osc.sendMsg("/inst/voicform/phoneme", [phoneme])

    # select phoneme via number [0-128]
    def setPhonemeNumber(self, number):
        if number >= 0 and number <= 128:
            osc.sendMsg("/inst/voicform/phonemeNum", [int(number)])

    # start singing [0.0-1.0]
    def sing(self, floatValue):
        if floatValue < 0 or floatValue > 1:
            print("VoicForm sing: floatValue should be between 0.0 and 1.0")
        else:
            osc.sendMsg("/inst/voicform/speak", [floatValue * 1.0])

    # stop singing [0.0-1.0]
    def quiet(self, floatValue):
        if floatValue >= 0 and floatValue <= 1:
            osc.sendMsg("/inst/voicform/quiet", [floatValue * 1.0])

    # set mix for voiced component [0.0-1.0]
    def setVoiced(self, mix):
        if mix >= 0 and mix <= 1:
            osc.sendMsg("/inst/voicform/voiced", [mix * 1.0])

    # set mix for unvoiced component [0.0-1.0]
    def setUnvoiced(self, mix):
        if mix >= 0 and mix <= 1:
            osc.sendMsg("/inst/voicform/unVoiced", [mix * 1.0])

    # set voiced/unvoiced mix [0.0-1.0]
    def setVoiceMix(self, mix):
        if mix >= 0 and mix <= 1:
            osc.sendMsg("/inst/voicform/voiceMix", [mix * 1.0])
        
    # pitch sweep [0.0-1.0]
    def setPitchSweepRate(self, rate):
        if rate >= 0 and rate <= 1:
            osc.sendMsg("/inst/voicform/pitchSweepRate", [rate * 1.0])

    # set vibrato frequency [Hz] and gain [0.0-1.0]
    def setVibrato(self, freq, gain):
        if gain >= 0 and gain <= 1:
            osc.sendMsg("/inst/voicform/vibratoFG", [freq * 1.0, gain * 1.0])

    # set loudness [0.0-1.0]
    def setLoudness(self, loudness):
        if loudness >= 0 and loudness <= 1:
            osc.sendMsg("/inst/voicform/loudness", [loudness * 1.0])


# Karplus Strong plucked string (StifKarp)
class PluckedString(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so. 
    def __init__(self):
        self.name = "stifkarp"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)

    # set pickup position [0.0-1.0]
    def setPickupPosition(self, position):
        if position >= 0 and position <= 1:
            osc.sendMsg("/inst/stifkarp/pickupPosition", [position * 1.0])

    # set string sustain [0.0-1.0]
    def setSustain(self, sustain):
        if sustain >= 0 and sustain <= 1:
            osc.sendMsg("/inst/stifkarp/sustain", [sustain * 1.0])

    # set string stretch [0.0-1.0]
    def setStretch(self, stretch):
        if stretch >= 0 and stretch <= 1:
            osc.sendMsg("/inst/stifkarp/stretch", [stretch * 1.0])

    # pluck the string [0.0-1.0]
    def pluck(self, strength):
        if strength >= 0 and strength <= 1:
            osc.sendMsg("/inst/stifkarp/pluck", [strength * 1.0])

    # set base loop gain [0.0-1.0]
    def setBaseLoopGain(self, gain):
        if gain >= 0 and gain <= 1:
            osc.sendMsg("/inst/stifkarp/baseLoopGain", [gain * 1.0])


# Sitar
class Sitar(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so.
    def __init__(self):
        self.name = "sitar"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)

    # pluck the string [0.0-1.0]
    def pluck(self, strength):
        if strength >= 0 and strength <= 1:
            osc.sendMsg("/inst/sitar/pluck", [strength * 1.0])
    

# Shakers (collisions of multiple independent sound-producing objects)
class Shakers(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so. 
    def __init__(self):
        self.name = "shakers"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)

    # select instrument by index as follows:
    #    -Maraca = 0
    #    - Cabasa = 1
    #    - Sekere = 2
    #    - Guiro = 3
    #    - Water Drops = 4
    #    - Bamboo Chimes = 5
    #    - Tambourine = 6
    #    - Sleigh Bells = 7
    #    - Sticks = 8
    #    - Crunch = 9
    #    - Wrench = 10
    #    - Sand Paper = 11
    #    - Coke Can = 12
    #    - Next Mug = 13
    #    - Penny + Mug = 14
    #    - Nickle + Mug = 15
    #    - Dime + Mug = 16
    #    - Quarter + Mug = 17
    #    - Franc + Mug = 18
    #    - Peso + Mug = 19
    #    - Big Rocks = 20
    #    - Little Rocks = 21
    #    - Tuned Bamboo Chimes = 22
    def preset(self, number):
        if number >= 0 and number <= 22:
            osc.sendMsg("/inst/shakers/preset", [int(number)])

    # set shake energy [0.0-1.0]
    def setEnergy(self, shakeEnergy):
        if shakeEnergy >= 0 and shakeEnergy <= 1:
            osc.sendMsg("/inst/shakers/energy", [shakeEnergy * 1.0])

    # set system decay [0.0-1.0]
    def setDecay(self, decay):
        if decay >= 0 and decay <= 1:
            osc.sendMsg("/inst/shakers/decay", [decay * 1.0])

    # set number of objects [0.0-128.0]
    def setObjects(self, numObjects):
        if numObjects >= 0 and numObjects <= 128:
            osc.sendMsg("/inst/shakers/objects", [numObjects * 1.0])


# Saxophone / wind instruments (Saxofony)
class Saxophone(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so. 
    def __init__(self):
        self.name = "saxofony"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)

    # set reed stiffness [0.0-1.0]
    def setStiffness(self, stiffness):
        if stiffness >= 0 and stiffness <= 1:
            osc.sendMsg("/inst/saxofony/stiffness", [stiffness * 1.0])

    # set reed aperture [0.0-1.0]
    def setAperture(self, aperture):
        if aperture >= 0 and aperture <= 1:
            osc.sendMsg("/inst/saxofony/aperture", [aperture * 1.0])

    # set pressure / volume [0.0-1.0]
    def setPressure(self, pressure):
        if pressure >= 0 and pressure <= 1:
            osc.sendMsg("/inst/saxofony/pressure", [pressure * 1.0])

    # set vibrato frequency [Hz], vibrato gain [0.0-1.0], and
    # noise component gain [0.0-1.0]
    def setVibrato(self, vibratoFreq, vibratoGain, noiseGain):
        if vibratoGain >= 0 and vibratoGain <= 1 and noiseGain >= 0 and noiseGain <= 1:
            osc.sendMsg("/inst/saxofony/vibrato", [vibratoFreq * 1.0,
                                                   vibratoGain * 1.0,
                                                   noiseGain * 1.0])

    # set blow position / lip stiffness [0.0-1.0]
    def setBlowPosition(self, position):
        if position >= 0 and position <= 1:
            osc.sendMsg("/inst/saxofony/blowPosition", [position * 1.0])

    # start blowing [0.0-1.0]
    def startBlowing(self, strength):
        if strength >= 0 and strength <= 1:
            osc.sendMsg("/inst/saxofony/startBlowing", [strength * 1.0])

    # stop blowing [0.0-1.0]
    def stopBlowing(self, strength):
        if strength >= 0 and strength <= 1:
            osc.sendMsg("/inst/saxofony/stopBlowing", [strength * 1.0])

    # set rate of attack [seconds]
    def setAttackRate(self, seconds):
        if seconds > 0:
            osc.sendMsg("/inst/saxofony/rate", [seconds * 1.0])


# Moog synthesizer (Moog)
class MoogSynthesizer(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so. 
    def __init__(self):
        self.name = "moog"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)

    # filter Q value [0.0-1.0]
    def setFilterQ(self, floatValue):
        if floatValue >= 0 and floatValue <= 1:
            osc.sendMsg("/inst/moog/filterQ", [floatValue * 1.0])

    # set filter sweep rate [0.0-1.0]
    def setFilterSweepRate(self, rate):
        if rate >= 0 and rate <= 1:
            osc.sendMsg("/inst/moog/filterSweepRate", [rate * 1.0])

    # set vibrato frequency [Hz] and gain [0.0-1.0]
    def setVibrato(self, freq, gain):
        if gain >= 0 and gain <= 1:
            osc.sendMsg("/inst/moog/vibratoFG", [freq * 1.0, gain * 1.0])

    # set aftertouch [0.0-1.0]
    def setAfterTouch(self, afterTouch):
        if afterTouch >= 0 and afterTouch <= 1:
            osc.sendMsg("/inst/moog/afterTouch", [afterTouch * 1.0])


# Struck bar instruments (ModalBar)
class StruckBar(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so. 
    def __init__(self):
        self.name = "modalbar"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)

    # set stick hardness [0.0-1.0]
    def setStickHardness(self, hardness):
        if hardness >= 0 and hardness <= 1:
            osc.sendMsg("/inst/modalbar/stickHardness", [hardness * 1.0])

    # set strike position [0.0-1.0]
    def setStrikePosition(self, position):
        if position >= 0 and position <= 1:
            osc.sendMsg("/inst/modalbar/strikePosition", [position * 1.0])

    # set vibrato frequency [Hz] and gain [0.0-1.0]
    def setVibrato(self, freq, gain):
        if gain >= 0 and gain <= 1:
            osc.sendMsg("/inst/modalbar/vibratoFG", [freq * 1.0, gain * 1.0])

    # set direct gain [0.0-1.0]
    def setDirectGain(self, gain):
        if gain >= 0 and gain <= 1:
            osc.sendMsg("/inst/modalbar/directGain", [gain * 1.0])

    # set master gain [0.0-1.0]
    def setMasterGain(self, gain):
        if gain >= 0 and gain <= 1:
            osc.sendMsg("/inst/modalbar/masterGain", [gain * 1.0])

    # set volume [0.0-1.0]
    def setVolume(self, volume):
        if volume >= 0 and volume <= 1:
            osc.sendMsg("/inst/modalbar/volume", [volume * 1.0])

    # choose preset instrument according to following integer index:
    #     - Marimba = 0
    #     - Vibraphone = 1
    #     - Agogo = 2
    #     - Wood1 = 3
    #     - Reso = 4
    #     - Wood2 = 5
    #     - Beats = 6
    #     - Two Fixed = 7
    #     - Clump = 8
    def preset(self, instrumentNumber):
        if instrumentNumber >= 0 and instrumentNumber <= 8:
            osc.sendMsg("/inst/modalbar/preset", [int(instrumentNumber)])

    # strike bar [0.0-1.0]
    def strike(self, strength):
        if strength >= 0 and strength <= 1:
            osc.sendMsg("/inst/modalbar/strike", [strength * 1.0])

    # damp the bar [0.0-1.0]
    def damp(self, amount):
        if amount >= 0 and amount <= 1:
            osc.sendMsg("/inst/modalbar/damp", [amount * 1.0])

    # set mode info: mode [0 or 1], mode ratio [float], mode radius [0.0-1.0],
    # mode gain [0.0-1.0]
    def setMode(self, mode, ratio, radius, gain):
        if mode >= 0 and mode <= 1 and radius >= 0 and radius <= 1 and gain >= 0 and gain <= 1:
            osc.sendMsg("/inst/modalbar/mode", [int(mode), ratio * 1.0,
                                            radius * 1.0, gain * 1.0])


# Blown bottle (BlowBotl)
class BlowBottle(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so. 
    def __init__(self):
        self.name = "blowbotl"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)

    # set vibrato frequency [Hz], vibrato gain [0.0-1.0] and noise gain [0.0-1.0]
    def setVibrato(self, vibratoFreq, vibratoGain, noiseGain):
        if vibratoGain >= 0 and vibratoGain <= 1 and noiseGain >= 0 and noiseGain <= 1:
            osc.sendMsg("/inst/blowbotl/vibrato", [vibratoFreq * 1.0,
                                               vibratoGain * 1.0,
                                               noiseGain * 1.0])

    # set volume [0.0-1.0]
    def setVolume(self, volume):
        if volume >= 0 and volume <= 1:
            osc.sendMsg("/inst/blowbotl/volume", [volume * 1.0])

    # set rate of attack [seconds]
    def setAttackRate(self, seconds):
        if seconds > 0:
            osc.sendMsg("/inst/blowbotl/rate", [seconds * 1.0])

    # start blowing [0.0-1.0]
    def startBlowing(self, strength):
        if strength >= 0 and strength <= 1:
            osc.sendMsg("/inst/blowbotl/startBlowing", [strength * 1.0])

    # stop blowing [0.0-1.0]
    def stopBlowing(self, floatValue):
        if floatValue >= 0 and floatValue <= 1:
            osc.sendMsg("/inst/blowbotl/stopBlowing", [floatValue * 1.0])


# Clarinet or other blowhole models
class BlowHole(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so. 
    def __init__(self):
        self.name = "blowhole"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)

    # set reed stiffness [0.0-1.0]
    def setReedStiffness(self, stiffness):
        if stiffness >= 0 and stiffness <= 1:
            osc.sendMsg("/inst/blowhole/reed", [stiffness * 1.0])

    # set noise component gain [0.0-1.0]
    def setNoiseGain(self, gain):
        if gain >= 0 and gain <= 1:
            osc.sendMsg("/inst/blowhole/noiseGain", [gain * 1.0])

    # set tonehole size [0.0-1.0]
    def setToneHoleSize(self, size):
        if size >= 0 and size <= 1:
            osc.sendMsg("/inst/blowhole/tonehole", [size * 1.0])

    # set vent frequency [0.0-1.0]
    def setVent(self, vent):
        if vent >= 0 and vent <= 1:
            osc.sendMsg("/inst/blowhole/vent", [vent * 1.0])

    # set pressure [0.0-1.0]
    def setPressure(self, pressure):
        if pressure >= 0 and pressure <= 1:
            osc.sendMsg("/inst/blowhole/pressure", [pressure * 1.0])

    # start blowing [0.0-1.0]
    def startBlowing(self, strength):
        if strength >= 0 and strength <= 1:
            osc.sendMsg("/inst/blowhole/startBlowing", [strength * 1.0])

    # stop blowing [0.0-1.0]
    def stopBlowing(self, floatValue):
        if floatValue >= 0 and floatValue <= 1:
            osc.sendMsg("/inst/blowhole/stopBlowing", [floatValue * 1.0])

    # set rate of attack [seconds]
    def setAttackRate(self, seconds):
        if seconds > 0:
            osc.sendMsg("/inst/blowhole/rate", [seconds * 1.0])


# Bowed string model
class Bowed(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so. 
    def __init__(self):
        self.name = "bowed"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)

    # set bow pressure [0.0-1.0] and position [0.0-1.0]
    def setBow(self, pressure, position):
        if pressure >= 0 and pressure <= 1 and position >= 0 and position <= 1:
            osc.sendMsg("/inst/bowed/bow", [pressure * 1.0, position * 1.0])

    # set vibrato frequency [Hz] and gain [0.0-1.0]
    def setVibrato(self, freq, gain):
        if gain >= 0 and gain <= 1:
            osc.sendMsg("/inst/bowed/vibratoFG", [freq * 1.0, gain * 1.0])

    # set volume [0.0-1.0]
    def setVolume(self, volume):
        if volume >= 0 and volume <= 1:
            osc.sendMsg("/inst/bowed/volume", [volume * 1.0])

    # start bowing [0.0-1.0]
    def startBowing(self, floatValue):
        if floatValue >= 0 and floatValue <= 1:
            osc.sendMsg("/inst/bowed/startBowing", [floatValue * 1.0])

    # stop bowing [0.0-1.0]
    def stopBowing(self, floatValue):
        if floatValue >= 0 and floatValue <= 1:
            osc.sendMsg("/inst/bowed/stopBowing", [floatValue * 1.0])


# reading from file (SndBuf)
class FileRead(Instrument):
    # initialize name, send message to ChucK to load the functions
    # for this particular instrument, time.sleep a bit for it to do so. 
    def __init__(self):
        self.name = "sndbuf"
        osc.sendMsg("/init", [self.name])
        time.sleep(0.5)

    # read from file
    def setFile(self, filename):
        osc.sendMsg("/inst/sndbuf/read", [filename])

    # set read position
    def setReadPosition(self, position):
        if position >= 0:
            osc.sendMsg("/inst/sndbuf/position", [int(position)])

    # set playback rate
    def setPlaybackRate(self, rate):
        if rate > 0:
            osc.sendMsg("/inst/sndbuf/rate", [rate * 1.0])

    # set looping
    def setLooping(self, doLoop):
        if doLoop >= 0:
            osc.sendMsg("/inst/sndbuf/loop", [int(doLoop)])

    # set looping repetition rate
    def setLoopRate(self, loopsPerSecond):
        if loopsPerSecond > 0:
            osc.sendMsg("/inst/sndbuf/loopRate", [loopsPerSecond * 1.0])
            
# The end, for now

def timer(seconds=0):
    """ A function to be used with 'for' """
    start = time.time()
    while True:
        timepast = time.time() - start
        if seconds != 0 and timepast > seconds:
            raise StopIteration()
        yield round(timepast, 3)

_timers = {}
def timeRemaining(seconds=0):
    """ Function to be used with 'while' """
    global _timers
    if seconds == 0: return True
    now = time.time()
    stack = traceback.extract_stack()
    filename, line_no, q1, q2 = stack[-2]
    if filename.startswith("<pyshell"):
        filename = "pyshell"
    if (filename, line_no) not in _timers:
        _timers[(filename, line_no)] = (now, seconds)
        return True
    start, duration = _timers[(filename, line_no)]
    if seconds != duration:
        _timers[(filename, line_no)] = (now, seconds)
        return True
    if now - start > duration:
        del _timers[(filename, line_no)]
        return False
    else:
        return True

def wait(seconds):
    """
    Wrapper for time.sleep() so that we may later overload.
    """
    return time.sleep(seconds)

def now():
    """
    Returns current time in seconds since 
    """
    return time.time()

def pickone(*args):
    """
    Randomly pick one of a list, or one between [0, arg).
    """
    if len(args) == 1:
        return random.randrange(args[0])
    else:
        return args[random.randrange(len(args))]

def pickone_range(start, stop):
    """
    Randomly pick one of a list, or one between [0, arg).
    """
    return random.randrange(start, stop)

def heads(): return flipCoin() == "heads"
def tails(): return flipCoin() == "tails"

def flipCoin():
    """
    Randomly returns "heads" or "tails".
    """
    return ("heads", "tails")[random.randrange(2)]

def randomNumber():
    """
    Returns a number between 0 (inclusive) and 1 (exclusive).
    """
    return random.random()

class BackgroundThread(threading.Thread):
    """
    A thread class for running things in the background.
    """
    def __init__(self, function, pause = 0.01):
        """
        Constructor, setting initial variables
        """
        self.function = function
        self._stopevent = threading.Event()
        self._sleepperiod = pause
        threading.Thread.__init__(self, name="MyroThread")
        
    def run(self):
        """
        overload of threading.thread.run()
        main control loop
        """
        while not self._stopevent.isSet():
            self.function()
            #self._stopevent.wait(self._sleepperiod)

    def join(self,timeout=None):
        """
        Stop the thread
        """
        self._stopevent.set()
        threading.Thread.join(self, timeout)

def loop(*functions):
    """
    Calls each of the given functions sequentially, N times.
    Example:

    >>> loop(f1, f2, 10)
    will call f1() then f2(), 10 times.
    """
    assert len(functions) > 1,"loop: takes 1 (or more) functions and an integer"
    assert type(functions[-1]) == int, "loop: last parameter must be an integer"
    count = functions[-1]
    for i in range(count):
        for function in functions[:-1]:
            print("   loop #%d: running %s()... " % (i + 1, function.__name__), 
end="")
            try:
                retval = function()
            except TypeError:
                retval = function(i + 1)
            if retval:
                print(" => %s" % retval)
            else:
                print("")
    stop()
    return "ok"

def doTogether(*functions):
    """
    Runs each of the given functions at the same time.
    Example:

    >>> doTogether(f1, f2, f3)
    will call f1() f2() and f3() together.
    """
    thread_results = [None] * len(functions)
    def makeThread(function, position):
        def newfunction():
            result = function()
            thread_results[position] = result
            return result
        import threading
        thread = threading.Thread()
        thread.run = newfunction
        return thread
    assert len(functions) >= 2, "doTogether: takes 2 (or more) functions"
    thread_list = []
    # first make the threads:
    for i in range(len(functions)):
        thread_list.append(makeThread(functions[i], i))
    # now, start them:
    for thread in thread_list:
        thread.start()
    # wait for them to finish:
    for thread in thread_list:
        thread.join()
    if thread_results == [None] * len(functions):
        print('ok')
    else:
        return thread_results


