import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import 'cart_screen.dart';
import 'payment_dialog.dart';
import 'qr_scanner_dialog.dart';

class CashierProductItem {
  final String name;
  final String category;
  final int price;
  final String imageUrl;
  final String stockLabel;

  const CashierProductItem({
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.stockLabel,
  });
}

class CashierScreen extends StatefulWidget {
  final OrderItem? order;
  final bool autoOpenCart;
  final bool startInLandscape;

  const CashierScreen({
    super.key,
    this.order,
    this.autoOpenCart = false,
    this.startInLandscape = false,
  });

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  static const Color green = Color(0xFF2E6944);
  static const Color darkGreen = Color(0xFF1E3528);
  static const Color muted = Color(0xFF718078);
  static const Color border = Color(0xFFDDE6DE);
  static const Color lightGreen = Color(0xFFEAF3E9);
  static const Color infoBg = Color(0xFFEDF5EE);

  final TextEditingController _searchController = TextEditingController();
  late final TextEditingController _notesController;
  late String _orderType;

  String category = 'Semua';
  final Map<String, int> quantities = {};
  bool _didAutoOpenCart = false;
  bool _isLandscape = false;

  final List<CashierProductItem> products = const [
    CashierProductItem(
      name: 'Nasi Ayam',
      category: 'Makanan',
      price: 25000,
      imageUrl:
          'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500',
      stockLabel: '24 porsi tersedia',
    ),
    CashierProductItem(
      name: 'Nasi Telur',
      category: 'Makanan',
      price: 18000,
      imageUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=500',
      stockLabel: '18 porsi tersedia',
    ),
    CashierProductItem(
      name: 'Es Teh',
      category: 'Minuman',
      price: 5000,
      imageUrl:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=500',
      stockLabel: '40 gelas tersedia',
    ),
    CashierProductItem(
      name: 'Kopi Susu',
      category: 'Minuman',
      price: 12000,
      imageUrl:
          'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=500',
      stockLabel: '8 gelas tersedia',
    ),
    CashierProductItem(
      name: 'Nasi Goreng Ayam Terasi',
      category: 'Makanan',
      price: 25000,
      imageUrl:
          'https://dcostseafood.id/wp-content/uploads/2022/04/Nasi-Goreng-ayam-terasi-1.jpg',
      stockLabel: '20 porsi tersedia',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadOrderItems();

    _orderType = widget.order?.orderType ?? 'Bawa pulang';
    _notesController = TextEditingController(
      text: widget.order?.notes ?? 'Sambal dipisah, ya.',
    );

    if (widget.startInLandscape) {
      _enterLandscape();
    } else if (widget.autoOpenCart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_didAutoOpenCart) {
          _didAutoOpenCart = true;
          _openCart();
        }
      });
    }
  }

  void _loadOrderItems() {
    if (widget.order != null) {
      final summary = widget.order!.itemsSummary;
      for (final part in summary.split(',')) {
        final itemStr = part.trim();
        final match = RegExp(r'^(\d+)\s+(.+)$').firstMatch(itemStr);
        if (match != null) {
          final count = int.tryParse(match.group(1)!) ?? 1;
          final name = match.group(2)!.trim();
          quantities[name] = count;
        } else if (itemStr.isNotEmpty) {
          quantities[itemStr] = 1;
        }
      }
      if (quantities.isEmpty) {
        quantities['Nasi Ayam'] = 2;
        quantities['Es Teh'] = 2;
      }
    }
  }

  void _enterLandscape() {
    setState(() {
      _isLandscape = true;
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitLandscape() {
    setState(() {
      _isLandscape = false;
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get totalItems => quantities.values.fold(0, (sum, value) => sum + value);

  int get totalAmount => products.fold(0, (sum, product) {
        return sum + product.price * (quantities[product.name] ?? 0);
      });

  List<CashierProductItem> get visibleProducts {
    final query = _searchController.text.trim().toLowerCase();
    return products.where((product) {
      final matchesCategory =
          category == 'Semua' || product.category == category;
      return matchesCategory && product.name.toLowerCase().contains(query);
    }).toList();
  }

  List<CartItem> get activeCartItems {
    final list = <CartItem>[];
    for (final p in products) {
      final qty = quantities[p.name] ?? 0;
      if (qty > 0) {
        list.add(
          CartItem(
            name: p.name,
            price: p.price,
            quantity: qty,
            imageUrl: p.imageUrl,
          ),
        );
      }
    }
    return list;
  }

  void _changeQuantity(String name, int delta) {
    setState(() {
      final next = (quantities[name] ?? 0) + delta;
      if (next <= 0) {
        quantities.remove(name);
      } else {
        quantities[name] = next;
      }
    });
  }

  void _openQrScanner() {
    showDialog(
      context: context,
      builder: (_) => QrScannerDialog(
        onProductScanned: (name, price) {
          _changeQuantity(name, 1);
        },
      ),
    );
  }

  Future<void> _openCart() async {
    final selected = activeCartItems;

    if (selected.isEmpty && widget.order != null) {
      quantities['Nasi Ayam'] = 2;
      quantities['Es Teh'] = 2;
      selected.addAll([
        CartItem(
          name: 'Nasi Ayam',
          price: 25000,
          quantity: 2,
          imageUrl: products[0].imageUrl,
        ),
        CartItem(
          name: 'Es Teh',
          price: 5000,
          quantity: 2,
          imageUrl: products[2].imageUrl,
        ),
      ]);
    }

    final updatedQuantities = await Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          order: widget.order,
          items: selected,
          initialQuantities: Map<String, int>.from(quantities),
        ),
      ),
    );

    if (updatedQuantities != null && mounted) {
      setState(() {
        quantities.clear();
        quantities.addAll(updatedQuantities);
      });
    }
  }

  void _showOrderTypePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pilih Jenis Pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                  ),
                ),
                ...['Bawa pulang', 'Makan di tempat', 'Antar'].map((type) {
                  final isSelected = _orderType == type;
                  return ListTile(
                    title: Text(
                      type,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? green : darkGreen,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: green)
                        : null,
                    onTap: () {
                      setState(() => _orderType = type);
                      Navigator.pop(sheetContext);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _proceedToPayment() {
    final customer = widget.order?.customerName ?? 'Rina';
    final rawNumber = (widget.order?.orderNumber ?? '042')
        .replaceAll('#', '')
        .replaceAll('NRV-', '');
    final orderNumberFormatted = '#NRV-$rawNumber';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentReceiptModal(
        order: widget.order,
        customerName: customer,
        orderNumber: orderNumberFormatted,
        items: activeCartItems,
        totalAmount: totalAmount,
        notes: _notesController.text,
        orderType: _orderType,
        onCompleted: () {
          setState(() {
            quantities.clear();
          });
          _exitLandscape();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscapeMode = _isLandscape ||
        media.orientation == Orientation.landscape ||
        media.size.width > media.size.height;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9F6),
        body: SafeArea(
          child: isLandscapeMode
              ? _buildLandscapeLayout()
              : _buildPortraitLayout(),
        ),
        bottomNavigationBar:
            isLandscapeMode ? null : _buildPortraitBottomBar(),
      ),
    );
  }

  // ==========================================
  // 1. PORTRAIT LAYOUT (Sesuai Figma Kasir)
  // ==========================================
  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // AppBar
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  _exitLandscape();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: darkGreen),
              ),
              const Text(
                'Kasir',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
            ],
          ),
        ),

        // Landscape Mode Banner (Klik untuk masuk mode landscape otomatis)
        InkWell(
          onTap: _enterLandscape,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 2, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.screen_rotation_outlined, color: green, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Masuk Menu Kasir Dalam Mode Landscape',
                    style: TextStyle(
                      color: green,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: green, size: 14),
              ],
            ),
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari nama produk',
                hintStyle: const TextStyle(color: muted, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: muted, size: 22),
                suffixIcon: InkWell(
                  onTap: _openQrScanner,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: green,
                      size: 22,
                    ),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // Scan Barcode with Camera Banner
        InkWell(
          onTap: _openQrScanner,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.camera_alt_outlined, color: green, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pindai barcode dengan kamera',
                    style: TextStyle(
                      color: green,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: green, size: 20),
              ],
            ),
          ),
        ),

        // Category Filter Pills
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['Semua', 'Makanan', 'Minuman'].map((value) {
              final active = value == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => category = value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active ? green : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? green : border,
                      ),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        color: active ? Colors.white : const Color(0xFF33453B),
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // Product Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: visibleProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (_, index) {
              final product = visibleProducts[index];
              final quantity = quantities[product.name] ?? 0;
              return _productCard(product, quantity);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: totalItems == 0 ? null : _openCart,
            icon: const Icon(Icons.shopping_basket_outlined, size: 20),
            label: Text(
              'Lihat keranjang · $totalItems item · ${formatRupiah(totalAmount)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              disabledBackgroundColor: const Color(0xFFDCE9DF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 2. LANDSCAPE LAYOUT (Sistem Kasir + Keranjang Terintegrasi Side-by-Side)
  // =========================================================================
  Widget _buildLandscapeLayout() {
    final customerName = widget.order?.customerName ?? 'Rina';
    final rawNumber = (widget.order?.orderNumber ?? '042')
        .replaceAll('#', '')
        .replaceAll('NRV-', '');
    final orderNumberFormatted = '#NRV-$rawNumber';
    final currentCart = activeCartItems;

    return Row(
      children: [
        // SISI KIRI (60%): Katalog Produk Kasir Figma
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            child: Column(
              children: [
                // Top Header Row
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _exitLandscape();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: darkGreen),
                      tooltip: 'Kembali',
                    ),
                    const Text(
                      'Kasir',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Search field
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Cari nama produk...',
                            hintStyle: const TextStyle(color: muted, fontSize: 13),
                            prefixIcon: const Icon(Icons.search, color: muted, size: 18),
                            suffixIcon: InkWell(
                              onTap: _openQrScanner,
                              child: const Icon(
                                Icons.qr_code_scanner_rounded,
                                color: green,
                                size: 18,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tombol Kembali ke Mode Portrait
                    InkWell(
                      onTap: _exitLandscape,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: border),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.stay_current_portrait_rounded,
                              size: 16,
                              color: darkGreen,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Mode Portrait',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: darkGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Category Filter Pills
                SizedBox(
                  height: 32,
                  child: Row(
                    children: ['Semua', 'Makanan', 'Minuman'].map((value) {
                      final active = value == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => setState(() => category = value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: active ? green : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: active ? green : border,
                              ),
                            ),
                            child: Text(
                              value,
                              style: TextStyle(
                                color: active ? Colors.white : const Color(0xFF33453B),
                                fontWeight:
                                    active ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // Grid Produk
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: visibleProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.82,
                    ),
                    itemBuilder: (_, index) {
                      final product = visibleProducts[index];
                      final quantity = quantities[product.name] ?? 0;
                      return _productCard(product, quantity, isCompact: true);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Garis Pembatas Vertikal
        Container(width: 1, color: const Color(0xFFE2EBE2)),

        // SISI KANAN (40%): Frame Keranjang Figma
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Pesanan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pesanan $customerName',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                        Text(
                          '$orderNumberFormatted · ${currentCart.length} produk, $totalItems item',
                          style: const TextStyle(fontSize: 11, color: muted),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: _showOrderTypePicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _orderType,
                              style: const TextStyle(
                                color: green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: green,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 14, color: Color(0xFFEFF3EF)),

                // Daftar Item di Keranjang
                Expanded(
                  child: currentCart.isEmpty
                      ? const Center(
                          child: Text(
                            'Pilih produk di sebelah kiri untuk menambah ke pesanan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: currentCart.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 12,
                            color: Color(0xFFF2F6F2),
                          ),
                          itemBuilder: (_, index) {
                            final item = currentCart[index];
                            return Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.imageUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 40,
                                      height: 40,
                                      color: lightGreen,
                                      child: const Icon(
                                        Icons.restaurant,
                                        color: green,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: darkGreen,
                                        ),
                                      ),
                                      Text(
                                        formatRupiah(item.price),
                                        style: const TextStyle(
                                          color: green,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: lightGreen,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () =>
                                            _changeQuantity(item.name, -1),
                                        child: const Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Icon(
                                            Icons.remove,
                                            size: 14,
                                            color: green,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: darkGreen,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () =>
                                            _changeQuantity(item.name, 1),
                                        child: const Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Icon(
                                            Icons.add,
                                            size: 14,
                                            color: green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),

                const Divider(height: 12, color: Color(0xFFEFF3EF)),

                // Catatan Pesanan Mini
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note, size: 16, color: muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _notesController.text.isEmpty
                              ? 'Tanpa catatan'
                              : _notesController.text,
                          style: const TextStyle(
                            fontSize: 11,
                            color: darkGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Subtotal & Tombol Pembayaran
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: muted,
                      ),
                    ),
                    Text(
                      formatRupiah(totalAmount),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: darkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: currentCart.isEmpty ? null : _proceedToPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      disabledBackgroundColor: const Color(0xFFDCE9DF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      'Lanjut ke pembayaran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Product Card Widget
  // ==========================================
  Widget _productCard(
    CashierProductItem product,
    int quantity, {
    bool isCompact = false,
  }) {
    final isSelected = quantity > 0;

    return Container(
      padding: EdgeInsets.all(isCompact ? 6 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
        border: Border.all(
          color: isSelected ? green : border,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
            child: AspectRatio(
              aspectRatio: isCompact ? 1.45 : 1.35,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: lightGreen,
                  child: Icon(
                    Icons.restaurant,
                    color: green,
                    size: isCompact ? 22 : 32,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: isCompact ? 4 : 8),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isCompact ? 12.5 : 14.5,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          SizedBox(height: isCompact ? 2 : 4),
          Text(
            product.stockLabel,
            style: TextStyle(color: muted, fontSize: isCompact ? 10 : 12),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatRupiah(product.price),
                  style: TextStyle(
                    color: green,
                    fontSize: isCompact ? 12 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _changeQuantity(product.name, 1),
                borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                child: Container(
                  width: isCompact ? 28 : 34,
                  height: isCompact ? 28 : 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? green : lightGreen,
                    borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                  ),
                  child: isSelected
                      ? Text(
                          '$quantity',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isCompact ? 12 : 14,
                          ),
                        )
                      : Icon(
                          Icons.add,
                          color: green,
                          size: isCompact ? 16 : 20,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
