import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  File? _image;
  String? imageUrl;

  String name = '';
  String category = '';
  String brand = '';
  String material = '';
  double originalPrice = 0;
  double salePrice = 0;
  int stock = 0;
  int rewardPoints = 0;
  String? discountTagline;

  List<String> sizes = [];
  List<String> colors = [];

  final List<String> categoryOptions = ['Casual', 'Party', 'Formal'];
  final List<String> brandOptions = ['Zara', 'H&M', 'Gucci'];

  final TextEditingController sizeController = TextEditingController();
  final TextEditingController colorController = TextEditingController();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    final fileName = 'dresses/${DateTime
        .now()
        .millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child(fileName);
    await ref.putFile(_image!);
    imageUrl = await ref.getDownloadURL();
  }

  void _addTag(String value, List<String> list) {
    if (value.isNotEmpty && !list.contains(value)) {
      setState(() {
        list.add(value);
      });
    }
  }

  void _removeTag(String value, List<String> list) {
    setState(() {
      list.remove(value);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _image != null) {
      _formKey.currentState!.save();

      await _uploadImage();

      final productData = {
        'name': name,
        'category': category,
        'brand': brand,
        'material': material,
        'originalPrice': originalPrice,
        'salePrice': salePrice,
        'stock': stock,
        'rewardPoints': rewardPoints,
        'discountTagline': discountTagline,
        'sizes': sizes,
        'colors': colors,
        'imageUrl': imageUrl,
        'rating': 0,
        'reviewCount': 0,
        'popularity': 0,
        'recommended': false,
        'isOnSale': salePrice > 0,
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('dresses').add(productData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
    }
  }

  Widget _buildTagChips(List<String> list, void Function(String) onRemove) {
    return Wrap(
      spacing: 8,
      children: list.map((e) {
        return Chip(
          label: Text(e),
          onDeleted: () => onRemove(e),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[100],
                      ),
                      child: _image != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                          : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.image, size: 50, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              'Tap to pick image',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                onSaved: (val) => name = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: 'Category'),
                items: categoryOptions
                    .map((cat) =>
                    DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => category = val!,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: 'Brand'),
                items: brandOptions
                    .map((brand) =>
                    DropdownMenuItem(value: brand, child: Text(brand)))
                    .toList(),
                onChanged: (val) => brand = val!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Material'),
                onSaved: (val) => material = val!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Original Price'),
                keyboardType: TextInputType.number,
                onSaved: (val) => originalPrice = double.parse(val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Sale Price'),
                keyboardType: TextInputType.number,
                onSaved: (val) => salePrice = double.parse(val ?? '0'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
                onSaved: (val) => stock = int.parse(val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Reward Points'),
                keyboardType: TextInputType.number,
                onSaved: (val) => rewardPoints = int.parse(val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Discount Tagline'),
                onSaved: (val) => discountTagline = val,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: sizeController,
                decoration: InputDecoration(
                  labelText: 'Add Size',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _addTag(sizeController.text.trim(), sizes);
                      sizeController.clear();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildTagChips(sizes, (val) => _removeTag(val, sizes)),
              const SizedBox(height: 12),
              TextField(
                controller: colorController,
                decoration: InputDecoration(
                  labelText: 'Add Color',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _addTag(colorController.text.trim(), colors);
                      colorController.clear();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildTagChips(colors, (val) => _removeTag(val, colors)),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Add Product'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _submitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}