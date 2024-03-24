<?php
session_start();
header('Content-Type: application/json'); // Specify the correct content type for JSON

$response = array();

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Connect to the database
    $servername = "localhost";
    $username = "root";
    $password = "";
    $dbname = "bit311";

    // Create connection
    $conn = new mysqli($servername, $username, $password, $dbname);

    // Check connection
    if ($conn->connect_error) {
        $response['error'] = "Connection failed: " . $conn->connect_error;
        echo json_encode($response);
        exit;
    }

    // Sanitize user input to prevent SQL injection
    $email = $conn->real_escape_string($_POST['email']);
    $password = $conn->real_escape_string($_POST['password']);

    // Create a hash of the password, if you are storing hashed passwords
    // $password = md5($password); // You should use a stronger hash function like password_hash() in production

    // Check if the user exists in the database
    $sql = "SELECT userID, name FROM users WHERE email = '$email' AND password = '$password'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $_SESSION['userID'] = $row['userID'];
        $_SESSION['name'] = $row['name'];
        $response['status'] = 'success';
        $response['userID'] = $row['userID'];
        $response['name'] = $row['name'];
    } else {
        $response['status'] = 'failure';
        $response['error'] = "Invalid email or password.";
    }

    $conn->close();
    echo json_encode($response);
    exit;
}
?>
