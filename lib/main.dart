import 'package:flutter/material.dart';

import 'data/repositories/auth_repository.dart';
import 'data/services/preferences_service.dart';
import 'domain/models/product.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/catalog/view_models/catalog_view_model.dart';

const ink = Color(0xFF24352B);
const leaf = Color(0xFF3D6B4A);
const cream = Color(0xFFF8F5ED);

void main() => runApp(const RupaRempahApp());

class RupaRempahApp extends StatelessWidget {
  const RupaRempahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rupa Rempah',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(seedColor: leaf),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: leaf, width: 1.5),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      final repository =
          AuthRepository(preferences: PreferencesService());
      final hasAccount = await repository.hasAccount();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            repository: repository,
            hasAccount: hasAccount,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF1DD), cream],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: leaf,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Rupa Rempah',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Racikan baik untuk hari yang lebih baik',
                style: TextStyle(color: ink.withOpacity(.65)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.repository,
    required this.hasAccount,
  });

  final AuthRepository repository;
  final bool hasAccount;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  late bool isRegisterMode = !widget.hasAccount;
  late final AuthViewModel viewModel =
      AuthViewModel(repository: widget.repository);

  @override
  void initState() {
    super.initState();
    isRegisterMode = !widget.hasAccount;
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    viewModel.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (isRegisterMode &&
        username.text.trim().isNotEmpty &&
        password.text.isNotEmpty) {
      await widget.repository.save(username.text, password.text);
    }

    final valid = await viewModel.login(username.text, password.text);
    if (!mounted || !valid) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(username: username.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rupa Rempah',
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isRegisterMode
                            ? 'Buat akun untuk mulai berbelanja.'
                            : 'Masuk untuk melanjutkan belanja.',
                        style: TextStyle(color: ink.withOpacity(.62)),
                      ),
                      const SizedBox(height: 36),
                      const Text(
                        'Username',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: username,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'contoh: pelanggan01',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: password,
                        obscureText: true,
                        onSubmitted: (_) => submit(),
                        decoration: const InputDecoration(
                          hintText: 'Masukkan password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          onPressed: viewModel.isLoading ? null : submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: leaf,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isRegisterMode ? 'Daftar & masuk' : 'Masuk',
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              isRegisterMode = !isRegisterMode;
                              viewModel.errorMessage = null;
                            });
                          },
                          child: Text(
                            isRegisterMode
                                ? 'Sudah punya akun? Masuk'
                                : 'Belum punya akun? Daftar',
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Center(
                        child: Text(
                          'Data login tersimpan di perangkat ini.',
                          style: TextStyle(
                            fontSize: 12,
                            color: ink.withOpacity(.52),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.username});

  final String username;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final catalog = CatalogViewModel();
  String query = '';

  @override
  void dispose() {
    catalog.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleProducts = catalog.products.where((product) {
      final term = query.toLowerCase();
      return product.name.toLowerCase().contains(term) ||
          product.category.toLowerCase().contains(term);
    }).toList();

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: cream,
        surfaceTintColor: cream,
        title: Semantics(
          label: 'Rupa Rempah',
          image: true,
          child: const Icon(
            Icons.spa_rounded,
            color: leaf,
            size: 29,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => showMenuSheet(context),
            icon: const Icon(Icons.more_horiz, color: ink),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: catalog,
        builder: (context, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${widget.username}',
                        style: const TextStyle(
                          color: leaf,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Temukan racikan favoritmu.',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        onChanged: (value) => setState(() => query = value),
                        decoration: const InputDecoration(
                          hintText: 'Cari produk atau kategori',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Produk pilihan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                          Text(
                            '${visibleProducts.length} produk',
                            style: TextStyle(color: ink.withOpacity(.55)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = visibleProducts[index];
                      return ProductCard(
                        product: product,
                        quantity: catalog.quantityOf(product),
                        onTapImage: () {
                          catalog.add(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} ditambahkan ke Total Jual.'),
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                        },
                        onAdd: () => catalog.add(product),
                        onRemove: () => catalog.remove(product),
                        onTapName: () => showProduct(context, product),
                      );
                    },
                    childCount: visibleProducts.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 230,
                    mainAxisExtent: 300,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: catalog,
        builder: (context, _) {
          return Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Semantics(
                  button: catalog.itemCount > 0,
                  label: catalog.itemCount == 0
                      ? 'Total jual belum ada produk'
                      : 'Buka pembayaran, total ${formatRupiah(catalog.total)}',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: catalog.itemCount == 0
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(catalog: catalog),
                              ),
                            ),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: catalog.itemCount == 0
                            ? const Color(0xFFD8DED5)
                            : leaf,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              catalog.itemCount == 0
                                  ? 'Total Jual: belum ada produk'
                                  : 'Total Jual (${catalog.itemCount} item)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            formatRupiah(catalog.total),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void showMenuSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 4, 24, 10),
              child: Text(
                'Bantuan & akun',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            menuTile(Icons.call_outlined, 'Call Center', '0812-3456-7890'),
            menuTile(Icons.sms_outlined, 'SMS Center', 'Kirim pesan ke Rupa Rempah'),
            menuTile(Icons.location_on_outlined, 'Lokasi / Maps', 'Jl. Slamet Riyadi, Solo'),
            menuTile(
              Icons.manage_accounts_outlined,
              'Update User & Password',
              'Kelola data login',
              () => showUpdate(context),
            ),
          ],
        ),
      ),
    );
  }

  ListTile menuTile(
    IconData icon,
    String title,
    String subtitle, [
    VoidCallback? action,
  ]) {
    return ListTile(
      leading: Icon(icon, color: leaf),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.pop(context);
        if (action != null) {
          action();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(subtitle)),
          );
        }
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onTapImage,
    required this.onAdd,
    required this.onRemove,
    required this.onTapName,
  });

  final Product product;
  final int quantity;
  final VoidCallback onTapImage;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onTapName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ink.withOpacity(.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: onTapImage,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Color(product.accent),
                          child: const Icon(
                            Icons.spa_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (quantity > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: leaf,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Dipilih $quantity',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category,
                  style: const TextStyle(
                    color: leaf,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onTapName,
                  child: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatRupiah(product.price),
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (quantity > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onPressed: onRemove,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$quantity terpilih',
                            style: const TextStyle(
                              color: ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onPressed: onAdd,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: IconButton.filledTonal(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        color: leaf,
        tooltip: icon == Icons.add ? 'Tambah produk' : 'Kurangi produk',
      ),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.catalog});

  final CatalogViewModel catalog;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

enum PaymentMethod { wallet, cash }

class _PaymentScreenState extends State<PaymentScreen> {
  final payment = TextEditingController();
  PaymentMethod selectedMethod = PaymentMethod.wallet;
  static const walletBalance = 100000;

  @override
  void dispose() {
    payment.dispose();
    super.dispose();
  }

  int get typedAmount =>
      int.tryParse(payment.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final total = widget.catalog.total;
    final paid = selectedMethod == PaymentMethod.wallet
        ? total
        : typedAmount;
    final canPay = selectedMethod == PaymentMethod.wallet
        ? walletBalance >= total
        : paid >= total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: cream,
        surfaceTintColor: cream,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          const Text(
            'Ringkasan pembelian',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Periksa total dan pilih cara pembayaranmu.',
            style: TextStyle(color: ink.withOpacity(.65), fontSize: 15),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total yang harus dibayar',
                  style: TextStyle(color: ink.withOpacity(.65)),
                ),
                const SizedBox(height: 6),
                Text(
                  formatRupiah(total),
                  style: const TextStyle(
                    color: ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 20),
                const Text(
                  'Metode pembayaran',
                  style: TextStyle(
                    color: ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                paymentOption(
                  method: PaymentMethod.wallet,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Saldo Rupa Rempah',
                  subtitle: 'Tersedia ${formatRupiah(walletBalance)}',
                ),
                const SizedBox(height: 10),
                paymentOption(
                  method: PaymentMethod.cash,
                  icon: Icons.payments_outlined,
                  title: 'Tunai',
                  subtitle: 'Masukkan nominal pembayaran',
                ),
                if (selectedMethod == PaymentMethod.cash) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: payment,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Nominal tunai',
                      hintText: 'Contoh: 100000',
                      prefixText: 'Rp ',
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                summaryRow(
                  selectedMethod == PaymentMethod.wallet
                      ? 'Sisa saldo'
                      : 'Kembalian',
                  selectedMethod == PaymentMethod.wallet
                      ? walletBalance >= total
                          ? formatRupiah(walletBalance - total)
                          : 'Saldo tidak cukup'
                      : paid >= total
                          ? formatRupiah(paid - total)
                          : 'Masih kurang ${formatRupiah(total - paid)}',
                  valueColor: canPay ? leaf : const Color(0xFFB84A3B),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: canPay ? completePayment : null,
            icon: const Icon(Icons.lock_outline, size: 19),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Text('Konfirmasi pembayaran'),
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentOption({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = selectedMethod == method;
    return Semantics(
      button: true,
      selected: selected,
      label: '$title, $subtitle',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => selectedMethod = method),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF1DD) : const Color(0xFFF8F8F5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? leaf : const Color(0xFFE2E5DE),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? leaf : ink.withOpacity(.65)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(color: ink.withOpacity(.62), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? leaf : ink.withOpacity(.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void completePayment() {
    widget.catalog.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pembayaran berhasil'),
        content: const Text('Terima kasih sudah berbelanja di Rupa Rempah.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(
              context,
              (route) => route.isFirst,
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  Widget summaryRow(String label, String value, {required Color valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: ink.withOpacity(.65))),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

String formatRupiah(int value) {
  return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (match) => '.')}';
}

void showProduct(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.category,
            style: const TextStyle(color: leaf, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            product.description,
            style: TextStyle(color: ink.withOpacity(.72), height: 1.5),
          ),
          const SizedBox(height: 18),
          Text(
            formatRupiah(product.price),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
        ],
      ),
    ),
  );
}

void showUpdate(BuildContext context) {
  final user = TextEditingController();
  final pass = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Update User & Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: user,
            decoration: const InputDecoration(labelText: 'Username baru'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pass,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password baru'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () async {
            if (user.text.isEmpty || pass.text.isEmpty) return;
            await AuthRepository(preferences: PreferencesService())
                .save(user.text, pass.text);
            if (!context.mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data akun berhasil diperbarui.')),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}
