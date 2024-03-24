<?php
// purchase_page.php
session_start();
if (!isset($_SESSION['userID'])) {
    header("Location: login.php");
    exit;
}

if (isset($_GET['productID'])) {
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

    // Get product details from the database
    $productID = $_GET['productID'];
    $sql = "SELECT productName, productPrice FROM products WHERE productID = '$productID'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $productName = $row['productName'];
        $productPrice = $row['productPrice'];

        echo "<h1>Purchase Product</h1>";
        echo "Product Name: " . $productName . "<br>";
        echo "Price: $" . $productPrice . "<br>";

        // Form for selecting quantity and making the purchase
        echo "<form action='purchase_product.php' method='post'>";
        echo "<input type='hidden' name='productID' value='" . $productID . "'>";
        echo "<label for='quantity'>Quantity:</label>";
        echo "<input type='number' name='quantity' value='1' min='1'><br><br>";
        echo "<button type='submit'>Buy Now</button>";
        echo "</form>";
    } else {
        echo "Product not found.";
    }

    $conn->close();
} else {
    echo "No product selected.";
}
?>
