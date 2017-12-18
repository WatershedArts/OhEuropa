<?php

    //-------------------------------------------------------------------------------
    // * Error system for return to printer
    //-------------------------------------------------------------------------------
    function errorReport($reason) {
        $data = array('error' => $reason);
        echo json_encode($data);
        exit;
    }

    //--------------------------------------------------------------
    // * Error Reporting to Slack
    //--------------------------------------------------------------
    function postMessageToSlack($type,$file,$line,$message) {
        // This should be defined somewhere
        $slackurl = "https://hooks.slack.com/services/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";

        // Data
        $senddata = array("text" => $type." : ".$file." - Line:".$line." - ".$message);
        $data_string = json_encode($senddata);
    
        $headers = array(
            'content-length:' . strlen($data_string),
            'content-type: application/json',
            'X-Accept: application/json'
        );

        $curl = curl_init();
        curl_setopt($curl,CURLOPT_POST, true);
        curl_setopt($curl,CURLOPT_URL, $slackurl);
        curl_setopt($curl,CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl,CURLOPT_HEADER, false);
        curl_setopt($curl,CURLOPT_HTTPHEADER, $headers);
        curl_setopt($curl,CURLOPT_POSTFIELDS, $data_string);
        curl_setopt($curl,CURLOPT_SSL_VERIFYPEER, true);

        $queryieddata = curl_exec($curl);
        $collated_data = array();

        if (curl_errno($curl)) {
            print_r("Error: " . curl_error($curl));
        }
        else {
            curl_close($curl);
        }
    }

    //--------------------------------------------------------------
    // * Credentials
    //--------------------------------------------------------------
	$dbname = "root";
	$passkey= "root";
	$host = "localhost";
	try {
		$DBH = new PDO('mysql:host=localhost;dbname=oheuropa',$dbname,$passkey);
	} catch (PDOException $e) {
		echo $e->getMessage();
		exit;
	}
?>