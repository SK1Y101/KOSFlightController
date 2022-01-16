// a set of UI specific skiylia functions

// globals to be used
global ti is terminal:input.

// -----< Interfaces and Input >-----

// function to draw the main display elements at the top and bottom of the screen
function drawBaseUI {
  // -----< Static Elements >-----
  // Draw the horizontal bars
  local bar is repeat("═", w). print bar at(0, 0). print bar at(0, 3). print bar at(0, h-3). print bar at(0, h).
  // draw the version information
  print "⟪"+name+" v"+ver+"⟫" at(w - ver:length - name:length - 5, 0).
  // draw the ship name
  print shipname at(1, 2).
  // draw the disk usage
  local vol is volume(1). local cap is vol:capacity. lock fs to vol:freespace.
  print "DSK: "+repeat(" ", cap:tostring:length)+"B / "+cap+"B Free" at(1, h-2).
  print "% Full" at(w-7, h-2).
  // draw the connection status
  print "CON: " at(1, h-1).
  // draw the Mission timer
  print "MET: " at(1, 1).
  // draw the battery status
  local batlen is toDP(fetchresource("electriccharge"):capacity):length.
  local powstring is "EC: "+repeat(" ",batlen)+"kJ".
  print powstring at(w - 1 - powstring:length, 1).

  //DSK:  397 / 5000 B - 107.94% Full

  // -----< Dynamic Elements >-----
  // mission time
  function drawMet { print formtime(missiontime) at(6,1).}
  // Battery power
  function drawBat { local pow is toDP(ship:electriccharge):padleft(batlen). print pow at(w - pow:length - 3, 1).}
  // Ship status
  function drawStt { print tocase(status, 3):padleft(12) at(w - 12 - 1, 2). return true.}
  // Disk capacity
  function drawDsk { print (cap-fs):tostring:padleft(cap:tostring:length) at(6, h-2).
    print toDP(100-100*fs/cap, 2):padleft(6) at(w-13, h-2).}
  // Control connection
  function drawCon { local contxt is choose "No Signal" if not con else (choose "Space Center" if con=1 else "Remote").
    print contxt:padright(20) at(6, h-1). }

  // -----< Update Triggers >-----
  // Update the mission time
  on floor(missiontime) { drawMet(). return true.} drawMet().
  // Update the electric charge
  on round(ship:electriccharge, 1) { drawBat(). return true.} drawBat().
  // update the ship status
  on status { drawStt(). return true. } drawStt().
  // Update the disk capacity
  on fs { drawDsk(). return true. } drawDsk().
  // Update the connection status
  on con { drawCon(). return true. } drawCon().
}

// function to draw the main interface of skiylia
function fetchInterfaces {
  // create a function to run a file
  function rpath { parameter file. runpath(file). return true. }
  // fetch all of the sub interfaces we can access
  local ints is list().
  for file in fetchfiles("0:/lib/skiylia/interfaces") {
    // create the return list
    local intdata is list().
    // fetch the name
    intdata:add(fromfile(file, "Menu Name:", char(10), file:name)).
    // fetch the description
    intdata:add(fromfile(file, "Description:")).
    // and fetch the function for this file
    intdata:add(rpath@:bind(file)).
    // add this interface to the list
    ints:add(intdata).
  }
  // add a spacer
  ints:add("-").
  // create the reboot command
  ints:add(list("Reboot", "Reboot SkiyliaOS", rebootskiylia@)).
  // create the shutdown command
  ints:add(list("Shutdown", "Shutdown SkiyliaOS completely", shutdownskiylia@)).
  // return
  return ints.
}.

// -----< Nice formatting >-----

// lef pad an item
function padded {
  // fetch the string to pad, and the places to pad to
  parameter s, places.
  // if we were given a string to match the length of
  if places:istype("string") {
    // then fetch it's length
    set places to places:length.
  }
  // and return the padded string
  return (s+""):padleft(places).
}

// format a number as a string with a given number of places
function toDP {
  // inputs
  parameter num, place is 1.
  // convert to string
  local num is round(num, place)+"".
  // add an additional zero if needed
  if place > 0 and not num:contains(".") {
    return num+".":padright(place+1):replace(" ","0").
  }
  // otherwise return the number
  return num.
}

// convert a string to a capitalised version
function capitalise {
  parameter s. local out is "".
  // itterate on the string
  for str in s:split(" ") {
    // capitalise the start and add to out
    set out to out+" "+str[0]:toupper+str:remove(0,1):tolower.
  }
  return out.
}

// convert a string with underscores to one with spaces
function tocase {
  // fetch string and whether the string should be 0: left, 1: lowercase, 2: uppercase, 3: capitalised
  parameter s, spec is 0.
  // replace underscores
  set s to s:replace("_", " ").
  // if we're not doing anything to it, return
  if not spec {
    return s.
  }
  // check for upper and lowercase
  if spec < 3 {
    return choose s:toupper if spec = 2 else s:tolower.
  }
  // or return capitalised
  return capitalise(s).
}

// convert a time to a nicely printed clock
function formtime {
  // fetch the time
  parameter clocktime.
  // convert to DD:HH:MM:SS
  return floor(timespan(clocktime):days)+":"+timestamp(clocktime):clock.
}

// print a string to the screen, being mindfull of multilines
function printmultiline {
  parameter s, xc is -1, yc is -1.
  // if we haven't been given a print location
  if xc < 0 or yc < 0 { print s. return. }
  // otherwise
  local n is 0. for str in s:split(char(10)) {
    // print the string at the needed location
    print str at(xc, yc+n). set n to n+1.
  }
}

// ensure a string fits within a rectangular area
function boxedstring {
  // fetch the string, height, width, and bewline breaking style
  parameter s, wc, hc, justified is 1.
  // if the length of the string is less than the width
  if s:length <= wc { return s. }
  // base output list
  local out is list().
  // repeat
  until false {
    // stop if we don't have enough characters for the next row
    if s:length <= wc { out:add(s). break. }
    // index of the newline split
    local idx is choose wc if justified else s:substring(0, wc):findlast(" ").
    // if we just cut off a word
    if s[idx] <> " " { set s to s:insert(idx-1, "-"). }
    // add the next row to the output, and remove from our string
    out:add(s:substring(0, idx)). set s to s:remove(0, idx):trim.
  }
  // if the output list is longer than the maximum height
  if out:length >= hc {
    // trim the output
    set out to out:sublist(0, hc+1).
    // fetch the location of the final space
    local idx is out[hc]:findlast(" ").
    // and choose the cutoff locations
    set idx to choose wc-3 if justified else (choose idx if idx<=wc-3 else out[hc]:substring(0, idx-1):findlast(" ")).
    // and update the last element with the cutoff symbol
    set out[hc] to out[hc]:substring(0, idx)+"...".
  }
  // make a new string by joining with the newline character
  return out:join(char(10)).
}

// -----< Basic Functions >-----

// show a short spinning graphic
function loadcircle {
  parameter t, xc, yc. local spin is list("─", "\", "│", "/").
  for _t in range(t / 0.1) { print spin[mod(_t, 4)] at(xc, yc). wait 0.1. }
}.

// clear a rectangle on the screen, defaults to the non-ui location
function cls {
  // define the area needed to clear
  parameter xc is 0, yc is 4, wc is w, hc is h-8.
  // create the clearing rows
  local row is repeat(" ", wc).
  // itterate over all needed rows
  for _y in range(yc, yc+hc) {
    // print the clearing elements.
    print row at(xc, _y).
  }
}

// create a string of repeating characters
function repeat {
  parameter char, len.
  // make a blank string and replace
  return "":padleft(len):replace(" ", char).
}

// append a character to a string
function addchar {
  // string, input char, and max length
  parameter s, c, ml is 20. local sl is s:length.
  // check for backspace
  if c = "bsp" { set s to s:remove(max(0,sl-1),min(sl,1)).}
  // check for alphanumeric
  else if (c >= " ") and (c <= "~") {
    // append if below max length, else replace
    set s to (choose s if sl < ml else s:remove(sl-1, 1)) + c:tostring.
  }.
  // return the string
  return s.
}.

// a function to get user input
function input {
  // inputs to the function
  parameter t, x, y, ml is 20.
  // clear the terminal buffer and create a temporary string
  ti:clear(). local tmp is "".
  // show the prompt and move the x and y coords to the end of the prompt
  print t at(x,y). set x to x+t:length+1.
  // begin the loop
  until false {
    // if something has been typed
    if ti:haschar {
      // get the next character
      local ch is ti:getchar().
      // backspace
      if ch = ti:backspace { set tmp to addchar(tmp, "bsp", ml). }
      // enter
      else if ch = ti:return { break. }
      // else, deal with characters
      else { set tmp to addchar(tmp, ch, ml). }
      // print the temp string to the display
      print (tmp+fc):padright(ml) at(x, y).
    }
  }
  // return the temporary string
  return tmp.
}

// a function to check if a singular key was pressed in the last interval
function checkinputkeys {
  // fetch the list of keys to check for
  parameter keys is list().
  // if we have an input
  if ti:haschar {
    // fetch the input
    local ch is ti:getchar().
    // and clear the previous inputs
    ti:clear().
    // check if the input is in the list
    if keys:contains(ch) {
      // return the index of that input
      return keys:find(ch).
    }
    // ptherwise, return the failure code
    return -1.
  }
  // ptherwise, return the failure code
  return -1.
}

// a function to return a list of specified keys from a lexicon
function fetchlexval {
  // fetch the list of keys to return
  parameter lex, keyvals is list(). local out is list().
  // itterate over the provided keys to search
  for val in keyvals {
    // check if it is in the lexicon
    if lex:haskey(val) {
      // add to our output
      out:add(lex[val]).
    }
  }
  // and return the output
  return out.
}
