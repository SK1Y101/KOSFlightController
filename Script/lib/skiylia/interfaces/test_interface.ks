// Menu name: Test interface
// Description: Testing Skiylia menu functionality

// clear the screen
cls().

// print the title
print "Test interface" at(4, 5).
print "Press [ Home ] to return" at(4, h-5).

// keep updating while the user hasn't pressed home
until checkinputkeys(list(ti:homecursor))+1. {
  wait 0.
}
