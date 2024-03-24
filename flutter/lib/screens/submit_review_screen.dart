import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/auth_service.dart';

class SubmitReviewScreen extends StatefulWidget {
  final int productID;

  const SubmitReviewScreen({Key? key, required this.productID}) : super(key: key);

  @override
  _SubmitReviewScreenState createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  int _rating = 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      // Use AuthService to retrieve the stored session cookie
      String? cookie = await AuthService().getCookie();

      // Send the review to the server along with the session cookie
      var response = await http.post(
        Uri.parse('http://10.150.185.200/BIT311_backend/submit_review.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': cookie ?? '', // Only include the cookie if it's not null
        },
        body: {
          'productID': widget.productID.toString(),
          'rating': _rating.toString(),
          'reviewDesc': _controller.text, // Make sure the key matches your PHP script's expected POST variable
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        // Assuming your PHP script returns a JSON response with a 'success' key
        if (jsonResponse['success']) {
          // Review submitted successfully
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Review submitted successfully!')),
          );
          Navigator.pop(context); // Go back to the previous screen
        } else {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit review: ${jsonResponse['message']}')),
          );
        }
      } else {
        // Handle server error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rating:'),
              DropdownButton<int>(
                value: _rating,
                onChanged: (int? newValue) {
                  setState(() {
                    _rating = newValue ?? 1;
                  });
                },
                items: List.generate(
                  5,
                      (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1} stars'),
                  ),
                ),
              ),
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Review'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your review';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _submitReview,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
