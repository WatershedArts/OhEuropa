## Oh Europa 

### Overview

Oh Europa is an iOS application which checks the users current location against a list of defined beacons. If the User is inside one of the beacon zones the application begins to stream live audio to the device.

### 

### Files

* AppDelegate.swift

##### Controllers 

| File | Purpose |
| --- | --- |
| OEAudioController.swift | Controls the live stream of audio and the cross fading. |
| OECompass.swift | Is responsible for the Compass View, so the rendering of the compass direction and the marker as well as the animations of the view. |
| OEHTTPController.swift | Controls the POST and GET requests to and from the Server. |
| OEGetBeacons.swift | Does the GET from the Server and handles local storage. |

##### Models

| File | Purpose |
| --- | --- |
| OEMapBeacon.swift | Storage for data. Also handles it own distance calculations. |

##### View Controllers 

| File | Purpose |
| --- | --- |

OETabBarViewController.swift
OECustomTabBar.swift
OECustomTabBarItem.swift
OEMapViewController.swift
OECompassViewController.swift
OEInformationViewController.swift

OEIntroViewController.swift

### Requirements

### Screens

### Thanks

