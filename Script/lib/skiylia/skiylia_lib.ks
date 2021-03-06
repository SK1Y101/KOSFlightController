// A set of skiylia library functions that will be used across scripts.

// -----< File manipulation >-----

// fetch a list of files in a given directory
function fetchfiles {
  // fetch the target and working directories
  parameter dir. local cwd is path().
  // move to the target dir, fetch the files, and move back
  cd(dir). list files in f. cd(path).
  // return
  return f.
}

// fetch data from a non-json file
function fromfile {
  // fetch the filename, string to search for, default return and character to end the search with
  parameter fname, search, echar is char(10), default is "".
  // fetch the file content
  local s is open(fname):readall:string.
  // ensure our search is in the file
  if s:contains(search) {
    // fetch the string after that point
    local str is s:split(search)[1].
    // return everything up to the endchar, or EOF if that dosen't exist
    return str:substring(0, min(str:length, str:find(echar))):trim:trimend.
  }
  // return the default
  return default.
}

// overwrite the boot file of a craft
function writeboot {
  // inputs
  parameter bf, nn is "".
  // delete the old boot and make a new one
  deletepath("1:/boot"). createdir("1:/boot").
  // if we didn't get a name, fetch the original
  if not nn { set nn to open(bf):name. }
  // and ensure the boot file is in the correct location
  set nn to "1:/boot/"+nn:replace("1:/", ""):replace("boot/","").
  // copy the file to the boot area and get the file
  copypath(bf, nn).
  // update the boot file
  set core:bootfilename to nn:replace(open(nn):extension, ""):replace("1:/", "").
}

// ensure we have a minui for when the craft leaves communications
function addbootui {
  // inputs
  parameter xc, yc.
  // check our booftile is not alread a minui
  if core:bootfilename = "boot/minui.ks" { typestatus("BootUi","Installed",xc,yc). return.}
  // fetch the maximum capacity for the boot volume
  local cap is volume(1):capacity.
  // fetch the minui files
  local uis is fetchfiles("0:/lib/skiylia/minui").
  // iterate over all found interfaces
  local bootable is list(). for ui in uis {
    // if the file is bootable,
    if ui:name:contains("boot") {
      // and add to the list
      bootable:add(round(ui:size/100)*100).
    }
  }
  // find the largest ui that will fit into the volume capacity
  local bfile is bootable:reverseiterator. until not bfile:next {
    // if the filesize is smaller than the capacity
    local bsize is bfile:value. if bsize <= cap {
      // add this bootfile
      writeboot("0:/lib/skiylia/minui/boot"+bsize, "minui").
      // show a success message and stop the loop
      typestatus("BootUi",bsize+" Installed",xc,yc). return.
    }
  }
  // show a failure message
  typestatus("BootUi","Failed to install",xc,yc).
}

// -----< Skiylia manipulation funcs >-----

// cleanly shutdown skiylia
function shutdownskiylia { cls(). type("SkiyliaOS Shutdown", 3, 5). loadcircle(0.7, 3, 7). set done to true. }

// reboot skiylia
function rebootskiylia { reboot. }

// -----< List manipulation >-----

// reverse a list
function reverse {
  // fetch the list
  parameter lis. local out is list().
  // create a reverse itterator
  local itter is lis:reverseiterator.
  // and built the list backwards
  until not itter:next { out:add(itter:value). }
  return out.
}

// extend a list with another list
function extend {
  parameter l1, l2 is list().
  if not l2:empty() { for x in l2 { l1:add(x). } }
}

// -----< Maths functions >-----

// faster tanh approximation
function tanh {
  // fetch input and absolute value
  parameter x. local a is abs(x).
  // small angle approximation
  if a < .2 { return x. }
  // large angle approximation
  if a > 3 { return x / a. }
  // expansion approximation
  return x * (27 + x*X) / (27 + 9*x*x).
}

// ceil of a number, because their function was too long
function ceil {
  parameter num, places is 0.
  return ceiling(num, places).
}

// -----< Vessel information functions >-----
function fetchresource {
  // resource name
  parameter resname.
  // itterate over the resources
  for res in ship:resources {
    // if we have a match, return the reference.
    if res:name = resname {
      return res.
    }
  }
}

// hoverscribt
function testing {

  set bnd to ship:bounds.
  lock height to round(bnd:bottomaltradar,1).
  lock g to body:mu / (body:radius + height)^2.
  lock a to maxthrust / mass.
  lock pitch to vang(facing:vector, up:vector).

  lock steering to up.

  set targetspeed to -2.

  wait 10.

  // keep the script running
  until false {
    until a <> 0 { wait until stage:ready. stage. }
    lock throttle to ((g / a) - tanh(verticalspeed - targetspeed)) / cos(pitch).
  }.
}.
