// Menu name: Flight Information
// Description: A useful interface that shows relevant flight information for the current vessel.
// location: 1

// the back button
lock back to checkinputkeys(list(ti:homecursor)) <> -1.

// print the title and return info
print "Flight Information":toupper at(4, 5).
print "Press [ Home ] to return" at(4, h-5).

// print the orbital elements
print "Orbital Elements" at(4, 7).
print "Sma:" at(5, 9).
print "Ecc:" at(5, 10).
print "Inc:" at(5, 11).
print "Arg:" at(5, 12).
print "Lan:" at(5, 13).
print "Tru:" at(5, 14).

// Orbital information
print "Orbital Information" at(4, 17).
print "Bdy:" at(5, 19).
print "Apo:" at(5, 20).
print "Per:" at(5, 21).
print "Vel:" at(5, 22).
print "Obt:" at(5, 23).
print "Nxt:" at(5, 24). lock transit to choose obt:nextpatch:body:name if obt:hasnextpatch else "".

// Vessel information
print "Vessel Information" at(4, 27).
print "Mas:" at(5, 29).
print "Alt:" at(5, 30). set bnd to ship:bounds. on stage { set bnd to ship:bounds. return true. }.
print "Spd:" at(5, 31).
print "SΔv:" at(5, 32).
print "VΔv:" at(5, 33).
print "Drw:" at(5, 34). lock b to ship:electriccharge.

// keep updating while the user hasn't pressed home
until false {
  // wait for a physics tick
  set p to b. wait 0.
  // if we had a quit request
  if back and con { break. }
  // update the orbital elements
  printline(tosi(obt:semimajoraxis, 3)+"m",       10, 9).
  printline(todi(obt:eccentricity, 2),            10, 10).
  printline(toDP(obt:inclination, 2)+"°",         10, 11).
  printline(toDP(obt:argumentofperiapsis, 2)+"°", 10, 12).
  printline(toDP(obt:lan, 2)+"°",                 10, 13).
  printline(toDP(obt:trueanomaly, 2)+"°",         10, 14).
  // Update the orbit information
  printline(body:name,                             10, 19).
  printline(tosi(obt:apoapsis, 3)+"m",             10, 20).
  printline(tosi(obt:periapsis, 3)+"m",            10, 21).
  printline(tosi(obt:velocity:orbit:mag, 3)+"m/s", 10, 22).
  printline(formtime(obt:period),                  10, 23).
  printline(capitalise(obt:transition + transit),  10, 24).
  // update the vessel information
  printline(tosi(mass, 3)+"t",                               10, 29).
  printline(tosi(bnd:bottomaltradar, 3)+"m",                 10, 30).
  printline(tosi(ship:velocity:surface:mag, 3)+"m/s",        10, 31).
  printline(tosi(ship:deltav:asl, 3)+"m/s",                  10, 32).
  printline(tosi(ship:deltav:vacuum, 3)+"m/s",               10, 33).
  printline(tosi(60000*(b-p)/kuniverse:timewarp:rate, 3)+"W",10, 34).
}
