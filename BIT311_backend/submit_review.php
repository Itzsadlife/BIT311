<?php
session_start();
header('Content-Type: application/json'); // This will specify that the response is JSON

if (!isset($_SESSION['userID'])) {
    echo json_encode(['success' => false, 'message' => 'User not logged in']);
    exit;
}

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
        echo json_encode(['success' => false, 'message' => $conn->connect_error]);
        exit;
    }

    // Get user input
    $userID = $_SESSION['userID'];
    $productID = $_POST['productID'];
    $rating = $_POST['rating'];
    $reviewDesc = $_POST['reviewDesc']; // Ensure the POST key here matches the key sent from Flutter

    // Insert review into the database using prepared statement
    $stmt = $conn->prepare("INSERT INTO reviews (userID, productID, rating, reviewDesc) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("iiis", $userID, $productID, $rating, $reviewDesc);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Review submitted successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => $stmt->error]);
    }

    $stmt->close();
    $conn->close();
}
?>
