
//----------------------------------------------------
// *
// * Variables and Constants
//----------------------------------------------------

// Define Host 
const HOST = "https://www.davidhaylock.co.uk/oheuropa/";

// Append the URL with HOST URL
const UPLOAD_ID_URL = HOST+"userinteraction.php?newuser=1";
const UPLOAD_EVENT = HOST+"userinteraction.php?newevent=1";
const GET_PLACES = HOST+"getdata.php?getplaces=1";
const MAX_DISTANCE_FOR_MARKERS = 20; // Km

const RADIO_STATION_URL = "https://streams.radio.co/s02776f249/listen";

var audioplayer;
var compassHeading;
var heading = 0;
var options = { frequency: 500 };  // Update every 3 seconds

var watchID = navigator.compass.watchHeading(onCompassSuccess, onCompassError, options);

var canvas = document.getElementById("compass");
var context = canvas.getContext("2d");
context.scale(2,2);
var centerX = canvas.width/2;
var centerY = canvas.height/2;
var radius =  80;
var compassImage = null;

var tmpMarkers = [];
    
var colours = ["#2ecc71","#3498db","#9b59b6","#34495e","#16a085","#27ae60","#2980b9","#8e44ad","#2c3e50","#f1c40f","#e67e22","#e74c3c","#ecf0f1","#95a5a6","#f39c12","#d35400","#c0392b","#bdc3c7","#7f8c8d"];

//----------------------------------------------------
// *
// * Canvas Context
//----------------------------------------------------

/**
  * Clear the Canvas Element
  * make it bigger than the area 
  * as app furnace expands the element
*/
function clear() {
    context.fillStyle="white";
    context.fillRect(0,0,500,500);
}

/**
  * Draw Marker
  * @param markerinfo (object) 
  * @param colour (color)
*/
function drawMarker(markerinfo,colour) {
    var width = 25;
    this.ang = markerinfo.bearing;

    var ang = degreesToRadians(this.ang);
    context.setTransform(1,0,0,1,centerX,centerY);
    context.rotate(ang);
    context.beginPath();
    context.moveTo(-width, radius + 5);
    context.lineTo(0, radius + 20);
    context.lineTo(width, radius + 5);
    context.closePath();
    context.fillStyle = colour;
    context.fill();
    
}

/**
  * Draw Compass
  * @param markers (array) 
*/
function drawCompass(markers,currentHeading) {
    context.setTransform(1,0,0,1,-centerX/2,-centerY/2);
    clear();
    
    context.setTransform(1,0,0,1,centerX,centerY);
    context.rotate(0 * (Math.PI / 180));
    context.beginPath();
    context.arc(0, 0, radius, 0, Math.PI * 2, true);
    context.closePath();
    context.fillStyle = "#34495e";
    context.fill();
    context.lineWidth = 1;
    context.strokeStyle = '#000';
    context.stroke();
    
    context.stroke();
    context.font = "15px Cabin";
    context.fillStyle = '#FFF';
    context.fillText("N",-7,-43);
    context.fillText("S",-7,57);
    context.fillText("W",-57,7);
    context.fillText("E",50,7);
    
    
    markers.forEach(function(marker,index){
        drawMarker(marker,colours[index]);
    });
}


//----------------------------------------------------
// *
// * Location and Marker Functions
//----------------------------------------------------

/**
  * Convert Degrees to Radians
  * @param deg (number) 
*/
function degreesToRadians(deg) {
    this.radians = (deg-180) * Math.PI / 180;
    return this.radians;
}

/**
  * Get Bearing
  * @param currentPoint (object) 
  * @param futurePoint (object) 
  * Calculate the Forward Azimuth
*/
function forwardAzimuth(currentPoint,futurePoint) {
    var lat1 = (Math.PI/180) * currentPoint.latitude;
    var lon1 = (Math.PI/180) * currentPoint.longitude;
    var lat2 = (Math.PI/180) * futurePoint.latitude;
    var lon2 = (Math.PI/180) * futurePoint.longitude;
    
    // Delta Calculations
    var deltaLat = lat2 - lat1;
    var deltaLon = lon2 - lon1;
    
    // Calculate the Theta 
    var theta = Math.atan2(
            Math.sin(deltaLon) * Math.cos(lat2),
            Math.cos(lat1)*Math.sin(lat2)-Math.sin(lat1)*Math.cos(lat2)*Math.cos(deltaLon)
        );
        
    var bearing = theta * ( (180 / Math.PI ) );
    bearing = ( bearing > 0 ? bearing : (360 + bearing));
    return bearing;
}

/**
  * Check for Nearby Markers
  * @return markers (object)
*/
function checkNearbyMarkers() {
    var latlng = af.locationSensor.getLastLocation();
    
    const myPos = {
        latitude: latlng.y,
        longitude: latlng.x
    };
    
    var i = 0;
    for(i = 0; i < tmpMarkers.length; i++) {
        tmpMarkers[i].bearing = forwardAzimuth(myPos,{latitude:tmpMarkers[i].lat , longitude: tmpMarkers[i].lng});
        tmpMarkers[i].distance = haversine(myPos,{ latitude: tmpMarkers[i].lat, longitude: tmpMarkers[i].lng },{ unit: 'km' });
    }
    
    var index = Math.min.apply(Math,tmpMarkers.map(function(o) {return o.distance;}));
    var newIndex = tmpMarkers.findIndex(x => x.distance==index);
    if(newIndex !== -1) { 
        ui.nearestmarkername.text(tmpMarkers[newIndex].name); 
        ui.nearestmarkerdistance.text(index.toFixed(2) + "km"); 
    }
}

/**
  * Successful Compass Event 
  * @return heading (number)
*/
function onCompassSuccess(aheading) {
  heading = aheading.magneticHeading;
}

/**
  * Error Compass Event 
  * @return heading (number)
*/
function onCompassError(compassError) {
    log('Compass error: ' + compassError.code);
}

//----------------------------------------------------
// *
// * Location and Marker Functions
//----------------------------------------------------

/**
  * Upload New User 
  * @param id (string)
  * 
  * Uploads the phone's randomely generated unique 
  * id token. This is mainly used for determining 
  * which user has been to which location.
  * This in no way stores any information about 
  * anyones phone. The id tag is faux.
*/
function uploadNewUserID(id) {
    $.ajax({
        url: UPLOAD_ID_URL,
        data: { 'userid': id },
        method: "POST",
        crossDomain: true,
        success: onUploadSuccess,
        error:function(jqXHR, textStatus,errorThrown) {
            log("Something is wrong " + textStatus + " " + errorThrown);
            log(jqXHR.status);
        }
    });
}

/**
  * Upload User Interaction 
  * @param type (string)
  * @param place (string)
  * 
  * Uploads event to the server.
*/
function uploadInteraction(type,place) {
    // Tell the console which zone
    //log(type + " " + place);
    
    // Get the Name of the Zone
    var placeid = place.split("|")[0];
    var zoneid = place.split("|")[1];
   
    if((type === "enter") || (type === "exit")) {
        //log("Good Command");
    }
    else {
        log("Invalid Upload Command");
        return 0;
    }
    
    // Data struct to be sent to the server
    var data = {
        'userid': af.storedData.userid,
        'placeid': placeid,
        'zoneid': zoneid,
        'action': type
    };
    
    $.ajax({
        url: UPLOAD_EVENT,
        data: data,
        method: "POST",
        crossDomain: true,
        success: onUploadSuccess,
        error:function(jqXHR, textStatus,errorThrown) {
            log("Something is wrong " + textStatus + " " + errorThrown);
            log(jqXHR.status);
        }
    });
    
    if((zoneid === "L") || (zoneid === "R")) {
        af.audioChannel.resume(0);
    }
    else if(zoneid === "C" && type === "enter") {
        af.audioChannel.pause(0);
        audioplayer.src = RADIO_STATION_URL;
        audioplayer.play();
    }
    else if(zoneid === "C" && type === "exit") {
        audioplayer.pause();
        audioplayer.src = null;
    }
    
    if(type === "exit") {
        af.audioChannel.pause(0);
    }
}

function playStream()
{
    
    audioplayer.pause();
    audioplayer.src = null;
    
    
    audioplayer.src = RADIO_STATION_URL;
    audioplayer.play();
}

/**
  * Upload Event Listeners 
*/
function onUploadFail(message) {
    log(JSON.stringify(message));
}

function onUploadSuccess(data) {
   log(JSON.stringify(data));
}

/**
  * Generate New User ID 
  * @param length (number)
  * 
  * Uploads event to the server.
*/
function makeNewUserID(length) {
    var id = "";
    var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    
    for(var i = 0; i < length; i++) 
    {
        id += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return id;
}

//----------------------------------------------------------------------------
// * Init
//----------------------------------------------------------------------------
function init() {
   
    //af.storedData = null;
    //af.saveStoredData();
    if(af.storedData === null) 
    {
        af.storedData = {};
        log("Creating New User ID");
        af.storedData.userid = makeNewUserID(15);
        log("New User ID " + af.storedData.userid);
        uploadNewUserID(af.storedData.userid);
        
        af.saveStoredData();
    } else {
        log("User ID " + af.storedData.userid);
    }
    
    $.getJSON(GET_PLACES,function(results){ 
       log(results);
         $.each(results.data, 
            function(key, data){
                var newmarker = {
                    'lat': data.lat,
                    'lng': data.lng, 
                    'radius': data.areasize, 
                    'name': data.name,
                    'placeid': data.placeid,
                    'zonenumber': data.zonenumber,
                    'bearing': 0,
                    'distance': null
            };
            tmpMarkers.push(newmarker);
            makeBox(newmarker);
        });
    });
        
    
    af.geoFeatures.setVisible(true);
    af.audioChannel.init(2);
    af.audioChannel.setCrossFadeTimes(0, 3, 3);
    af.audioChannel.add(0,"./audio/radio.mp3",
        {
            volume: 0.5,
            loop:true,
            alwaysFadeIn: true
        }
    );
    af.audioChannel.pause(0);
    
    audioplayer = document.getElementById('audioplayer');   
}

//----------------------------------------------------------------------------
// * Make Zone Box 
// * params data : data from server
//----------------------------------------------------------------------------
function makeBox(data) {
    // As AF gives us this for free get the bounding box from the point
    var point = new af.Point("new", new af.Coord(data.lng, data.lat), data.radius);

    var centercoords = point.getBounds();
    var zone = new af.Zone(data.placeid+"|C", [
        new af.Coord(centercoords.left, centercoords.top),
        new af.Coord(centercoords.right, centercoords.top),
        new af.Coord(centercoords.right, centercoords.bottom),
        new af.Coord(centercoords.left, centercoords.bottom)
    ]);
    
    zone.setShapeVisible(true);
    zone.setMovein(function() { uploadInteraction("enter",data.placeid+"|C"); });
    zone.setMoveout(function() { uploadInteraction("exit",data.placeid+"|C"); });
    zone.setMarkerVisible(true);
    zone.setMarkerImage("./assets/marker2.png",30,30,"center","center",true);
    af.geoFeatures.addFeature(zone);
       
    var previousBounds = centercoords;
    /*for(var i = 1; i < parseInt(data.zonenumber); i++) 
    {
        if(i <= 1) {
            log("I = 0 Zone " + JSON.stringify(centercoords));    
        }
        else {
            var outerpoint = new af.Point("out", 
                                          new af.Coord(data.lng, data.lat), 
                                          parseFloat(data.radius*parseInt(i))
                                          );
                                          
            var innerpoint = new af.Point("in", 
                                          new af.Coord(data.lng, data.lat), 
                                          parseFloat(data.radius*parseInt(i-1))
                                          );
            
            var outerzoneright = new af.Zone(
                data.placeid+"|R"+i,
                [
                    new af.Coord(outerpoint.right,outerpoint.top),
                    new af.Coord(data.lng,outerpoint.top),
                    new af.Coord(data.lng,innerpoint.top),
                    new af.Coord(innerpoint.right,innerpoint.top),
                    new af.Coord(innerpoint.right,innerpoint.bottom),
                    new af.Coord(data.lng,innerpoint.bottom),
                    new af.Coord(data.lng,outerpoint.bottom),
                    new af.Coord(outerpoint.right,outerpoint.bottom)
                ]
            );
    
        
            outerzoneright.setShapeVisible(true);
            outerzoneright.setMovein(function() { uploadInteraction("enter"); });
            outerzoneright.setMoveout(function() { uploadInteraction("exit"); });
            outerzoneright.setMarkerVisible(false);
            af.geoFeatures.addFeature(outerzoneright);
            log("I = " + i + "\n Inner Zone " + JSON.stringify(innerpoint.getBounds())+ "\n Outer Zone " + JSON.stringify(outerpoint.getBounds()));
        }
    }*/
        point = new af.Point("new", new af.Coord(data.lng, data.lat), parseFloat(data.radius*parseInt(2)));
        var cc = point.getBounds();
        
        
        /*
            Should form this sort of shape : )
             _______ ______
            |    __||__   |
            |   |      |  |
            |   |__  __|  |
            |______||_____|
        */
        
        var outerzoneleft = new af.Zone(
            data.placeid+"|L",
            [
                new af.Coord(cc.left,cc.top), // Top Left 
                new af.Coord(data.lng,cc.top), // Top Middle
                new af.Coord(data.lng,previousBounds.top), // Center Inner Top
                new af.Coord(previousBounds.left,previousBounds.top), // Inner Left
                new af.Coord(previousBounds.left,previousBounds.bottom), // Inner Bottom Left
                new af.Coord(data.lng,previousBounds.bottom), // Inner Center Bottom
                new af.Coord(data.lng,cc.bottom), // 
                new af.Coord(cc.left,cc.bottom)
            ]
        );
        
        var outerzoneright = new af.Zone(
            data.placeid+"|R",
            [
                new af.Coord(cc.right,cc.top),
                new af.Coord(data.lng,cc.top),
                new af.Coord(data.lng,previousBounds.top),
                new af.Coord(previousBounds.right,previousBounds.top),
                new af.Coord(previousBounds.right,previousBounds.bottom),
                new af.Coord(data.lng,previousBounds.bottom),
                new af.Coord(data.lng,cc.bottom),
                new af.Coord(cc.right,cc.bottom)
            ]
        );
    
        outerzoneleft.setShapeVisible(true);
        outerzoneright.setShapeVisible(true);
        outerzoneright.setMovein(function() { uploadInteraction("enter",data.placeid+"|R"); });
        outerzoneleft.setMovein(function() { uploadInteraction("enter",data.placeid+"|L"); });
        
        outerzoneright.setMoveout(function() { uploadInteraction("exit",data.placeid+"|R"); });
        outerzoneleft.setMoveout(function() { uploadInteraction("exit",data.placeid+"|L"); });
        
        outerzoneleft.setMarkerVisible(false);
        outerzoneright.setMarkerVisible(false);
        
        af.geoFeatures.addFeature(outerzoneleft);
        af.geoFeatures.addFeature(outerzoneright);
        
        previousBounds = cc;
    //}
    
    //var features = af.geoFeatures.getFeatures();
    //for (var i=0; i<features.length; i++) {
    //    features[i].setMarkerImage("./assets/marker.png",48,48,"center","bottom");
    //}
}

init();

setInterval(function() { checkNearbyMarkers(); },40);
setInterval(function() { drawCompass(tmpMarkers,heading); },10);

var haversine = (function () {
  var RADII = {
    km:    6371,
    mile:  3960,
    meter: 6371000,
    nmi:   3440
  }

  // convert to radians
  var toRad = function (num) {
    return num * Math.PI / 180
  }

  // convert coordinates to standard format based on the passed format option
  var convertCoordinates = function (format, coordinates) {
    switch (format) {
    case '[lat,lon]':
      return { latitude: coordinates[0], longitude: coordinates[1] }
    case '[lon,lat]':
      return { latitude: coordinates[1], longitude: coordinates[0] }
    case '{lon,lat}':
      return { latitude: coordinates.lat, longitude: coordinates.lon }
    case 'geojson':
      return { latitude: coordinates.geometry.coordinates[1], longitude: coordinates.geometry.coordinates[0] }
    default:
      return coordinates
    }
  }

  return function haversine (startCoordinates, endCoordinates, options) {
    options   = options || {}

    var R = options.unit in RADII
      ? RADII[options.unit]
      : RADII.km

    var start = convertCoordinates(options.format, startCoordinates)
    var end = convertCoordinates(options.format, endCoordinates)

    var dLat = toRad(end.latitude - start.latitude)
    var dLon = toRad(end.longitude - start.longitude)
    var lat1 = toRad(start.latitude)
    var lat2 = toRad(end.latitude)

    var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2)
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))

    if (options.threshold) {
      return options.threshold > (R * c)
    }

    return R * c
  }

})()


