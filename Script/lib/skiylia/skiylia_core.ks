// -----< Global variables >-----
global ver is "0.1".

global beep is char(7). global nl is char(10).
global quote is char(34). global comma is char(44).

// -----< Helper functions >-----
// type to the screen with some delay
function type { parameter txt, x is 0, y is 0, ts is 0. local p is 0.
  for t in txt { if t = nl { set p to 0. set y to y+1. }. print t at(x+p, y). set p to p+1. wait ts. }. }.

// clear the screen
clearscreen.

// show the skiylia version
type("Skiylia Operating System", 3, 3).
type("Version "+ver, 3, 4).

print beep.
