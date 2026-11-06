import 'dart:typed_data';

class TransactionItem {
  final String name;
  final String detail;
  final int amount;

  const TransactionItem({
    required this.name,
    required this.detail,
    required this.amount,
  });
}

class ExpenseItem {
  final String title;
  final String detail;
  final int amount;

  const ExpenseItem({
    required this.title,
    required this.detail,
    required this.amount,
  });
}

class ProductItem {
  final String name;
  final int price;
  final int stock;
  final double rating;
  final int reviewCount;

  const ProductItem({
    required this.name,
    required this.price,
    this.stock = 0,
    this.rating = 0,
    this.reviewCount = 0,
  });
}

class OrderItem {
  final String id;
  final String customerName;
  final String orderNumber;
  String status; // 'Baru', 'Diproses', 'Selesai'
  final String time;
  final String orderType;
  final String itemsSummary;
  final int totalAmount;
  bool isPaid;

  OrderItem({
    required this.id,
    required this.customerName,
    required this.orderNumber,
    required this.status,
    required this.time,
    required this.orderType,
    required this.itemsSummary,
    required this.totalAmount,
    required this.isPaid,
  });
}

class TopProductItem {
  final String name;
  final int revenue;
  final String soldLabel;

  const TopProductItem({
    required this.name,
    required this.revenue,
    required this.soldLabel,
  });
}

class UserBusinessData {
  String ownerName;
  String businessName;
  String category;
  String phone;
  String email;
  String address;
  String description;
  String featuredProducts;
  Uint8List? profileImageBytes;
  int omzetToday;
  int newOrders;
  int processingOrders;
  int completedOrders;
  int income;
  int expense;
  String reportPeriod;
  List<double> weeklyChartValues;
  bool isDemo;
  final List<TransactionItem> transactions;
  final List<ExpenseItem> expenses;
  final List<ProductItem> products;
  final List<OrderItem> orders;
  final List<TopProductItem> topProducts;

  UserBusinessData({
    required this.ownerName,
    required this.businessName,
    required this.category,
    required this.phone,
    required this.email,
    this.address = 'Belum diatur',
    this.description = '',
    this.featuredProducts = '',
    this.profileImageBytes,
    this.omzetToday = 0,
    this.newOrders = 0,
    this.processingOrders = 0,
    this.completedOrders = 0,
    this.income = 0,
    this.expense = 0,
    this.reportPeriod = '30 Sep – 6 Okt 2026',
    List<double>? weeklyChartValues,
    this.isDemo = false,
    List<TransactionItem>? transactions,
    List<ExpenseItem>? expenses,
    List<ProductItem>? products,
    List<OrderItem>? orders,
    List<TopProductItem>? topProducts,
  }) : weeklyChartValues =
           weeklyChartValues ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
       transactions = transactions ?? [],
       expenses = expenses ?? [],
       products = products ?? [],
       orders = orders ?? [],
       topProducts = topProducts ?? [];

  int get totalOrdersCount => newOrders + processingOrders + completedOrders;

  int get netProfit => income - expense;

  bool get hasInsightData =>
      isDemo ||
      income > 0 ||
      expense > 0 ||
      transactions.isNotEmpty ||
      topProducts.isNotEmpty;

  String get ownerInitials {
    final parts = ownerName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'NU';
    if (parts.length == 1) {
      final word = parts.first.toUpperCase();
      return word.length >= 2 ? word.substring(0, 2) : word;
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory UserBusinessData.empty({
    required String ownerName,
    required String businessName,
    required String category,
    required String phone,
    required String email,
    String address = 'Alamat usaha belum diatur',
  }) {
    return UserBusinessData(
      ownerName: ownerName,
      businessName: businessName,
      category: category,
      phone: phone,
      email: email,
      address: address,
      description: '',
      featuredProducts: '',
      omzetToday: 0,
      newOrders: 0,
      processingOrders: 0,
      completedOrders: 0,
      income: 0,
      expense: 0,
      reportPeriod: '30 Sep – 6 Okt 2026',
      weeklyChartValues: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      isDemo: false,
      transactions: [],
      expenses: [],
      products: [],
      orders: [],
      topProducts: [],
    );
  }

  factory UserBusinessData.demo({String email = 'masamba@warungmasamba.id'}) {
    return UserBusinessData(
      ownerName: 'Mas Amba',
      businessName: 'Warung Mas Amba',
      category: 'Kuliner',
      phone: '0812 3456 7890',
      email: email,
      address: 'Jl. Melati No. 12, Bandung',
      description:
          'Kuliner rumahan dengan menu hangat untuk pelanggan sekitar.',
      featuredProducts: 'Nasi Ayam, Es Teh, Nasi Telur',
      omzetToday: 540000,
      newOrders: 3,
      processingOrders: 2,
      completedOrders: 12,
      income: 3420000,
      expense: 2180000,
      reportPeriod: '30 Sep – 6 Okt 2026',
      weeklyChartValues: [0.48, 0.66, 0.54, 0.92, 0.82, 0.60, 0.78],
      isDemo: true,
      transactions: [
        const TransactionItem(
          name: 'Rina',
          detail: '09.41 · Tunai',
          amount: 54000,
        ),
        const TransactionItem(
          name: 'Budi',
          detail: '09.25 · QRIS',
          amount: 36000,
        ),
      ],
      expenses: [],
      products: [
        const ProductItem(
          name: 'Nasi Ayam',
          price: 25000,
          stock: 30,
          rating: 4.9,
          reviewCount: 128,
        ),
        const ProductItem(
          name: 'Es Teh',
          price: 5000,
          stock: 50,
          rating: 4.8,
          reviewCount: 96,
        ),
        const ProductItem(
          name: 'Nasi Telur',
          price: 18000,
          stock: 25,
          rating: 4.7,
          reviewCount: 74,
        ),
        const ProductItem(
          name: 'Kopi Susu',
          price: 12000,
          stock: 20,
          rating: 4.6,
          reviewCount: 51,
        ),
      ],
      orders: [
        OrderItem(
          id: '042',
          customerName: 'Rina',
          orderNumber: '#042',
          status: 'Baru',
          time: '09.35',
          orderType: 'Bawa pulang',
          itemsSummary: '2 Nasi Ayam, 2 Es Teh',
          totalAmount: 60000,
          isPaid: false,
        ),
        OrderItem(
          id: '041',
          customerName: 'Andi',
          orderNumber: '#041',
          status: 'Diproses',
          time: '09.30',
          orderType: 'Bawa pulang',
          itemsSummary: '1 Nasi Ayam, 1 Kopi Susu',
          totalAmount: 37000,
          isPaid: false,
        ),
        OrderItem(
          id: '040',
          customerName: 'Budi',
          orderNumber: '#040',
          status: 'Selesai',
          time: '09.25',
          orderType: 'Bawa pulang',
          itemsSummary: '2 Nasi Telur',
          totalAmount: 36000,
          isPaid: true,
        ),
      ],
      topProducts: [
        const TopProductItem(
          name: 'Nasi Ayam',
          revenue: 1700000,
          soldLabel: '68 porsi terjual',
        ),
        const TopProductItem(
          name: 'Es Teh',
          revenue: 480000,
          soldLabel: '96 gelas terjual',
        ),
        const TopProductItem(
          name: 'Nasi Telur',
          revenue: 756000,
          soldLabel: '42 porsi terjual',
        ),
      ],
    );
  }
}

String formatRupiah(int amount) {
  if (amount == 0) return 'Rp0';
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return '${amount < 0 ? '-Rp' : 'Rp'}$buffer';
}

class AuthService {
  static const String demoEmail = 'masamba@warungmasamba.id';
  static const String demoPassword = 'password123';

  static final Set<String> _demoEmailAliases = {
    'masamba@warungmasamba.id',
    'demo@nirva.id',
    'amba@nirva.id',
    'amba@gmail.com',
    'masamba@gmail.com',
    'warungmasamba@gmail.com',
  };

  static final UserBusinessData _sharedDemoData = UserBusinessData.demo();

  static final Map<String, Map<String, String>> _accounts = {
    for (final email in _demoEmailAliases)
      email: {
        'name': 'Mas Amba',
        'phone': '0812 3456 7890',
        'email': 'masamba@warungmasamba.id',
        'password': demoPassword,
        'businessName': 'Warung Mas Amba',
        'category': 'Kuliner',
      },
  };

  static final Map<String, UserBusinessData> _businessDataByEmail = {
    for (final email in _demoEmailAliases) email: _sharedDemoData,
  };

  static String? currentEmail;

  static Map<String, String>? get currentAccount {
    if (currentEmail == null) return null;
    return _accounts[currentEmail!];
  }

  static UserBusinessData? get currentBusinessData {
    if (currentEmail == null) return null;
    final key = currentEmail!.trim().toLowerCase();

    if (_businessDataByEmail.containsKey(key)) {
      return _businessDataByEmail[key];
    }

    final account = _accounts[key];
    if (account != null) {
      final data = UserBusinessData.empty(
        ownerName: account['name'] ?? 'Pemilik Usaha',
        businessName: account['businessName'] ?? 'Usaha Saya',
        category: account['category'] ?? 'Kuliner',
        phone: account['phone'] ?? '',
        email: key,
      );
      _businessDataByEmail[key] = data;
      return data;
    }

    return null;
  }

  // Registrasi akun baru dengan data usaha kosong (Rp0)
  static bool register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String businessName,
    required String category,
  }) {
    final key = email.trim().toLowerCase();

    if (_accounts.containsKey(key)) {
      return false;
    }

    final cleanName = name.trim();
    final cleanPhone = phone.trim();
    final cleanBusinessName = businessName.trim();

    _accounts[key] = {
      'name': cleanName,
      'phone': cleanPhone,
      'email': key,
      'password': password,
      'businessName': cleanBusinessName,
      'category': category,
    };

    _businessDataByEmail[key] = UserBusinessData.empty(
      ownerName: cleanName,
      businessName: cleanBusinessName,
      category: category,
      phone: cleanPhone,
      email: key,
    );

    // Tidak langsung login setelah registrasi.
    currentEmail = null;

    return true;
  }

  // Login berdasarkan email dan password akun
  static bool login({required String email, required String password}) {
    final key = email.trim().toLowerCase();

    final account = _accounts[key];
    if (account == null) {
      return false;
    }

    final isDemoAlias = _demoEmailAliases.contains(key);
    final validDemoPasswords = {
      demoPassword,
      '12345678',
      'amba1234',
      'demo1234',
    };

    final passwordMatches =
        account['password'] == password ||
        (isDemoAlias && validDemoPasswords.contains(password));

    if (!passwordMatches) {
      return false;
    }

    currentEmail = key;

    if (isDemoAlias) {
      _businessDataByEmail[key] = _sharedDemoData;
    } else {
      _businessDataByEmail.putIfAbsent(
        key,
        () => UserBusinessData.empty(
          ownerName: account['name'] ?? 'Pemilik Usaha',
          businessName: account['businessName'] ?? 'Usaha Saya',
          category: account['category'] ?? 'Kuliner',
          phone: account['phone'] ?? '',
          email: key,
        ),
      );
    }

    return true;
  }

  // Logout membersihkan pengguna aktif tanpa menghapus data akun
  static void logout() {
    currentEmail = null;
  }

  // Fitur Kasir: mencatat transaksi penjualan/pemasukan baru untuk akun aktif
  static void addTransaction({
    required String customerName,
    required int amount,
    String paymentMethod = 'Tunai',
    String itemsSummary = 'Transaksi Kasir',
    String orderType = 'Bawa pulang',
    String? timeLabel,
  }) {
    final data = currentBusinessData;
    if (data == null || amount <= 0) return;

    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final time = timeLabel ?? '$hh.$mm';
    final cleanCustomer = customerName.trim().isEmpty
        ? 'Pelanggan'
        : customerName.trim();

    data.income += amount;
    data.omzetToday += amount;
    data.completedOrders += 1;
    data.transactions.insert(
      0,
      TransactionItem(
        name: cleanCustomer,
        detail: '$time · $paymentMethod',
        amount: amount,
      ),
    );

    final nextOrderNum = (data.isDemo ? 40 : 0) + data.orders.length + 1;
    final formattedNumber = '#${nextOrderNum.toString().padLeft(3, '0')}';

    data.orders.insert(
      0,
      OrderItem(
        id: nextOrderNum.toString(),
        customerName: cleanCustomer,
        orderNumber: formattedNumber,
        status: 'Selesai',
        time: time,
        orderType: orderType,
        itemsSummary: itemsSummary,
        totalAmount: amount,
        isPaid: true,
      ),
    );

    if (!data.isDemo && data.weeklyChartValues.every((v) => v == 0.0)) {
      data.weeklyChartValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.75];
    }
  }

  // Fitur Pesanan: membuat pesanan baru dari halaman Pesanan
  static void createOrder({
    required String customerName,
    required String itemsSummary,
    required int totalAmount,
    String orderType = 'Bawa pulang',
    String status = 'Baru',
    bool isPaid = false,
  }) {
    final data = currentBusinessData;
    if (data == null || totalAmount <= 0) return;

    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final time = '$hh.$mm';
    final cleanCustomer = customerName.trim().isEmpty
        ? 'Pelanggan'
        : customerName.trim();
    final cleanItems = itemsSummary.trim().isEmpty
        ? 'Pesanan Usaha'
        : itemsSummary.trim();

    final nextOrderNum = (data.isDemo ? 40 : 0) + data.orders.length + 1;
    final formattedNumber = '#${nextOrderNum.toString().padLeft(3, '0')}';

    if (status == 'Baru') {
      data.newOrders += 1;
    } else if (status == 'Diproses') {
      data.processingOrders += 1;
    } else {
      data.completedOrders += 1;
    }

    if (isPaid) {
      data.omzetToday += totalAmount;
      data.income += totalAmount;
      data.transactions.insert(
        0,
        TransactionItem(
          name: cleanCustomer,
          detail: '$time · Tunai',
          amount: totalAmount,
        ),
      );
      if (!data.isDemo && data.weeklyChartValues.every((v) => v == 0.0)) {
        data.weeklyChartValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.75];
      }
    }

    data.orders.insert(
      0,
      OrderItem(
        id: nextOrderNum.toString(),
        customerName: cleanCustomer,
        orderNumber: formattedNumber,
        status: status,
        time: time,
        orderType: orderType,
        itemsSummary: cleanItems,
        totalAmount: totalAmount,
        isPaid: isPaid,
      ),
    );
  }

  // Mengubah status pesanan (Baru, Diproses, Selesai)
  static void updateOrderStatus(OrderItem order, String newStatus) {
    final data = currentBusinessData;
    if (data == null || order.status == newStatus) return;

    if (order.status == 'Baru' && data.newOrders > 0) {
      data.newOrders -= 1;
    } else if (order.status == 'Diproses' && data.processingOrders > 0) {
      data.processingOrders -= 1;
    } else if (order.status == 'Selesai' && data.completedOrders > 0) {
      data.completedOrders -= 1;
    }

    order.status = newStatus;

    if (newStatus == 'Baru') {
      data.newOrders += 1;
    } else if (newStatus == 'Diproses') {
      data.processingOrders += 1;
    } else if (newStatus == 'Selesai') {
      data.completedOrders += 1;
    }
  }

  // Menandai pesanan sudah dibayar
  static void markOrderPaid(OrderItem order, {String paymentMethod = 'Tunai'}) {
    final data = currentBusinessData;
    if (data == null || order.isPaid) return;

    order.isPaid = true;
    data.omzetToday += order.totalAmount;
    data.income += order.totalAmount;
    data.transactions.insert(
      0,
      TransactionItem(
        name: order.customerName,
        detail: '${order.time} · $paymentMethod',
        amount: order.totalAmount,
      ),
    );
    if (!data.isDemo && data.weeklyChartValues.every((v) => v == 0.0)) {
      data.weeklyChartValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.75];
    }
  }

  // Fitur Keuangan: mencatat pengeluaran usaha untuk akun aktif
  static void addExpense({
    required String title,
    required int amount,
    String? timeLabel,
  }) {
    final data = currentBusinessData;
    if (data == null || amount <= 0) return;

    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final time = timeLabel ?? '$hh.$mm';

    data.expense += amount;
    data.expenses.insert(
      0,
      ExpenseItem(
        title: title.trim().isEmpty ? 'Pengeluaran Usaha' : title.trim(),
        detail: '$time · Pengeluaran',
        amount: amount,
      ),
    );
  }

  // Fitur Produk: menambah produk untuk akun aktif
  static void addProduct({
    required String name,
    required int price,
    int stock = 0,
  }) {
    final data = currentBusinessData;
    if (data == null || name.trim().isEmpty || price < 0) return;

    data.products.add(
      ProductItem(name: name.trim(), price: price, stock: stock),
    );
  }

  // Fitur Profil: memperbarui profil pemilik
  static void updateOwnerProfile({
    required String ownerName,
    required String phone,
  }) {
    final data = currentBusinessData;
    if (data == null) return;

    if (ownerName.trim().isNotEmpty) {
      data.ownerName = ownerName.trim();
      if (currentEmail != null && _accounts.containsKey(currentEmail)) {
        _accounts[currentEmail!]!['name'] = data.ownerName;
      }
    }
    if (phone.trim().isNotEmpty) {
      data.phone = phone.trim();
      if (currentEmail != null && _accounts.containsKey(currentEmail)) {
        _accounts[currentEmail!]!['phone'] = data.phone;
      }
    }
  }

  // Fitur Profil: memperbarui informasi usaha
  static void updateBusinessProfile({
    required String businessName,
    required String address,
    required String category,
    String? description,
    String? featuredProducts,
  }) {
    final data = currentBusinessData;
    if (data == null) return;

    if (businessName.trim().isNotEmpty) {
      data.businessName = businessName.trim();
      if (currentEmail != null && _accounts.containsKey(currentEmail)) {
        _accounts[currentEmail!]!['businessName'] = data.businessName;
      }
    }
    if (address.trim().isNotEmpty) {
      data.address = address.trim();
    }
    if (category.trim().isNotEmpty) {
      data.category = category.trim();
      if (currentEmail != null && _accounts.containsKey(currentEmail)) {
        _accounts[currentEmail!]!['category'] = data.category;
      }
    }
    if (description != null) data.description = description.trim();
    if (featuredProducts != null) {
      data.featuredProducts = featuredProducts.trim();
    }
  }

  static void updateProfileImage(Uint8List bytes) {
    final data = currentBusinessData;
    if (data != null) data.profileImageBytes = bytes;
  }
}
