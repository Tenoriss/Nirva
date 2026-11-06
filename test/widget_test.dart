import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirva_umkm/screens/dashboard/dashboard_screen.dart';
import 'package:nirva_umkm/services/auth_service.dart';

void main() {
  testWidgets('Pengujian lengkap Akun Demo dan Akun Baru pada 4 halaman utama', (
    WidgetTester tester,
  ) async {
    // === AKUN DEMO ===
    // 1. Login akun demo
    final demoLoginSuccess = AuthService.login(
      email: AuthService.demoEmail,
      password: AuthService.demoPassword,
    );
    expect(demoLoginSuccess, isTrue);

    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    // 2. Buka Beranda
    expect(find.text('Warung Mas Amba'), findsWidgets);
    expect(find.text('Rp540.000'), findsOneWidget);

    // 3. Klik Pesanan, pastikan 17 pesanan dan ketiga kartu sesuai
    await tester.tap(find.text('Pesanan'));
    await tester.pump();

    expect(find.text('Semua 17'), findsOneWidget);
    expect(find.text('Baru 3'), findsOneWidget);
    expect(find.text('Diproses 2'), findsOneWidget);
    expect(find.text('Selesai 12'), findsOneWidget);
    expect(find.text('Rina · #042'), findsOneWidget);
    expect(find.text('Andi · #041'), findsOneWidget);
    expect(find.text('Budi · #040'), findsOneWidget);
    expect(find.text('Rp60.000'), findsOneWidget);
    expect(find.text('Rp37.000'), findsOneWidget);

    // 4. Klik Insight, pastikan laporan mingguan tampil
    await tester.tap(find.text('Insight').last);
    await tester.pump();

    expect(find.text('Insight bisnis'), findsOneWidget);
    expect(find.text('30 Sep – 6 Okt 2026'), findsOneWidget);
    expect(find.text('Rp3.420.000'), findsOneWidget);
    expect(find.text('Rp2.180.000'), findsOneWidget);
    expect(find.text('Rp1.240.000'), findsOneWidget);
    expect(find.text('Nasi Ayam'), findsOneWidget);
    expect(find.text('Es Teh'), findsOneWidget);
    expect(find.text('Nasi Telur'), findsOneWidget);

    // 5. Klik Profil, pastikan identitas Mas Amba tampil
    await tester.tap(find.text('Profil').last);
    await tester.pump();

    expect(find.text('MAS AMBA'), findsOneWidget);
    expect(find.text('MA'), findsOneWidget);
    expect(find.text('masamba@warungmasamba.id'), findsOneWidget);
    expect(find.text('0812 3456 7890'), findsOneWidget);
    expect(find.text('Jl. Melati No. 12, Bandung'), findsOneWidget);
    expect(find.text('Kuliner · Usaha aktif'), findsOneWidget);

    // 6. Logout
    AuthService.logout();
    expect(AuthService.currentEmail, isNull);

    // === AKUN BARU ===
    // 1. Registrasi akun baru
    final registerSuccess = AuthService.register(
      name: 'Nadia Putri',
      phone: '0812 9876 5432',
      email: 'nadia@umkm.id',
      password: 'Password123',
      businessName: 'Kedai Nadia',
      category: 'Kuliner',
    );
    expect(registerSuccess, isTrue);

    // 2. Login menggunakan akun tersebut
    final newLoginSuccess = AuthService.login(
      email: 'nadia@umkm.id',
      password: 'Password123',
    );
    expect(newLoginSuccess, isTrue);

    await tester.pumpWidget(
      MaterialApp(key: UniqueKey(), home: const DashboardScreen()),
    );

    // 3. Buka Beranda, pastikan kosong
    expect(
      find.text('Belum ada transaksi. Yuk, mulai catat aktivitas usaha Anda!'),
      findsOneWidget,
    );
    expect(find.text('Rp540.000'), findsNothing);

    // 4. Buka Pesanan, pastikan kosong
    await tester.tap(find.text('Pesanan'));
    await tester.pump();

    expect(find.text('Semua 0'), findsOneWidget);
    expect(find.text('Baru 0'), findsOneWidget);
    expect(find.text('Diproses 0'), findsOneWidget);
    expect(find.text('Selesai 0'), findsOneWidget);
    expect(find.text('Belum ada pesanan.'), findsOneWidget);
    expect(find.text('Rina · #042'), findsNothing);

    // 5. Buka Insight, pastikan kosong
    await tester.tap(find.text('Insight').last);
    await tester.pump();

    expect(find.text('Belum ada data insight.'), findsOneWidget);
    expect(find.text('Rp3.420.000'), findsNothing);
    expect(find.text('Nasi Ayam'), findsNothing);

    // 6. Buka Profil, pastikan data registrasi tampil
    await tester.tap(find.text('Profil').last);
    await tester.pump();

    expect(find.text('NADIA PUTRI'), findsOneWidget);
    expect(find.text('NP'), findsOneWidget);
    expect(find.text('nadia@umkm.id'), findsOneWidget);
    expect(find.text('0812 9876 5432'), findsOneWidget);
    expect(find.text('Kedai Nadia'), findsWidgets);
    expect(find.text('MAS AMBA'), findsNothing);

    // 7. Logout
    AuthService.logout();

    // 8. Login kembali ke akun demo dan pastikan seluruh data demo tetap tersedia
    final reloginDemo = AuthService.login(
      email: AuthService.demoEmail,
      password: AuthService.demoPassword,
    );
    expect(reloginDemo, isTrue);

    await tester.pumpWidget(
      MaterialApp(key: UniqueKey(), home: const DashboardScreen()),
    );
    expect(find.text('Rp540.000'), findsOneWidget);
    expect(find.text('Semua 17'), findsOneWidget);
    expect(find.text('Rp3.420.000'), findsOneWidget);
    expect(find.text('MAS AMBA'), findsOneWidget);
  });
}
