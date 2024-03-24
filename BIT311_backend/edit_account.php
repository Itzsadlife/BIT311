<?php
session_start();
$response = array('success' => false, 'message' => '');

if (!isset($_SESSION['userID'])) {
    $response['message'] = 'User not logged in';
    echo json_encode($response);
    exit;
}

// Connect to the database
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "bit311";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    $response['message'] = "Connection failed: " . $conn->connect_error;
    echo json_encode($response);
    exit;
}

$userID = $_SESSION['userID'];

// Update user information
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $newEmail = $_POST['email'];
    $newPassword = $_POST['password'];

    $updateSql = "UPDATE users SET email = ?, password = ? WHERE userID = ?";
    
    // Prepare and bind
    $stmt = $conn->prepare($updateSql);
    $stmt->bind_param("ssi", $newEmail, $newPassword, $userID);

    if ($stmt->execute()) {
        $response['success'] = true;
        $response['message'] = "Account updated successfully!";
    } else {
        $response['message'] = "Error updating account: " . $stmt->error;
    }

    $stmt->close();
} else {
    // Fetch user information for GET request
    $sql = "SELECT email, password FROM users WHERE userID = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $userID);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $response['email'] = $row['email'];
        // It's not a good practice to send passwords back, even if they are hashed
        // $response['password'] = $row['password'];
        $response['success'] = true;
    } else {
        $response['message'] = "User not found";
    }
    $stmt->close();
}

$conn->close();
echo json_encode($response);
?>
