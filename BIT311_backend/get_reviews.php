<?php
// get_reviews.php
// Start the session if it has not already been started
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

header('Content-Type: application/json');

// Ensure the user is logged in
if (!isset($_SESSION['userID'])) {
    echo json_encode(['error' => 'User not logged in']);
    exit;
}

// Database connection details
$servername = "localhost";
$username = "root"; // Your database username
$password = ""; // Your database password
$dbname = "bit311"; // Your database name

// Create database connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    echo json_encode(['error' => 'Connection failed: ' . $conn->connect_error]);
    exit;
}

// Get the productID from the query string
$productID = isset($_GET['productID']) ? $_GET['productID'] : '';

// Fetch reviews from the database
$sql = "SELECT r.reviewID, r.rating, r.reviewDesc, u.name as userName
        FROM reviews r
        INNER JOIN users u ON r.userID = u.userID
        WHERE r.productID = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $productID);
$stmt->execute();
$result = $stmt->get_result();

$reviews = [];

if (!empty($row['rating']) && !empty($row['reviewDesc'])) {
    $reviewData = [
        'rating' => $row['rating'],
        'reviewDesc' => $row['reviewDesc']
    ];
    
    // Check if userName is not null and add it to the review data
    if (!empty($row['name'])) {
        $reviewData['reviewerName'] = $row['name'];
    }

    $products[$row['productID']]['reviews'][] = $reviewData;
}


if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $reviews[] = $row;
    }
}

echo json_encode($reviews);

$stmt->close();
$conn->close();
?>
