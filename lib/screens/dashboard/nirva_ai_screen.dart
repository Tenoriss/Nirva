import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class NirvaAiScreen extends StatefulWidget {
  const NirvaAiScreen({super.key});

  @override
  State<NirvaAiScreen> createState() => _NirvaAiScreenState();
}

class _NirvaAiScreenState extends State<NirvaAiScreen> {
  static const green = Color(0xFF347B57);
  static const darkGreen = Color(0xFF233D30);
  static const mutedGreen = Color(0xFF718078);
  static const background = Color(0xFFF7FAF7);

  final _questionController = TextEditingController();
  final _scrollController = ScrollController();
  String? _question;
  String? _answer;

  UserBusinessData get data =>
      AuthService.currentBusinessData ??
      UserBusinessData.empty(
        ownerName: 'Pemilik Usaha',
        businessName: 'Usaha Saya',
        category: 'Kuliner',
        phone: '',
        email: AuthService.currentEmail ?? '',
      );

  bool get isDemo => data.isDemo;

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _ask([String? suggestion]) {
    final question = (suggestion ?? _questionController.text).trim();
    if (question.isEmpty) return;

    setState(() {
      _question = question;
      _answer = _createAnswer(question);
      _questionController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _createAnswer(String question) {
    if (!isDemo) {
      return 'Halo ${data.ownerName}, saya siap membantu mengembangkan '
          '${data.businessName}. Tambahkan transaksi atau produk terlebih dahulu '
          'agar saran saya bisa disesuaikan dengan kondisi usaha Anda.';
    }

    final normalized = question.toLowerCase();
    if (normalized.contains('promosi') || normalized.contains('penjualan')) {
      return 'Halo ${data.ownerName}, pemasukan naik 8% minggu ini. '
          'Nasi Ayam menyumbang penjualan terbesar.\n\n'
          'Buat paket hemat\n'
          'Nasi Ayam + Es Teh seharga Rp28.000.\n\n'
          'Siapkan stok lebih awal\n'
          'Penjualan tertinggi terjadi hari Sabtu.\n\n'
          'Tawarkan ke pelanggan lama\n'
          'Bagikan menu harian lewat WhatsApp.';
    }

    return 'Berdasarkan ringkasan ${data.reportPeriod}, '
        '${data.topProducts.first.name} menjadi produk terlaris. '
        'Saya bisa membantu membuat promosi atau menganalisis pengeluaran usaha.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: darkGreen),
        ),
        title: const Text(
          'NIRVA AI',
          style: TextStyle(
            color: darkGreen,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              _question = null;
              _answer = null;
            }),
            icon: const Icon(Icons.history_rounded, color: darkGreen),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIntroCard(),
                    const SizedBox(height: 26),
                    Center(
                      child: Text(
                        _question == null ? 'Hari ini' : 'Hari ini · 09.45',
                        style: const TextStyle(color: mutedGreen, fontSize: 16),
                      ),
                    ),
                    if (_question != null) ...[
                      const SizedBox(height: 22),
                      _buildQuestionBubble(),
                      const SizedBox(height: 22),
                      _buildAnswerCard(),
                    ] else ...[
                      const SizedBox(height: 22),
                      _buildWelcomeCard(),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSuggestion(
                            'Bantu buat promosi',
                            'promosi',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildSuggestion(
                            'Analisis pengeluaran',
                            'pengeluaran',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Saran AI perlu disesuaikan dengan kondisi usaha.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: mutedGreen, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3E9),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          const _NirvaMark(size: 82),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Teman diskusi usaha Anda',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDemo
                      ? 'Saran praktis dari data ${data.businessName}.'
                      : 'Saran awal untuk ${data.businessName}.',
                  style: const TextStyle(color: mutedGreen, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6DE)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: green, size: 25),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isDemo
                  ? 'Tanyakan apa saja tentang penjualan, produk, atau strategi usaha ${data.businessName}.'
                  : 'Halo ${data.ownerName}, ceritakan tantangan usaha Anda. Saya akan membantu dengan saran yang sederhana dan praktis.',
              style: const TextStyle(
                color: darkGreen,
                fontSize: 16,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBubble() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 430),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: const BoxDecoration(
          color: green,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
        ),
        child: Text(
          _question!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6DE)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: green, size: 23),
              SizedBox(width: 9),
              Text(
                'NIRVA AI',
                style: TextStyle(
                  color: green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _answer!,
            style: const TextStyle(color: darkGreen, fontSize: 16, height: 1.5),
          ),
          if (isDemo) ...[
            const SizedBox(height: 16),
            Text(
              'Berdasarkan ringkasan ${data.reportPeriod}.',
              style: const TextStyle(color: mutedGreen, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestion(String label, String value) {
    return OutlinedButton(
      onPressed: () => _ask(value),
      style: OutlinedButton.styleFrom(
        foregroundColor: green,
        side: const BorderSide(color: Color(0xFFDCE6DE)),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E8E1))),
      ),
      child: TextField(
        controller: _questionController,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _ask(),
        decoration: InputDecoration(
          hintText: 'Tanya tentang usaha Anda...',
          hintStyle: const TextStyle(color: mutedGreen),
          filled: true,
          fillColor: background,
          contentPadding: const EdgeInsets.fromLTRB(18, 15, 8, 15),
          suffixIcon: IconButton(
            onPressed: _ask,
            style: IconButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_upward_rounded),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: const BorderSide(color: Color(0xFFDCE6DE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: const BorderSide(color: Color(0xFFDCE6DE)),
          ),
        ),
      ),
    );
  }
}

class _NirvaMark extends StatelessWidget {
  const _NirvaMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _NirvaMarkPainter()),
    );
  }
}

class _NirvaMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.22)),
      Paint()..color = const Color(0xFF347B57),
    );
    final leaf = Path()
      ..moveTo(size.width * 0.21, size.height * 0.79)
      ..cubicTo(
        size.width * 0.19,
        size.height * 0.43,
        size.width * 0.43,
        size.height * 0.20,
        size.width * 0.80,
        size.height * 0.20,
      )
      ..cubicTo(
        size.width * 0.81,
        size.height * 0.55,
        size.width * 0.64,
        size.height * 0.80,
        size.width * 0.32,
        size.height * 0.80,
      )
      ..close();
    canvas.drawPath(leaf, Paint()..color = Colors.white);
    final vein = Path()
      ..moveTo(size.width * 0.20, size.height * 0.80)
      ..lineTo(size.width * 0.58, size.height * 0.43);
    canvas.drawPath(
      vein,
      Paint()
        ..color = const Color(0xFF347B57)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.055,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
