# ShipNav

ShipNav is a customizable microcontroller ship systemthat intends to assist with the managing of a ship.

## Dependencies
ShipNav requires the following to properly operate:
* Screen
* Microphone

However, for full functionality, it requires the following:
* HyperDrive (Configuring coordinates, warping)
* Speaker (Sound effects, music player)
* LifeSensor (Radar system, "scan" command)
* Instrument (Radar system, "scan command, etc.)
* Gyro (Targeting system, detection system)
* Anchor ("Anchor" command)


## Installation

* Connect all modules with an EthernetCable and Port.
* Power the microcontroller and its connected parts.
* Turn on the microcontroller via a mode 0 polysilicon
* Attach a transformer to the microcontroller and power it to automatically start the microcontroller when the server starts (optional)
## Settings
```
Settings.VesselName - The name of the ship.
Settings.AllowPublicGPS - Whether the ship will publicly share its position and name. This is used for displaying ships onto radars. (Does not share coordinates)
Settings.ConfigPrefix - The prefix used for configuring attachments (e.g. "-Headlights false" or "-EngineSwitch true").
Settings.HomeBase - The coordinates of the home base, used by the "home command". Set this to false to disable this feature.

Settings.RadarUpdateTime - Determines often the radar is updated in seconds.
Settings.MapSize-- The size of the map in studs; note that players over 2000 studs away cannot be seen; setting this to values higher than 2000 will cause issues with the map.

```
## Commands
```
"scan" - Prints nearby players' names and distances from the ship into the F9 console
"radar" - Initiates the radar screen
"home" - Teleports the ship to the configured home base, if applicable [Settings.HomeBase] [incomplete]
```

## Contributing
To contribute, open a [pull request](https://github.com/hail12pink/ShipNav/pulls)
## License
[MIT](https://choosealicense.com/licenses/mit/)