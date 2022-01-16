// Handles the creation and interaction with Menus, as they are quite complicated and would fill the Skiylia_ui package.

global ti is terminal:input.
// keypress array
global keylist is lexicon(
  "up", ti:upcursorone,
  "down", ti:downcursorone,
  "left", ti:leftcursorone,
  "right", ti:rightcursorone,
  "enter", ti:return,
  "home", ti:homecursor,
  "end", ti:endcursor).

// the main skiylia interface
function mainInterface {
  // fetch the available interfaces
  local ints is fetchInterfaces().
  // define the bounding box of the menu
  local bbox is list(1, 5, w-1, h-10).
  // draw the base main menu
  local mainmenu is drawmenu(ints, "Main menu", bbox).
  // fetch the allowed keypresses
  local keypress is fetchlexval(keylist, list("up", "down", "left", "right", "enter")).
  // and the things that will execute forever
  until done {
    // check if we have an input to handle
    local keypressed is checkinputkeys(keypress).
    // if we do
    if keypressed >= 0 {
      // if the user changed the page/item
      if keypressed = 0 { updatemenu(mainmenu, bbox,-1, 0). }
      if keypressed = 1 { updatemenu(mainmenu, bbox, 1, 0). }
      if keypressed = 2 { updatemenu(mainmenu, bbox, 0,-1). }
      if keypressed = 3 { updatemenu(mainmenu, bbox, 0, 1). }
      // if the user pressed enter
      if keypressed = 4 { if execmenu(mainmenu) { drawmenu(mainmenu, "Main menu", bbox). } }
    }
    // wait for one physics tick
    wait 0.
  }
  // show a shutdown sequence
  cls().
  type("SkiyliaOS Shutdown", 3, 5).
  loadcircle(0.5, 3, 7). clearscreen.
}

// How will menus work?

// up/down arrow to select the next or previous value
// left/right arrow to select the next or previous page (if there are any)
// Enter to interact with the choice
// Home to return to main ui, End to return to the previous page?

// convert a list of options into a menu list
function initmenulist {
  // fetch the available options, and options per page.
  parameter options, ppage is 20.
  // create the output list and page key
  local out is lexicon(). local p is 0.
  // keep going until the list is empty
  until options:empty {
    // fetch the number of options this page
    local n is min(ppage, options:length).
    // add thos options to the output
    out:add(p, options:sublist(0, n)).
    // and remove the options from the original list
    for x in range(0, n) { options:remove(0). }
    // increment the page counter
    set p to p + 1.
  }
  // add the total number of pages
  out:add("pages", p).
  // and select the zeroth item by default
  out:add("page", 0). out:add("item", 0).
  // return
  return out.
}

// draw a menu
function drawmenu {
  // fetch the options, bounding box, as well as current page to show.
  parameter options, title, bbox. local ppage is bbox[3]-7.
  // print the title and description deliminator
  print tocase(title, 2):padright(bbox[2]-bbox[0]-2) at(bbox[0]+3, bbox[1]). print repeat("=", bbox[3]+1) at(bbox[0], bbox[1]+bbox[3]-4).
  // ensure we have the required options menu type
  if not options:istype("lexicon") { set options to initmenulist(options, ppage). }
  // fetch the number of pages
  local npage is options:pages.
  // print the pages marker
  local pmarker is "Page "+padded("", npage)+" / "+padded(npage, npage).
  print pmarker at(bbox[0]+bbox[2]-pmarker:length-1, bbox[1]).
  // draw the current menu
  drawmenuupdate(options, bbox, options:item, options:page).
  // and return the menu list
  return options.
}

// draw the new menu selection
function drawmenuupdate {
  // fetch the options, bounding box, and the page and item to show
  parameter opt, bbox, item is 0, page is 0, olditem is -1, oldpage is -1.
  // if the page number has changed
  if page <> oldpage {
    // update the page number
    local pmarklen is (""+opt:pages):length. local pmark is padded((page+1), pmarklen).
    print pmark at(bbox[0]+bbox[2]-pmarklen-5, bbox[1]).
    // update the page with the new page items
    for n in range(0, opt[page]:length) { print tocase(opt[page][n][0]:trim, 3) at(bbox[0]+2, bbox[1]+n+3).}
    // then ensure we change the description
    set olditem to -1.
  }
  // if the item has changed
  if item <> olditem {
    // update the cursor position
    print "  " at(bbox[0], bbox[1]+3+olditem).
    print ">>" at(bbox[0], bbox[1]+3+item).
    // fetch the current item description
    local desc is boxedstring(opt[page][item][1], bbox[2]-1, 4, 0).
    // clear the previous decsription
    cls(bbox[0], bbox[1]+bbox[3]-3, bbox[2], 4).
    // and show the new one
    printmultiline(desc, bbox[0], bbox[1]+bbox[3]-3).
  }
}

// check which area of the menu needs updating
function updatemenu {
  // fetch the options, bounding box, item increment, and page increment
  parameter opt, bbox, iteminc is 0, pageinc is 0.
  // fetch the option details
  local page is opt:page. local item is opt:item. local maxpage is opt:pages.
  // the newpage and item begin at current
  local newpage is page. local newitem is item.
  // if we are incrementing a page
  if pageinc {
    // fetch the next page by wrapping
    set newpage to mod(page+pageinc+maxpage, maxpage).
    // if the page changed, ensure we change the item too
    if newpage <> page { set item to -1. set iteminc to 1. }
  }
  // if we are incrementing an item
  if iteminc {
    // fetch the number of items this page
    local nitem is opt[page]:length.
    // fetch the next item by wrapping around (ensuring positive selection)
    set newitem to mod(item+iteminc+nitem, nitem).
    // if we have a blank, fetch the next.
    until opt[page][newitem] <> "-" { set newitem to mod(newitem+iteminc+nitem, nitem).}
  }
  // update the menu
  drawmenuupdate(opt, bbox, newitem, newpage, item, page).
  // update the page and item number
  set opt:page to newpage. set opt:item to newitem.
}

// execute the function related to the menu item
function execmenu {
  // fetch the menu
  parameter opt.
  // fetch the function
  local func is opt[opt:page][opt:item][2].
  // and execute. if we executed a script, this will return true to redraw the main menu
  return func().
}
