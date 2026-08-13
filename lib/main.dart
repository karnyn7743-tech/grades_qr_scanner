import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const KeyGeneratorApp());
}

class KeyGeneratorApp extends StatelessWidget {
  const KeyGeneratorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مولّد المفاتيح - طالوت الهاشمي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const GeneratorHomeScreen(),
    );
  }
}

class GeneratorHomeScreen extends StatefulWidget {
  const GeneratorHomeScreen({Key? key}) : super(key: key);

  @override
  State<GeneratorHomeScreen> createState() => _GeneratorHomeScreenState();
}

class _GeneratorHomeScreenState extends State<GeneratorHomeScreen> {
  final TextEditingController _deviceIdController = TextEditingController();

  // 🔑 كلمة السر السرية المتطابقة تماماً مع LicenseService
  final String _secretSalt = "MyCustomAppSecret_2026_@Key";

  String _generatedKey = "";

  void _generateKey() {
    FocusScope.of(context).unfocus(); // إغلاق لوحة المفاتيح
    final deviceId = _deviceIdController.text.trim();

    if (deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال معرّف الجهاز أولاً!')),
      );
      return;
    }

    // نفس خوارزمية التوليد المطابقة لتطبيق الاتصالات
    final rawData = "$deviceId|$_secretSalt";
    final bytes = utf8.encode(rawData);
    final digest = sha256.convert(bytes);
    final hexString = digest.toString().toUpperCase();
    final keyPart = hexString.substring(0, 16);

    setState(() {
      _generatedKey =
          "${keyPart.substring(0, 4)}-${keyPart.substring(4, 8)}-${keyPart.substring(8, 12)}-${keyPart.substring(12, 16)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مولّد مفاتيح التفعيل'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.vpn_key_rounded,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            const Text(
              'لوحة تفعيل أجهزة المستخدمين',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'أدخل معرّف الجهاز الذي أرسله لك الزبون لتوليد مفتاح التفعيل المخصص له',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 28),

            // حقل إدخال Device ID
            TextField(
              controller: _deviceIdController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              decoration: InputDecoration(
                labelText: 'معرّف الجهاز (Device ID)',
                hintText: 'مثال: 8f3b2a9d10e5f221',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone_android),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _deviceIdController.clear();
                    setState(() {
                      _generatedKey = "";
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // زر التوليد
            ElevatedButton.icon(
              onPressed: _generateKey,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('توليد المفتاح الآن', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // كارت عرض مفتاح التفعيل المولّد
            if (_generatedKey.isNotEmpty) ...[
              Card(
                color: Colors.deepPurple.shade50,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.deepPurple, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'مفتاح التفعيل الخاص بالجهاز:',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        _generatedKey,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _generatedKey));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم نسخ مفتاح التفعيل للحافظة بنجاح!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('نسخ المفتاح لإرساله للزبون'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
