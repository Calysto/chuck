SimpleOSC 0.2.5

ixi software - 10/4/2008
www.ixi-software.net

Install :
in the command line / terminal type 'python setup.py install'
Windows users can also just copy the osc folder into C:/python/2.x/Lib/site-packages

Description:
SimpleOSC is a simple API for the Open Sound Control for Python 
(by Daniel Holth, Clinton McChesney 
--> pyKit.tar.gz file at http://wiretap.stetson.edu
Documentation at http://wiretap.stetson.edu/docs/pyKit/)

The main aim of this implementation is to provide with a simple way to
deal with the OSC implementation that makes life easier to those who
don't have understanding of sockets. This would not be on your screen
without the help of Daniel Holth and the support of Buchsenhausen, Innsbruck, Austria.


How to use:
Check the appTemplate.py example to see how to use it. You can place the osc folder next to your module
or you can also copy it into the python site-packages folder (if you know where this lives in your system).
Note that firewalls and routers tend to block nerwork ports for security. Make
sure you use ports that are open for the OSC comunication.


Download page:
www.ixi-software.net/download/simpleosc.html
or go to www.ixi-software.net and get into backyard/code section
Note that simpleOSC is included in Mirra graphics library as well.


License : 
 This library is free software; you can redistribute it and/or modify it under the terms of the Lesser GNU, Lesser General Public License as published by the Free Software Foundation.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

SimpleOSC contains small parts by others such as OSC.py by Daniel Holth. Licence and credits are included on those parts from others.


System requirements:
OS X, GNU/Linux, Windows .... with Python installed


About OSC:
http://cnmat.cnmat.berkeley.edu/OSC/


Files:
appTemplate.py	 the example, run this to see how it works
oscTestpatch.pd	Pure Data example
oscTestPatch.sc	SuperCollider example
oscTestPatch.pat	MAX/MSP example
oscTestPatch.ck		ChucK example
readme.txt		this file :)
osc folder:
	OSC.py		Daniel Holth's OSC implementation
	oscApi.py		Set of functions that simplify the use of Daniels implementation


Changes
0.2.5
added threads to listener area thanks to Christopher Frauenberger.
0.2.4
added double values thanks to Christopher Frauenberger
0.2.3.2
ChucK example added.

0.2.3.1
- array in sendMsg takes default value to [] to allow for this type of messages
osc.sendMsg('/quit')

0.2.3
- some optimisation. got rid of some variables and functions

0.2.2
- added setup.py

0.2.1
- it sends by default to local host "127.0.0.1" ip and port 9000
- it receives by default from local host "127.0.0.1" ip and port 9001

0.2
- in order to make it simpler to use simpleOSC the callBackManager and ouSockets are now
global variables in the oscAPI module so that the user does not have to deal with them. This
makes the API cleaner and more compact. 

0.1.3
- switched licence to LGPL.

0.1.2
- some tiding up

0.1.1
- removed oscController.py to make it more general
- osc.py and oscAPI.py are now a package to make it more compact
- included latest version of OSC.py 


Feedback:
contact us on www.ixi-software.net
info@ixi-software.net


