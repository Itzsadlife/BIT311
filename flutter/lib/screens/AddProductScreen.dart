import 'package:flutter/material.dart';
import 'package:bit311_assignment/services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String productName = '';
  String productPrice = '';
  String productDesc = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await ProductService().addProduct({
          'productName': productName,
          'productPrice': productPrice,
          'productDesc': productDesc,
        });
        Navigator.of(context).pop(); // Go back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Product Name'),
                onSaved: (value) => productName = value ?? '',
                validator: (value) => value!.isEmpty ? 'Please enter a product name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => productPrice = value ?? '',
                validator: (value) => value!.isEmpty ? 'Please enter a product price' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Product Description'),
                onSaved: (value) => productDesc = value ?? '',
                validator: (value) => value!.isEmpty ? 'Please enter a product description' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
