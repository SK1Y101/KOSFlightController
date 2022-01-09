clearscreen. lock b to ship:electriccharge. until homeconnection:isconnected {
set p to b. wait 0.
print shipname at(3,2).
print "MET: "+floor(timespan(missiontime):days)+":"+timestamp(missiontime):clock at(3,4).
print "BAT: "+round(b,1)+"kJ      " at(3,5).
print "DRW: "+round(60*(b-p)/kuniverse:timewarp:rate,3)+"kW      " at(3,6).
print "STT: "+status+"      " at(3,7).}
run "0:/boot/skiylia".
