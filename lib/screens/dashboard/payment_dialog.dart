import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import 'cart_screen.dart';

class BankInfo {
  final String code;
  final String name;
  final String accountNumber;
  final String accountHolder;
  final Color brandColor;
  final IconData icon;

  const BankInfo({
    required this.code,
    required this.name,
    required this.accountNumber,
    required this.accountHolder,
    required this.brandColor,
    required this.icon,
  });
}

const List<BankInfo> kIndonesianBanks = [
  BankInfo(
    code: 'BCA',
    name: 'Bank Central Asia (BCA)',
    accountNumber: '8271 9023 4410',
    accountHolder: 'NIRVA UMKM - Mas Amba',
    brandColor: Color(0xFF005DAA),
    icon: Icons.account_balance,
  ),
  BankInfo(
    code: 'MANDIRI',
    name: 'Bank Mandiri',
    accountNumber: '1320 0984 7123 5',
    accountHolder: 'NIRVA UMKM - Mas Amba',
    brandColor: Color(0xFF003D79),
    icon: Icons.account_balance,
  ),
  BankInfo(
    code: 'BRI',
    name: 'Bank Rakyat Indonesia (BRI)',
    accountNumber: '0341 0100 2345 508',
    accountHolder: 'NIRVA UMKM - Mas Amba',
    brandColor: Color(0xFF00529C),
    icon: Icons.account_balance,
  ),
  BankInfo(
    code: 'BNI',
    name: 'Bank Negara Indonesia (BNI)',
    accountNumber: '0892 3411 90',
    accountHolder: 'NIRVA UMKM - Mas Amba',
    brandColor: Color(0xFFE55300),
    icon: Icons.account_balance,
  ),
  BankInfo(
    code: 'BSI',
    name: 'Bank Syariah Indonesia (BSI)',
    accountNumber: '7182 9304 12',
    accountHolder: 'NIRVA UMKM - Mas Amba',
    brandColor: Color(0xFF00A39D),
    icon: Icons.account_balance,
  ),
  BankInfo(
    code: 'CIMB',
    name: 'CIMB Niaga',
    accountNumber: '7051 8920 3341',
    accountHolder: 'NIRVA UMKM - Mas Amba',
    brandColor: Color(0xFFED1C24),
    icon: Icons.account_balance,
  ),
  BankInfo(
    code: 'PERMATA',
    name: 'Permata Bank',
    accountNumber: '4109 8234 11',
    accountHolder: 'NIRVA UMKM - Mas Amba',
    brandColor: Color(0xFF008144),
    icon: Icons.account_balance,
  ),
  BankInfo(
    code: 'DANAMON',
    name: 'Bank Danamon',
    accountNumber: '0036 1289 4412',
    accountHolder: 'NIRVA UMKM - Mas Amba',
    brandColor: Color(0xFFFF7900),
    icon: Icons.account_balance,
  ),
];

class PaymentReceiptModal extends StatefulWidget {
  final OrderItem? order;
  final String customerName;
  final String orderNumber;
  final List<CartItem> items;
  final int totalAmount;
  final String notes;
  final String orderType;
  final VoidCallback? onCompleted;

  const PaymentReceiptModal({
    super.key,
    this.order,
    required this.customerName,
    required this.orderNumber,
    required this.items,
    required this.totalAmount,
    this.notes = 'Sambal dipisah, ya.',
    this.orderType = 'Bawa pulang',
    this.onCompleted,
  });

  @override
  State<PaymentReceiptModal> createState() => _PaymentReceiptModalState();
}

class _PaymentReceiptModalState extends State<PaymentReceiptModal> {
  static const Color green = Color(0xFF2E6944);
  static const Color darkGreen = Color(0xFF1E3528);
  static const Color muted = Color(0xFF718078);
  static const Color border = Color(0xFFDDE6DE);
  static const Color lightGreen = Color(0xFFEAF3E9);

  // Steps: 'payment' -> 'receipt'
  String _currentStep = 'payment';
  String _selectedMethod = 'Tunai'; // 'Tunai', 'QRIS', 'Transfer Bank'
  BankInfo _selectedBank = kIndonesianBanks.first;

  // Tunai State
  late final TextEditingController _cashController;
  int _receivedAmount = 0;

  // Printing state
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _receivedAmount = widget.totalAmount;
    _cashController = TextEditingController(text: '${widget.totalAmount}');
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  void _onCashChanged(String val) {
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    final numVal = int.tryParse(clean) ?? 0;
    setState(() {
      _receivedAmount = numVal;
    });
  }

  void _finishPaymentAndShowReceipt() {
    // 1. Update order status to Selesai
    if (widget.order != null) {
      AuthService.updateOrderStatus(widget.order!, 'Selesai');
      widget.order!.isPaid = true;
    }

    // 2. Add transaction record to AuthService
    String paymentDetail = _selectedMethod;
    if (_selectedMethod == 'Transfer Bank') {
      paymentDetail = 'Transfer ${_selectedBank.code}';
    }

    AuthService.addTransaction(
      customerName: widget.customerName,
      amount: widget.totalAmount,
      paymentMethod: paymentDetail,
    );

    // 3. Move to receipt step
    setState(() {
      _currentStep = 'receipt';
    });
  }

  void _simulatePrintReceipt() {
    setState(() => _isPrinting = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _isPrinting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.print, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Nota berhasil dicetak ke Printer Thermal Bluetooth!'),
              ],
            ),
            backgroundColor: green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9F6),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _currentStep == 'payment'
                  ? _buildPaymentStep()
                  : _buildReceiptStep(),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // STEP 1: PAYMENT METHOD SELECTION & CONFIRMATION
  // =========================================================================
  Widget _buildPaymentStep() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
          color: Colors.white,
          child: Row(
            children: [
              const Text(
                'Pembayaran Pesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: muted),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total to pay banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD3E7D6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Pembayaran',
                            style: TextStyle(fontSize: 12.5, color: muted),
                          ),
                          Text(
                            widget.customerName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        formatRupiah(widget.totalAmount),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Method Selector Tabs (Tunai, QRIS, Transfer Bank)
                const Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    _methodTab('Tunai', Icons.payments_outlined),
                    const SizedBox(width: 8),
                    _methodTab('QRIS', Icons.qr_code_2_rounded),
                    const SizedBox(width: 8),
                    _methodTab('Transfer Bank', Icons.account_balance_outlined),
                  ],
                ),

                const SizedBox(height: 16),

                // Specific Method Content
                if (_selectedMethod == 'Tunai') _buildCashSection(),
                if (_selectedMethod == 'QRIS') _buildQrisSection(),
                if (_selectedMethod == 'Transfer Bank') _buildBankSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _methodTab(String method, IconData icon) {
    final active = _selectedMethod == method;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = method),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? green : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? green : border,
              width: active ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: active ? Colors.white : darkGreen,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                method,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.bold : FontWeight.w600,
                  color: active ? Colors.white : darkGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // METHOD 1: TUNAI (CASH)
  // -------------------------------------------------------------
  Widget _buildCashSection() {
    final change = _receivedAmount - widget.totalAmount;
    final quickAmounts = {
      widget.totalAmount,
      widget.totalAmount + (widget.totalAmount % 50000 == 0 ? 50000 : 50000 - (widget.totalAmount % 50000)),
      100000,
      200000,
    }.toList()..sort();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Uang Diterima dari Pelanggan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 8),

          // Input uang
          TextField(
            controller: _cashController,
            keyboardType: TextInputType.number,
            onChanged: _onCashChanged,
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: darkGreen,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAF8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: green, width: 1.5),
              ),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // Quick presets
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickAmounts.map((amt) {
              final isExact = amt == widget.totalAmount;
              return InkWell(
                onTap: () {
                  _cashController.text = '$amt';
                  _onCashChanged('$amt');
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _receivedAmount == amt ? lightGreen : const Color(0xFFF1F5F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _receivedAmount == amt ? green : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    isExact ? 'Uang Pas' : formatRupiah(amt),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: _receivedAmount == amt ? green : darkGreen,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const Divider(height: 24),

          // Kembalian
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                change >= 0 ? 'Kembalian' : 'Uang Kurang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: change >= 0 ? muted : const Color(0xFFC93B2B),
                ),
              ),
              Text(
                formatRupiah(change.abs()),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: change >= 0 ? green : const Color(0xFFC93B2B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: change < 0 ? null : _finishPaymentAndShowReceipt,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                disabledBackgroundColor: const Color(0xFFDCE9DF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Konfirmasi & Cetak Struk Belanja',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // METHOD 2: QRIS (DUMMY CODE & CASHIER VERIFICATION)
  // -------------------------------------------------------------
  Widget _buildQrisSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          // QRIS Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE52329),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QRIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 13,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'PEMBAYARAN DIGITAL NASIONAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'WARUNG MAS AMBA',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const Text(
            'NMID: ID1020260429188 · A01',
            style: TextStyle(fontSize: 10.5, color: muted),
          ),

          const SizedBox(height: 12),

          // QR Code Graphic
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD6DFD8), width: 1.5),
            ),
            child: CustomPaint(
              size: const Size(160, 160),
              painter: QrisCodePainter(),
            ),
          ),

          const SizedBox(height: 10),

          // Total & Instruction
          Text(
            formatRupiah(widget.totalAmount),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: green,
            ),
          ),
          const Text(
            'Pindai QRIS ini dengan BCA, Mandiri, BRI, GoPay, OVO, ShopeePay, Dana, dll.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: muted),
          ),

          const SizedBox(height: 14),

          // Status menunggu konfirmasi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: const Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: Color(0xFFB78103), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Menunggu pelanggan scan & bayar. Klik konfirmasi setelah dana masuk.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7A5600),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Tombol Konfirmasi Pembayaran Kasir
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _finishPaymentAndShowReceipt,
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: const Text(
                'Konfirmasi QRIS Berhasil & Cetak Struk',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // METHOD 3: TRANSFER BANK (ALL INDONESIAN BANKS & CONFIRMATION)
  // -------------------------------------------------------------
  Widget _buildBankSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Bank Tujuan Transfer:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 8),

          // Bank Chips Grid / Scroll
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kIndonesianBanks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final bank = kIndonesianBanks[index];
                final isSelected = _selectedBank.code == bank.code;

                return InkWell(
                  onTap: () => setState(() => _selectedBank = bank),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? bank.brandColor : const Color(0xFFF4F6F4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? bank.brandColor : border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        bank.code,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : darkGreen,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // Detail Rekening Terpilih
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedBank.brandColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _selectedBank.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedBank.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Nomor Rekening:',
                  style: TextStyle(fontSize: 11, color: muted),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedBank.accountNumber,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: darkGreen,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: _selectedBank.accountNumber.replaceAll(' ', ''),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Nomor rekening ${_selectedBank.name} disalin ke clipboard!',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.copy, size: 14, color: green),
                            SizedBox(width: 4),
                            Text(
                              'Salin',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Atas Nama:',
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                    Text(
                      _selectedBank.accountHolder,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: darkGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Status Menunggu Konfirmasi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: const Row(
              children: [
                Icon(Icons.receipt_long, color: Color(0xFFB78103), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Periksa mutasi rekening / bukti transfer pelanggan, lalu konfirmasi pembayaran.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7A5600),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Tombol Konfirmasi Transfer Kasir
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _finishPaymentAndShowReceipt,
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: Text(
                'Konfirmasi Transfer ${_selectedBank.code} & Cetak Struk',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // STEP 2: STRUK BELANJA & PENCETAKAN NOTA (RECEIPT VIEW)
  // =========================================================================
  Widget _buildReceiptStep() {
    final now = DateTime.now();
    final dateStr = '${now.day} Okt ${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final rawNumber = widget.orderNumber.replaceAll('#', '').replaceAll('NRV-', '');
    final fullOrderNumber = '#NRV-$rawNumber';

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: green, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Pembayaran Berhasil Diterima',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  widget.onCompleted?.call();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close, color: muted),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Kertas Struk Belanja Thermal
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo / Nama Toko
                      const Text(
                        'WARUNG MAS AMBA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Jl. Melati No. 12, Bandung · 0812-3456-7890',
                        style: TextStyle(fontSize: 10, color: muted),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'NIRVA UMKM POS SYSTEM',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1,
                          color: green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Divider(thickness: 1, height: 1),
                      const SizedBox(height: 8),

                      // Metadata Struk
                      _receiptRow('Waktu', dateStr),
                      _receiptRow('No. Struk', fullOrderNumber),
                      _receiptRow('Kasir', 'Kasir 1 (Mas Amba)'),
                      _receiptRow('Pelanggan', widget.customerName),
                      _receiptRow('Jenis', widget.orderType),

                      const SizedBox(height: 8),
                      const Divider(thickness: 1, height: 1),
                      const SizedBox(height: 10),

                      // Daftar Item
                      ...widget.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: darkGreen,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item.quantity}x @ ${formatRupiah(item.price)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: muted,
                                    ),
                                  ),
                                  Text(
                                    formatRupiah(item.price * item.quantity),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: darkGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      const Divider(thickness: 1, height: 16),

                      // Subtotal & Pajak
                      _receiptRow(
                        'Subtotal',
                        formatRupiah(widget.totalAmount),
                      ),
                      _receiptRow('Diskon', '-Rp0'),
                      _receiptRow('Pajak (0%)', 'Rp0'),

                      const SizedBox(height: 6),
                      const Divider(thickness: 1.5, height: 1),
                      const SizedBox(height: 6),

                      // TOTAL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: darkGreen,
                            ),
                          ),
                          Text(
                            formatRupiah(widget.totalAmount),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      const Divider(thickness: 1, height: 1),
                      const SizedBox(height: 8),

                      // Metode Pembayaran Detail
                      _receiptRow(
                        'Metode Bayar',
                        _selectedMethod == 'Transfer Bank'
                            ? 'Transfer ${_selectedBank.code}'
                            : _selectedMethod,
                      ),
                      if (_selectedMethod == 'Tunai') ...[
                        _receiptRow('Uang Diterima', formatRupiah(_receivedAmount)),
                        _receiptRow(
                          'Kembalian',
                          formatRupiah(max(0, _receivedAmount - widget.totalAmount)),
                        ),
                      ],

                      if (widget.notes.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _receiptRow('Catatan', widget.notes),
                      ],

                      const SizedBox(height: 12),

                      // LUNAS BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: green, width: 1.5),
                        ),
                        child: const Text(
                          '*** LUNAS / PAID ***',
                          style: TextStyle(
                            color: green,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Text(
                        'Terima kasih atas kunjungan Anda!\nBarang yang sudah dibeli tidak dapat ditukar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: muted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons (Cetak Struk, Kirim, Selesai)
                Row(
                  children: [
                    // Tombol Cetak Nota
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: _isPrinting ? null : _simulatePrintReceipt,
                        icon: _isPrinting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.print_outlined, size: 18),
                        label: Text(
                          _isPrinting ? 'Mencetak...' : 'Cetak Nota',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tombol Kirim WhatsApp / Bagikan
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Nota belanja siap dibagikan via WhatsApp!',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_outlined, size: 16),
                        label: const Text('Kirim'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: darkGreen,
                          side: const BorderSide(color: border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Tombol Selesai
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () {
                      widget.onCompleted?.call();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Selesai & Transaksi Baru',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: green,
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

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: muted)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// CUSTOM PAINTER UNTUK QRIS CODE
// =========================================================================
class QrisCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3528)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final unit = w / 25; // 25x25 grid

    // Function to draw QR Finder Pattern (corners)
    void drawFinder(double x, double y) {
      // Outer 7x7
      canvas.drawRect(Rect.fromLTWH(x, y, unit * 7, unit * 7), paint);
      // Inner 5x5 clear
      canvas.drawRect(
        Rect.fromLTWH(x + unit, y + unit, unit * 5, unit * 5),
        Paint()..color = Colors.white,
      );
      // Center 3x3
      canvas.drawRect(
        Rect.fromLTWH(x + unit * 2, y + unit * 2, unit * 3, unit * 3),
        paint,
      );
    }

    // Top-Left
    drawFinder(0, 0);
    // Top-Right
    drawFinder(unit * 18, 0);
    // Bottom-Left
    drawFinder(0, unit * 18);

    // Timing patterns
    for (int i = 8; i < 17; i += 2) {
      canvas.drawRect(Rect.fromLTWH(unit * 6, unit * i, unit, unit), paint);
      canvas.drawRect(Rect.fromLTWH(unit * i, unit * 6, unit, unit), paint);
    }

    // Pseudo-random data modules (deterministic pattern)
    for (int r = 0; r < 25; r++) {
      for (int c = 0; c < 25; c++) {
        // Skip corner finder zones
        if ((r < 8 && c < 8) || (r < 8 && c > 16) || (r > 16 && c < 8)) continue;
        // Skip central logo area
        if (r >= 10 && r <= 14 && c >= 10 && c <= 14) continue;

        if (((r * 7 + c * 13 + (r * c)) % 3 == 0) || ((r + c) % 5 == 0)) {
          canvas.drawRect(Rect.fromLTWH(c * unit, r * unit, unit, unit), paint);
        }
      }
    }

    // Center QRIS Logo Box
    final centerRect = Rect.fromLTWH(unit * 9.5, unit * 9.5, unit * 6, unit * 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, Radius.circular(unit)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, Radius.circular(unit)),
      Paint()
        ..color = const Color(0xFFE52329)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Little red Q mark inside center
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      unit * 1.6,
      Paint()..color = const Color(0xFFE52329),
    );
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      unit * 0.9,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
