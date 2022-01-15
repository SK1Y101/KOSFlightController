// a set of UI specific skiylia functions

// globals to be used
global ti is terminal:input.

// function to draw the main display
function drawUI {
  // -----< Static Elements >-----
  // Draw the horizontal bars
  local bar is repeat("═", w). print bar at(0, 0). print bar at(0, 3). print bar at(0, h-3). print bar at(0, h).
  // draw the version information
  print "⟪"+name+" v"+ver+"⟫" at(w - ver:length - name:length - 5, 0).
  // draw the ship name
  print shipname at(1, 2).
  // draw the disk usage
  local vol is volume(1). local cap is vol:capacity. lock fs to vol:freespace.
  print "DSK Usd: "+repeat(" ", cap:tostring:length)+" / "+cap+" B" at(1, h-2).
  print "DSK Fre: "+repeat(" ", cap:tostring:length)+" / "+cap+" B" at(1, h-1).
  // draw the Mission timer
  print "MET: " at(1, 1).
  // draw the battery status
  local batlen is toDP(fetchresource("electriccharge"):capacity):length.
  local powstring is "EC: "+repeat(" ",batlen)+"kJ".
  print powstring at(w - 1 - powstring:length, 1).

  // -----< Dynamic Elements >-----
  // mission time
  function drawMet { print formtime(missiontime) at(6,1).}
  // Battery power
  function drawBat { local pow is toDP(ship:electriccharge):padleft(batlen). print pow at(w - pow:length - 3, 1).}
  // Ship status
  function drawStt { print status:padleft(12) at(w - 12 - 1, 2). return true.}
  // Disk capacity
  function drawDsk { print fs:tostring:padleft(cap:tostring:length) at(10, h-1).
    print (cap-fs):tostring:padleft(cap:tostring:length) at(10, h-2).}

  // -----< Update Triggers >-----
  // Update the mission time
  on floor(missiontime) { drawMet(). return true.} drawMet().
  // Update the electric charge
  on round(ship:electriccharge, 1) { drawBat(). return true.} drawBat().
  // update the ship status
  on status { drawStt(). return true. } drawStt().
  // Update the disk capacity
  on fs { drawDsk(). return true. } drawDsk().
}

// show a short spinning graphic
function loadcircle {
  parameter t, xc, yc. local spin is list("─", "\", "│", "/").
  for _t in range(t / 0.1) { print spin[mod(_t, 4)] at(xc, yc). wait 0.1. }
}.

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
    set out to out+" "+str[0]:toupper+str:remove(0,1).
  }
  return out.
}

// convert a time to a nicely printed clock
function formtime {
  // fetch the time
  parameter clocktime.
  // convert to DD:HH:MM:SS
  return floor(timespan(clocktime):days)+":"+timestamp(clocktime):clock.
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

// initialise a menu
function initmenu {
  // fetch the options, top left coords, width and height. also compute number of pages needed
  parameter options, title, xc, yc, wc, hc. local numpages is ceil(options / (hc-6)).
  // print the title and description deliminator
  print title at(xc, yc). print repeat("=", wc) at(xc, yc+hc-4).
  // print the page marker if needed
  if numpages > 1 {
    // create the page deliniation string
    local pagemarker is "Page "+1+" / "+numpages.
    // and print
    print pagemarker at(xc+wc-pagemarker:length, yc).
  }
  // fetch all of the choices that will fit on the page
  local printoptions is options:sublist(0, hc-6).
  // print the options
  local n is 0. for x in printoptions {
    // print the name neatly
    print capitalise(x:replace("_", " ")) at(xc, yc+n).
    // increment n
    set n to n+1.
  }
}
