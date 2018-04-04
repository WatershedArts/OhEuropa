var map;
var style = [{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#444444"}]},{"featureType": "administrative.country","elementType": "labels.text","stylers": [{"saturation": "18"},{"lightness": "-55"},{"visibility": "simplified"},{"color": "#4484a1"}]},{"featureType": "landscape","elementType": "all","stylers": [{"color": "#f2f2f2"},{"saturation": "28"},{"lightness": "42"},{"gamma": "2.01"},{"weight": "1"}]},{"featureType": "poi","elementType": "all","stylers": [{"visibility": "off"}]},{"featureType": "road","elementType": "all","stylers": [{"saturation": -100},{"lightness": 45}]},{"featureType": "road.highway","elementType": "all","stylers": [{"visibility": "simplified"}]},{"featureType": "road.arterial","elementType": "labels.icon","stylers": [{"visibility": "off"}]},{"featureType": "transit","elementType": "all","stylers": [{"visibility": "off"}]},{"featureType": "water","elementType": "all","stylers": [{"color": "#aaced9"},{"visibility": "on"}]}];
var contraststyle = [{"featureType":"administrative","elementType":"labels.text.fill","stylers":[{"color":"#444444"}]},{"featureType":"administrative.country","elementType":"geometry.stroke","stylers":[{"visibility":"on"},{"color":"#000000"}]},{"featureType":"landscape","elementType":"all","stylers":[{"color":"#f2f2f2"}]},{"featureType":"poi","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"road","elementType":"all","stylers":[{"saturation":-100},{"lightness":45},{"visibility":"on"},{"hue":"#2980b9"}]},{"featureType":"road","elementType":"geometry","stylers":[{"visibility":"on"},{"color":"#2980b9"},{"saturation":"77"},{"weight":"0.52"}]},{"featureType":"road.highway","elementType":"all","stylers":[{"visibility":"simplified"}]},{"featureType":"road.arterial","elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"featureType":"transit","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"water","elementType":"all","stylers":[{"color":"#293e5b"},{"visibility":"on"}]}];
var beacons = [];

/**
 * Get an Overview from the Server
*/
function getOverview() {
    $.getJSON("http://oheuropa.com/api/getdata.php?getoverview", function(json) {
        console.log(json);
        document.getElementById("numberofmarkers").innerHTML = json.data.numberofmarkers;
        document.getElementById("numberofusers").innerHTML = json.data.numberofusers;
        document.getElementById("numberofinteractions").innerHTML = json.data.numberofinteractions;
    });

    $.getJSON("https://public.radio.co/stations/s02776f249/status",function(data) {
        document.getElementById("currenttrack").innerHTML = "Current Track: " + data.current_track.title;
        document.getElementById("radiostatus").innerHTML = data.status.toUpperCase();
    });
}

/**
 * Remove Beacon From Map
*/
function removeBeaconFromMap(id) {
    console.log(id);
    for(var i = 0; i < beacons.length; i++ ) {
        if(beacons[i].id == id) {
            console.log(beacons[i]);
            beacons[i].outercircle.setMap(null);
            beacons[i].innercircle.setMap(null);
            beacons[i].circle.setMap(null);
            beacons[i].marker.setMap(null);
        }
    }
}

/**
 * Create New Markers Information
*/
function createMarkerInfoWindow(data) {
    var html = "<div>" +
        "<h3>Place Name: "+data.name+"</h3>" +
        "<h4>Place ID: "+data.placeid+"</h4>" +
        "<h4>Radio Plays: "+data.radioplays+"</h4>" +
        "<h6>Date Created: "+data.datecreated+"</h6>" +
        "<form method='POST' target='this-iframe' action='http://oheuropa.com/api/remove.php'>" +
        "<input type='hidden' name='placeid' value='"+data.placeid+"'>"+
        "<input class='btn btn-danger' onclick=\"removeBeaconFromMap('" + data.placeid + "');\" type='submit' name='delete' value='Delete'>" +
        "</form>" +
        "</div>";
    return html;
}

/**
 * Get Places from the Server
*/
function getBeacons(map) {
    var image = './OhEuropaMarker.png';
    $.getJSON("http://oheuropa.com/api/getdata.php?getplaces", function(json) {
        $.each(json['data'], function(key,data){

            var infoWindowContent = createMarkerInfoWindow(data);
            var infowindow = new google.maps.InfoWindow({
                content: infoWindowContent
            });

            var outercircle = new google.maps.Circle({
                fillColor: '#FF0000',
                fillOpacity: '0.5',
                strokeColor: '#FF0000',
                map: map,
                center: { 'lat': parseFloat(data['lat']), 'lng':parseFloat(data['lng'])},
                radius: parseFloat(data["outerradius"])
            });

            var innercircle = new google.maps.Circle({
                fillColor: '#FFFF00',
                fillOpacity: '0.5',
                strokeColor: '#FFFF00',
                map: map,
                center: { 'lat': parseFloat(data['lat']), 'lng':parseFloat(data['lng'])},
                radius: parseFloat(data["innerradius"])
            });

            var circle = new google.maps.Circle({
                fillColor: '#00FF00',
                fillOpacity: '0.5',
                strokeColor: '#00FF00',
                map: map,
                center: { 'lat': parseFloat(data['lat']), 'lng':parseFloat(data['lng'])},
                radius: parseFloat(data["centerradius"])
            });

            var marker = new google.maps.Marker({
                position: {
                    lat: parseFloat(data['lat']),
                    lng: parseFloat(data['lng'])
                },
                map: map,
                animation: google.maps.Animation.DROP,
                title: data['name']
            });

            marker.addListener('click',function(){
                infowindow.open(map,marker);
            });

            var bData = { id: data['placeid'], outercircle: outercircle, innercircle: innercircle, circle: circle, marker: marker };
            beacons.push(bData);
        });
    });
}

/**
* Initialize The Map
*/
function initializeMap() {

    map = new google.maps.Map(document.getElementById('map'), {
        minZone: 4,
        maxZone: 20,
        mapTypeId: 'satellite',
        center: {
            lat: 55.7727871,
            lng: 9.3665475
        },
        zoom: 4,
        disableDoubleClickZoom: true,
        mapTypeControl:false,
        scaleControl:false,
        streetViewControl: false,
        fullscreenControl: false
    });

    google.maps.event.addListener(map,'dblclick', function(e) {
    document.getElementById('lat').innerHTML = e.latLng.lat();
    document.getElementById('lng').innerHTML =  e.latLng.lng();

    $('#mySchmodal').modal('show',{
        'mode': 0,
        'lon': e.latLng.lng(),
        'lat': e.latLng.lat()
        });
    });


    // Limit the zoom level
    google.maps.event.addListener(map, 'zoom_changed', function () {
        if (map.getZoom() < 4) map.setZoom(4);
    });

    getBeacons(map);
    getOverview();
    setInterval(getOverview,(10000*1));
}

/**
 * Login to Radio.co
*/
function loginToRadio() {
    console.log("Logging Into Radio.co!");
    $.ajax(
        {
            type: "POST",
            url: 'http://oheuropa.com/api/test.php',
            data: { 'login' : 1 },
            success: function(res) {
                console.log(res);
                getRadioPlaylist();
            },
            error: function(err) {
                console.log(err);
            }
        }
    );
}

/**
 * Login to Radio.co
*/
function getRadioPlaylist() {
    console.log("Getting Playlist Information");
    $.ajax(
        {
            type: "GET",
            url: 'https://davidhaylock.co.uk/oheuropa/test.php',
            data: { 'getplaylist' : 1 },
            done: function(res) {
                console.log("Done: " + JSON.stringify(res));
            },
            error: function(res) {
                // Slice the end character from response.
                var returnString = res.responseText.substring(0,res.responseText.length-1);
                var parsedData = JSON.parse(returnString);
                // console.log(parseData.tracks);
                for (var i = 0; i < parsedData.tracks.length; i++) {
                    console.log(parsedData.tracks[i]);
                    var t = "<tr>"+
                    "<td>"+parsedData.tracks[i].id+"</td>"+
                    "<td>"+parsedData.tracks[i].artist+"</td>"+
                    "<td>"+parsedData.tracks[i].title+"</td>"+
                    "</tr>";
                    $('#songlist').append(t);
                }

            }
        }
    );
}

/**
 * Logout of Radio.co
*/
function logoutOfRadio() {
    console.log("Logging Out Of Radio.co!");
    $.ajax(
        {
            type: "POST",
            url: 'http://oheuropa.com/api/test.php',
            data: { 'logout' : 1 },
            success: function(res) {
                console.log(res);
            },
            error: function(err) {
                console.log(err);
            }
        }
    );
}


$(document).ready(function(e) {
    $('#mapmanager').load('mapmanager.html',function(){
        console.log("Loaded Map Manager");
        initializeMap();
    });

    $('#songmanager').load('songmanager.html',function(){
        console.log("Loaded Song Manager");
        loginToRadio();
    });


    $('#sidebar').load('sidebar.html',function(){
        console.log("Loaded Sidebar");
    });


    $('#sidebar').on('show.bs.modal', function (event) {
        var object = event.relatedTarget;
        var modal = $(this);

        switch(object['mode']) {
            case 0:
            {
                $('#hotspot').show();
                $('#song').hide();
                document.getElementById('lng').value = object['lon'];
                document.getElementById('lat').value = object['lat'];
                document.getElementById('titlelabel').innerHTML = "Add New Beacon";
            }
            break;
            case 1:
            {
                $('#hotspot').hide();
                $('#song').show();
                document.getElementById('titlelabel').innerHTML = "Add New Song";
            }
            break;
            default: break;
        }
    });

    $('#song').click(function(){
        $('#mySchmodal').modal('show',{
            'mode': 1
        });
    });

    $("#overviewtrigger").click(function() {
        $("#overview").animate({height:'toggle'},500,function() {
            console.log("Complete");
        });

        if($(this).hasClass("overviewopen")) {
            $(this).animate({top:217}, 500);
            $(this).addClass("overviewclose");
            $(this).removeClass("overviewopen");
            $(this).children('i:first').removeClass('fa-chevron-down');
            $(this).children('i:first').addClass('fa-chevron-up');
        }
        else if($(this).hasClass("overviewclose")) {
            $(this).animate({top:22}, 500);
            $(this).addClass("overviewopen");
            $(this).removeClass("overviewclose");
            $(this).children('i:first').removeClass('fa-chevron-up');
            $(this).children('i:first').addClass('fa-chevron-down');
        }
    });
});


function iframeChanged(obj) {
    var iframecontents = $(obj).contents()[0];
    var info = iframecontents.body.outerText;

    if(!info) {
        console.log("No Action Required!");
        return;
    } else {
        var object = JSON.parse(info);
        console.log(object.success);
        if(object.success === true) {
            $("#mySchmodal").modal('hide');
            getBeacons(map);
            new Notification("Successfully Uploaded Beacon to Server!", {
                body: object.message
              });
        }
        else if(object.success === false) {
            new Notification("Failed to Upload Beacon to Server!", {
                body: object.message
              });
        }
    }
}
