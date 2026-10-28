import 'package:flutter/foundation.dart';
import '../../../../domain/models/product.dart';

class CatalogViewModel extends ChangeNotifier {
  final products = const [
    Product(name: 'Sabun Cair Kunyit', category: 'Perawatan tubuh', description: 'Sabun cair lembut dengan ekstrak kunyit dan aroma rempah yang menenangkan untuk pemakaian harian.', price: 28000, imageUrl: 'https://images.unsplash.com/photo-1772038786507-647371ac686b?auto=format&fit=crop&fm=jpg&ixlib=rb-4.1.0&q=60&w=900', accent: 0xFFE9B949),
    Product(name: 'Body Scrub Kopi', category: 'Perawatan tubuh', description: 'Scrub kopi dengan tekstur halus untuk membantu mengangkat sel kulit mati dan membuat kulit terasa lebih segar.', price: 35000, imageUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=900&q=85', accent: 0xFFB9764A),
    Product(name: 'Serum Wajah Rempah', category: 'Skin care', description: 'Serum ringan dengan bahan alami pilihan untuk menjaga kelembapan dan tampilan kulit tetap sehat.', price: 49000, imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=900&q=85', accent: 0xFF8DB58A),
    Product(name: 'Lulur Beras', category: 'Perawatan tubuh', description: 'Lulur tradisional berbahan beras yang membantu merawat kulit agar terasa halus dan cerah alami.', price: 30000, imageUrl: 'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=900&q=85', accent: 0xFFD7B58D),
    Product(name: 'Minyak Esensial Sereh', category: 'Aromaterapi', description: 'Aroma sereh yang segar untuk menemani waktu istirahat dan menciptakan suasana rumah yang nyaman.', price: 42000, imageUrl: 'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=900&q=85', accent: 0xFFA3C66C),
    Product(name: 'Balm Jahe Hangat', category: 'Kesehatan keluarga', description: 'Balm hangat dengan aroma jahe untuk pijat ringan setelah aktivitas sehari-hari.', price: 24000, imageUrl: 'https://erda.co/cdn/shop/files/erdarefres000465-R1-006-1A_ab5061b9-26ef-403a-b5a9-3c2f1755b335.png?v=1764014040&width=900', accent: 0xFFD9825B),
  ];
  final Map<String, int> cart = {};
  int get total => cart.entries.fold(0, (sum, item) => sum + products.firstWhere((p) => p.name == item.key).price * item.value);
  int get itemCount => cart.values.fold(0, (sum, quantity) => sum + quantity);
  int quantityOf(Product product) => cart[product.name] ?? 0;
  void add(Product product) { cart[product.name] = (cart[product.name] ?? 0) + 1; notifyListeners(); }
  void remove(Product product) {
    final quantity = quantityOf(product);
    if (quantity <= 1) {
      cart.remove(product.name);
    } else {
      cart[product.name] = quantity - 1;
    }
    notifyListeners();
  }
  void clear() { cart.clear(); notifyListeners(); }
}
