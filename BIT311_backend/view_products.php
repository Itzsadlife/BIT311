<?php
// view_products.php
session_start();
header('Content-Type: application/json'); // Ensure we're sending JSON

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

// Modify this SQL query to join the products table with the reviews table
$sql = "SELECT p.productID, p.productName, p.productDesc, p.productPrice, p.productImg, r.rating, r.reviewDesc 
         FROM products p 
         LEFT JOIN reviews r ON p.productID = r.productID";
$result = $conn->query($sql);

$products = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        // Check if this productID already has an entry in $products
        if (!isset($products[$row['productID']])) {
            $products[$row['productID']] = [
                'productID' => $row['productID'],
                'productName' => $row['productName'],
                'productDesc' => $row['productDesc'],
                'productPrice' => $row['productPrice'],
                'productImg' => $row['productImg'], // Ensure you have a valid URL or path for the product image
                'reviews' => []
            ];
        }
        // If there is a review for this row, add it to the 'reviews' array
        if (!empty($row['rating']) && !empty($row['reviewDesc'])) {
            $products[$row['productID']]['reviews'][] = [
                'rating' => $row['rating'],
                'reviewDesc' => $row['reviewDesc']
            ];
        }
    }
    // Use array_values to reset the keys of the $products array
    echo json_encode(array_values($products));
} else {
    echo json_encode([]);
}

$conn->close();
?>
