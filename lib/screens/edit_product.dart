import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/dress_model.dart';
import '../services/imgbb_service.dart';
import '../widgets/dynamic_image.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  EditProductScreen({required this.productId});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  String? name;
  String? category;
  String? brand;
  String? material;
  double? originalPrice;
  double? salePrice;
  int? popularity;
  bool? recommended;
  bool? isOnSale;
  String? imageUrl;
  int? stock;
  double? rating;
  int? reviewCount;
  List<String>? sizes;
  List<String>? colors;
  int? rewardPoints;
  String? discountTagline;
  DateTime? createdAt;

  File? _newImage;
  final _picker = ImagePicker();

  late Dress selectedDress;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchProductData();
  }

  // Fetch product data from Firestore based on productId
  Future<void> fetchProductData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('dresses').doc(widget.productId).get();
      if (doc.exists) {
        selectedDress = Dress.fromFirestore(doc.data()!, doc.id);
        setState(() {
          name = selectedDress.name;
          category = selectedDress.category;
          brand = selectedDress.brand;
          material = selectedDress.material;
          originalPrice = selectedDress.originalPrice;
          salePrice = selectedDress.salePrice;
          popularity = selectedDress.popularity;
          recommended = selectedDress.recommended;
          isOnSale = selectedDress.isOnSale;
          imageUrl = selectedDress.imageUrl;
          stock = selectedDress.stock;
          rating = selectedDress.rating;
          reviewCount = selectedDress.reviewCount;
          sizes = List<String>.from(selectedDress.sizes);
          colors = List<String>.from(selectedDress.colors);
          rewardPoints = selectedDress.rewardPoints;
          discountTagline = selectedDress.discountTagline;
          createdAt = selectedDress.createdAt;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product not found")),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("Error fetching product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading product: $e")),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImage = File(picked.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_newImage == null) return;
    final uploadedUrl = await ImgBBService.uploadImage(_newImage!);
    if (uploadedUrl != null) {
      imageUrl = uploadedUrl;
    }
  }

  // Update product details
  void updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      try {
        await _uploadImage();
        final updatedDress = Dress(
          id: selectedDress.id,
          name: name!,
          category: category!,
          brand: brand!,
          material: material!,
          originalPrice: originalPrice!,
          salePrice: salePrice,
          popularity: popularity!,
          recommended: recommended!,
          isOnSale: isOnSale!,
          imageUrl: imageUrl!,
          stock: stock!,
          rating: rating!,
          reviewCount: reviewCount!,
          sizes: sizes!,
          colors: colors!,
          rewardPoints: rewardPoints!,
          discountTagline: discountTagline?.isNotEmpty == true ? discountTagline : null,
          createdAt: createdAt!,
        );

        // Save the updated Dress object to Firestore
        await FirebaseFirestore.instance.collection('dresses').doc(
            widget.productId).update({
          'name': updatedDress.name,
          'category': updatedDress.category,
          'brand': updatedDress.brand,
          'material': updatedDress.material,
          'originalPrice': updatedDress.originalPrice,
          'salePrice': updatedDress.salePrice,
          'popularity': updatedDress.popularity,
          'recommended': updatedDress.recommended,
          'isOnSale': updatedDress.isOnSale,
          'imageUrl': updatedDress.imageUrl,
          'stock': updatedDress.stock,
          'rating': updatedDress.rating,
          'reviewCount': updatedDress.reviewCount,
          'sizes': updatedDress.sizes,
          'colors': updatedDress.colors,
          'rewardPoints': updatedDress.rewardPoints,
          'discountTagline': updatedDress.discountTagline,
          'createdAt': updatedDress.createdAt,
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product updated successfully!")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error updating product: $e")));
        print("Error updating product: $e");
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isSaving = true;
      });
      try {
        await FirebaseFirestore.instance.collection('dresses').doc(widget.productId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product deleted successfully")),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting product: $e")),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: "Delete Product",
            onPressed: _isSaving ? null : _deleteProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                      child: _newImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _newImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                          : (imageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: DynamicImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                          : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 50, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              'Tap to pick new image',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _sectionTitle("Basic Information"),
              _buildTextField("Product Name", name!, (val) => name = val),
              _buildTextField("Category", category!, (val) => category = val),
              _buildTextField("Brand", brand!, (val) => brand = val),
              _buildTextField("Material", material!, (val) => material = val),

              const SizedBox(height: 20),
              _sectionTitle("Pricing & Inventory"),
              _buildNumberField(
                  "Original Price", originalPrice!.toString(), (val) =>
              originalPrice = double.tryParse(val)),
              _buildNumberField(
                  "Sale Price", salePrice?.toString() ?? "", (val) =>
              salePrice = double.tryParse(val)),
              _buildNumberField("Stock", stock!.toString(), (val) =>
              stock = int.tryParse(val)),

              const SizedBox(height: 20),
              _sectionTitle("Ratings & Reviews"),
              _buildNumberField("Rating", rating!.toString(), (val) =>
              rating = double.tryParse(val)),
              _buildNumberField(
                  "Review Count", reviewCount!.toString(), (val) =>
              reviewCount = int.tryParse(val)),

              const SizedBox(height: 20),
              _sectionTitle("Attributes"),
              _buildToggle(
                  "Recommended", recommended!, (val) => recommended = val),
              _buildToggle("On Sale", isOnSale!, (val) => isOnSale = val),

              const SizedBox(height: 20),
              _sectionTitle("Sizes"),
              _buildChoiceWrap(sizes!, (selectedList) => sizes = selectedList),

              const SizedBox(height: 20),
              _sectionTitle("Colors"),
              _buildChoiceWrap(
                  colors!, (selectedList) => colors = selectedList),

              const SizedBox(height: 20),
              _sectionTitle("Other Details"),
              _buildNumberField(
                  "Reward Points", rewardPoints!.toString(), (val) =>
              rewardPoints = int.tryParse(val)),
              _buildTextField(
                  "Discount Tagline", discountTagline ?? "", (val) =>
              discountTagline = val),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? "Saving..." : "Save Changes"),
                  onPressed: _isSaving ? null : updateProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue,
      Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildNumberField(String label, String initialValue,
      Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
          title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildToggle(String title, bool currentValue,
      Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: currentValue,
      onChanged: (val) => setState(() => onChanged(val)),
    );
  }

  Widget _buildChoiceWrap(List<String> options,
      Function(List<String>) onSelectionChanged) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: options.map((item) {
        return FilterChip(
          label: Text(item),
          selected: options.contains(item),
          onSelected: (selected) {
            setState(() {
              if (selected && !options.contains(item)) {
                onSelectionChanged([...options, item]);
              } else if (!selected) {
                onSelectionChanged(options.where((s) => s != item).toList());
              }
            });
          },
        );
      }).toList(),
    );
  }
}
