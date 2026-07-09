import '../models/dress_model.dart';
import '../widgets/dynamic_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_product.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  int getColumnCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1000) return 4;
    if (width > 750) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('dresses')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text("No products found."));
        }

        final List<Dress> fetchedDresses = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Dress.fromFirestore(data, doc.id);
        }).toList();

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: fetchedDresses.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getColumnCount(context),
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: screenWidth < 600 ? 0.55 : 0.65,
          ),
          itemBuilder: (context, index) {
            final dress = fetchedDresses[index];

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
                        child: DynamicImage(
                          imageUrl: dress.imageUrl,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  const SizedBox(height: 2),
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
      },
    );
  }
}
