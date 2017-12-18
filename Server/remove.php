<?php

    if(isset($_POST['delete'])) {
        include('dev_oheuropa.php');
        if (!isset($_POST['placeid'])) {
            $feedback = array( "success" => false, "message" => "No Place ID Specified!" );
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
            echo json_encode($feedback);
            exit;
        }

        $feedback = array( "success" => true, "message" => "Successfully Deleted Data!" );
        echo json_encode($feedback);
        exit;
    }