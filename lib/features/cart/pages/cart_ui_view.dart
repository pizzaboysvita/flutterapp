import 'package:flutter/material.dart';
import 'package:pizza_boys/data/models/cart/cart_ui_model.dart';


class CartUIView extends StatelessWidget {
  const CartUIView({super.key});

@override
Widget build(BuildContext context) {
  final args = ModalRoute.of(context)!.settings.arguments as List<CartUIItem>?;

  return Scaffold(
    appBar: AppBar(
      title: const Text.rich(
        TextSpan(
          children: [
            TextSpan(text: "My ", style: TextStyle(color: Colors.black)),
            TextSpan(text: "Cart", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    body: args == null || args.isEmpty
        ? const Center(child: Text("Your cart is empty 🛍️"))
        : Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: args.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = args[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl ??
                                  "https://via.placeholder.com/50",
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Qty: ${item.quantity} | ${item.size ?? ''} ${item.largeOption ?? ''}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                if (item.addons != null &&
                                    item.addons!.isNotEmpty)
                                  Text(
                                    "Addons: ${item.addons!.join(', ')}",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  ),
                                if (item.choices != null &&
                                    item.choices!.isNotEmpty)
                                  Text(
                                    "Sides: ${item.choices!.join(', ')}",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            "\$${(item.price).toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ✅ Total + Checkout
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "\$${args.fold<double>(0, (sum, item) => sum + item.price).toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Checkout logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Proceed to Checkout",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
  );
}




}
