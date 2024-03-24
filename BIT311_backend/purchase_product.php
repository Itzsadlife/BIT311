<?php
// purchase_product.php
session_start();
if (!isset($_SESSION['userID'])) {
    header("Location: login.php");
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
        die("Connection failed: " . $conn->connect_error);
    }

    // Get productID and quantity from the form submission
    $productID = $_POST['productID'];
    $quantity = $_POST['quantity'];
    $userID = $_SESSION['userID']; // Get the user ID from the session

    // Fetch product price from database
    $sql = "SELECT productPrice FROM products WHERE productID = '$productID'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $productPrice = $row['productPrice'];
        $totalPrice = $quantity * $productPrice;

        // Insert order into the database
        $orderSql = "INSERT INTO orders (userID, productID, amount) VALUES (?, ?, ?)";
        $stmt = $conn->prepare($orderSql);
        $stmt->bind_param("iii", $userID, $productID, $quantity);
        
        // At the end of your PHP script
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => "Order placed successfully!"]);
        } else {
            echo json_encode(['success' => false, 'message' => "Error placing order: " . $conn->error]);
        }
        exit;  // Make sure to stop the script execution after sending the response


        $stmt->close();

        // Here you would integrate with PayPal to handle payment
        // For now, we'll just display a message
        echo "<p>Total price for $quantity units: $" . $totalPrice . "</p>";
        // Include a link to proceed to payment or further instructions
        echo "<br><a href='index.html'>Back to Home</a>";
    } else {
        echo "Product not found";
    }

    $conn->close();
} else {
    echo json_encode(['success' => false, 'message' => "Please select a product and quantity."]);
}
?>
