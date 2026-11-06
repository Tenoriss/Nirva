import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const green = Color(0xFF347B57);
  static const darkGreen = Color(0xFF233D30);
  static const background = Color(0xFFF6F9F6);

  final _accountFormKey = GlobalKey<FormState>();
  final _businessFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessController = TextEditingController();

  int currentStep = 0;

  bool obscurePassword = true;
  bool agreeTerms = false;

  String selectedCategory = 'Kuliner';

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Kuliner',
      'description': 'Makanan, minuman, dan katering',
      'icon': Icons.restaurant_outlined,
    },
    {
      'name': 'Fesyen',
      'description': 'Pakaian, sepatu, dan aksesori',
      'icon': Icons.checkroom_outlined,
    },
    {
      'name': 'Ritel',
      'description': 'Toko kelontong dan kebutuhan harian',
      'icon': Icons.shopping_bag_outlined,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  InputDecoration decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF829188)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDDE6DE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDDE6DE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: green, width: 1.5),
      ),
    );
  }

  Widget fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkGreen,
        ),
      ),
    );
  }

  Widget progressIndicator() {
    return Row(
      children: List.generate(2, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index == 0 ? 5 : 0,
              left: index == 1 ? 5 : 0,
            ),
            height: 4,
            decoration: BoxDecoration(
              color: index <= currentStep ? green : const Color(0xFFDDE6DE),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }

  void nextStep() {
    if (!_accountFormKey.currentState!.validate()) return;

    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan setujui syarat penggunaan dan kebijakan privasi.',
          ),
        ),
      );
      return;
    }

    setState(() {
      currentStep = 1;
    });
  }

  void previousStep() {
    setState(() {
      currentStep = 0;
    });
  }

  void finishRegistration() {
    if (!_businessFormKey.currentState!.validate()) return;

    final success = AuthService.register(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
      businessName: _businessController.text,
      category: selectedCategory,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email sudah terdaftar. Silakan gunakan email lain.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registrasi berhasil! Silakan login dengan akun Anda.'),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget accountStep() {
    return Form(
      key: _accountFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kenalan dulu, yuk.',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Buat akun untuk mulai mengelola usaha dengan lebih mudah.',
            style: TextStyle(color: Color(0xFF708077), fontSize: 14),
          ),
          const SizedBox(height: 20),

          fieldLabel('Nama pemilik'),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: decoration(
              'Masukkan nama lengkap',
              Icons.person_outline,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama pemilik wajib diisi';
              }
              if (value.trim().length < 3) {
                return 'Nama minimal 3 karakter';
              }
              return null;
            },
          ),

          const SizedBox(height: 15),

          fieldLabel('Nomor ponsel'),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: decoration(
              'Contoh: 0812 3456 7890',
              Icons.phone_outlined,
            ),
            validator: (value) {
              final phone = value?.replaceAll(RegExp(r'[\s-]'), '') ?? '';

              if (phone.isEmpty) {
                return 'Nomor ponsel wajib diisi';
              }

              if (!RegExp(r'^(\+62|0)[0-9]{8,13}$').hasMatch(phone)) {
                return 'Nomor ponsel tidak valid';
              }

              return null;
            },
          ),

          const SizedBox(height: 15),

          fieldLabel('Email'),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: decoration('Masukkan email aktif', Icons.mail_outline),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email wajib diisi';
              }

              if (!RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              ).hasMatch(value.trim())) {
                return 'Format email tidak valid';
              }

              return null;
            },
          ),

          const SizedBox(height: 15),

          fieldLabel('Kata sandi'),
          TextFormField(
            controller: _passwordController,
            obscureText: obscurePassword,
            decoration: decoration('Masukkan kata sandi', Icons.lock_outline)
                .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata sandi wajib diisi';
              }
              if (value.length < 8 ||
                  !RegExp(r'[A-Za-z]').hasMatch(value) ||
                  !RegExp(r'[0-9]').hasMatch(value)) {
                return 'Minimal 8 karakter, huruf dan angka';
              }
              return null;
            },
          ),

          const SizedBox(height: 8),

          const Text(
            'Gunakan minimal 8 karakter, huruf dan angka.',
            style: TextStyle(fontSize: 12, color: Color(0xFF708077)),
          ),

          const SizedBox(height: 10),

          CheckboxListTile(
            value: agreeTerms,
            onChanged: (value) {
              setState(() {
                agreeTerms = value ?? false;
              });
            },
            activeColor: green,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Saya menyetujui Syarat Penggunaan dan Kebijakan Privasi NIRVA UMKM.',
              style: TextStyle(fontSize: 12, color: Color(0xFF708077)),
            ),
          ),
        ],
      ),
    );
  }

  Widget businessStep() {
    return Form(
      key: _businessFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ruang untuk usaha Anda.',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ceritakan usaha Anda agar NIRVA bisa membantu dengan lebih tepat.',
            style: TextStyle(fontSize: 14, color: Color(0xFF708077)),
          ),

          const SizedBox(height: 22),

          fieldLabel('Nama usaha'),
          TextFormField(
            controller: _businessController,
            textCapitalization: TextCapitalization.words,
            decoration: decoration(
              'Contoh: Warung Mas Amba',
              Icons.storefront_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama usaha wajib diisi';
              }
              if (value.trim().length < 3) {
                return 'Nama usaha minimal 3 karakter';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          fieldLabel('Kategori usaha'),

          ...categories.map((category) {
            final isSelected = selectedCategory == category['name'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(17),
                onTap: () {
                  setState(() {
                    selectedCategory = category['name'];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEAF3E9) : Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: isSelected ? green : const Color(0xFFDDE6DE),
                      width: isSelected ? 1.3 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(category['icon'], color: green, size: 23),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: darkGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category['description'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF708077),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle_outline
                            : Icons.circle_outlined,
                        color: isSelected ? green : const Color(0xFFDDE6DE),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 5),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: green, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Data usaha dan kategori dapat diubah kapan saja melalui Profil.',
                    style: TextStyle(fontSize: 13, color: green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGreen),
          onPressed: () {
            if (currentStep == 1) {
              previousStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          currentStep == 0 ? 'Daftar akun' : 'Daftar usaha',
          style: const TextStyle(fontWeight: FontWeight.bold, color: darkGreen),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    progressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      currentStep == 0
                          ? 'LANGKAH 1 DARI 2 · AKUN ANDA'
                          : 'LANGKAH 2 DARI 2 · USAHA ANDA',
                      style: const TextStyle(
                        color: green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    currentStep == 0 ? accountStep() : businessStep(),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE0E8E1))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: currentStep == 0 ? nextStep : finishRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    currentStep == 0
                        ? 'Lanjutkan ke data usaha'
                        : 'Buka ruang usaha saya',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
