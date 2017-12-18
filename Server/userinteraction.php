<?php
    header("Expires: Mon, 26 Jul 1997 05:00:00 GMT"); 
    header("Last-Modified: " . gmdate( "D, d M Y H:i:s" ) . "GMT"); 
    header("Cache-Control: no-cache, must-revalidate"); 
    header("Pragma: no-cache");
    header("Content-type: application/json");
    header("Access-Control-Allow-Origin: *");
    include('dev_oheuropa.php');
    //----------------------------------------------------------------------------
    // * This is where we upload new data from the Client Application
    //----------------------------------------------------------------------------
    if(isset($_GET['newuser'])) {
        if (!isset($_GET['userid'])) {
            $feedback = array( "success" => false, "message" => "No User Id Attached!" );
            postMessageToSlack("FAILURE","userinteration.php",__LINE__,"No User Id Attached!");
            echo json_encode($feedback);
            exit;
        }

        $userid = $_GET['userid'];
      
        // Insert New Item into Users
        $query = "INSERT INTO `users` ( `userid` ) VALUES( :userid )";
        $insert = $DBH->prepare($query);
        $insert->execute(array(":userid" => $userid));

        if (!$insert) {
            $feedback = array( "success" => false, "message" => $insert->getMessage());
            postMessageToSlack("FAILURE","userinteration.php",__LINE__,$insert->getMessage());
            echo json_encode($feedback);
            exit;
        }

        // Encode feedback as JSON & output:
        $feedback = array( "success" => true, "message" => "Thanks $userid is now added to the database" );
        postMessageToSlack("SUCESSS","userinteration.php",__LINE__,"$userid is now added to the database");
        echo json_encode($feedback);
        exit;
    }
    //----------------------------------------------------------------------------
    // * This is where we tell the server a user has performed an action
    //----------------------------------------------------------------------------
    else if(isset($_GET['newevent'])) {
        if (!isset($_GET['userid'])) {
            $feedback = array( "success" => false, "message" => "No User Id Attached!" );
            echo json_encode($feedback);
            exit;
        }

        if (!isset($_GET['placeid'])) {
            $feedback = array( "success" => false, "message" => "No Place ID!" );
            echo json_encode($feedback);
            exit;
        }

        if (!isset($_GET['zoneid'])) {
            $feedback = array( "success" => false, "message" => "No Zone ID!" );
            echo json_encode($feedback);
            exit;
        }
        
        if (!isset($_GET['action'])) {
            $feedback = array( "success" => false, "message" => "No Action!" );
            echo json_encode($feedback);
            exit;
        }

        $userid = $_GET['userid'];
        $placeid = $_GET['placeid'];
        $zoneid = $_GET['zoneid'];
        $action = $_GET['action'];
      
        // Insert New Item into Users
        $query = "INSERT INTO `interactions` 
                ( 
                    `userid`, 
                    `placeid`,
                    `zoneid`,
                    `action`
                ) 
                VALUES( 
                    :userid, 
                    :placeid,
                    :zoneid,
                    :action
                )";

        $insert = $DBH->prepare($query);
        $insert->execute(
            array(
                ":userid" => $userid,
                ":placeid" => $placeid,
                ":zoneid" => $zoneid,
                ":action" => $action
            )
        );

        if (!$insert) {
            $feedback = array( "success" => false, "message" => $insert->getMessage());
            echo json_encode($feedback);
            exit;
        }

        $feedback = array( "success" => true, "message" => "Success" );
        echo json_encode($feedback);
        exit;
    }

