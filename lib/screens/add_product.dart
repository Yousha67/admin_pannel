import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/imgbb_service.dart';

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
  bool _isSubmitting = false;

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
    imageUrl = await ImgBBService.uploadImage(_image!);
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
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product image')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        _formKey.currentState!.save();

        await _uploadImage();

        if (imageUrl == null) {
          throw Exception("Failed to upload image. Please try again.");
        }

        final productData = {
          'name': name,
          'category': category,
          'brand': brand,
          'material': material,
          'originalPrice': originalPrice,
          'salePrice': salePrice > 0 ? salePrice : null, // Store null if not set
          'stock': stock,
          'rewardPoints': rewardPoints,
          'discountTagline': discountTagline?.isNotEmpty == true ? discountTagline : null,
          'sizes': sizes,
          'colors': colors,
          'imageUrl': imageUrl,
          'rating': 0.0,
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

        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          imageUrl = null;
          name = '';
          category = '';
          brand = '';
          material = '';
          originalPrice = 0;
          salePrice = 0;
          stock = 0;
          rewardPoints = 0;
          discountTagline = null;
          sizes.clear();
          colors.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
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
                onSaved: (val) => name = val ?? '',
                validator: (val) => val == null || val.isEmpty ? 'Product Name is required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                items: categoryOptions
                    .map((cat) =>
                    DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => category = val ?? '',
                validator: (val) => val == null || val.isEmpty ? 'Category is required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Brand'),
                items: brandOptions
                    .map((brand) =>
                    DropdownMenuItem(value: brand, child: Text(brand)))
                    .toList(),
                onChanged: (val) => brand = val ?? '',
                validator: (val) => val == null || val.isEmpty ? 'Brand is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Material'),
                onSaved: (val) => material = val ?? '',
                validator: (val) => val == null || val.isEmpty ? 'Material is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Original Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onSaved: (val) => originalPrice = double.tryParse(val ?? '0') ?? 0.0,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Original Price is required';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  if (double.parse(val) <= 0) return 'Price must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Sale Price (Optional)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onSaved: (val) => salePrice = double.tryParse(val ?? '') ?? 0.0,
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    if (double.tryParse(val) == null) return 'Enter a valid number';
                    if (double.parse(val) < 0) return 'Price cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
                onSaved: (val) => stock = int.tryParse(val ?? '0') ?? 0,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Stock is required';
                  if (int.tryParse(val) == null) return 'Enter a valid integer';
                  if (int.parse(val) < 0) return 'Stock cannot be negative';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Reward Points'),
                keyboardType: TextInputType.number,
                onSaved: (val) => rewardPoints = int.tryParse(val ?? '0') ?? 0,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Reward Points is required';
                  if (int.tryParse(val) == null) return 'Enter a valid integer';
                  if (int.parse(val) < 0) return 'Reward Points cannot be negative';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Discount Tagline (Optional)'),
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
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isSubmitting ? 'Adding...' : 'Add Product'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}