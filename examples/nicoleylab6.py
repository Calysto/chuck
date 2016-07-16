## Nicole Yulo ##
## Playing multiple instruments at once. ##
#### Original Creation ####

# Initializes chuck
from chuck import *
# Asks for outgoing com port
#initialize(ask("What port?"))

init()

# Play Once function
def playOnce(instrument, time, strength):
   instrument.noteOn(strength)
   wait(time)

# Defines the instruments:
def playShakers():
   sh = Shakers()
   sh.connect()
   for i in range(2):
       playOnce(sh, 2, 6)
       playOnce(sh, 1, 5)
       playOnce(sh, 1, 5)
       playOnce(sh, 2, 6)
       playOnce(sh, 1, 5)
       playOnce(sh, 1, 5)
       playOnce(sh, 1, 6)
       wait(1)

def playMandolin():
   m = Mandolin()
   m.connect()
   m.setGain(1)
   beat = 0.4
   for i in range(2):
       playOnce(m, beat, 0.5)
       playOnce(m, beat, 0.5)
       playOnce(m, beat/2, 0.5)
       wait(2)
       playOnce(m, beat/2, 0.5)
       playOnce(m, beat/4, 0.5)
       wait(1)
       playOnce(m, beat, 0.5)
       playOnce(m, beat*2, 0.5)
       wait(2)
   m.noteOn(1)

def playSitar():
    si = Sitar()
    si.connect()
    si.pluck(1)
    for i in range(4):
       playOnce(si, 1, 5)
       wait(0.2)
       playOnce(si, 0.5, 5)
       playOnce(si, 2, 5)
       wait(2)

# Main Function: (+ the doTogether function)
def main():
    wait(3)
    doTogether(playMandolin, playSitar, playShakers)
main()
    

