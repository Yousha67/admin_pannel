import 'package:flutter/material.dart';
import '../models/dress_model.dart';
import 'edit_product.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  Future<void> deleteDress(BuildContext context, String id) async {
    final index = dresses.indexWhere((d) => d.id == id);
    if (index != -1) {
      dresses.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted')),
      );
    }
  }

  int getColumnCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1000) return 4;
    if (width > 750) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    if (dresses.isEmpty) {
      return const Center(child: Text("No products found."));
    }

    double screenWidth = MediaQuery.of(context).size.width;

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: dresses.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getColumnCount(context),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: screenWidth < 600 ? 0.55 : 0.65,
      ),
      itemBuilder: (context, index) {
        final dress = dresses[index];

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProductScreen(productId: dress.id),
                ),
              );
            },
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      dress.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            dress.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            '${dress.brand} • ${dress.category}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Column(
                          children: [
                            Text(
                              'PKR: ${dress.salePrice?.toStringAsFixed(0) ?? dress.originalPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: dress.salePrice != null ? Colors.pink : Colors.black,
                              ),
                            ),
                            if (dress.salePrice != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                'PKR: ${dress.originalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
