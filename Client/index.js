var map;
var style = [{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#444444"}]},{"featureType": "administrative.country","elementType": "labels.text","stylers": [{"saturation": "18"},{"lightness": "-55"},{"visibility": "simplified"},{"color": "#4484a1"}]},{"featureType": "landscape","elementType": "all","stylers": [{"color": "#f2f2f2"},{"saturation": "28"},{"lightness": "42"},{"gamma": "2.01"},{"weight": "1"}]},{"featureType": "poi","elementType": "all","stylers": [{"visibility": "off"}]},{"featureType": "road","elementType": "all","stylers": [{"saturation": -100},{"lightness": 45}]},{"featureType": "road.highway","elementType": "all","stylers": [{"visibility": "simplified"}]},{"featureType": "road.arterial","elementType": "labels.icon","stylers": [{"visibility": "off"}]},{"featureType": "transit","elementType": "all","stylers": [{"visibility": "off"}]},{"featureType": "water","elementType": "all","stylers": [{"color": "#aaced9"},{"visibility": "on"}]}];
var contraststyle = [{"featureType":"administrative","elementType":"labels.text.fill","stylers":[{"color":"#444444"}]},{"featureType":"administrative.country","elementType":"geometry.stroke","stylers":[{"visibility":"on"},{"color":"#000000"}]},{"featureType":"landscape","elementType":"all","stylers":[{"color":"#f2f2f2"}]},{"featureType":"poi","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"road","elementType":"all","stylers":[{"saturation":-100},{"lightness":45},{"visibility":"on"},{"hue":"#2980b9"}]},{"featureType":"road","elementType":"geometry","stylers":[{"visibility":"on"},{"color":"#2980b9"},{"saturation":"77"},{"weight":"0.52"}]},{"featureType":"road.highway","elementType":"all","stylers":[{"visibility":"simplified"}]},{"featureType":"road.arterial","elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"featureType":"transit","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"water","elementType":"all","stylers":[{"color":"#293e5b"},{"visibility":"on"}]}];
var beacons = [];

/**
 * Get the Songs from the Server
*/
function getSongs() {
    $.getJSON("https://www.davidhaylock.co.uk/oheuropa/getdata.php?getsongs", function(json){
        $.each(json['data'], function(key,data){
            $("#songlist").append('<tr><td>'+data.id+'</td><td>'+data.songname+'</td><td>'+data.recorded+'</td><td><button style="margin-right:5px;" class="btn btn-primary">Misc</button><button style="margin-right:5px;" class="btn btn-success">Edit</button><button style="margin-right:5px;" class="btn btn-danger">Delete</button></td></tr>');
        });
    });
}

/**
 * Get an Overview from the Server
*/
function getOverview() {
    $.getJSON("https://www.davidhaylock.co.uk/oheuropa/getdata.php?getoverview", function(json) {             
        console.log(json);
        document.getElementById("numberofsongs").innerHTML = json.data['numberofsongs'];
        document.getElementById("numberofmarkers").innerHTML = json.data['numberofmarkers'];
        document.getElementById("numberofusers").innerHTML = json.data['numberofusers'];
        document.getElementById("numberofinteractions").innerHTML = json.data['numberofinteractions'];
    });

    $.getJSON("https://public.radio.co/stations/s02776f249/status",function(data) {
        document.getElementById("currenttrack").innerHTML = "Current Track: " + data.current_track.title;
        document.getElementById("radiostatus").innerHTML = data.status.toUpperCase();
    });
       
    // $.getJSON("https://studio.radio.co/api/v1/stations/s02776f249/tracks?page=1&order=desc&order_by=id",function(data) {
    //     console.log(data);
    // });
}



/**
 * Create New Markers Information
*/
function createMarkerInfoWindow(data) {
    var html = "<div>" +
        "<h3>Place Name: "+data['name']+"</h3>" +
        "<h4>Place ID: "+data['placeid']+"</h4>" +
        "<h4>Radio Plays: "+data['radioplays']+"</h4>" +
        "<h6>Date Created: "+data['datecreated']+"</h6>" +
        "<form method='POST' target='this-iframe' action='https://www.davidhaylock.co.uk/oheuropa/remove.php'>" +
        "<input type='hidden' name='placeid' value='"+data['placeid']+"'>"+
        "<input class='btn btn-danger' type='submit' name='delete' value='Delete'>" +
        "</form>" +
        "</div>"
    return html;
}

/**
 * Get Places from the Server
*/
function getBeacons(map) {
    var image = './marker.png';
    $.getJSON("https://www.davidhaylock.co.uk/oheuropa/getdata.php?getplaces", function(json) {
        $.each(json['data'], function(key,data){
            
            var infoWindowContent = createMarkerInfoWindow(data);
            var infowindow = new google.maps.InfoWindow({
                content: infoWindowContent
            });

            var marker = new google.maps.Marker({
                position: {
                    lat: parseFloat(data['lat']),
                    lng: parseFloat(data['lng'])
                },
                map: map,
                animation: google.maps.Animation.DROP,
                title: data['name'],
                icon: image
            });

            marker.addListener('click',function(){
                infowindow.open(map,marker);
            });
            beacons.push(marker);
        });
    });
}

/**
* Initialize The Map
*/
function initializeMap() {
    
    map = new google.maps.Map(document.getElementById('map'), {
        styles: contraststyle,
        minZone: 4,
        maxZone: 20,
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
    document.getElementById('lat').innerHTML = e.latLng.lat()
    document.getElementById('lng').innerHTML =  e.latLng.lng()

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
    getSongs();
    setInterval(getOverview,(10000*1));
}

/**
 * Clear Beacons
*/
function clearBeacons(map) {
    for(var i = 0; i < beacons.length; i++) {
        beacons[i].setMap(map);
    }
    beacons = [];
}

/**
 * Get Places from the Server
*/


$(document).ready(function(e) {
    $('#mapmanager').load('mapmanager.html',function(){
        console.log("Loaded Map Manager");
        initializeMap();
    });
    // $('#songmanager').load('songmanager.html',function(){
    //     console.log("Loaded Song Manager");
    // });


    $('#sidebar').load('sidebar.html',function(){
        console.log("Loaded Sidebar");
    });    


    $('#sidebar').on('show.bs.modal', function (event) {
        var object = event.relatedTarget;
        var modal = $(this)

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
            console.log("Complete")
        });

        if($(this).hasClass("overviewopen")) {
            $(this).animate({top:217}, 500);
            $(this).addClass("overviewclose");
            $(this).removeClass("overviewopen");
            $(this).children('i:first').removeClass('fa-chevron-down')
            $(this).children('i:first').addClass('fa-chevron-up')
        }
        else if($(this).hasClass("overviewclose")) {
            $(this).animate({top:22}, 500);
            $(this).addClass("overviewopen");
            $(this).removeClass("overviewclose");
            $(this).children('i:first').removeClass('fa-chevron-up')
            $(this).children('i:first').addClass('fa-chevron-down')
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
            clearBeacons(null);
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