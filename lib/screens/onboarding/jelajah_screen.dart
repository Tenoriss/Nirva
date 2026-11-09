import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';
import 'login_required_dialog.dart';

class JelajahScreen extends StatelessWidget {
  const JelajahScreen({super.key});

  static const String heroImage =
      'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=1000';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tablet = constraints.maxWidth >= 600;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: tablet ? 28 : 16,
                          vertical: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _header(context),
                            const SizedBox(height: 26),
                            _hero(constraints.maxWidth),
                            const SizedBox(height: 20),
                            _benefits(),
                            const SizedBox(height: 20),
                            _loginCta(context),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    _bottomNavigation(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 27),
        ),
        const SizedBox(width: 9),
        const Text(
          'NIRVA UMKM',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selamat datang di NIRVA UMKM!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primary,
            ),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
          color: AppColors.primaryDark,
        ),
      ],
    );
  }

  Widget _hero(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pill('Jelajah NIRVA • Untuk UMKM Indonesia'),
        const SizedBox(height: 14),
        Text(
          'Usaha lebih rapi,\nlangkah lebih pasti.',
          style: TextStyle(
            fontSize: width >= 600 ? 38 : 25,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Kenali cara NIRVA membantu mengelola usaha '
          'sehari-hari, dalam satu tempat.',
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: width >= 600 ? 2.5 : 1.75,
                child: Image.network(
                  heroImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.primaryLight,
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: AppColors.primary,
                      size: 48,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: _imageLabel(Icons.check_circle_outline, 'Pesanan rapi'),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: _imageLabel(Icons.trending_up, 'Terus tumbuh'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.explore_outlined,
              size: 17,
              color: AppColors.primary,
            ),
            const SizedBox(width: 7),
            const Expanded(
              child: Text(
                'Jelajahi dulu. Masuk saat Anda siap mulai.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _benefits() {
    final benefits = [
      (
        Icons.assignment_outlined,
        'Pesanan lebih tertata',
        'Catat dan pantau pesanan dari masuk hingga selesai. Tidak ada pesanan yang terlewat.',
        'Status pesanan • Riwayat transaksi',
      ),
      (
        Icons.inventory_2_outlined,
        'Produk & stok terkontrol',
        'Atur katalog, harga, dan jumlah stok. Ketahui kapan produk perlu diisi kembali.',
        'Katalog produk • Pemantauan stok',
      ),
      (
        Icons.account_balance_wallet_outlined,
        'Keuangan lebih jelas',
        'Rapikan catatan pemasukan dan pengeluaran agar laba usaha lebih mudah dipantau.',
        'Pemasukan • Pengeluaran • Laba',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Satu aplikasi, banyak manfaat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Lebih sedikit urusan administrasi. Lebih banyak waktu '
          'untuk mengembangkan usaha.',
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        ...benefits.map(
          (benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _benefitCard(benefit.$1, benefit.$2, benefit.$3, benefit.$4),
          ),
        ),
      ],
    );
  }

  Widget _benefitCard(
    IconData icon,
    String title,
    String description,
    String footer,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  footer,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginCta(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Masuk dan mulai kelola usaha',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Masuk untuk menggunakan fitur NIRVA UMKM.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _bottomNavigation(BuildContext context) {
    const labels = ['Beranda', 'Jelajah', 'Pesanan', 'Akun'];
    const icons = [
      Icons.home_outlined,
      Icons.explore_outlined,
      Icons.shopping_bag_outlined,
      Icons.person_outline,
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.only(top: 7, bottom: 8),
      child: Row(
        children: List.generate(4, (index) {
          final active = index == 1;

          return Expanded(
            child: InkWell(
              onTap: () {
                if (index == 1) return;
                if (index == 0) {
                  Navigator.pop(context);
                  return;
                }
                if (index == 2) {
                  showLoginRequiredDialog(context);
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${labels[index]} akan segera tersedia.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primaryLight
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      icons[index],
                      size: 21,
                      color: active
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      color: active
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _imageLabel(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
