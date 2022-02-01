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
  print "DSK: " at(1, h-2).
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
  function drawMet { print formtime(missiontime)+"   " at(6,1).}
  // Battery power
  function drawBat { local pow is toDP(ship:electriccharge):padleft(batlen). print pow at(w - pow:length - 3, 1).}
  // Ship status
  function drawStt { print tocase(status, 3):padleft(12) at(w - 12 - 1, 2).}
  // Disk capacity
  function drawDsk { print (tobi(cap-fs)+"B / "+tobi(cap)+"B Used"):padright(30) at(6, h-2).
    print toDP(100-100*fs/cap, 2):padleft(6) at(w-13, h-2).}
  // Control connection
  function drawCon { local contxt is choose "No Signal" if not con else (choose "Space Centre" if con=1 else "Remote").
    print contxt:padright(20) at(6, h-1). }

  // -----< Update Triggers >-----
  // Update the mission time
  on floor(missiontime) { if showtrig { drawMet(). return true.}} drawMet().
  // Update the electric charge
  on round(ship:electriccharge, 1) { if showtrig { drawBat(). return true.}} drawBat().
  // update the ship status
  on status { if showtrig { drawStt(). return true.} } drawStt().
  // Update the disk capacity
  on fs { if showtrig { drawDsk(). return true.} } drawDsk().
  // Update the connection status
  on con { if showtrig { drawCon(). return true.} } drawCon().
}

// -----< Nice formatting >-----

// print over an entire line
function printline { parameter s, xc, yc. print s:padright(w-xc) at(xc, yc). }

// format a number with a binary suffix
function tobi {
  // fetch the number and the number of places to show
  parameter num, places is 2.
  // list the binary prefixes
  local prefs is list("", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi", "Yi").
  // ensure num is a number
  if num:istype("string") { set num to num:toscalar(). }
  // fetch the power of 1024 that the number fits into
  local pow is choose min(8, max(0, floor(log10(abs(num)) / log10(1024)))) if num else 0.
  // return the number with the prefix
  return toDP(num / 1024^pow, choose places if pow else 0)+prefs[pow].
}

// format a number with an si suffix
function tosi {
  // fetch the number and the number of places to show
  parameter num, places is 2.
  // list the si prefixes
  local prefs is list("y", "z", "a", "f", "p", "n", "μ", "m", "", "K", "M", "G", "T", "P", "E", "Z", "Y").
  // ensure num is a number
  if num:istype("string") { set num to num:toscalar(). }
  // fetch the power of 1000 that the number fits into
  local pow is choose min(8, max(-8, floor(log10(abs(num)) / 3))) if num else 0.
  // return the number with the prefix
  return toDP(num / 1000^pow, places)+prefs[pow+8].
}

// format a number with a decimal suffix
function todi {
  // fetch the number and the number of places to show
  parameter num, places is 2, thou is false.
  // ensure num is a number
  if num:istype("string") { set num to num:toscalar(). }
  // fetch the power of 10 that the number fits into
  local pow is choose floor(log10(abs(num))) if num else 0.
  // if we are dividing into thousands, find the nearest
  if thou { set pow to 3 * floor(pow / 3). }
  // return the number with the prefix
  return toDP(num / 10^pow, places)+"*10^"+pow.
}

// format a number as a string with a given number of places
function toDP {
  // inputs
  parameter num, place is 1.
  // convert to string
  set num to round(num, place)+"".
  // ensure we have enough decimal places
  if place > 0 { if not num:contains(".") { set num to num+".". }
    set num to num:padright(place + num:find(".") + 1):replace(" ","0"). }
  // otherwise return the number
  return num.
}

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

// convert a string to a capitalised version
function capitalise {
  parameter s. local out is list().
  // itterate on the string
  for str in s:split(" ") {
    // capitalise the start and add to out
    out:add(str[0]:toupper+str:remove(0,1):tolower).
  }
  return out:join(" ").
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

// convert an arbitary string to one that wraps over lines
function stringToMultiline {
  // fetch the string, allowed width, and justification type
  parameter s, wc, justified is 1.
  // base output list
  local out is list().
  // repeat indefinitely
  until false {
    // fetch the maximum string this line, and the guess index
    local thisline is s:substring(0, min(wc, s:length)). local idx is wc.
    // find the location of any linebreaks
    local nidx is thisline:find(char(10)).
    // if there is a newline, then split here
    if nidx >= 0 { set idx to nidx. }
    // if we don't have enough characters left to split, add
    else if s:length <= wc { out:add(s). break. }
    // otherwise
    else {
      // if we are not justified, find the new index
      if not justified { set idx to thisline:findlast(" "). }
      // if we just cut off a word, and there wasn't already a division, add a dividing mark
      if (s[idx] <> " ") and (s[idx] <> "-") { set s to s:insert(idx-1, "-"). } }
    // add the next row to the output, and remove the dealt with characters
    out:add(s:substring(0, idx)). set s to s:remove(0, idx):trim.
  }
  // return the divided string
  return out.
}

// ensure a string fits within a rectangular area
function boxedstring {
  // fetch the string, height, width, and newline breaking style
  parameter s, wc, hc, justified is 1.
  // fetch the divided string list
  local out is stringToMultiline(s, wc, justified).
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

// scroll a string that doesn't fit into view
function scrolledstring {
  // fetch the string to add, the output list, width, height, and justification type
  parameter ns, ol, wc, hc, justified is 1.
  // convert the string to a newline list
  local s is stringToMultiline(ns, wc, justified).
  // extend our output list with the new string
  for x in s { ol:add(x). }
  // remove anything from the front if our length is too long
  set ol to ol:sublist(max(0, ol:length - hc), ol:length).
  // return the output string too
  return ol:join(char(10)).

  // convert the string to a newline list
  local out is stringToMultiline(s, wc, justified).
  // if the output string will be too tall
  if out:length > hc { out:remove(out:length - hc). }
  // make the final string by joining the newlines
  return out:join(char(10)).
}

// use the multiline print and the scrolled string to have a pretty output log
function logtoscreen {
  // fetch the string, list of outputs, x, y, w, h coordinates of the area, and justification type
  parameter s, out, xc, yc, wc, hc, js is 1.
  // create the scrolled string (ensuring it is a string), and print it
  printmultiline(scrolledstring(s+"", out, wc, hc, js), xc, yc).
}

// -----< Basic Functions >-----

function boop { print beep at(1,1). }

// show a short spinning graphic
function loadcircle {
  parameter t, xc, yc. local spin is list("─", "\", "│", "/").
  for _t in range(t / 0.1) { print spin[mod(_t, 4)] at(xc, yc). wait 0.1. }
}.

// clear a rectangle on the screen, defaults to the non-ui location
function cls {
  // define the area needed to clear
  parameter xc is 0, yc is 4, wc is w+1, hc is h-8.
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
    // otherwise, return the failure code
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
