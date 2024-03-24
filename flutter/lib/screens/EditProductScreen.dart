import 'package:flutter/material.dart';
import 'package:bit311_assignment/services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final dynamic product;

  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String productName;
  late String productPrice;
  late String productDesc;

  @override
  void initState() {
    super.initState();
    productName = widget.product['productName'];
    productPrice = widget.product['productPrice'].toString();
    productDesc = widget.product['productDesc'];
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await ProductService().editProduct({
          'productID': widget.product['productID'].toString(),
          'productName': productName,
          'productPrice': productPrice,
          'productDesc': productDesc,
        });
        Navigator.of(context).pop(); // Go back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to edit product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Edit Product'),
    ),
    body: Form(
    key: _formKey,
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    children: [
    TextFormField(
    initialValue: productName,
    decoration: InputDecoration(labelText: 'Product Name'),
    onSaved: (value) => productName = value ?? '',
    validator: (value) => value!.isEmpty ? 'Please enter a product name' : null,
    ),
    TextFormField(
    initialValue: productPrice,
    decoration: InputDecoration(labelText: 'Product Price'),
    keyboardType: TextInputType.number,
    onSaved: (value) => productPrice = value ?? '',
    validator: (value) => value!.isEmpty ? 'Please enter a product price' : null,
    ),
      TextFormField(
        initialValue: productDesc,
        decoration: InputDecoration(labelText: 'Product Description'),
        onSaved: (value) => productDesc = value ?? '',
        validator: (value) => value!.isEmpty ? 'Please enter a product description' : null,
      ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: _submitForm,
        child: Text('Save Changes'),
      ),
    ],
    ),
    ),
    ),
    );
  }
}