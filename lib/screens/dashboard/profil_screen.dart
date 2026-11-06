import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';

class ProfilScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback? onDataChanged;

  const ProfilScreen({super.key, required this.onLogout, this.onDataChanged});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  static const Color green = Color(0xFF2E7450);
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickProfilePhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (image == null) return;

    AuthService.updateProfileImage(await image.readAsBytes());
    setState(() {});
    widget.onDataChanged?.call();
    _showMessage('Foto profil berhasil diperbarui.');
  }

  void _openEditOwnerSheet() {
    final data = businessData;
    final nameController = TextEditingController(text: data.ownerName);
    final phoneController = TextEditingController(text: data.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Edit Profil Pemilik',
                      style: TextStyle(
                        fontSize: 18,
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
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nama Pemilik',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      AuthService.updateOwnerProfile(
                        ownerName: nameController.text,
                        phone: phoneController.text,
                      );
                      setState(() {});
                      widget.onDataChanged?.call();
                      Navigator.pop(sheetContext);
                      _showMessage('Profil pemilik berhasil diperbarui.');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openEditBusinessSheet() {
    final data = businessData;
    final businessController = TextEditingController(text: data.businessName);
    final addressController = TextEditingController(text: data.address);
    final descriptionController = TextEditingController(text: data.description);
    final productsController = TextEditingController(
      text: data.featuredProducts,
    );
    String category = data.category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Ubah Data Usaha',
                        style: TextStyle(
                          fontSize: 18,
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: businessController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Nama Usaha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Alamat Usaha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Usaha',
                      hintText: 'Ceritakan usaha Anda',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: productsController,
                    decoration: InputDecoration(
                      labelText: 'Produk Unggulan',
                      hintText: 'Contoh: Nasi Ayam, Es Teh',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kategori Usaha',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['Kuliner', 'Fesyen', 'Ritel'].map((item) {
                      final active = category == item;
                      return ChoiceChip(
                        label: Text(item),
                        selected: active,
                        onSelected: (_) {
                          setSheetState(() => category = item);
                        },
                        selectedColor: green,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: active ? Colors.white : darkGreen,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        AuthService.updateBusinessProfile(
                          businessName: businessController.text,
                          address: addressController.text,
                          category: category,
                          description: descriptionController.text,
                          featuredProducts: productsController.text,
                        );
                        setState(() {});
                        widget.onDataChanged?.call();
                        Navigator.pop(sheetContext);
                        _showMessage('Data usaha berhasil diperbarui.');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Simpan Usaha',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductsCard(UserBusinessData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Produk & rating pelanggan',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Produk unggulan berdasarkan penilaian customer.',
            style: TextStyle(fontSize: 13, color: mutedText),
          ),
          const SizedBox(height: 14),
          if (data.products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Belum ada produk. Tambahkan produk untuk melihat rating pelanggan.',
                style: TextStyle(color: mutedText, height: 1.4),
              ),
            )
          else
            ...data.products.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fastfood_outlined,
                        color: green,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              color: darkGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            formatRupiah(product.price),
                            style: const TextStyle(
                              color: mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (product.rating > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 17,
                                color: Color(0xFFE7A51B),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: darkGreen,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${product.reviewCount} ulasan',
                            style: const TextStyle(
                              color: mutedText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Belum ada rating',
                        style: TextStyle(color: mutedText, fontSize: 11),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = businessData;

    final settingsMenus = [
      (Icons.people_outline_rounded, 'Kelola tim'),
      (Icons.print_outlined, 'Pengaturan struk'),
      (Icons.notifications_none_rounded, 'Notifikasi'),
      (Icons.help_outline_rounded, 'Pusat bantuan'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          const Text(
            'Profil',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: darkGreen,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 16),

          // OWNER PROFILE CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: _pickProfilePhoto,
                      borderRadius: BorderRadius.circular(34),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE6F2EA),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: data.profileImageBytes == null
                            ? Text(
                                data.ownerInitials,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: green,
                                ),
                              )
                            : ClipOval(
                                child: Image.memory(
                                  data.profileImageBytes!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.ownerName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: darkGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pemilik usaha',
                            style: TextStyle(fontSize: 14, color: mutedText),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _openEditOwnerSheet,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: green,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEAF0EB)),
                const SizedBox(height: 14),
                Text(
                  data.email,
                  style: const TextStyle(fontSize: 15, color: mutedText),
                ),
                const SizedBox(height: 10),
                Text(
                  data.phone.isEmpty ? '-' : data.phone,
                  style: const TextStyle(fontSize: 15, color: mutedText),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // USAHA SAYA HEADER
          Row(
            children: [
              const Text(
                'Usaha saya',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: darkGreen,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _openEditBusinessSheet,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Text(
                    'Ubah',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: green,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // BUSINESS CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.storefront_outlined,
                        color: green,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.businessName,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: darkGreen,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            data.address,
                            style: const TextStyle(
                              fontSize: 14,
                              color: mutedText,
                            ),
                          ),
                          if (data.description.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              data.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: mutedText,
                                height: 1.4,
                              ),
                            ),
                          ],
                          if (data.featuredProducts.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Produk unggulan',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: darkGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.featuredProducts,
                              style: const TextStyle(
                                fontSize: 14,
                                color: mutedText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F2EA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${data.category} · Usaha aktif',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: green,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildProductsCard(data),

          // SETTINGS MENU CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              children: settingsMenus.map((item) {
                return ListTile(
                  onTap: () => _showMessage('Menu ${item.$2} dipilih.'),
                  leading: Icon(item.$1, color: green, size: 22),
                  title: Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: darkGreen,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: mutedText,
                    size: 22,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // LOGOUT BUTTON
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: widget.onLogout,
              style: OutlinedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: green,
                side: const BorderSide(color: cardBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, color: green, size: 20),
              label: const Text(
                'Keluar dari akun',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // FOOTER
          const Center(
            child: Text(
              'NIRVA UMKM · Versi 1.0.0',
              style: TextStyle(fontSize: 12, color: mutedText),
            ),
          ),
        ],
      ),
    );
  }
}
