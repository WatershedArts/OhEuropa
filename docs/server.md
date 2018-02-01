## Oh Europa Server

### Overview

The server system is fairly basic. 
It contains three unique databases.

* Places
* Interactions
* Users

### Files

* db_includes.php
* getdata.php
* remove.php
* upload.php
* userinteraction.php

### Calls

| Type | File | Call | Parameters |
| --- | --- | --- | --- |
| **GET** | getdata.php | getoverview | None |
| **GET** | getdata.php | getplaces | None |
| **POST** | upload.php | submit | lat,lng, placeid,placename,centerradius,innerradius,outerradius|
| **POST** | userinteraction.php | newuser | userid |
| **POST** | userinteraction.php | newevent | userid,placeid,zoneid,action | 
| **POST** | remove.php | delete | placeid |

### Database Creation

#### Places

```
CREATE TABLE IF NOT EXISTS `places` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `placeid` varchar(255) NOT NULL,
  `lat` varchar(100) NOT NULL,
  `lng` varchar(100) NOT NULL,
  `centerradius` varchar(12) NOT NULL,
  `innerradius` varchar(12) NOT NULL,
  `outerradius` varchar(12) NOT NULL,
  `datecreated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
```

#### Interactions

```
CREATE TABLE IF NOT EXISTS `interactions` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `placeid` varchar(255) NOT NULL,
  `zoneid` varchar(255) NOT NULL,
  `action` varchar(100) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `userid` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
```

#### Users 

```
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL,
  `userid` varchar(255) NOT NULL,
  `dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

