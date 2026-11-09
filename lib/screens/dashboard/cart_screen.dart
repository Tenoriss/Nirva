import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'payment_dialog.dart';

class CartItem {
  final String name;
  final int price;
  final int quantity;
  final String imageUrl;

  const CartItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  CartItem copyWith({
    String? name,
    int? price,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItem(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class CartScreen extends StatefulWidget {
  final OrderItem? order;
  final List<CartItem> items;
  final Map<String, int>? initialQuantities;

  const CartScreen({
    super.key,
    required this.items,
    this.order,
    this.initialQuantities,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color green = Color(0xFF2E6944);
  static const Color darkGreen = Color(0xFF1E3528);
  static const Color muted = Color(0xFF718078);
  static const Color border = Color(0xFFDDE6DE);
  static const Color lightGreen = Color(0xFFEAF3E9);
  static const Color infoBg = Color(0xFFEDF5EE);

  late final TextEditingController _notesController;
  late final Map<String, int> _quantities;
  late final Map<String, CartItem> _itemLookup;
  late String _orderType;

  @override
  void initState() {
    super.initState();
    _quantities = <String, int>{};
    _itemLookup = <String, CartItem>{};

    for (final item in widget.items) {
      _itemLookup[item.name] = item;
      _quantities[item.name] = item.quantity;
    }

    if (widget.initialQuantities != null) {
      for (final entry in widget.initialQuantities!.entries) {
        if (entry.value > 0) {
          _quantities[entry.key] = entry.value;
          _itemLookup.putIfAbsent(
            entry.key,
            () => CartItem(
              name: entry.key,
              price: entry.key == 'Nasi Ayam'
                  ? 25000
                  : entry.key == 'Nasi Telur'
                      ? 18000
                      : entry.key == 'Es Teh'
                          ? 5000
                          : 12000,
              quantity: entry.value,
              imageUrl: entry.key == 'Nasi Ayam'
                  ? 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500'
                  : entry.key == 'Nasi Telur'
                      ? 'https://images.unsplash.com/photo-1547592180-85f173990554?w=500'
                      : entry.key == 'Es Teh'
                          ? 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=500'
                          : 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=500',
            ),
          );
        }
      }
    }

    _orderType = widget.order?.orderType ?? 'Bawa pulang';
    _notesController = TextEditingController(
      text: widget.order?.notes ?? 'Sambal dipisah, ya.',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<CartItem> get activeItems {
    final list = <CartItem>[];
    _quantities.forEach((name, qty) {
      if (qty > 0 && _itemLookup.containsKey(name)) {
        list.add(_itemLookup[name]!.copyWith(quantity: qty));
      }
    });
    return list;
  }

  int get totalItems => _quantities.values.fold(0, (sum, val) => sum + val);

  int get totalAmount {
    int sum = 0;
    _quantities.forEach((name, qty) {
      if (qty > 0 && _itemLookup.containsKey(name)) {
        sum += _itemLookup[name]!.price * qty;
      }
    });
    return sum;
  }

  void _updateQuantity(String name, int delta) {
    setState(() {
      final current = _quantities[name] ?? 0;
      final next = current + delta;
      if (next <= 0) {
        _quantities.remove(name);
      } else {
        _quantities[name] = next;
      }
    });
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
        items: activeItems,
        totalAmount: totalAmount,
        notes: _notesController.text,
        orderType: _orderType,
        onCompleted: () {
          Navigator.pop(context, _quantities);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerName = widget.order?.customerName ?? 'Rina';
    final rawNumber = (widget.order?.orderNumber ?? '042')
        .replaceAll('#', '')
        .replaceAll('NRV-', '');
    final orderNumberFormatted = '#NRV-$rawNumber';
    final currentActiveItems = activeItems;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _quantities);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F9F6),
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context, _quantities),
            icon: const Icon(Icons.arrow_back, color: darkGreen),
          ),
          title: const Text(
            'Keranjang',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Order Title
                      Text(
                        'Pesanan $customerName',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$orderNumberFormatted · ${currentActiveItems.length} produk, $totalItems item',
                        style: const TextStyle(fontSize: 13, color: muted),
                      ),
                      const SizedBox(height: 16),

                      // Cart Items Container
                      if (currentActiveItems.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: border),
                          ),
                          child: const Center(
                            child: Text(
                              'Keranjang belanja kosong.',
                              style: TextStyle(color: muted, fontSize: 14),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: border),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: currentActiveItems.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 24,
                              thickness: 1,
                              color: Color(0xFFF0F4F0),
                            ),
                            itemBuilder: (_, index) {
                              final item = currentActiveItems[index];
                              return _cartItemRow(item);
                            },
                          ),
                        ),

                      // Button: + Tambah produk lain
                      InkWell(
                        onTap: () => Navigator.pop(context, _quantities),
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          margin: const EdgeInsets.only(top: 14),
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: border),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: green, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Tambah produk lain',
                                style: TextStyle(
                                  color: green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Jenis Pesanan
                      const Text(
                        'Jenis pesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _showOrderTypePicker,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _orderType,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: darkGreen,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: muted),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Catatan Pesanan (opsional)
                      const Text(
                        'Catatan pesanan (opsional)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _notesController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: 'Tambah catatan pesanan...',
                                  hintStyle: TextStyle(
                                    color: muted,
                                    fontSize: 14,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: darkGreen,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.edit_outlined,
                              color: muted,
                              size: 20,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Info Banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: infoBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: green, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Periksa jumlah dan catatan. Diskon dan metode bayar dipilih di langkah berikutnya.',
                                style: TextStyle(
                                  color: green,
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Subtotal and Payment Button Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFEEF2EE)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                            color: Color(0xFF55655D),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatRupiah(totalAmount),
                          style: const TextStyle(
                            color: darkGreen,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            currentActiveItems.isEmpty ? null : _proceedToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          disabledBackgroundColor: const Color(0xFFDCE9DF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Lanjut ke pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartItemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 58,
              height: 58,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: lightGreen,
                  child: const Icon(Icons.restaurant, color: green),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  formatRupiah(item.price),
                  style: const TextStyle(
                    color: green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total ${formatRupiah(item.price * item.quantity)}',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _updateQuantity(item.name, -1),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(Icons.remove, size: 16, color: green),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      color: darkGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _updateQuantity(item.name, 1),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(Icons.add, size: 16, color: green),
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
