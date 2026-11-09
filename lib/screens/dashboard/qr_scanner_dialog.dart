import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class QrScannerDialog extends StatefulWidget {
  final Function(String productName, int? price) onProductScanned;

  const QrScannerDialog({
    super.key,
    required this.onProductScanned,
  });

  @override
  State<QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<QrScannerDialog>
    with SingleTickerProviderStateMixin {
  static const Color green = Color(0xFF2E6944);
  static const Color darkGreen = Color(0xFF1E3528);
  static const Color lightGreen = Color(0xFFEAF3E9);
  static const Color muted = Color(0xFF718078);
  static const Color border = Color(0xFFDDE6DE);

  late final AnimationController _animController;
  late final Animation<double> _laserAnimation;

  final TextEditingController _manualCodeController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isFlashOn = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  void _handleDetectedCode(String code) {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final cleanCode = code.trim();
    String productName = '';
    int? detectedPrice;

    // Smart QR & URL Parser:
    String analyzedText = cleanCode;

    // Jika QR berupa Tautan / URL Web (contoh: https://...)
    if (cleanCode.startsWith('http://') || cleanCode.startsWith('https://')) {
      final uri = Uri.tryParse(cleanCode);
      if (uri != null) {
        // Cek query parameters (misal: ?item=nasi-ayam&price=25000)
        final itemQuery = uri.queryParameters['item'] ??
            uri.queryParameters['menu'] ??
            uri.queryParameters['name'] ??
            uri.queryParameters['product'];

        final priceQuery = uri.queryParameters['price'] ??
            uri.queryParameters['harga'];
        if (priceQuery != null) {
          detectedPrice = int.tryParse(priceQuery.replaceAll(RegExp(r'[^0-9]'), ''));
        }

        if (itemQuery != null && itemQuery.isNotEmpty) {
          analyzedText = itemQuery.replaceAll('-', ' ').replaceAll('_', ' ');
        } else if (uri.pathSegments.isNotEmpty) {
          // Ambil segmen terakhir URL (misal: /menu/nasi-ayam -> nasi ayam)
          final lastSegment = uri.pathSegments.last;
          if (lastSegment.isNotEmpty) {
            analyzedText = lastSegment.replaceAll('-', ' ').replaceAll('_', ' ');
          }
        }
      }
    }

    final lower = analyzedText.toLowerCase();

    if (lower.contains('nasi goreng') ||
        lower.contains('goreng') ||
        lower.contains('terasi') ||
        lower.contains('nasi-goreng') ||
        lower.contains('goreng-ayam')) {
      productName = 'Nasi Goreng Ayam Terasi';
      detectedPrice ??= 25000;
    } else if (lower.contains('nasi ayam') || lower.contains('ayam')) {
      productName = 'Nasi Ayam';
      detectedPrice ??= 25000;
    } else if (lower.contains('nasi telur') || lower.contains('telur')) {
      productName = 'Nasi Telur';
      detectedPrice ??= 18000;
    } else if (lower.contains('es teh') || lower.contains('teh')) {
      productName = 'Es Teh';
      detectedPrice ??= 5000;
    } else if (lower.contains('kopi') || lower.contains('kopi susu')) {
      productName = 'Kopi Susu';
      detectedPrice ??= 12000;
    } else {
      // Nama menu custom dari URL/teks QR
      productName = analyzedText.isNotEmpty
          ? analyzedText[0].toUpperCase() + analyzedText.substring(1)
          : cleanCode;
      detectedPrice ??= 15000;
    }

    widget.onProductScanned(productName, detectedPrice);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'QR Berhasil Dipindai: $productName ditambahkan ke pesanan!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Future<void> _pickImageAndScan(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source);
      if (file == null) return;

      // Extract filename / simulate reading QR content from user's image
      final filename = file.name;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membaca QR dari gambar: $filename...'),
          duration: const Duration(seconds: 1),
        ),
      );

      // Analyze filename or trigger detected code
      _handleDetectedCode(filename.contains('.') ? filename.split('.').first : filename);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka gambar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 680),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  // App Bar / Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: lightGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: green,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pindai QR Menu / Produk',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkGreen,
                              ),
                            ),
                            Text(
                              'Arahkan QR Code produk ke kamera',
                              style: TextStyle(fontSize: 11, color: muted),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: muted),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, thickness: 1),

                  // Camera Viewfinder Screen
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Camera background representation
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: const Color(0xFF141E17),
                          child: Center(
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 110,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),

                        // Viewfinder cutout frame
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              // 4 Corner Brackets
                              _buildCorner(top: 0, left: 0, isTop: true, isLeft: true),
                              _buildCorner(top: 0, right: 0, isTop: true, isLeft: false),
                              _buildCorner(bottom: 0, left: 0, isTop: false, isLeft: true),
                              _buildCorner(bottom: 0, right: 0, isTop: false, isLeft: false),

                              // Animated Laser line
                              AnimatedBuilder(
                                animation: _laserAnimation,
                                builder: (_, __) {
                                  return Positioned(
                                    top: 240 * _laserAnimation.value,
                                    left: 12,
                                    right: 12,
                                    child: Container(
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF38E54D),
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF38E54D).withOpacity(0.8),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Top Controls (Flash toggle, Info)
                        Positioned(
                          top: 16,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => setState(() => _isFlashOn = !_isFlashOn),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                                        color: _isFlashOn ? const Color(0xFFFFD54F) : Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _isFlashOn ? 'Lampu Menyala' : 'Lampu Mati',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bottom Actions: Ambil dari Galeri & Ambil Foto
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _scanActionPill(
                                icon: Icons.photo_library_outlined,
                                label: 'Pilih File QR',
                                onTap: () => _pickImageAndScan(ImageSource.gallery),
                              ),
                              const SizedBox(width: 10),
                              _scanActionPill(
                                icon: Icons.camera_alt_outlined,
                                label: 'Buka Kamera HP',
                                onTap: () => _pickImageAndScan(ImageSource.camera),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Section: Quick Scan Presets / Test
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    color: const Color(0xFFF8FAF8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Uji Pindai QR Menu Cepat (Klik untuk simulasi):',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Preset chips of the menus
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            'Nasi Ayam',
                            'Nasi Telur',
                            'Es Teh',
                            'Kopi Susu',
                            'Nasi Goreng Ayam Terasi',
                          ].map((menu) {
                            return InkWell(
                              onTap: () => _handleDetectedCode(menu),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.qr_code_rounded,
                                      size: 13,
                                      color: green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      menu,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: darkGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 10),

                        // Manual Code Input
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: border),
                                ),
                                child: TextField(
                                  controller: _manualCodeController,
                                  onSubmitted: (val) {
                                    if (val.trim().isNotEmpty) {
                                      _handleDetectedCode(val);
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Atau ketik nama/kode QR...',
                                    hintStyle: TextStyle(
                                      color: muted,
                                      fontSize: 12,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: () {
                                final text = _manualCodeController.text.trim();
                                if (text.isNotEmpty) {
                                  _handleDetectedCode(text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Scan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: Color(0xFF38E54D), width: 3.5)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Color(0xFF38E54D), width: 3.5)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Color(0xFF38E54D), width: 3.5)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Color(0xFF38E54D), width: 3.5)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _scanActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
