import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'insight_screen.dart';
import 'nirva_ai_screen.dart';
import 'cashier_screen.dart';
import 'order_detail_screen.dart';
import 'pesanan_screen.dart';
import 'profil_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color green = Color(0xFF347B57);
  static const Color darkGreen = Color(0xFF233D30);
  static const Color background = Color(0xFFF6F9F6);

  int selectedIndex = 0;

  final List<String> menuTitles = ['Beranda', 'Pesanan', 'Insight', 'Profil'];

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

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String get currentDate {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final now = DateTime.now();

    return '${days[now.weekday - 1]}, '
        '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openStoreRanking() {
    const stores = [
      ('#1', 'Warung Mas Amba', 'Kuliner', '4.9'),
      ('#2', 'Kedai Senja', 'Kuliner', '4.8'),
      ('#3', 'Dapur Nusa', 'Kuliner', '4.8'),
      ('#4', 'Rasa Rumah', 'Kuliner', '4.7'),
      ('#5', 'Kopi Pagi', 'Kuliner', '4.7'),
      ('#6', 'Batik Kita', 'Fesyen', '4.6'),
      ('#7', 'Toko Harapan', 'Ritel', '4.6'),
      ('#8', 'Kreasi Lokal', 'Kerajinan', '4.5'),
      ('#9', 'Manis Sore', 'Kuliner', '4.5'),
      ('#10', 'Pasar Tetangga', 'Ritel', '4.4'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFD89419),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Top 10 Toko',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Text(
                'Peringkat dummy berdasarkan performa kategori.',
                style: TextStyle(color: Color(0xFF708077), fontSize: 12),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: stores.length,
                  separatorBuilder: (_, index) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final store = stores[index];
                    final isCurrent = businessData.isDemo && index == 0;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: isCurrent
                            ? const Color(0xFFE6F2EA)
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        child: Text(
                          store.$1.replaceFirst('#', ''),
                          style: TextStyle(
                            color: isCurrent ? green : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        store.$2,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('${store.$3} · Rating ${store.$4}'),
                      trailing: index < 3
                          ? const Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFD89419),
                            )
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void logout() {
    AuthService.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void openCashierSheet({
    bool initialExpenseMode = false,
    OrderItem? order,
    bool startInLandscape = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CashierScreen(
          order: order,
          startInLandscape: startInLandscape,
        ),
      ),
    );
  }

  void openCashierSheetLegacy({bool initialExpenseMode = false}) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String paymentMethod = 'Tunai';
    bool isExpenseMode = initialExpenseMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final data = businessData;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storefront_outlined, color: green),
                        const SizedBox(width: 8),
                        const Text(
                          'Kasir & Catatan Keuangan',
                          style: TextStyle(
                            fontSize: 17,
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF3E9),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Pemasukan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF708077),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  formatRupiah(data.income),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF2F2),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Pengeluaran',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF708077),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  formatRupiah(data.expense),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB42318),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(
                              child: Text('Transaksi Kasir (Pemasukan)'),
                            ),
                            selected: !isExpenseMode,
                            onSelected: (_) {
                              setSheetState(() => isExpenseMode = false);
                            },
                            selectedColor: const Color(0xFFEAF3E9),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: !isExpenseMode ? green : darkGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(
                              child: Text('Catat Pengeluaran'),
                            ),
                            selected: isExpenseMode,
                            onSelected: (_) {
                              setSheetState(() => isExpenseMode = true);
                            },
                            selectedColor: const Color(0xFFFDF2F2),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isExpenseMode
                                  ? const Color(0xFFB42318)
                                  : darkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: isExpenseMode
                            ? 'Keterangan Pengeluaran'
                            : 'Nama Pelanggan',
                        hintText: isExpenseMode
                            ? 'Contoh: Beli bahan baku'
                            : 'Contoh: Siti',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Nominal (Rp)',
                        hintText: 'Contoh: 45000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (!isExpenseMode) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ['Tunai', 'QRIS', 'Transfer'].map((method) {
                          final active = paymentMethod == method;
                          return ChoiceChip(
                            label: Text(method),
                            selected: active,
                            onSelected: (_) {
                              setSheetState(() => paymentMethod = method);
                            },
                            selectedColor: green,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: active ? Colors.white : darkGreen,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          final rawAmount = amountController.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          final amount = int.tryParse(rawAmount) ?? 0;

                          if (amount <= 0) {
                            showMessage('Masukkan nominal yang valid.');
                            return;
                          }

                          setState(() {
                            if (isExpenseMode) {
                              AuthService.addExpense(
                                title: nameController.text,
                                amount: amount,
                              );
                            } else {
                              AuthService.addTransaction(
                                customerName: nameController.text,
                                amount: amount,
                                paymentMethod: paymentMethod,
                              );
                            }
                          });

                          Navigator.pop(sheetContext);
                          showMessage(
                            isExpenseMode
                                ? 'Pengeluaran berhasil dicatat.'
                                : 'Transaksi kasir berhasil ditambahkan.',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isExpenseMode
                              ? 'Simpan Pengeluaran'
                              : 'Simpan Transaksi',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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

  void openProductsSheet() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final products = businessData.products;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: green),
                        const SizedBox(width: 8),
                        Text(
                          'Produk (${products.length})',
                          style: const TextStyle(
                            fontSize: 17,
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
                    const SizedBox(height: 8),
                    if (products.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Belum ada produk terdaftar pada usaha ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF708077),
                          ),
                        ),
                      )
                    else
                      ...products.map(
                        (item) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: darkGreen,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                formatRupiah(item.price),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: green,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tambah Produk Baru',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Nama produk',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Harga',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final name = nameController.text.trim();
                            final rawPrice = priceController.text.replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );
                            final price = int.tryParse(rawPrice) ?? 0;

                            if (name.isEmpty || price <= 0) {
                              showMessage('Isi nama dan harga produk.');
                              return;
                            }

                            setState(() {
                              AuthService.addProduct(name: name, price: price);
                            });
                            setSheetState(() {
                              nameController.clear();
                              priceController.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Tambah'),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: IndexedStack(
              index: selectedIndex,
              children: [
                buildHome(),
                PesananScreen(
                  onDataChanged: () => setState(() {}),
                ),
                const InsightScreen(),
                ProfilScreen(
                  onLogout: logout,
                  onDataChanged: () => setState(() {}),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(),
    );
  }

  Widget buildHome() {
    final data = businessData;
    final transactions = data.transactions;

    final omzetSubtitle = data.isDemo
        ? '↑ 12% dari kemarin · ${data.completedOrders} transaksi selesai'
        : data.completedOrders == 0 && data.omzetToday == 0
        ? 'Belum ada transaksi hari ini · 0 transaksi selesai'
        : '${data.completedOrders} transaksi selesai hari ini';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'NIRVA UMKM',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => showMessage('Belum ada notifikasi baru.'),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: darkGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // GREETING
          Text(
            '$greeting, ${data.ownerName} 👋',
            style: const TextStyle(fontSize: 14, color: Color(0xFF708077)),
          ),
          const SizedBox(height: 5),
          Text(
            data.businessName,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            currentDate,
            style: const TextStyle(fontSize: 12, color: Color(0xFF708077)),
          ),

          const SizedBox(height: 10),

          // OMZET CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Omzet hari ini',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Spacer(),
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formatRupiah(data.omzetToday),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  omzetSubtitle,
                  style: const TextStyle(
                    color: Color(0xFFDCECE1),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          InkWell(
            onTap: _openStoreRanking,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDDE7DF)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events_outlined,
                    color: Color(0xFFD89419),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Peringkat toko',
                          style: TextStyle(
                            color: darkGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          data.isDemo
                              ? 'Peringkat #1 di kategori ${data.category}'
                              : 'Belum ada peringkat — mulai catat transaksi',
                          style: const TextStyle(
                            color: Color(0xFF708077),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    data.isDemo
                        ? Icons.workspace_premium_rounded
                        : Icons.lock_outline_rounded,
                    color: data.isDemo
                        ? const Color(0xFFD89419)
                        : const Color(0xFF9AA79E),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ORDER STATISTICS
          Row(
            children: [
              Expanded(child: buildStatCard('${data.newOrders}', 'Baru')),
              const SizedBox(width: 10),
              Expanded(
                child: buildStatCard('${data.processingOrders}', 'Diproses'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildStatCard('${data.completedOrders}', 'Selesai'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // QUICK ACTIONS
          Row(
            children: [
              Expanded(
                child: buildQuickAction(
                  Icons.add_circle_outline,
                  'Buat pesanan',
                  () => setState(() => selectedIndex = 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildQuickAction(Icons.auto_awesome, 'NIRVA AI', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NirvaAiScreen()),
                  );
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildQuickAction(Icons.bar_chart_rounded, 'Insight', () {
                  setState(() => selectedIndex = 2);
                }),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // PRODUCT AND CASHIER
          Row(
            children: [
              Expanded(
                child: buildMainMenu(
                  Icons.inventory_2_outlined,
                  'Produk',
                  openProductsSheet,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildMainMenu(
                  Icons.storefront_outlined,
                  'Kasir',
                  () => openCashierSheet(startInLandscape: true),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // RECENT TRANSACTIONS HEADER
          Row(
            children: [
              const Text(
                'Riwayat terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() => selectedIndex = 1);
                },
                child: const Text(
                  'Lihat semua',
                  style: TextStyle(color: green, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          // TRANSACTION LIST
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFDDE6DE)),
            ),
            child: transactions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 12,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF3E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            color: green,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Belum ada transaksi. Yuk, mulai catat aktivitas usaha Anda!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF708077),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < transactions.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 8, color: Colors.transparent),
                        buildTransaction(
                          transactions[i].name,
                          transactions[i].detail,
                          formatRupiah(transactions[i].amount),
                          onTap: i < data.orders.length
                              ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrderDetailScreen(
                                      order: data.orders[i],
                                      onDataChanged: () => setState(() {}),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFDDE6DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF708077)),
          ),
        ],
      ),
    );
  }

  Widget buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: const Color(0xFFEAF3E9),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: green, size: 24),
              const SizedBox(height: 7),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: darkGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMainMenu(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 88,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: green, size: 19),
              const SizedBox(width: 9),
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: darkGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTransaction(
    String name,
    String detail,
    String amount, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3E9),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: green,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(
                    color: Color(0xFF708077),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  // BOTTOM NAVIGATION MENGIKUTI DESAIN FIGMA
  Widget buildBottomNavigation() {
    const icons = [
      Icons.home_outlined,
      Icons.format_list_numbered_rounded,
      Icons.bar_chart_rounded,
      Icons.person_outline_rounded,
    ];

    const menuColors = [
      Color(0xFF233D30), // Beranda
      Color(0xFFE59400), // Pesanan
      Color(0xFF29B6F6), // Insight
      Color(0xFF7C4D25), // Profil
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E8E1))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Row(
            children: List.generate(4, (index) {
              final selected = selectedIndex == index;
              final itemColor = menuColors[index];

              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFE8F0E8)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(icons[index], color: itemColor, size: 23),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        menuTitles[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: itemColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
