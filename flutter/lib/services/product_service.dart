import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {
  final String baseUrl = 'http://192.168.98.55/BIT311_backend/';

  Future<List<dynamic>> getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cookie = prefs.getString('cookie');
    Map<String, String> headers = {};

    // If there is a cookie, add it to the headers
    if (cookie != null) {
      headers['Cookie'] = cookie;
    }

    // Now make the http request with the session cookie if it exists
    final response = await http.get(Uri.parse('${baseUrl}view_products.php'), headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      // If the response contains an "error" key, handle it here
      if (jsonData is Map<String, dynamic> && jsonData.containsKey('error')) {
        throw Exception(jsonData['error']);
      }

      // If the decoded JSON data is a list, return it
      if (jsonData is List) {
        return jsonData;
      } else {
        throw Exception('Data format is incorrect');
      }
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    final response = await http.post(
      Uri.parse('${baseUrl}add_product.php'),
      body: productData,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add product');
    }
  }

  Future<void> editProduct(Map<String, dynamic> productData) async {
    final response = await http.post(
      Uri.parse('${baseUrl}edit_product.php'),
      body: productData,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to edit product');
    }
  }

  Future<void> deleteProduct(int productId) async {
    final response = await http.post(
      Uri.parse('${baseUrl}delete_product.php'),
      body: {'productID': productId.toString()},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  // Add this method to your ProductService class
  Future<List<dynamic>> getReviews(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cookie = prefs.getString('cookie');
    Map<String, String> headers = {};

    if (cookie != null) {
      headers['Cookie'] = cookie;
    }

    final response = await http.get(
      Uri.parse('${baseUrl}get_reviews.php?productID=$productId'),
      headers: headers,
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> reviews = json.decode(response.body);
      return reviews;
    } else {
      // If the call to the server was not successful, throw an error
      throw Exception('Failed to load reviews: ${response.statusCode} ${response.body}');
    }
  }


}
