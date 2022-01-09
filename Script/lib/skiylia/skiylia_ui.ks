// a set of UI specific skiylia functions

// globals to be used
global ti is terminal:input.
global fr is list("─","│","┌","┐","└","┘","┬","┴","├","┤","┼").
global fb is list("═","║","╔","╗","╚","╝","╦","╩","╠","╣","╬").

// draw a ui box
function drawbox {
  // fetch x, ym width, height, and box characters
  parameter _x,_y,_w,_h,_f is fr. local mid is "":padleft(_w-2).
  // itterate on the edges
  for y in range(1,_h) { print _f[1]+mid+_f[1] at(_x,_y+y).}
  // create the top and bottom
  set mid to mid:replace(" ",_f[0]).
  print _f[2]+mid+_f[3] at(_x,_y). print _f[4]+mid+_f[5] at(_x,_y+_h-1).
}

// show a short spinning graphic
function loadcircle {
  parameter t, xc, yc. local spin is list("─", "\", "│", "/").
  for _t in range(t / 0.1) { print spin[mod(_t, 4)] at(xc, yc). wait 0.1. }
}.

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
