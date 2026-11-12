import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const RMRFoodApp());
}

class RMRFoodApp extends StatelessWidget {
  const RMRFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RMR Food',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          primary: const Color(0xFFF57C00), // Warna Oranye Hangat
          secondary: const Color(0xFFFFB300), // Kuning Cerah
        ),
        useMaterial3: true,
      ),
      home: const MenuPage(),
    );
  }
}

// Model Menu Makanan
class FoodItem {
  final String name;
  final String category;
  final int price;
  final String imageAsset;

  FoodItem({
    required this.name,
    required this.category,
    required this.price,
    required this.imageAsset,
  });
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Daftar Menu Sarapan Pagi RMR Food
  final List<FoodItem> menuList = [
    FoodItem(name: 'Nasi Uduk Spesial', category: 'Sarapan', price: 12000, imageAsset: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=400'),
    FoodItem(name: 'Lontong Sayur Padang', category: 'Sarapan', price: 10000, imageAsset: 'https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=400'),
    FoodItem(name: 'Bubur Ayam Komplit', category: 'Sarapan', price: 11000, imageAsset: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400'),
    FoodItem(name: 'Teh Manis Hangat', category: 'Minuman', price: 4000, imageAsset: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=400'),
    FoodItem(name: 'Kopi Hitam Tradisional', category: 'Minuman', price: 5000, imageAsset: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400'),
  ];

  // Menyimpan item yang dipilih beserta jumlahnya (Key: Nama Makanan, Value: Jumlah)
  final Map<String, int> cart = {};

  void updateCart(String name, int delta) {
    setState(() {
      int currentQty = cart[name] ?? 0;
      int newQty = currentQty + delta;
      if (newQty > 0) {
        cart[name] = newQty;
      } else {
        cart.remove(name);
      }
    });
  }

  int getTotalPrice() {
    int total = 0;
    cart.forEach((name, qty) {
      var item = menuList.firstWhere((element) => element.name == name);
      total += item.price * qty;
    });
    return total;
  }

  void checkoutWhatsApp() async {
    if (cart.isEmpty) return;

    String message = "Halo RMR Food, saya ingin memesan:\n\n";
    cart.forEach((name, qty) {
      var item = menuList.firstWhere((element) => element.name == name);
      message += "- $name ($qty porsi) = Rp ${item.price * qty}\n";
    });
    message += "\n*Total Pembayaran: Rp ${getTotalPrice()}*\n\nMohon segera diproses ya, terima kasih!";

    // Ganti nomor WhatsApp di bawah dengan nomor WhatsApp warung Anda (format internasional tanpa angka 0 di depan, misal 628...)
    String phone = "6281234567890"; 
    String url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = cart.values.fold(0, (sum, element) => sum + element);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RMR Food', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('Warung Sarapan Pagi & Minuman Segar', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner Promo / Header Kekinian
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF57C00),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Selamat Pagi! ☀️", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Pesan sarapan favoritmu langsung dari HP, siap santap atau diantar.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Buka • 06.00 - 11.00", style: TextStyle(color: Color(0xFFF57C00), fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          
          // Daftar Menu (Grid/List)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: menuList.length,
              itemBuilder: (context, index) {
                final item = menuList[index];
                int qty = cart[item.name] ?? 0;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        // Gambar Menu
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageAsset,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 70, height: 70, color: Colors.grey[300],
                              child: const Icon(Icons.fastfood, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Detail Menu
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.category, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text("Rp ${item.price}", style: const TextStyle(fontSize: 14, color: Color(0xFFF57C00), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        // Tombol Tambah / Kurang Pesanan
                        qty == 0
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF57C00),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(60, 32),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => updateCart(item.name, 1),
                                child: const Text("Pilih", style: TextStyle(fontSize: 12)),
                              )
                            : Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                    onPressed: () => updateCart(item.name, -1),
                                  ),
                                  Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFFF57C00), size: 20),
                                    onPressed: () => updateCart(item.name, 1),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Tombol Keranjang Bawah (Floating Checkout Bar)
      bottomNavigationBar: totalItems >  0
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("$totalItems Menu Dipilih", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text("Rp ${getTotalPrice()}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF57C00))),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366), // Warna khas WhatsApp
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: checkoutWhatsApp,
                    icon: const Icon(Icons.chat),
                    label: const Text("Pesan via WhatsApp", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
