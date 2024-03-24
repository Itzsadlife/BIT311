<?php
session_start();
header('Content-Type: application/json'); // Set the header to return JSON

if (!isset($_SESSION['userID'])) {
    echo json_encode(['error' => 'User not logged in']);
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
    echo json_encode(['error' => $conn->connect_error]);
    exit;
}

// Get userID (in a real application, userID should be obtained from session or login system)
$userID = $_SESSION['userID'];

// Fetch orders from the database
$sql = "INSERT INTO `products` (`productID`, `productName`, `productDesc`, `productPrice`, `productImg`) VALUES (NULL, '', '', '', '')";
$result = $conn->query($sql);

$orders = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $orders[] = [
            'orderID' => $row['orderID'],
            'productName' => $row['productName'],
            'amount' => $row['amount'],
            'productID' => $row['productID'],
            'submitReviewUrl' => 'submit_review.php?productID=' . $row['productID'] // You can use this URL in your app to navigate to the review submission screen
        ];
    }
}

echo json_encode($orders);

$conn->close();
?>
