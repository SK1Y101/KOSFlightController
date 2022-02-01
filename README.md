# KOSFlightController
My detail flight controller for the Kerbal Space Program Mod "Kerbal Operating System", designed for my Realism Overhaul Save

## What does it do?
As of version 0.4, not a lot!

### Boot-up Sequence
On opening a craft (be that switching from the tracking station, launching from the pad, or something else), this will begin.

The script will load the required Skiylia Scripts that handle shared functions, and will attempt to install a bootUI.

This BootUI Interface will be shown while the craft is not connected to the Kerbal Space Centre. There are currently 3 different sized BootUI:
- 100B, which shows the "Loss of Signal" display.
- 200B, Which shows loss of signal, as well as altitude
- 400B, Which shows loss of signal, as well as altitude

The flight computer will select the largest of the 3 that will fit into the spacecrafts local disk. Larger UI's show more information in a nicer format than smaller, so there is no reason to ever select a 200B UI if the disk can store 400B

These are being redesigned in Skiylia 0.4

### Main interface
At the completion of the above, the script will show the main interface.

This incomplete interface will display relevant and constantly updating information about the current spacecraft, such as:
- S.O.S Version
- Mission elapsed time
- Spacecraft name
- Stored Power
- Flight Status
- Disk Capacity
- Connection status

In the centre of the screen sits all interface elements of Skiylia. For the main menu, this is a list of available functionality, with a description as to what each function does.

Below is an Example of the current Main Interface Layout. Note the large central section where all interface elements lie.
```
═════════════════════════════════⟪SkiyliaOS v0.2⟫═
 MET: 45:12:04:34                    EC:  450.2kJ
 Test Craft VI                           Escaping
══════════════════════════════════════════════════

    MAIN MENU                          Page 1 / 1


 >> Flight Information
    -
    Reboot
    Shutdown
















 ================================================
 A Useful interface that shows relevant flight
 information of the current vessel.


══════════════════════════════════════════════════
 DSK: 768B / 5.00MiB Used             15.36% Full
 Con: Space Centre
══════════════════════════════════════════════════
```

### Sub interfaces
By using the arrow keys on the main menu, a user can select each of the sub-interfaces to open, or to reboot/shutdown the flight computer.

currently, only the Flight Information display is available, and as the description at the bottom of the main interface states, it will show relevant information about the current vessel.

Pressing the `Home` Button while in this view will take you back to the main interface, though only while the vessel is connected to the Space centre, as these scripts are not stored in the vessel storage memory.

The current layout of the Flight information display is given below. Note how the updating elements listed previously are still visible.
```
════════════════════════════════⟪SkiyliaOS v0.2⟫══
 MET: 14:15:53:21                    EC: 1475.9kJ
 Test Craft V                            Orbiting
══════════════════════════════════════════════════

    Flight Information

    Orbital Elements
     Sma: 703.98Km
     Ecc: 2.5*10^-6
     Inc: 0.02°
     Arg: 120.56°
     Lan: 45.80°
     Tru: 182.00°

    Orbital Information
     Bdy: Kerbin
     Apo: 703.99Km
     Per: 703.98Km
     Vel: 3.002Km/s
     Obt: 1:45:01:21
     Nxt: None

    Vessel Information
     Alt: 124.19Km
     Spd: 2.741Km/s
     SΔv: 1.290Km/s
     VΔv: 1.290Km/s
     Drw: -1.43KW


    Press [ Home ] to return

══════════════════════════════════════════════════
 DSK: 768B / 5.00MiB Used             15.36% Full
 Con: Space Centre
══════════════════════════════════════════════════
```
