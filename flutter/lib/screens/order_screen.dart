import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import 'submit_review_screen.dart'; // Make sure to import the SubmitReviewScreen

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() async {
    var cookie = await AuthService().getCookie(); // Get the saved cookie from SharedPreferences

    var url = Uri.parse('http://10.150.185.200/BIT311_backend/view_orders.php');
    var response = await http.get(url, headers: {
      "Accept": "application/json",
      "Cookie": cookie ?? "", // Include the cookie in the header
    });

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        var orders = json.decode(response.body);
        if (orders is List) {
          setState(() {
            _orders = orders;
          });
        } else {
          print('The fetched data is not a list of orders');
          // You can set _orders to an empty list or handle this case as you see fit.
          setState(() {
            _orders = [];
          });
        }
      } catch (e) {
        print('Error parsing orders: $e');
      }
    } else {
      // Handle server errors or invalid responses
      print('Failed to load orders');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          var order = _orders[index];
          return Card(
            child: ListTile(
              title: Text(order['productName'] ?? 'Unknown Product'),
              subtitle: Text('Amount: ${order['amount']?.toString() ?? '0'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // Add this line to constrain the Row size to its children
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.rate_review),
                    onPressed: () {
                      int productId = int.tryParse(order['productID'].toString()) ?? 0;
                      if (productId > 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubmitReviewScreen(productID: productId),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Product ID is unavailable for this order.')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      // Use the Share package to share the order details
                      String content = 'Check out the product I ordered: ${order['productName']}!!! :D';
                      Share.share(content);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
