import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'order_detail_screen.dart';

class PesananScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;
  final VoidCallback? onProcessOrder;

  const PesananScreen({super.key, this.onDataChanged, this.onProcessOrder});

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  static const Color green = Color(0xFF347B57);
  static const Color darkGreen = Color(0xFF1E3528);
  static const Color mutedText = Color(0xFF6B7B72);
  static const Color cardBorder = Color(0xFFDDE6DE);

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';

  UserBusinessData get businessData {
    return AuthService.currentBusinessData ??
        UserBusinessData.empty(
          ownerName: 'Pemilik Usaha',
          businessName: 'Usaha Baru',
          category: 'Kuliner',
          phone: '',
          email: AuthService.currentEmail ?? '',
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    setState(() {});
    widget.onDataChanged?.call();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<OrderItem> get _filteredOrders {
    final query = _searchController.text.trim().toLowerCase();
    return businessData.orders.where((order) {
      final matchesFilter =
          _selectedFilter == 'Semua' || order.status == _selectedFilter;
      final matchesSearch =
          query.isEmpty ||
          order.customerName.toLowerCase().contains(query) ||
          order.orderNumber.toLowerCase().contains(query) ||
          order.itemsSummary.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _openCreateOrderSheet() {
    final customerController = TextEditingController();
    final itemsController = TextEditingController();
    final totalController = TextEditingController();
    String orderType = 'Bawa pulang';
    String status = 'Baru';
    bool isPaid = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 22,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Buat Pesanan Baru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: customerController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nama Pelanggan',
                        hintText: 'Contoh: Rina',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: itemsController,
                      decoration: InputDecoration(
                        labelText: 'Detail Pesanan',
                        hintText: 'Contoh: 2 Nasi Ayam, 2 Es Teh',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: totalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Total Harga (Rp)',
                        hintText: 'Contoh: 60000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Jenis Pesanan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ['Bawa pulang', 'Makan di tempat', 'Antar'].map(
                        (type) {
                          final active = orderType == type;
                          return ChoiceChip(
                            label: Text(type),
                            selected: active,
                            onSelected: (_) {
                              setSheetState(() => orderType = type);
                            },
                            selectedColor: green,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: active ? Colors.white : darkGreen,
                            ),
                          );
                        },
                      ).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Status Pesanan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ['Baru', 'Diproses', 'Selesai'].map((item) {
                        final active = status == item;
                        return ChoiceChip(
                          label: Text(item),
                          selected: active,
                          onSelected: (_) {
                            setSheetState(() => status = item);
                          },
                          selectedColor: green,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: active ? Colors.white : darkGreen,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: green,
                      title: const Text(
                        'Tandai sudah dibayar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkGreen,
                        ),
                      ),
                      value: isPaid,
                      onChanged: (value) {
                        setSheetState(() => isPaid = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final rawTotal = totalController.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          final amount = int.tryParse(rawTotal) ?? 0;

                          if (customerController.text.trim().isEmpty ||
                              amount <= 0) {
                            _showMessage(
                              'Mohon isi nama pelanggan dan total pesanan.',
                            );
                            return;
                          }

                          AuthService.createOrder(
                            customerName: customerController.text,
                            itemsSummary: itemsController.text,
                            totalAmount: amount,
                            orderType: orderType,
                            status: status,
                            isPaid: isPaid,
                          );

                          _notifyChanged();
                          Navigator.pop(sheetContext);
                          _showMessage('Pesanan berhasil ditambahkan.');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Simpan Pesanan',
                          style: TextStyle(fontWeight: FontWeight.bold),
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

  void _openOrderDetail(OrderItem order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(
          order: order,
          onDataChanged: () => _notifyChanged(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = businessData;
    final filteredOrders = _filteredOrders;

    final filters = [
      ('Semua', data.totalOrdersCount),
      ('Baru', data.newOrders),
      ('Diproses', data.processingOrders),
      ('Selesai', data.completedOrders),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              const Text(
                'Pesanan',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: darkGreen,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showMessage('Belum ada notifikasi pesanan.'),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: darkGreen,
                  size: 27,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // SEARCH BAR
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14, color: darkGreen),
              decoration: InputDecoration(
                hintText: 'Cari pelanggan atau nomor pesanan',
                hintStyle: const TextStyle(fontSize: 14, color: mutedText),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: mutedText,
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 18,
                          color: mutedText,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // FILTER STATUS PILLS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((item) {
                final label = item.$1;
                final count = item.$2;
                final isSelected = _selectedFilter == label;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      setState(() {
                        _selectedFilter = label;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? green : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? green : cardBorder,
                        ),
                      ),
                      child: Text(
                        '$label $count',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : darkGreen,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 18),

          // SECTION HEADER: Hari ini, 6 Oktober + Buat pesanan +
          Row(
            children: [
              const Text(
                'Hari ini, 6 Oktober',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkGreen,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _openCreateOrderSheet,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Text(
                    'Buat pesanan +',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: green,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ORDER CARDS OR EMPTY STATE
          if (data.orders.isEmpty)
            _buildEmptyOrdersState()
          else if (filteredOrders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardBorder),
              ),
              child: const Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 36, color: mutedText),
                  SizedBox(height: 10),
                  Text(
                    'Pesanan tidak ditemukan.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Coba gunakan kata kunci atau filter status lain.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: mutedText),
                  ),
                ],
              ),
            )
          else
            ...filteredOrders.map(_buildOrderCard),
        ],
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3E9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: green,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum ada pesanan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pesanan usaha Anda akan muncul di sini setelah transaksi pertama.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: mutedText, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderItem order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openOrderDetail(order),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${order.customerName} · ${order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: darkGreen,
                        ),
                      ),
                    ),
                    _buildStatusBadge(order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${order.time} · ${order.orderType}',
                  style: const TextStyle(fontSize: 14, color: mutedText),
                ),
                const SizedBox(height: 10),
                Text(
                  order.itemsSummary,
                  style: const TextStyle(
                    fontSize: 15,
                    color: darkGreen,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFEAF0EB)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      formatRupiah(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: darkGreen,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.isPaid ? 'Sudah dibayar' : 'Belum dibayar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: order.isPaid
                                ? green
                                : const Color(0xFF8B5E20),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: order.isPaid ? green : const Color(0xFF8B5E20),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Baru':
        bgColor = const Color(0xFFD85B5B);
        textColor = const Color(0xFF2B1212);
        break;
      case 'Diproses':
        bgColor = const Color(0xFFFDF3DF);
        textColor = const Color(0xFF7A5216);
        break;
      case 'Selesai':
      default:
        bgColor = const Color(0xFFE6F2EA);
        textColor = const Color(0xFF2E7450);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
