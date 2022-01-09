clearscreen. until homeconnection:isconnected {
print shipname at(3,2).
print "MET: "+floor(missiontime)+"s" at(3,4).
print "BAT: "+round(ship:electriccharge,1)+"kJ " at(3,5).}
run "0:/boot/skiylia".
