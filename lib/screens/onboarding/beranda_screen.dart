import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  int selectedTab = 0;
  int selectedCategory = 0;

  final categories = ['Makanan', 'Pakaian', 'Dekorasi'];

  static const String heroImage =
      'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=1000';
  static const String aboutImage =
      'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=1000';
  static const String umkmImage =
      'https://images.unsplash.com/photo-1556740758-90de374c12ad?w=1000';
  static const String productImage =
      'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=1000';
  static const String reviewImage =
      'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=1000';

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final desktop = width >= 900;
            final tablet = width >= 600;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: desktop
                              ? 36
                              : tablet
                              ? 28
                              : 16,
                          vertical: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _header(),
                            const SizedBox(height: 26),
                            _hero(width),
                            const SizedBox(height: 18),
                            _quickFeatures(tablet),
                            const SizedBox(height: 20),
                            _loginPrompt(),
                            const SizedBox(height: 22),
                            _aboutSection(tablet),
                            const SizedBox(height: 22),
                            _topUmkmSection(tablet),
                            const SizedBox(height: 16),
                            _productsSection(tablet),
                            const SizedBox(height: 16),
                            _testimonialsSection(tablet),
                            const SizedBox(height: 16),
                            _developerSection(),
                            const SizedBox(height: 20),
                            _bottomCallToAction(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    _bottomNavigation(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // HEADER
  Widget _header() {
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
          onPressed: () => showMessage('Selamat datang di NIRVA UMKM!'),
          icon: const Icon(Icons.notifications_none_rounded),
          color: AppColors.primaryDark,
        ),
      ],
    );
  }

  // HERO SECTION
  Widget _hero(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pill('Untuk UMKM Indonesia'),
        const SizedBox(height: 14),
        Text(
          'Bangun bisnis lebih\nmudah bersama NIRVA.',
          style: TextStyle(
            fontSize: width >= 600 ? 38 : 25,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pesanan, produk, dan keuangan usaha. '
          'Semua rapi dalam satu tempat.',
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
                child: _networkImage(heroImage),
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

  // QUICK FEATURES
  Widget _quickFeatures(bool tablet) {
    final features = [
      (Icons.assignment_outlined, 'Pesanan lebih tertata'),
      (Icons.auto_awesome, 'NIRVA AI'),
      (Icons.bar_chart_rounded, 'Insight bisnis'),
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
          'Lebih sedikit urusan administrasi. '
          'Lebih banyak waktu untuk mengembangkan usaha.',
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 10,
            mainAxisExtent: tablet ? 125 : 90,
          ),
          itemBuilder: (context, index) {
            final item = features[index];

            return _benefitCard(item.$1, item.$2);
          },
        ),
      ],
    );
  }

  Widget _benefitCard(IconData icon, String title) {
    return _card(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // LOGIN PROMPT
  Widget _loginPrompt() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
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
              'Mulai sekarang',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            const Text(
              'Sudah punya akun? ',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Masuk',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ABOUT
  Widget _aboutSection(bool tablet) {
    return _sectionCard(
      title: 'Tentang Kami',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NIRVA UMKM membantu usaha mikro, kecil, dan '
            'menengah mengelola pesanan, produk, dan keuangan '
            'dengan lebih rapi, cepat, dan mudah dipantau.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: tablet ? 2.7 : 1.75,
              child: _networkImage(aboutImage),
            ),
          ),
          const SizedBox(height: 12),
          _bullet('Kelola pesanan, produk, dan stok dalam satu tempat'),
          _bullet('Pantau penjualan, laba, dan kinerja usaha secara cepat'),
          _bullet('Dukung pengambilan keputusan bisnis dengan data'),
        ],
      ),
    );
  }

  // TOP UMKM
  Widget _topUmkmSection(bool tablet) {
    final items = [
      ('Kedai Kopi Bumi', 'Makanan & Minuman • 4.9/5', '+18%'),
      ('Toko Baju Lokal', 'Pakaian • 4.8/5', '+14%'),
      ('Warung Makan Sehat', 'Makanan • 4.8/5', '+12%'),
    ];

    return _sectionCard(
      title: 'Top UMKM Bulan Ini',
      badge: 'Contoh konsep',
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: tablet ? 2.7 : 1.9,
              child: _networkImage(umkmImage),
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(items.length, (index) {
            final item = items[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  _rank(index + 1),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _pill(item.$3),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // PRODUCTS
  Widget _productsSection(bool tablet) {
    final productSets = [
      [
        ('Kopi Susu Gula Aren', 'Makanan • 1.2k terjual', 'Rp18k'),
        ('Kaas Katun Lokal', 'Pakaian • 980 terjual', 'Rp85k'),
        ('Tas Anyaman Ramah Lingkungan', 'Aksesori • 760 terjual', 'Rp45k'),
      ],
      [
        ('Kemeja Linen Lokal', 'Pakaian • 850 terjual', 'Rp95k'),
        ('Kaos Katun Lokal', 'Pakaian • 980 terjual', 'Rp85k'),
        ('Outer Casual', 'Pakaian • 700 terjual', 'Rp120k'),
      ],
      [
        ('Vas Keramik', 'Dekorasi • 650 terjual', 'Rp55k'),
        ('Tas Anyaman', 'Dekorasi • 760 terjual', 'Rp45k'),
        ('Hiasan Meja', 'Dekorasi • 500 terjual', 'Rp35k'),
      ],
    ];

    final products = productSets[selectedCategory];

    return _sectionCard(
      title: 'Produk Terlaris',
      badge: 'Contoh konsep',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            children: List.generate(categories.length, (index) {
              final active = selectedCategory == index;

              return ChoiceChip(
                label: Text(categories[index]),
                selected: active,
                onSelected: (_) {
                  setState(() => selectedCategory = index);
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
                labelStyle: TextStyle(
                  fontSize: 11,
                  color: active ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                showCheckmark: false,
                side: BorderSide.none,
              );
            }),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: tablet ? 2.7 : 1.9,
              child: _networkImage(productImage),
            ),
          ),
          const SizedBox(height: 10),
          ...products.map((product) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: SizedBox(
                      width: 43,
                      height: 43,
                      child: _networkImage(productImage),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.$1,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          product.$2,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    product.$3,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // TESTIMONIALS
  Widget _testimonialsSection(bool tablet) {
    return _sectionCard(
      title: 'Apa Kata Mereka',
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: tablet ? 2.7 : 1.9,
              child: _networkImage(reviewImage),
            ),
          ),
          const SizedBox(height: 12),
          _review(
            '“NIRVA membantu saya mengelola pesanan dan stok '
                'lebih cepat. Sekarang saya bisa fokus ke pemasaran '
                'dan meningkatkan penjualan.”',
            'Ayu Rahmawati',
            'Pemilik Warung Makan Sehat',
            'AR',
          ),
          const SizedBox(height: 9),
          _review(
            '“Laporan penjualan dan laba jadi lebih jelas. '
                'Saya bisa tahu produk mana yang paling laris '
                'dan kapan harus restock.”',
            'Budi Raharjo',
            'Pemilik Toko Baju Lokal',
            'BR',
          ),
        ],
      ),
    );
  }

  Widget _review(String quote, String name, String role, String initials) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '★★★★★',
            style: TextStyle(
              color: AppColors.primary,
              letterSpacing: 2,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            quote,
            style: const TextStyle(
              fontSize: 11,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: AppColors.primary,
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 9, color: Colors.white),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      role,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // DEVELOPER
  Widget _developerSection() {
    return _sectionCard(
      title: 'Profil Developer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil pengembang aplikasi NIRVA UMKM.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 23,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, color: AppColors.primary, size: 27),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Freda Stanlye @ Atennnn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Developer | UI/UX Enthusiast | '
                        'Programmer | System Analyst',
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BOTTOM CTA
  Widget _bottomCallToAction() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
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

  // BOTTOM NAVIGATION
  Widget _bottomNavigation() {
    final labels = ['Beranda', 'Jelajah', 'Pesanan', 'Akun'];
    final icons = [
      Icons.home_outlined,
      Icons.explore_outlined,
      Icons.shopping_bag_outlined,
      Icons.person_outline,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.only(top: 7, bottom: 8),
      child: Row(
        children: List.generate(4, (index) {
          final active = selectedTab == index;

          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() => selectedTab = index);

                if (index != 0) {
                  showMessage('${labels[index]} akan segera tersedia.');
                }
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

  // REUSABLE WIDGETS
  Widget _sectionCard({
    required String title,
    String? badge,
    required Widget child,
  }) {
    return _card(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (badge != null) _pill(badge),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(14),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _rank(int number) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        '$number',
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 6, color: AppColors.primary),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageLabel(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _networkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return Container(
          color: AppColors.primaryLight,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.primaryLight,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.primary,
            size: 35,
          ),
        );
      },
    );
  }
}
