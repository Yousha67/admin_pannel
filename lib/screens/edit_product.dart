import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dress_model.dart';

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

  late Dress selectedDress;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchProductData();
  }

  // Fetch product data from Firestore based on productId
  void fetchProductData() {
    selectedDress = dresses.firstWhere(
          (dress) => dress.id == widget.productId,
      orElse: () => throw Exception("Product not found"),
    );

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
      sizes = selectedDress.sizes;
      colors = selectedDress.colors;
      rewardPoints = selectedDress.rewardPoints;
      discountTagline = selectedDress.discountTagline;
      createdAt = selectedDress.createdAt;
    });
  }

  // Update product details
  void updateProduct() async {
    if (_formKey.currentState!.validate()) {
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
        discountTagline: discountTagline,
        createdAt: createdAt!,
      );

      try {
        // Save the updated Dress object to Firestore
        await FirebaseFirestore.instance.collection('products').doc(
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
            SnackBar(content: Text("Product updated successfully!")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error updating product")));
        print("Error updating product: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (name == null || category == null || brand == null || material == null ||
        originalPrice == null || stock == null || rating == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Edit Product")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Basic Information"),
              _buildTextField("Product Name", name!, (val) => name = val),
              _buildTextField("Category", category!, (val) => category = val),
              _buildTextField("Brand", brand!, (val) => brand = val),
              _buildTextField("Material", material!, (val) => material = val),

              SizedBox(height: 20),
              _sectionTitle("Pricing & Inventory"),
              _buildNumberField(
                  "Original Price", originalPrice!.toString(), (val) =>
              originalPrice = double.tryParse(val)),
              _buildNumberField(
                  "Sale Price", salePrice?.toString() ?? "", (val) =>
              salePrice = double.tryParse(val)),
              _buildNumberField("Stock", stock!.toString(), (val) =>
              stock = int.tryParse(val)),

              SizedBox(height: 20),
              _sectionTitle("Ratings & Reviews"),
              _buildNumberField("Rating", rating!.toString(), (val) =>
              rating = double.tryParse(val)),
              _buildNumberField(
                  "Review Count", reviewCount!.toString(), (val) =>
              reviewCount = int.tryParse(val)),

              SizedBox(height: 20),
              _sectionTitle("Attributes"),
              _buildToggle(
                  "Recommended", recommended!, (val) => recommended = val),
              _buildToggle("On Sale", isOnSale!, (val) => isOnSale = val),

              SizedBox(height: 20),
              _sectionTitle("Sizes"),
              _buildChoiceWrap(sizes!, (selectedList) => sizes = selectedList),

              SizedBox(height: 20),
              _sectionTitle("Colors"),
              _buildChoiceWrap(
                  colors!, (selectedList) => colors = selectedList),

              SizedBox(height: 20),
              _sectionTitle("Other Details"),
              _buildNumberField(
                  "Reward Points", rewardPoints!.toString(), (val) =>
              rewardPoints = int.tryParse(val)),
              _buildTextField(
                  "Discount Tagline", discountTagline ?? "", (val) =>
              discountTagline = val),

              SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text("Save Changes"),
                  onPressed: updateProduct,
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 14)),
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
