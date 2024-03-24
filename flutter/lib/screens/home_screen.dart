import 'package:bit311_assignment/screens/product_details_screen.dart';
import 'package:bit311_assignment/screens/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:bit311_assignment/services/product_service.dart';
import 'AddProductScreen.dart';
import '../services/auth_service.dart';
import 'edit_account_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _products = [];
  List _filteredProducts = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() async {
    try {
      var products = await ProductService().getProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
      });
    } catch (e) {
      // Handle the error. If it's a user not logged in error, you might want to
      // prompt them to log in. For other errors, you might want to display a
      // message or retry the operation.
      print(e.toString());
    }
  }

  void _filterProducts(String query) {
    List filtered = _products.where((product) {
      return product['productName'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredProducts = filtered;
    });
  }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    title: Text('Products'),
    ),
    // Add a floating action button for the admin to add products
    floatingActionButton: FloatingActionButton(
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AddProductScreen()),
    );
    },
    child: Icon(Icons.add),
    ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    'https://www.courts.com.my/media/logo/stores/1/logo.png',
                    width: 100, // Set the width of the logo
                    height: 100, // Set the height of the logo
                  ),
                  Text(
                    'Navigation',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Orders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit), // Choose an appropriate icon
              title: Text('Edit Account'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditAccountScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () async {
                await AuthService().logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Image.network(
            'https://www.courts.com.my/media/logo/stores/1/logo.png',
            width: double.infinity, // Use the full width of the screen
            height: 65, // Set a fixed height for the logo
            fit: BoxFit.cover, // Ensure the logo covers the space
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterProducts('');
                  },
                ),
              ),
              onChanged: (value) {
                _filterProducts(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                var product = _filteredProducts[index];
                return Card(
                  child: ListTile(
                    title: Text(product['productName']),
                    subtitle: Text('\$${product['productPrice']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            product: product,
                            productService: ProductService(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[200], // Set the background color to light gray
    );
  }
}