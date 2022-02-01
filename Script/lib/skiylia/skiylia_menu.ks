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
  // define the bounding box of the menu
  local bbox is list(1, 5, w-1, h-10).
  // fetch the available interfaces
  local ints is fetchMainInterface(bbox).
  // draw the base main menu
  local mainmenu is drawmenu(ints, "Main menu", bbox).
  // and do the menu keypress updatey thing
  menuinputs("Main menu", mainmenu, bbox, true).
}

// How will menus work?

// up/down arrow to select the next or previous value
// left/right arrow to select the next or previous page (if there are any)
// Enter to interact with the choice
// Home to return to main ui, End to return to the previous page?

// each menu option will be:
// (name on menu, description, callback function)

// function to fetch the main menu interfaces for skiylia
function fetchMainInterface {
  // fetch the bounding box, so that we can compute how many pages are needed
  parameter bbox.
  // create the spacer
  local spacer is "-".
  // create the reboot command
  local bootcom is list("Reboot", "Reboot SkiyliaOS", rebootskiylia@).
  // create the shutdown command
  local shutcom is list("Shutdown", "Shutdown SkiyliaOS completely", shutdownskiylia@).
  // create the list of functions to add
  local bot_func is list(spacer, bootcom, shutcom).
  // fetch the available interfaces
  local ints is fetchInterfaces().
  // add our functions to the bottom of every page
  set ints to addToPage(ints, bbox, bot_func).
  // return the interfaces
  return ints.
}

// function to adding certain options to the bottom or top of every page
function addToPage {
  // fetch the bottom and top functions that should be added
  parameter ints, bbox, bfunc is list(), tfunc is list(). local ppage is bbox[3]-7.
  // reverse the lists, so that we insert correctly
  local rbfunc is reverse(bfunc). local rtfunc is reverse(tfunc).
  // itterate over the options
  local p is 0. until p*ppage > ints:length {
    // fetch the starting and ending indicies
    local sidx is ppage*(p). local eidx is ppage*(p+1) - bfunc:length.
    // insert the starting functions
    for x in rtfunc { ints:insert(sidx, x). }
    // if this page isn't full, append the final values
    if eidx > ints:length { for x in bfunc { ints:add(x). } }
    // otherwise insert the ending functions
    else { for x in rbfunc { ints:insert(eidx, x). } }
    // increment the page number
    set p to p+1.
  }
  return ints.
}

// function to fetch available interfaces from a directory
function fetchInterfaces {
  // fetch the available interfaces from a specific directory, as well as the function to bind things to
  parameter dir is "0:/lib/skiylia/interfaces", intfunc is interfaceFromFile@.
  // fetch all of the sub interfaces we can access
  local ints is list(). local locs is list(). local maxloc is 0.
  for file in fetchfiles(dir) {
    // create the menu object for the file
    local intdata is intfunc(file).
    // fetch the menu location, keeping track of the largest given
    local thisloc is fromfile(file, "location:", char(10), ""+(maxloc+1)):toscalar().
    set maxloc to max(maxloc, thisloc). locs:add(thisloc).
    // add this interface to the list
    ints:add(intdata).
  }
  // return the interface list,
  return sortInts(ints, locs, maxloc+1).
}.

// the standard function to fetch interface infromation from a file
function interfaceFromFile {
  // fetch the file, and the execution function
  parameter file. local function rpath { parameter file. runpath(file). return true. }
  // return the name and description of this file here
  return list(fromfile(file, "Menu Name:", char(10), file:name),
              fromfile(file, "Description:"),
              // bind the 'enter' function too
              rpath@:bind(file)).
}

// sort a list according to a secondary list of locations
function sortInts {
  // fetch the list of interfaces as well as their maximum length
  parameter lis, loc, mloc is -1. local sor is list().
  // ensure mloc makes sense
  set mloc to max(mloc, lis:length).
  // itterate over the maximu length
  for x in range(mloc) {
    // if this index is a valid choice, add the interface
    if loc:contains(x) { sor:add(lis[loc:find(x)]). }
    // otherwise, add a spacer
    else { sor:add("-"). }
  }
  // return the sorted interface list
  return sor.
}

// convert a list of options into a menu list
function initmenulist {
  // fetch the available options, and options per page.
  parameter options, ppage is 20.
  // create the output list and page key
  local out is lexicon(). local p is 0.
  // keep going until the list is empty
  until options:empty {
    // remove any spacers from the start of each page
    until not (options[0] = "-") { options:remove(0). }
    // fetch the number of options this page
    local n is min(ppage, options:length).
    // add those options to the output
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
  parameter options, title, bbox. local ppage is bbox[3]-7. cls().
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
    for n in range(0, opt[page]:length) { print tocase(opt[page][n][0]:trim, 3) at(bbox[0]+3, bbox[1]+n+3).}
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
function selectmenu {
  // fetch the menu
  parameter opt, title, bbox.
  // fetch the function
  local func is opt[opt:page][opt:item][2].
  // clear the screen and execute. if we executed an interface (the function returned 0), redraw the previous menu
  boop(). cls(). if func() { drawmenu(opt, title, bbox). }
}

// function to check for menu inputs
function menuinputs {
  // fetch the details specific to this menu
  parameter thisname, thismenu, thisbbox, ismainmenu is false.
  // fetch any extra inputs the user might be able to enter
  parameter extrakeys is list(), extrafuncs is list(). local back is false.
  // fetch the standard keypress array
  local kp is fetchlexval(keylist, list("home", "up", "down", "left", "right", "enter")).
  // fetch the standard functions array
  local kf is list({ set back to con. },
                   updatemenu@:bind(thismenu, thisbbox,-1, 0),
                   updatemenu@:bind(thismenu, thisbbox, 1, 0),
                   updatemenu@:bind(thismenu, thisbbox, 0,-1),
                   updatemenu@:bind(thismenu, thisbbox, 0, 1),
                   selectmenu@:bind(thismenu, thisname, thisbbox)).
  // extend our keypress and key function arrays with the inputted functions.
  extend(kp, extrakeys). extend(kf, extrafuncs).
  // if this is not the main menu
  if not ismainmenu {
    until back {
      // check if we have an input to handle
      local keypressed is checkinputkeys(kp).
      // if we had an input, execute that function
      if keypressed >= 0 { kf[keypressed](). }
      // wait for one physics tick
      wait 0.
    }
  // the main menu has literally the same code
  } else {
    // remove the back key things and loop indefinitely
    kp:remove(0). kf:remove(0). until done {
      // check if we have an input to handle
      local keypressed is checkinputkeys(kp).
      // if we had an input, execute that function
      if keypressed >= 0 { kf[keypressed](). }
      // wait for one physics tick
      wait 0.
    }
  }
}
