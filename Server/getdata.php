<?php

    if(isset($_GET['getplaces']))
    {
        include('/var/sites/o/oheuropa.com/keys/db_includes.php');

        $query = "
            SELECT
                id,
                name,
                placeid,
                lat,
                lng,
                datecreated,
                centerradius,
                innerradius,
                outerradius,
                (
                    SELECT
                        COUNT(id)
                    FROM `interactions`
                    WHERE zoneid = 'C'
                    AND action = 'enter'
                    AND placeid = places.placeid
                ) as radioplays,
                (
                    SELECT
                        COUNT(id)
                    FROM `interactions`
                    WHERE (zoneid = 'I' OR zoneid = 'O')
                    AND action = 'enter'
                    AND placeid = places.placeid
                ) as nearbys
                FROM `places` as places
            ";

        $results = $DBH->prepare($query);
        $results->execute();

        if (!$results) {
            $feedback = array( "success" => false, "message" => "Error: " . $idsResult->errorCode());
            postMessageToSlack("FAILURE","getdata.php",__LINE__,"Error: " . $idsResult->errorCode());
            echo json_encode($feedback);
            exit;
        }

        if ($results->rowCount() == 0) {
            $feedback = array( "success" => false, "message" => "Error: No Rows!");
            postMessageToSlack("FAILURE","getdata.php",__LINE__,"Error: No Rows!");
            echo json_encode($feedback);
            exit;
        }

        $places = array();
        while ($row = $results->fetch(PDO::FETCH_ASSOC)) {
            $places[] = $row;
        }

        // header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
        // header("Last-Modified: " . gmdate( "D, d M Y H:i:s" ) . "GMT");
        // header("Cache-Control: no-cache, must-revalidate");
        // header("Pragma: no-cache");
        // header("Access-Control-Allow-Origin: *");
        header("Content-type: application/json");
        
        $feedback = array( "success" => true, "data" => $places );
        postMessageToSlack("SUCCESS","getdata.php",__LINE__, "Found ".count($places)." Beacons");
        echo json_encode($feedback);
        exit;
    }
    else if(isset($_GET['getsongs'])) {

        include('/var/sites/o/oheuropa.com/keys/db_includes.php');

        // postMessageToSlack("ATTEMPT","getdata.php",__LINE__,"Attempting to Get Songs");

        $query = "SELECT * FROM `songs`";
        $results = $DBH->prepare($query);
        $results->execute();

        if (!$results) {
            $feedback = array( "success" => false, "message" => "Error: " . $idsResult->errorCode());
            postMessageToSlack("FAILURE","getdata.php",__LINE__,"Error: " . $idsResult->errorCode());
            echo json_encode($feedback);
            exit;
        }

        if ($results->rowCount() == 0) {
            $feedback = array( "success" => false, "message" => "Error: No Rows!");
            postMessageToSlack("FAILURE","getdata.php",__LINE__,"Error: No Rows!");
            echo json_encode($feedback);
            exit;
        }

        $songs = array();
        while ($row = $results->fetch(PDO::FETCH_ASSOC)) {
            $songs[] = $row;
        }

        header("Content-type: application/json");

        $feedback = array( "success" => true, "numberofsongs" => count($songs) , "data" => $songs );
        echo json_encode($feedback);
        exit;
    }
    else if(isset($_GET['getoverview'])) {

        include('/var/sites/o/oheuropa.com/keys/db_includes.php');

        $query = "
            SELECT
                (SELECT COUNT(id) FROM `users`) as numberofusers,
                (SELECT COUNT(id) FROM `places`) as numberofmarkers,
                (SELECT COUNT(id) FROM `interactions`) as numberofinteractions
        ";
        $results = $DBH->prepare($query);
        $results->execute();

        if (!$results) {
            $feedback = array( "success" => false, "message" => "Error: " . $idsResult->errorCode());
            postMessageToSlack("FAILURE","getdata.php",__LINE__,"Error: " . $idsResult->errorCode());
            echo json_encode($feedback);
            exit;
        }

        if ($results->rowCount() == 0) {
            $feedback = array( "success" => false, "message" => "Error: No Rows!");
            postMessageToSlack("FAILURE","getdata.php",__LINE__,"Error: No Rows!");
            echo json_encode($feedback);
            exit;
        }

        $overview = $results->fetch(PDO::FETCH_OBJ);

        $query = "
            SELECT
                COUNT( interactions.id ) AS radioplays,
                interactions.placeid,
                places.name,
                places.lat,
                places.lng,
                places.datecreated
            FROM  `interactions` AS interactions
            INNER JOIN  `places` AS places
            ON interactions.placeid = places.placeid
            WHERE zoneid =  'C'
                AND ACTION =  'enter'
            GROUP BY placeid
        ";
        $results = $DBH->prepare($query);
        $results->execute();

        if (!$results) {
            $feedback = array( "success" => false, "message" => "Error: " . $idsResult->errorCode());
            postMessageToSlack("FAILURE","getdata.php",__LINE__,"Error: " . $idsResult->errorCode());
            echo json_encode($feedback);
            exit;
        }

        $places = "";
        if ($results->rowCount() == 0) {
            // postMessageToSlack("FAILURE","getdata.php",__LINE__,"Error: No Rows!");
            $places = "No Data";

        } else {
            $places = array();
            while ($row = $results->fetch(PDO::FETCH_ASSOC)) {
                $places[] = $row;
            }
        }

        header("Content-type: application/json");
        // header("Access-Control-Allow-Origin: *");
        $feedback = array( "success" => true, "data" => $overview, "placedata" => $places );
        echo json_encode($feedback);
        exit;
    }
