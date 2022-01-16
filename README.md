# KOSFlightController
My detail flight controller for the Kerbal Space Program Mod "Kerbal Operating System", designed for my Realism Overhaul Save

## What does it do?
As of version 0.3, not a lot!

### Boot-up Sequence
On opening a craft (be that switching from the tracking station, launching from the pad, or something else), this will begin.

The script will load the required Skiylia Scripts that handle shared functions, and will attempt to install a bootUI.

This BootUI Interface will be shown while the craft is not connected to the Kerbal Space Centre. There are currently 3 different sized BootUI:
- 100B, which shows the current missiontime.
- 200B, which shows the current missiontime as a timestamp integer, the name of the vessel, and the current stored power
- 400B, which shows the missiontime as a dd:hh:mm:ss string, the name and status of the vessel, the current stored power, and the current power consumption of the vessel.

The flight computer will select the largest of the 3 that will fit into the spacecrafts local disk. Larger UI's show more information in a nicer format than smaller, so there is no reason to ever select a 200B UI if the disk can store 400B

### Main interface
At the completion of the above, the script will show the main interface.

This incomplete interface will display relevant and constantly updating information about the current spacecraft, such as:
- S.O.S Version
- Mission elapsed time
- Spacecraft name
- Stored Power
- Flight Status
- Disk Capacity

In the centre of the screen sits all interface elements of Skiylia. For the main menu, this is a list of available functionality, with a description as to what each function does.

Below is an Example of the current Main Interface Layout. Note the large central section where all interface elements lie.
```
════════════════════════════════⟪SkiyliaOS v0.2⟫══
 MET: 45:12:04:34                    EC:  450.2kJ
 Test Craft VI                           Escaping
══════════════════════════════════════════════════

    MAIN MENU                          Page 1 / 1


 >> Test Interface
    -
    Reboot
    Shutdown
















 ================================================
 Testing Skiylia menu functionality



══════════════════════════════════════════════════
 DSK Used:  768 / 5000 B
 DSK Free: 4232 / 5000 B
══════════════════════════════════════════════════
```
