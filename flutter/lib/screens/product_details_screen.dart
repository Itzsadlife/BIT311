    import 'dart:convert';
    import 'package:flutter/material.dart';
    import 'package:http/http.dart' as http;
    import 'package:shared_preferences/shared_preferences.dart';
    import '../services/product_service.dart';
    import 'dart:io';
    import 'package:pdf/pdf.dart';
    import 'package:pdf/widgets.dart' as pw;
    import 'package:printing/printing.dart';
    import 'package:path_provider/path_provider.dart';

    class ProductDetailsScreen extends StatefulWidget {
      final dynamic product;
      final ProductService productService;

      ProductDetailsScreen({required this.product, required this.productService});

      @override
      _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
    }

    class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
      final TextEditingController quantityController = TextEditingController(text: "1");

      @override
      void dispose() {
        // Clean up the controller when the widget is disposed.
        quantityController.dispose();
        super.dispose();
      }

      @override
      Widget build(BuildContext context) {
        final int productId = int.tryParse(widget.product['productID']) ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.product['productName']),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.network(
                  widget.product['productImg'] ?? 'Default Image URL',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 8),
                Text(
                  widget.product['productName'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(widget.product['productDesc']),
                Text('Price: \$${widget.product['productPrice']}'),
                SizedBox(height: 16),
                Text('Enter Quantity', style: TextStyle(fontSize: 16)),
                TextField(
                  controller: quantityController, // Make sure you have defined this controller in your state class
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Quantity',
                    // Add border, label, and other styling if necessary
                  ),
                ),
                SizedBox(height: 16),
                Text('Reviews from our customer:', style: TextStyle(fontSize: 16)),
                // Your existing FutureBuilder and other widgets would remain the same
                FutureBuilder<List<dynamic>>(
                  future: widget.productService.getReviews(productId),
                  builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      List<dynamic> reviews = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true, // Ensure the ListView takes up only as much space as needed
                        physics: ClampingScrollPhysics(), // Disable scrolling inside the ListView
                        itemCount: reviews.length,
                        itemBuilder: (BuildContext context, int index) {
                          var review = reviews[index];
                          return ListTile(
                            title: Text(review['userName'] ?? 'Anonymous'),
                            subtitle: Text(review['reviewDesc']),
                            trailing: Icon(Icons.star, color: Colors.amber),
                          );
                        },

                      );
                    } else {
                      return Text('No reviews yet');
                    }
                  },
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await purchaseProduct();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 60), // Set a minimum size for the button
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Add padding inside the button
                      textStyle: TextStyle(fontSize: 18), // Increase the font size
                    ),
                    child: Text('Purchase'),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      Future<void> purchaseProduct() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? cookie = prefs.getString('cookie');
        var uri = Uri.parse('http://10.150.185.200/BIT311_backend/purchase_product.php');
        int quantity = int.tryParse(quantityController.text) ?? 1;

        try {
          var response = await http.post(
            uri,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Cookie': cookie ?? '',
            },
            body: {
              'productID': widget.product['productID'].toString(),
              'quantity': quantity.toString(),
            },
          );

          var jsonResponse = json.decode(response.body);
          if (response.statusCode == 200 && jsonResponse['success']) {
            // Generate and print the receipt
            await generateAndPrintReceipt();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse['message'])),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Purchase failed. Please try again.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e')),
          );
        }
      }

      Future<void> generateAndPrintReceipt() async {
        final pdf = pw.Document();
        final now = DateTime.now();

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Receipt', style: pw.TextStyle(fontSize: 24)),
                  pw.Text('Date: ${now.toString()}'),
                  pw.Text('Product: ${widget.product['productName']}'),
                  pw.Text('Quantity: ${quantityController.text}'),
                  pw.Text('Price: \$${widget.product['productPrice']}'),
                  pw.Padding(padding: const pw.EdgeInsets.all(10)),
                  pw.Text('Thank you for your purchase!'),
                ],
              );
            },
          ),
        );

        // Get external storage directory
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/receipt-${now.toIso8601String()}.pdf');

        // Save the document
        await file.writeAsBytes(await pdf.save());

        // Open the PDF document in a viewer
        await Printing.sharePdf(bytes: await pdf.save(), filename: 'receipt-${now.toIso8601String()}.pdf');
      }
    }
