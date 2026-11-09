import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'cashier_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderItem order;
  final VoidCallback? onDataChanged;
  final VoidCallback? onProcessOrder;

  const OrderDetailScreen({
    super.key,
    required this.order,
    this.onDataChanged,
    this.onProcessOrder,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  static const green = Color(0xFF347B57);
  static const darkGreen = Color(0xFF1E3528);
  static const mutedText = Color(0xFF6B7B72);
  static const cardBorder = Color(0xFFDDE6DE);

  OrderItem get order => widget.order;

  void _processOrder() {
    AuthService.updateOrderStatus(order, 'Diproses');
    widget.onDataChanged?.call();

    if (widget.onProcessOrder != null) {
      widget.onProcessOrder!();
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CashierScreen(
          order: order,
          autoOpenCart: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F9F6),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: darkGreen),
        ),
        title: const Text(
          'Detail pesanan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur lainnya akan segera tersedia.'),
              ),
            ),
            icon: const Icon(Icons.more_horiz, color: darkGreen),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#NRV-${order.orderNumber.replaceFirst('#', '')}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                  ),
                  _statusBadge(order.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '6 Okt 2026 · ${order.time}',
                style: const TextStyle(fontSize: 11, color: mutedText),
              ),
              const SizedBox(height: 16),
              _customerCard(),
              const SizedBox(height: 18),
              const Text(
                'Rincian pesanan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 9),
              _itemsCard(),
              const SizedBox(height: 14),
              _summaryCard(),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _processOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Proses pesanan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customerCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _decoration(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 21,
            backgroundColor: Color(0xFFEAF3E9),
            child: Icon(Icons.person_outline, color: green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  order.orderType,
                  style: const TextStyle(fontSize: 11, color: mutedText),
                ),
                const SizedBox(height: 3),
                Text(
                  'Catatan: ${order.notes}',
                  style: const TextStyle(fontSize: 10, color: mutedText),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nomor pelanggan belum tersedia.')),
            ),
            icon: const Icon(Icons.phone_outlined, color: green, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _itemsCard() {
    final items = order.itemsSummary.split(', ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _decoration(),
      child: Column(
        children: [
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3E9),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.restaurant_outlined,
                      color: green,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: darkGreen,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: mutedText, size: 19),
                ],
              ),
            ),
          ),
          const Divider(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 11, color: mutedText),
              ),
              Text(
                formatRupiah(order.totalAmount),
                style: const TextStyle(fontSize: 12, color: darkGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total pembayaran',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: darkGreen,
            ),
          ),
          Text(
            formatRupiah(order.totalAmount),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status == 'Selesai'
            ? const Color(0xFFEAF3E9)
            : const Color(0xFFFFF3D7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: status == 'Selesai' ? green : const Color(0xFF9A6900),
        ),
      ),
    );
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: cardBorder),
    );
  }
}
