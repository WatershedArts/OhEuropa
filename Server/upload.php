<?php

    include('dev_oheuropa.php');
    //----------------------------------------------------------------------------
    // * This is where we upload new data from the Client Application
    //----------------------------------------------------------------------------
    if(isset($_POST['submit']))
    {
        if (!isset($_POST['placeid']) || $_POST['placeid'] == "") {
            $feedback = array( "success" => false, "message" => "No Place ID Specified!" );
            echo json_encode($feedback);
            exit;
        }

        if (!isset($_POST['lng']) || !isset($_POST['lat']) ) {
            $feedback = array( "success" => false, "message" => "No Coordinates Specified!" );
            echo json_encode($feedback);
            exit;
        }

        if (!isset($_POST['placename']) || $_POST['placename'] == "") {
            $feedback = array( "success" => false, "message" => "No Place Name Specified!" );
            echo json_encode($feedback);
            exit;
        }

        if (!isset($_POST['centerradius']) || $_POST['centerradius'] == "") {
            $feedback = array( "success" => false, "message" => "No Center Area Size Specified!" );
            echo json_encode($feedback);
            exit;
        }

        if (!isset($_POST['innerradius']) || $_POST['innerradius'] == "") {
            $feedback = array( "success" => false, "message" => "No Inner Area Size Specified!" );
            echo json_encode($feedback);
            exit;
        }

        if (!isset($_POST['outerradius']) || $_POST['outerradius'] == "") {
            $feedback = array( "success" => false, "message" => "No Outer Area Size Specified!" );
            echo json_encode($feedback);
            exit;
        }

        $placeid = $_POST['placeid'];
        $name = $_POST['placename'];
        $long = $_POST['lng'];
        $lat = $_POST['lat'];
        $center_radius = $_POST['centerradius'];
        $inner_radius = $_POST['innerradius'];
        $outer_radius = $_POST['outerradius'];

        // Insert New Item into Users
        $query = "
            INSERT INTO `places`
            (
                `placeid`,
                `lng`,
                `lat`,
                `name`,
                `centerradius`,
                `innerradius`,
                `outerradius`
            )
            VALUES
            (
                :placeid,
                :lng,
                :lat,
                :name,
                :centerradius,
                :innerradius,
                :outerradius
            )
        ";

        $insert = $DBH->prepare($query);
        $insert->execute(
            array(
                ":placeid" => $placeid,
                ":lng" => $long,
                ":lat" => $lat,
                ":name" => $name,
                ":centerradius" => $center_radius,
                ":innerradius" => $inner_radius,
                ":outerradius" => $outer_radius
            )
        );

        if (!$insert) {
            echo "Error: " .$insert->getMessage();
            exit;
        }

        // var_dump($insert->errorInfo());
        $feedback = array( "success" => true, "message" => "Successfully Uploaded New Beacon ".$placeid);
        echo json_encode($feedback);
        exit;
    }
    else if(isset($_POST['uploadsong']))
    {
        if (!isset($_POST['songname'])) {
            $feedback = array( "success" => false, "message" => "No Song Name Specified!" );
            postMessageToSlack("FAILED","upload.php",__LINE__,"No Song Name Specified!");
            echo json_encode($feedback);
            exit;
        }

        if (!isset($_POST['artistname'])) {
            $feedback = array( "success" => false, "message" => "No Artist's Name Specified!" );
            postMessageToSlack("FAILED","upload.php",__LINE__,"No Artist's Name Specified!");
            echo json_encode($feedback);
            exit;
        }

        if (!isset($_POST['placerecorded'])) {
            $feedback = array( "success" => false, "message" => "No Place Recorded Specified!" );
            postMessageToSlack("FAILED","upload.php",__LINE__,"No Place Recorded Specified!");
            echo json_encode($feedback);
            exit;
        }


        if ($_FILES['file']['size'] <= 0)
        {
            $feedback = array( "success" => false, "message" => "No File Exists!" );
            echo json_encode($feedback);
            postMessageToSlack("FAILED","upload.php",__LINE__,"No File Exists!");
            exit;
        }

        $uploadfile = "./songs/".basename($_FILES['file']['name']);

        if (move_uploaded_file($_FILES['file']['tmp_name'], $uploadfile))
        {
            echo "File is valid, and was successfully uploaded.\n";
            echo "<br>";
            echo "<pre>";
            print_r($_FILES);
            echo "</pre>";

            $conn_id = ftp_connect("olive.radio.co");
            echo $conn_id;
            exit;
            $login_result = ftp_login($conn_id, "s02776f249.u78c97c364", "18555779023b");

			// check connection
			if ((!$conn_id) || (!$login_result)) {
			echo "FTP connection has failed!";
			echo "Attempted to connect to $ftp_server for user $ftp_user_name";
			exit;
			} else {
			echo "Connected to $ftp_server, for user $ftp_user_name";
			}

			// upload the file
			$upload = ftp_put($conn_id, $uploadfile, $_FILES['file']['tmp_name'], FTP_BINARY);

			// check upload status
			if (!$upload) {
			echo "FTP upload has failed!";
			} else {
			echo "Uploaded $source_file to $ftp_server as $destination_file";
			}

			// close the FTP stream
			ftp_close($conn_id);
        }
        else
        {
            echo "Possible file upload attack!\n";
            exit;
        }

        $songname = $_POST['songname'];
        $artistname = $_POST['artistname'];
        $placerecorded = $_POST['placerecorded'];


        // Insert New Item into Users
        $query = "
            INSERT INTO `songs`
            (
                `songname`,
                `artistsname`,
                `recorded`,
                `filelocation`
            )
            VALUES
            (
                :songname,
                :artistsname,
                :recorded,
                :filelocation
            )
        ";

        $insert = $DBH->prepare($query);
        $insert->execute(array(
            ":songname" => $songname,
            ":artistsname" => $artistname,
            ":recorded" => $placerecorded,
            ":filelocation" => $uploadfile
        ));

        if (!$insert) {
            echo "Error: " .$insert->getMessage();
            $feedback = array( "success" => false, "message" => $insert->getMessage() );
            echo json_encode($feedback);
            postMessageToSlack("FAILED","upload.php",__LINE__,$insert->getMessage());
            exit;
        }

        // var_dump($insert->errorInfo());
        $feedback = array( "success" => true, "message" => "Successfully Uploaded Data!" );
        echo json_encode($feedback);
        exit;
    }
