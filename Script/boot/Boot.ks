// define some global variables that will be used
lock con to homeconnection:isconnected.
global w is 50. global h is 56.
global title is "boot".
global ver is 0.1.

// set the terminal size and clear it
set terminal:height to h+1.
set terminal:width to w.
clearscreen.

// some functions
function type { parameter text, xpos is 1, ypos is 1, textspeed is 0.01.
 local pos is 0. For x in text { print x at (xpos+pos, ypos). set pos to pos+1. wait textspeed. }}.

// clear the middle of the terminal
function cls { for x in range(9, h-3) { print "":padleft(w-2) at(1, x). }. }.

// open the terminal
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

// show a quick loading sequence
type("Skiylian Operating System v"+ver, 2, 2).
type("Loading", 2, 3). type("....", 9, 3, 0.25).
