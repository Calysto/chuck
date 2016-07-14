SinOsc sinosc;
BandedWG bandedwg;
BlowBotl blowbotl;
BlowHole blowhole;
Bowed bowed;
Brass brass;
Clarinet clarinet;
Flute flute;
BeeThree beethree;
FMVoices fmvoices;
HevyMetl hevymetl;
PercFlut percflut;
Rhodey rhodey;
TubeBell tubebell;
Wurley wurley;
Mandolin mandolin;
ModalBar modalbar;
Moog moog;
Saxofony saxofony;
Shakers shakers;
Sitar sitar;
StifKarp stifkarp;
VoicForm voicform;
SndBuf sndbuf;

OscRecv orec;
9000 => orec.port;
orec.listen();
1 => int verbose;
1::hour => dur playtime;

// listener class looking for a particular message
// and passing it on to the handler
class OscListener {
    fun void listen(string msg, OscHandler @ om) {
        if(verbose) <<< "OscListener     ", msg >>>;
        orec.event(msg) @=> OscEvent oe;
        while(true) {
            oe => now;
            while (oe.nextMsg() != 0) {
                om.handle(oe);
            }
        }
    }

    fun void listenStk(string msg, OscHandler @ om, StkInstrument @ stk) {
        if(verbose) <<< "OscListener Stk ", msg, stk >>>;
        orec.event(msg) @=> OscEvent oe;
        while(true) {
            oe => now;
            while (oe.nextMsg() != 0) {
                om.handleStk(oe, stk);
            }
        }
    }

    fun void listenUGen(string msg, OscHandler @ om, UGen @ ugen) {
        if(verbose) <<< "OscListener UGen", msg, ugen >>>;
        orec.event(msg) @=> OscEvent oe;
        while(true) {
            oe => now;
            while (oe.nextMsg() != 0) {
                om.handleUGen(oe, ugen);
            }
        }
    }
}
OscListener ol;

// OSC Handler base class
class OscHandler {
    fun void handle(OscEvent oe) {
        return; 
    }

    fun void handleStk(OscEvent oe, StkInstrument @ stk) {
        return;
    }

    fun void handleUGen(OscEvent oe, UGen @ ugen) {
        return;
    }
}


// ugen handlers
class UGenGain extends OscHandler {
    fun void handleUGen(OscEvent oe, UGen @ ugen) {
        oe.getFloat() => float temp => ugen.gain;
        if(verbose) <<< "ugen gain: ", temp >>>;
    }
}
UGenGain ugen_gain;

class UGenConnect extends OscHandler {
    fun void handleUGen(OscEvent oe, UGen @ ugen) {
        oe.getString() => string conn;
        oe.getInt() => int temp;
        if(conn == "dac") {
            if(temp == 1) ugen => dac;
            else ugen =< dac;
        }
        if(verbose) <<< "ugen connect", conn, ": ", temp >>>;
    }
}
UGenConnect ugen_connect;


// stkinstrument handles
class StkInstrumentFreq extends OscHandler {
    fun void handleStk(OscEvent oe, StkInstrument @ stk) {
        oe.getFloat() => float temp => stk.freq;
        if(verbose) <<< "stk freq: ", temp >>>;
    }
}
StkInstrumentFreq stk_freq;

class StkInstrumentNoteOn extends OscHandler {
    fun void handleStk(OscEvent oe, StkInstrument @ stk) {
        oe.getFloat() => float temp => stk.noteOn;
        if(verbose) <<< "stk noteOn: ", temp >>>;
    }
}
StkInstrumentNoteOn stk_noteOn;

class StkInstrumentNoteOff extends OscHandler {
    fun void handleStk(OscEvent oe, StkInstrument @ stk) {
        oe.getFloat() => float temp => stk.noteOff;
        if(verbose) <<< "stk noteOff: ", temp >>>;
    }
}
StkInstrumentNoteOff stk_noteOff;


// sinosc handlers
class SinOscFreq extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => sinosc.freq;
        if(verbose) <<< "sinosc freq:", temp >>>;
}
}
SinOscFreq sinosc_freq;

fun void sinosc_control_shred() {
    spork ~ ol.listenUGen("/inst/sinosc/gain,f", ugen_gain, sinosc);
    spork ~ ol.listenUGen("/inst/sinosc/connect,s,i", ugen_connect, sinosc);
    spork ~ ol.listen("/inst/sinosc/freq,f", sinosc_freq);
    while(true)
        playtime => now;
}


// sndbuf handlers
class SndBufFreq extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => sndbuf.freq;
        if(verbose) <<< "sndbuf loop rate:", temp >>>;
    }
}
SndBufFreq sndbuf_freq;

class SndBufLoop extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getInt() => int temp => sndbuf.loop;
        if(verbose) <<< "sndbuf loop:", temp >>>;
    }
}
SndBufLoop sndbuf_loop;

class SndBufChunks extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getInt() => int temp => sndbuf.chunks;
        if(verbose) <<< "sndbuf chunks:", temp >>>;
    }
}
SndBufChunks sndbuf_chunks;

class SndBufRead extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getString() => string temp => sndbuf.read;
        if(verbose) <<< "sndbuf read:", temp >>>;
    }
}
SndBufRead sndbuf_read;

class SndBufPos extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getInt() => int temp => sndbuf.pos;
        if(verbose) <<< "sndbuf position:", temp >>>;
    }
}
SndBufPos sndbuf_pos;

class SndBufRate extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => sndbuf.rate;
        if(verbose) <<< "sndbuf rate:", temp >>>;
    }
}
SndBufRate sndbuf_rate;

fun void sndbuf_control_shred() {
    spork ~ ol.listenUGen("/inst/sndbuf/gain,f", ugen_gain, sndbuf);
    spork ~ ol.listenUGen("/inst/sndbuf/connect,s,i", ugen_connect, sndbuf);
    spork ~ ol.listen("/inst/sndbuf/read,s", sndbuf_read);
    spork ~ ol.listen("/inst/sndbuf/chunks,i", sndbuf_chunks);
    spork ~ ol.listen("/inst/sndbuf/position,i", sndbuf_pos);
    spork ~ ol.listen("/inst/sndbuf/rate,f", sndbuf_rate);
    spork ~ ol.listen("/inst/sndbuf/loop,i", sndbuf_loop);
    spork ~ ol.listen("/inst/sndbuf/loopRate,f", sndbuf_freq);
    while(true)
        playtime => now;
}


// mandolin handlers
class MandolinPluck extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => mandolin.pluck;
        if(verbose) <<< "mandolin pluck:", temp >>>;
    }
}
MandolinPluck mandolin_pluck;

fun void mandolin_control_shred() {
    spork ~ ol.listenUGen("/inst/mandolin/gain,f", ugen_gain, mandolin);
    spork ~ ol.listenUGen("/inst/mandolin/connect,s,i", ugen_connect, mandolin);
    spork ~ ol.listenStk("/inst/mandolin/freq,f", stk_freq, mandolin);
    spork ~ ol.listenStk("/inst/mandolin/noteOn,f", stk_noteOn, mandolin);
    spork ~ ol.listenStk("/inst/mandolin/noteOff,f", stk_noteOn, mandolin);
    spork ~ ol.listen("/inst/mandolin/pluck,f", mandolin_pluck);
    while(true) 
        playtime => now;
}


// fmvoices controls
class FMVoicesVowel extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => fmvoices.vowel;
        if(verbose) <<< "fmvoices vowel:", temp >>>;
    }
}
FMVoicesVowel fmvoices_vowel;

class FMVoicesSpectralTilt extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => fmvoices.spectralTilt;
        if(verbose) <<< "fmvoices spectralTilt:", temp >>>;
    }
}
FMVoicesSpectralTilt fmvoices_spectralTilt;

class FMVoicesAdsrTarget extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => fmvoices.adsrTarget;
        if(verbose) <<< "fmvoices adsrTarget:", temp >>>;
    }
}
FMVoicesAdsrTarget fmvoices_adsrTarget;

fun void fmvoices_control_shred() {
    spork ~ ol.listenUGen("/inst/fmvoices/gain,f", ugen_gain, fmvoices);
    spork ~ ol.listenUGen("/inst/fmvoices/connect,s,i", ugen_connect, fmvoices);
    spork ~ ol.listenStk("/inst/fmvoices/freq,f", stk_freq, fmvoices);
    spork ~ ol.listenStk("/inst/fmvoices/noteOn,f", stk_noteOn, fmvoices);
    spork ~ ol.listenStk("/inst/fmvoices/noteOff,f", stk_noteOff, fmvoices);
    spork ~ ol.listen("/inst/fmvoices/vowel,f", fmvoices_vowel);
    spork ~ ol.listen("/inst/fmvoices/spectralTilt,f", fmvoices_spectralTilt);
    spork ~ ol.listen("/inst/fmvoices/adsrTarget,f", fmvoices_adsrTarget);
    while(true)
        playtime => now;
}


// voicform controls
class VoicFormPhoneme extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getString() => string temp => voicform.phoneme;
        if(verbose) <<< "voicform phoneme:", temp >>>;
    }
}
VoicFormPhoneme voicform_phoneme;

class VoicFormPhonemeNum extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getInt() => int temp => voicform.phonemeNum;
        if(verbose) <<< "voicform phonemeNum:", temp >>>;
    }
}
VoicFormPhonemeNum voicform_phonemeNum;

class VoicFormSpeak extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => voicform.speak;
        if(verbose) <<< "voicform speak:", temp >>>;
    }
}
VoicFormSpeak voicform_speak;

class VoicFormQuiet extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => voicform.quiet;
        if(verbose) <<< "voicform quiet:", temp >>>;
    }
}
VoicFormQuiet voicform_quiet;

class VoicFormVoiced extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => voicform.voiced;
        if(verbose) <<< "voicform voiced:", temp >>>;
    }
}
VoicFormVoiced voicform_voiced;

class VoicFormUnVoiced extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => voicform.unVoiced;
        if(verbose) <<< "voicform unVoiced:", temp >>>;
    }
}
VoicFormUnVoiced voicform_unVoiced;

class VoicFormPitchSweepRate extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => voicform.pitchSweepRate;
        if(verbose) <<< "voicform pitchSweepRate:", temp >>>;
    }
}
VoicFormPitchSweepRate voicform_pitchSweepRate;

class VoicFormVoiceMix extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => voicform.voiceMix;
        if(verbose) <<< "voicform voiceMix:", temp >>>;
    }
}
VoicFormVoiceMix voicform_voiceMix;

class VoicFormVibratoFG extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float vFreq;
        oe.getFloat() => float vGain;
        if(vFreq >= 0)
            vFreq => voicform.vibratoFreq;
        if(vGain >= 0)
            vGain => voicform.vibratoGain;
        if(verbose) <<< "voicform vibratoFG:", vFreq, vGain >>>;
    }
}
VoicFormVibratoFG voicform_vibratoFG;

class VoicFormLoudness extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => voicform.loudness;
        if(verbose) <<< "voicform loudness:", temp >>>;
    }
}
VoicFormLoudness voicform_loudness;

fun void voicform_control_shred() {
    spork ~ ol.listenUGen("/inst/voicform/gain,f", ugen_gain, voicform);
    spork ~ ol.listenUGen("/inst/voicform/connect,s,i", ugen_connect, voicform);
    spork ~ ol.listenStk("/inst/voicform/freq,f", stk_freq, voicform);
    spork ~ ol.listenStk("/inst/voicform/noteOn,f", stk_noteOn, voicform);
    spork ~ ol.listenStk("/inst/voicform/noteOff,f", stk_noteOff, voicform);
    spork ~ ol.listen("/inst/voicform/phoneme,s", voicform_phoneme);
    spork ~ ol.listen("/inst/voicform/phonemeNum,i", voicform_phonemeNum);
    spork ~ ol.listen("/inst/voicform/speak,f", voicform_speak);
    spork ~ ol.listen("/inst/voicform/quiet,f", voicform_quiet);
    spork ~ ol.listen("/inst/voicform/voiced,f", voicform_voiced);
    spork ~ ol.listen("/inst/voicform/unVoiced,f", voicform_unVoiced);
    spork ~ ol.listen("/inst/voicform/pitchSweepRate,f", voicform_pitchSweepRate);
    spork ~ ol.listen("/inst/voicform/voiceMix,f", voicform_voiceMix);
    spork ~ ol.listen("/inst/voicform/vibratoFG,f,f", voicform_vibratoFG);
    spork ~ ol.listen("/inst/voicform/loudness,f", voicform_loudness);
    while(true)
        playtime => now;
}


// sitar controls
class SitarPluck extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => sitar.pluck;
        if(verbose) <<< "sitar pluck:", temp >>>;
    }
}
SitarPluck sitar_pluck;

fun void sitar_control_shred() {
    spork ~ ol.listenUGen("/inst/sitar/gain,f", ugen_gain, sitar);
    spork ~ ol.listenUGen("/inst/sitar/connect,s,i", ugen_connect, sitar);
    spork ~ ol.listenStk("/inst/sitar/freq,f", stk_freq, sitar);
    spork ~ ol.listenStk("/inst/sitar/noteOn,f", stk_noteOn, sitar);
    spork ~ ol.listenStk("/inst/sitar/noteOff,f", stk_noteOff, sitar);
    spork ~ ol.listen("/inst/sitar/pluck,f", sitar_pluck);
    while(true)
        playtime => now;
}


// stifkarp controls
class StifKarpPickupPosition extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => stifkarp.pickupPosition;
        if(verbose) <<< "stifkarp pickupPosition:", temp >>>;
    }
}
StifKarpPickupPosition stifkarp_pickupPosition;

class StifKarpSustain extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => stifkarp.sustain;
        if(verbose) <<< "stifkarp sustain:", temp >>>;
    }
}
StifKarpSustain stifkarp_sustain;

class StifKarpStretch extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => stifkarp.stretch;
        if(verbose) <<< "stifkarp stretch:", temp >>>;
    }
}
StifKarpStretch stifkarp_stretch;

class StifKarpPluck extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => stifkarp.pluck;
        if(verbose) <<< "stifkarp pluck:", temp >>>;
    }
}
StifKarpPluck stifkarp_pluck;

class StifKarpBaseLoopGain extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => stifkarp.baseLoopGain;
        if(verbose) <<< "stifkarp baseLoopGain:", temp >>>;
    }
}
StifKarpBaseLoopGain stifkarp_baseLoopGain;

fun void stifkarp_control_shred() {
    spork ~ ol.listenUGen("/inst/stifkarp/gain,f", ugen_gain, stifkarp);
    spork ~ ol.listenUGen("/inst/stifkarp/connect,s,i", ugen_connect, stifkarp);
    spork ~ ol.listenStk("/inst/stifkarp/freq,f", stk_freq, stifkarp);
    spork ~ ol.listenStk("/inst/stifkarp/noteOn,f", stk_noteOn, stifkarp);
    spork ~ ol.listenStk("/inst/stifkarp/noteOff,f", stk_noteOff, stifkarp);
    spork ~ ol.listen("/inst/stifkarp/pickupPosition,f", stifkarp_pickupPosition);
    spork ~ ol.listen("/inst/stifkarp/sustain,f", stifkarp_sustain);
    spork ~ ol.listen("/inst/stifkarp/stretch,f", stifkarp_stretch);
    spork ~ ol.listen("/inst/stifkarp/pluck,f", stifkarp_pluck);
    spork ~ ol.listen("/inst/stifkarp/baseLoopGain,f", stifkarp_baseLoopGain);
    while(true)
        playtime => now;
}


// shakers controls class 
class ShakersPreset extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getInt() => int temp => shakers.preset;
        if(verbose) <<< "shakers preset:", temp >>>;
    }
}
ShakersPreset shakers_preset;

class ShakersEnergy extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => shakers.energy;
        if(verbose) <<< "shakers energy:", temp >>>;
    }
}
ShakersEnergy shakers_energy;

class ShakersDecay extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => shakers.decay;
        if(verbose) <<< "shakers decay:", temp >>>;
    }
}
ShakersDecay shakers_decay;

class ShakersObjects extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => shakers.objects; // 0.0 to 128.0
        if(verbose) <<< "shakers objects:", temp >>>;
    }
}
ShakersObjects shakers_objects;

fun void shakers_control_shred() {
    spork ~ ol.listenUGen("/inst/shakers/gain,f", ugen_gain, shakers);
    spork ~ ol.listenUGen("/inst/shakers/connect,s,i", ugen_connect, shakers);
    spork ~ ol.listenStk("/inst/shakers/freq,f", stk_freq, shakers);
    spork ~ ol.listenStk("/inst/shakers/noteOn,f", stk_noteOn, shakers);
    spork ~ ol.listenStk("/inst/shakers/noteOff,f", stk_noteOff, shakers);
    spork ~ ol.listen("/inst/shakers/preset,i", shakers_preset);
    spork ~ ol.listen("/inst/shakers/energy,f", shakers_energy);
    spork ~ ol.listen("/inst/shakers/decay,f", shakers_decay);
    spork ~ ol.listen("/inst/shakers/objects,f", shakers_objects);
    while(true) 
        playtime => now;
}


// saxofony controls
class SaxofonyStiffness extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => saxofony.stiffness;
        if(verbose) <<< "saxofony stiffness:", temp >>>;
    }
}
SaxofonyStiffness saxofony_stiffness;

class SaxofonyAperture extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => saxofony.aperture;
        if(verbose) <<< "saxofony aperture:", temp >>>;
    }
}
SaxofonyAperture saxofony_aperture;

class SaxofonyPressure extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => saxofony.pressure;
        if(verbose) <<< "saxofony pressure:", temp >>>;
    }
}
SaxofonyPressure saxofony_pressure;

class SaxofonyVibrato extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float vFreq;
        oe.getFloat() => float vGain;
        oe.getFloat() => float nGain;
        if(vFreq >= 0)
            vFreq => saxofony.vibratoFreq;
        if(vGain >= 0)
            vGain => saxofony.vibratoGain;
        if(nGain >= 0)
            nGain => saxofony.noiseGain;
        if(verbose) <<< "saxofony vibrato:", vFreq, vGain, nGain >>>;
    }
}
SaxofonyVibrato saxofony_vibrato;

class SaxofonyBlowPosition extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => saxofony.blowPosition;
        if(verbose) <<< "saxofony blowPosition:", temp >>>;
    }
}
SaxofonyBlowPosition saxofony_blowPosition;

class SaxofonyStartBlowing extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => saxofony.startBlowing;
        if(verbose) <<< "saxofony startBlowing:", temp >>>;
    }
}
SaxofonyStartBlowing saxofony_startBlowing;

class SaxofonyStopBlowing extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => saxofony.stopBlowing;
        if(verbose) <<< "saxofony stopBlowing:", temp >>>;
    }
}
SaxofonyStopBlowing saxofony_stopBlowing;

class SaxofonyRate extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => saxofony.rate;
        if(verbose) <<< "saxofony rate:", temp >>>;
    }
}
SaxofonyRate saxofony_rate;

fun void saxofony_control_shred() {
    spork ~ ol.listenUGen("/inst/saxofony/gain,f", ugen_gain, saxofony);
    spork ~ ol.listenUGen("/inst/saxofony/connect,s,i", ugen_connect, saxofony);
    spork ~ ol.listenStk("/inst/saxofony/freq,f", stk_freq, saxofony);
    spork ~ ol.listenStk("/inst/saxofony/noteOn,f", stk_noteOn, saxofony);
    spork ~ ol.listenStk("/inst/saxofony/noteOff,f", stk_noteOff, saxofony);
    spork ~ ol.listen("/inst/saxofony/stiffness,f", saxofony_stiffness);
    spork ~ ol.listen("/inst/saxofony/aperture,f", saxofony_aperture);
    spork ~ ol.listen("/inst/saxofony/pressure,f", saxofony_pressure);
    spork ~ ol.listen("/inst/saxofony/vibrato,f,f,f", saxofony_vibrato);
    spork ~ ol.listen("/inst/saxofony/blowPosition,f", saxofony_blowPosition);
    spork ~ ol.listen("/inst/saxofony/startBlowing,f", saxofony_startBlowing);
    spork ~ ol.listen("/inst/saxofony/stopBlowing,f", saxofony_stopBlowing);
    spork ~ ol.listen("/inst/saxofony/rate,f", saxofony_rate);
    while(true)
        playtime => now;
}


// moog controls 
class MoogFilterQ extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => moog.filterQ;
        if(verbose) <<< "moog filterQ:", temp >>>;
    }
}
MoogFilterQ moog_filterQ;

class MoogFilterSweepRate extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => moog.filterSweepRate;
        if(verbose) <<< "moog filterSweepRate:", temp >>>;
    }
}
MoogFilterSweepRate moog_filterSweepRate;

class MoogVibratoFG extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float freq;
        oe.getFloat() => float gain;
        if(freq >= 0)
            freq => moog.vibratoFreq;
        if(gain >= 0)
            gain => moog.vibratoGain;
        if(verbose) <<< "moog vibratoFG:", freq, gain >>>;
    }
}
MoogVibratoFG moog_vibratoFG;

class MoogAfterTouch extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => moog.afterTouch;
        if(verbose) <<< "moog afterTouch:", temp >>>;
    }
}
MoogAfterTouch moog_afterTouch;

fun void moog_control_shred() {
    spork ~ ol.listenUGen("/inst/moog/gain,f", ugen_gain, moog);
    spork ~ ol.listenUGen("/inst/moog/connect,s,i", ugen_connect, moog);
    spork ~ ol.listenStk("/inst/moog/freq,f", stk_freq, moog);
    spork ~ ol.listenStk("/inst/moog/noteOn,f", stk_noteOn, moog);
    spork ~ ol.listenStk("/inst/moog/noteOff,f", stk_noteOff, moog);
    spork ~ ol.listen("/inst/moog/filterQ,f", moog_filterQ);
    spork ~ ol.listen("/inst/moog/filterSweepRate,f", moog_filterSweepRate);
    spork ~ ol.listen("/inst/moog/vibratoFG,f,f", moog_vibratoFG);
    spork ~ ol.listen("/inst/moog/afterTouch,f", moog_afterTouch);
    while(true) 
        playtime => now;
}


// modalbar controls
class ModalBarStickHardness extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => modalbar.stickHardness;
        if(verbose) <<< "modalbar stickHardness:", temp >>>;
    }
}
ModalBarStickHardness modalbar_stickHardness;

class ModalBarStrikePosition extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => modalbar.strikePosition;
        if(verbose) <<< "modalbar strikePosition:", temp >>>;
    }
}
ModalBarStrikePosition modalbar_strikePosition;

class ModalBarVibratoFG extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float freq;
        oe.getFloat() => float gain;
        if(freq >= 0)
            freq => modalbar.vibratoFreq;
        if(gain >= 0)
            gain => modalbar.vibratoGain;
        if(verbose) <<< "modalbar vibratoFG:", freq, gain >>>;
    }
}
ModalBarVibratoFG modalbar_vibratoFG;

class ModalBarMasterGain extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => modalbar.masterGain;
        if(verbose) <<< "modalbar masterGain:", temp >>>;
    }
}
ModalBarMasterGain modalbar_masterGain;

class ModalBarDirectGain extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => modalbar.directGain;
        if(verbose) <<< "modalbar directGain:", temp >>>;
    }
}
ModalBarDirectGain modalbar_directGain;

class ModalBarVolume extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => modalbar.volume;
        if(verbose) <<< "modalbar volume:", temp >>>;
    }
}
ModalBarVolume modalbar_volume;

class ModalBarPreset extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getInt() => int temp => modalbar.preset;
        if(verbose) <<< "modalbar preset:", temp >>>;
    }
}
ModalBarPreset modalbar_preset;

class ModalBarStrike extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => modalbar.strike;
        if(verbose) <<< "modalbar strike:", temp >>>;
    }
}
ModalBarStrike modalbar_strike;

class ModalBarDamp extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => modalbar.damp;
        if(verbose) <<< "modalbar damp:", temp >>>;
    }
}
ModalBarDamp modalbar_damp;

class ModalBarMode extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getInt() => int mode;
        if(mode >= 0) mode => modalbar.mode;
        oe.getFloat() => float ratio;
        if(ratio >= 0) ratio => modalbar.modeRatio;
        oe.getFloat() => float radius;
        if(radius >= 0) radius => modalbar.modeRadius;
        oe.getFloat() => float gain;
        if(gain >= 0) gain => modalbar.modeGain;
        if(verbose) <<< "modalbar mode:", mode, ratio, radius, gain >>>;
    }
}
ModalBarMode modalbar_mode;

fun void modalbar_control_shred() {
    spork ~ ol.listenUGen("/inst/modalbar/gain,f", ugen_gain, modalbar);
    spork ~ ol.listenUGen("/inst/modalbar/connect,s,i", ugen_connect, modalbar);
    spork ~ ol.listenStk("/inst/modalbar/freq,f", stk_freq, modalbar);
    spork ~ ol.listenStk("/inst/modalbar/noteOn,f", stk_noteOn, modalbar);
    spork ~ ol.listenStk("/inst/modalbar/noteOff,f", stk_noteOff, modalbar);
    spork ~ ol.listen("/inst/modalbar/stickHardness,f", modalbar_stickHardness);
    spork ~ ol.listen("/inst/modalbar/strikePosition,f", modalbar_strikePosition);
    spork ~ ol.listen("/inst/modalbar/vibratoFG,f,f", modalbar_vibratoFG);
    spork ~ ol.listen("/inst/modalbar/directGain,f", modalbar_directGain);
    spork ~ ol.listen("/inst/modalbar/masterGain,f", modalbar_masterGain);
    spork ~ ol.listen("/inst/modalbar/volume,f", modalbar_volume);
    spork ~ ol.listen("/inst/modalbar/preset,i", modalbar_preset);
    spork ~ ol.listen("/inst/modalbar/strike,f", modalbar_strike);
    spork ~ ol.listen("/inst/modalbar/damp,f", modalbar_damp);
    spork ~ ol.listen("/inst/modalbar/mode,i,f,f,f", modalbar_mode);
    while(true)
        playtime => now;
}


// blowbotl controls
class BlowBotlVibrato extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float vFreq;
        oe.getFloat() => float vGain;
        oe.getFloat() => float nGain;
        if(vFreq >= 0)
            vFreq => blowbotl.vibratoFreq;
        if(vGain >= 0) 
            vGain => blowbotl.vibratoGain;
        if(nGain >= 0)
            nGain => blowbotl.noiseGain;
        if(verbose) <<< "blowbotl vibrato:", vFreq, vGain, nGain >>>;
    }
}
BlowBotlVibrato blowbotl_vibrato;

class BlowBotlVolume extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => blowbotl.volume;
        if(verbose) <<< "blowbotl volume:", temp >>>;
    }
}
BlowBotlVolume blowbotl_volume;

class BlowBotlRate extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => blowbotl.rate;
        if(verbose) <<< "blowbotl rate:", temp >>>;
    }
}
BlowBotlRate blowbotl_rate;

class BlowbotlStartBlowing extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => blowbotl.startBlowing;
        if(verbose) <<< "blowbotl startBlowing:", temp >>>;
    }
}
BlowbotlStartBlowing blowbotl_startBlowing;

class BlowBotlStopBlowing extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => blowbotl.stopBlowing;
        if(verbose) <<< "blowbotl stopBlowing:", temp >>>;
    }
}
BlowBotlStopBlowing blowbotl_stopBlowing;

fun void blowbotl_control_shred() {
    spork ~ ol.listenUGen("/inst/blowbotl/gain,f", ugen_gain, blowbotl);
    spork ~ ol.listenUGen("/inst/blowbotl/connect,s,i", ugen_connect, blowbotl);
    spork ~ ol.listenStk("/inst/blowbotl/freq,f", stk_freq, blowbotl);
    spork ~ ol.listenStk("/inst/blowbotl/noteOn,f", stk_noteOn, blowbotl);
    spork ~ ol.listenStk("/inst/blowbotl/noteOff,f", stk_noteOff, blowbotl);
    spork ~ ol.listen("/inst/blowbotl/vibrato,f,f,f", blowbotl_vibrato);
    spork ~ ol.listen("/inst/blowbotl/volume,f", blowbotl_volume);
    spork ~ ol.listen("/inst/blowbotl/rate,f", blowbotl_rate);
    spork ~ ol.listen("/inst/blowbotl/startBlowing,f", blowbotl_startBlowing);
    spork ~ ol.listen("/inst/blowbotl/stopBlowing,f", blowbotl_stopBlowing);
    while(true) 
        playtime => now;
}


// blowhole controls
class BlowHoleReed extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => blowhole.reed;
        if(verbose) 
            <<< "blowhole reed:", temp >>>;
    }
}
BlowHoleReed blowhole_reed;

class BlowHoleNoiseGain extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => blowhole.noiseGain;
        if(verbose) 
            <<< "blowhole noiseGain:", temp >>>;
    }
}
BlowHoleNoiseGain blowhole_noiseGain;

class BlowHoleTonehole extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => blowhole.tonehole;
        if(verbose) 
            <<< "blowhole tonehole:", temp >>>;
    }
}
BlowHoleTonehole blowhole_tonehole;

class BlowHoleVent extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => blowhole.vent;
        if(verbose) <<< "blowhole vent:", temp >>>;
    }
}
BlowHoleVent blowhole_vent;

class BlowHolePressure extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => blowhole.pressure;
        if(verbose) <<< "blowhole pressure:", temp >>>;
    }
}
BlowHolePressure blowhole_pressure;

class BlowHoleRate extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => blowhole.rate;
        if(verbose) <<< "blowhole rate:", temp >>>;
    }
}
BlowHoleRate blowhole_rate;

class BlowHoleStartBlowing extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => blowhole.startBlowing;
        if(verbose) <<< "blowhole startBlowing:", temp >>>;
    }
}
BlowHoleStartBlowing blowhole_startBlowing;

class BlowHoleStopBlowing extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => blowhole.stopBlowing;
        if(verbose) <<< "blowhole stopBlowing:", temp >>>;
    }
}
BlowHoleStopBlowing blowhole_stopBlowing;

fun void blowhole_control_shred() {
    spork ~ ol.listenUGen("/inst/blowhole/gain,f", ugen_gain, blowhole);
    spork ~ ol.listenUGen("/inst/blowhole/connect,s,i", ugen_connect, blowhole);
    spork ~ ol.listenStk("/inst/blowhole/freq,f", stk_freq, blowhole);
    spork ~ ol.listenStk("/inst/blowhole/noteOn,f", stk_noteOn, blowhole);
    spork ~ ol.listenStk("/inst/blowhole/noteOff,f", stk_noteOff, blowhole);
    spork ~ ol.listen("/inst/blowhole/reed,f", blowhole_reed);
    spork ~ ol.listen("/inst/blowhole/noiseGain,f", blowhole_noiseGain);
    spork ~ ol.listen("/inst/blowhole/tonehole,f", blowhole_tonehole);
    spork ~ ol.listen("/inst/blowhole/vent,f", blowhole_vent);
    spork ~ ol.listen("/inst/blowhole/pressure,f", blowhole_pressure);
    spork ~ ol.listen("/inst/blowhole/startBlowing,f", blowhole_startBlowing);
    spork ~ ol.listen("/inst/blowhole/stopBlowing,f", blowhole_stopBlowing);
    spork ~ ol.listen("/inst/blowhole/rate,f", blowhole_rate);
    while(true)
        playtime => now;
}


// bowed controls
class BowedBow extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float pressure;
        oe.getFloat() => float position;
        if(pressure >= 0)
            pressure => bowed.bowPressure;
        if(position >= 0)
            position => bowed.bowPosition;
        if(verbose) <<< "bowed bow:", pressure, position >>>;
    }
}
BowedBow bowed_bow;

class BowedVibratoFG extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float freq;
        oe.getFloat() => float gain;
        if(freq >= 0)
            freq => bowed.vibratoFreq;
        if(gain >= 0)
            gain => bowed.vibratoGain;
        if(verbose) <<< "bowed vibratoFG:", freq, gain >>>;
    }
}
BowedVibratoFG bowed_vibratoFG;

class BowedVolume extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => bowed.volume;
        if(verbose) <<< "bowed volume:", temp >>>;
    }
}
BowedVolume bowed_volume;

class BowedStartBowing extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => bowed.startBowing;
        if(verbose) <<< "bowed startBowing:", temp >>>;
    }
}
BowedStartBowing bowed_startBowing;

class BowedStopBowing extends OscHandler {
    fun void handle(OscEvent oe) {
        oe.getFloat() => float temp => bowed.stopBowing;
        if(verbose) <<< "bowed stopBowing:", temp >>>;
    }
}
BowedStopBowing bowed_stopBowing;

fun void bowed_control_shred() {
    spork ~ ol.listenUGen("/inst/bowed/gain,f", ugen_gain, bowed);
    spork ~ ol.listenUGen("/inst/bowed/connect,s,i", ugen_connect, bowed);
    spork ~ ol.listenStk("/inst/bowed/freq,f", stk_freq, bowed);
    spork ~ ol.listenStk("/inst/bowed/noteOn,f", stk_noteOn, bowed);
    spork ~ ol.listenStk("/inst/bowed/noteOff,f", stk_noteOff, bowed);
    spork ~ ol.listen("/inst/bowed/bow,f,f", bowed_bow);
    spork ~ ol.listen("/inst/bowed/vibratoFG,f,f", bowed_vibratoFG);
    spork ~ ol.listen("/inst/bowed/volume,f", bowed_volume);
    spork ~ ol.listen("/inst/bowed/startBowing,f", bowed_startBowing);
    spork ~ ol.listen("/inst/bowed/stopBowing,f", bowed_stopBowing);
    while(true)
        playtime => now;
}


// get everything started
int instruments[0];

fun void control_shred() {
    orec.event("/init,s") @=> OscEvent oe;
    while(true) {
        oe => now;
        while (oe.nextMsg() != 0) {
            oe.getString() => string str;
            // select appropriate instrument
            select_instrument(str);
            if(verbose) <<< "init", str >>>;
        }
    }
}

fun void select_instrument(string name) {
    if(instruments[name] != 0) 
        return;
    1 => instruments[name];
    if(name == "sinosc") 
        spork ~ sinosc_control_shred();
    else if(name == "sndbuf")
        spork ~ sndbuf_control_shred();
    else if(name == "mandolin")
        spork ~ mandolin_control_shred();
    else if(name == "fmvoices")
        spork ~ fmvoices_control_shred();
    else if(name == "voicform")
        spork ~ voicform_control_shred();
    else if(name == "sitar") 
        spork ~ sitar_control_shred();
    else if(name == "stifkarp")
        spork ~ stifkarp_control_shred();
    else if(name == "shakers")
        spork ~ shakers_control_shred();
    else if(name == "saxofony")
        spork ~ saxofony_control_shred();
    else if(name == "moog")
        spork ~ moog_control_shred();
    else if(name == "modalbar") 
        spork ~ modalbar_control_shred();
    else if(name == "blowbotl")
        spork ~ blowbotl_control_shred();
    else if(name == "blowhole")
        spork ~ blowhole_control_shred();
    else if(name == "bowed")
        spork ~ bowed_control_shred();
}

control_shred();

