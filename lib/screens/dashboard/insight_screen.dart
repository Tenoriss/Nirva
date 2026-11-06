import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class InsightScreen extends StatefulWidget {
  const InsightScreen({super.key});

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  static const Color green = Color(0xFF2E7450);
  static const Color lightBarGreen = Color(0xFFBDD6B2);
  static const Color darkGreen = Color(0xFF1E3528);
  static const Color mutedText = Color(0xFF6B7B72);
  static const Color cardBorder = Color(0xFFDDE6DE);

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

  void _openPeriodSelector() {
    final periods = [
      '30 Sep – 6 Okt 2026',
      '23 Sep – 29 Sep 2026',
      '16 Sep – 22 Sep 2026',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Periode Laporan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 12),
              ...periods.map((period) {
                final selected = businessData.reportPeriod == period;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    period,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? green : darkGreen,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check_circle, color: green)
                      : null,
                  onTap: () {
                    setState(() {
                      businessData.reportPeriod = period;
                    });
                    Navigator.pop(sheetContext);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _openGuideSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: green),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Panduan: Pisahkan Uang Pribadi & Usaha',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                '1. Gunakan pencatatan rutin setiap kali membeli bahan baku dan kebutuhan operasional harian.\n\n'
                '2. Jangan mengambil uang kas usaha untuk keperluan pribadi tanpa mencatatnya sebagai penarikan.\n\n'
                '3. Evaluasi laba bersih setiap minggu di menu Insight NIRVA agar arus kas tetap sehat.',
                style: TextStyle(fontSize: 13, color: darkGreen, height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = businessData;
    final hasData = data.hasInsightData;
    const days = ['Rab', 'Kam', 'Jum', 'Sab', 'Min', 'Sen', 'Sel'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              const Text(
                'Insight bisnis',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: darkGreen,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _openPeriodSelector,
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  color: darkGreen,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // RINGKASAN MINGGUAN HEADER
          Row(
            children: [
              const Text(
                'Ringkasan mingguan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkGreen,
                ),
              ),
              const Spacer(),
              Text(
                data.reportPeriod,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // WEEKLY SUMMARY CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pemasukan',
                            style: TextStyle(fontSize: 14, color: mutedText),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatRupiah(data.income),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: green,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data.isDemo
                                ? '↑ 8% minggu lalu'
                                : hasData
                                ? 'Periode berjalan'
                                : 'Belum ada pemasukan',
                            style: const TextStyle(
                              fontSize: 13,
                              color: mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pengeluaran',
                            style: TextStyle(fontSize: 14, color: mutedText),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatRupiah(data.expense),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: green,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Bahan & operasional',
                            style: TextStyle(fontSize: 13, color: mutedText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (hasData) ...[
                  // WEEKLY BAR CHART
                  SizedBox(
                    height: 130,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(days.length, (index) {
                        final ratio = index < data.weeklyChartValues.length
                            ? data.weeklyChartValues[index].clamp(0.12, 1.0)
                            : 0.2;
                        final isHighlighted = index == days.length - 1;

                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 26,
                                height: 92 * ratio,
                                decoration: BoxDecoration(
                                  color: isHighlighted ? green : lightBarGreen,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                    bottom: Radius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                days[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: mutedText,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ] else ...[
                  // EMPTY STATE FOR NEW ACCOUNT
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F9F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.bar_chart_rounded, color: green, size: 32),
                        SizedBox(height: 10),
                        Text(
                          'Belum ada data insight.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mulai catat transaksi dan pengeluaran untuk melihat perkembangan usaha Anda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: mutedText,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // LABA BERSIH ROW
                Row(
                  children: [
                    const Text(
                      'Laba bersih',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: mutedText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatRupiah(data.netProfit),
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // PRODUK TERLARIS HEADER
          Row(
            children: [
              const Text(
                'Produk terlaris',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: darkGreen,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        data.topProducts.isEmpty
                            ? 'Belum ada data produk terlaris.'
                            : 'Menampilkan seluruh produk terlaris minggu ini.',
                      ),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Text(
                    'Lihat semua',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: green,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // PRODUK TERLARIS CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder),
            ),
            child: data.topProducts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Belum ada produk terlaris. Data akan muncul setelah produk terjual.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: mutedText,
                        height: 1.4,
                      ),
                    ),
                  )
                : Column(
                    children: List.generate(data.topProducts.length, (index) {
                      final product = data.topProducts[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < data.topProducts.length - 1 ? 16 : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: darkGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.soldLabel,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatRupiah(product.revenue),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: darkGreen,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
          ),

          const SizedBox(height: 16),

          // TIPS UMKM CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F1E8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: green, size: 19),
                    SizedBox(width: 7),
                    Text(
                      'TIPS UMKM',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: green,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pisahkan uang pribadi dan usaha',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Catat belanja bahan setiap hari agar laba lebih mudah dipantau.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5D7065),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _openGuideSheet,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Baca panduan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: green,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16, color: green),
                      ],
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
