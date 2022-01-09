// A set of skiylia library functions that will be used across scripts.

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
  // fetch the working path, move to the boot folder, fetch ui's, and return to working dir
  local cwd is path(). cd("0:/lib/skiylia/minui"). list files in uis. cd(cwd).
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
      typestatus("BootUi:",bsize+"B UI Installed",xc,yc). return.
    }
  }
  // show a failure message
  typestatus("BootUi","Failed to install",xc,yc).
}

// hoverscribt
function testing {

  set bnd to ship:bounds.
  lock h to round(bnd:bottomaltradar,1).
  lock g to body:mu / (body:radius + h)^2.
  lock a to maxthrust / mass.
  lock pitch to vang(facing:vector, up:vector).

  lock steering to up.

  set targetspeed to -2.

  wait 10.

  function tanh { parameter x.
    local a is abs(x).
    if a < .2 {return x. }
    else if a > 3 { return x / a. }
    return x * (27 + x*x) / ( 27 + 9*x*x). }

  // keep the script running
  until false {
    until a <> 0 { wait until stage:ready. stage. }
    lock throttle to ((g / a) - tanh(verticalspeed - targetspeed)) / cos(pitch).
  }.
}.
