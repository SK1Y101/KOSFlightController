// check if we have the bootup sequence enabled or not
clearscreen. parameter bootup is 1. set showtrig to false.
// bootup parameter:
// 0: don't show boot sequence
// 1: show boot sequence

// screensize
global w is 49. global h is 56.
set terminal:width to w+1. set terminal:height to h+1.

// open the terminal once the ship has been loaded
wait until ship:unpacked. core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

// clear the screen and show a simple loading text if the boot sequence is enabled
if bootup<>0 { print "Loading..." at(3, 3). wait .5. }

// launch the main skiylia files if we have a connection. (The vessel may have lost access to the archive since the last reboot)
if homeconnection:isconnected {
  runpath("0:/lib/skiylia/skiylia_core", bootup).
}
// otherwise reboot
else {
  reboot.
}
