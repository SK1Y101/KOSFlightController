// -----< Global variables >-----
global ver is "0.2". global name is "SkiliaOS".
global path is "0:/lib/skiylia".
global beep is char(7). global nl is char(10).
global quote is char(34). global comma is char(44).

// -----< Helper functions >-----
// type to the screen with some delay
function type { parameter txt, x is 0, y is 0, ts is 0. local p is 0.
  for t in txt { if t = nl { set p to 0. set y to y+1. }. print t at(x+p, y). set p to p+1. wait ts. }. }.

// type a staus message to the screen
function typestatus { parameter sname, sstat, xc, yc. type(sname:padright(10)+": "+sstat, xc, yc).}

// load a file
function load { parameter file. if exists(file) { runoncepath(file). return true. } }

// load a module
function loadmodule { parameter name, x, y, rel is "".
  local l is load((path+"/"+rel+"/"+name):replace("//", "/")).
  typestatus("Module",name+(choose " loaded" if l else " failed"), x, y). return l. }

// reboot if we ever change connectedness.
//clearscreen. on homeconnection:isconnected { reboot. return true. }

// show the skiylia version
typestatus("Booting", "Skiylia Operating System", 3, 3).
typestatus("Version", ver, 3, 4).

// load modules
loadmodule("skiylia_lib", 3, 5).
loadmodule("skiylia_ui", 3, 6).

// ensure we have a bootable ui
addbootui(3, 7).

// complete
type("Load complete"+beep, 3, 9).
loadcircle(0.5, 3, 10). clearscreen.

// draw the main UI.
drawUI().

// execute the main skiylia loop.
until false.
