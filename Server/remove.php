<?php

    include('/var/sites/o/oheuropa.com/keys/db_includes.php');

    postMessageToSlack("SUCCESS","remove.php",__LINE__,"Deleting Location");

    if (!isset($_POST['placeid'])) {
        $feedback = array( "success" => false, "message" => "No Place ID Specified!" );
        postMessageToSlack("FAILURE","remove.php",__LINE__,"No Place ID Specified!");
        echo json_encode($feedback);
        exit;
    }

        $placeid = $_POST['placeid'];
        
        $query = "
        	DELETE 
	        	FROM `places` 
	        WHERE placeid = :placeid
        ";

        $result = $DBH->prepare($query);
        $result->execute(
        	array(
        		":placeid" => $placeid
        	)
        );

        if (!$result) {
            $feedback = array( "success" => false, "message" => $result->getMessage());
            postMessageToSlack("FAILURE","remove.php",__LINE__,$result->getMessage());
            echo json_encode($feedback);
            exit;
        }

        postMessageToSlack("SUCCESS","remove.php",__LINE__,"Successfully Deleted Data!");
        $feedback = array( "success" => true, "message" => "Successfully Deleted Data!" );
        echo json_encode($feedback);
        exit;
    // }