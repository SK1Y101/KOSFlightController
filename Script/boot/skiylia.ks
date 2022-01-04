// screensize
global w is 50. global h is 56.
set terminal:width to w. set terminal:height to h+1.

// open the terminal once the ship has been loaded
wait until ship:unpacked. CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

// clear the screen and show a simple loading text
clearscreen. print "Loading..." at(3, 3).
wait .5.

// launch the main skiylia files.
runpath("0:/lib/skiylia/skiylia_core").