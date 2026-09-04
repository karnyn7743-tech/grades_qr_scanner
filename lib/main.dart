import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const KeyGeneratorApp());
}

class KeyGeneratorApp extends StatelessWidget {
  const KeyGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مولّد تراخيص الاختبارات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xF2F4F7FF),
      ),
      home: const KeyGeneratorScreen(),
    );
  }
}

class KeyGeneratorScreen extends StatefulWidget {
  const KeyGeneratorScreen({super.key});

  @override
  State<KeyGeneratorScreen> createState() => _KeyGeneratorScreenState();
}

class _KeyGeneratorScreenState extends State<KeyGeneratorScreen> {
  final TextEditingController _deviceIdController = TextEditingController();
  final TextEditingController _generatedKeyController = TextEditingController();

  // المفتاح السري المطابق تماماً والموجود في تطبيق maker_exampapers
  static const String _secretSalt = "ZulQarnain_Exam_App_2026_SecretKey";

  /// دالة حساب كود التفعيل بنفس خوارزمية التطبيق الرئيسي
  void _generateKey() {
    String deviceId = _deviceIdController.text.trim();

    if (deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى إدخال معرّف الجهاز أولاً!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final bytes = utf8.encode("$deviceId$_secretSalt");
    final digest = sha256.convert(bytes);
    // اقتطاع أول 8 رموز وتحويلها لأحرف كبيرة
    String activationCode = digest.toString().substring(0, 8).toUpperCase();

    setState(() {
      _generatedKeyController.text = activationCode;
    });

    FocusScope.of(context).unfocus(); // إغلاق لوحة المفاتيح
  }

  /// دالة نسخ المفتاح للحافظة
  void _copyToClipboard() {
    if (_generatedKeyController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedKeyController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم نسخ مفتاح التفعيل بنجاح!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مولّد مفاتيح التفعيل"),
        centerTitle: true,
        elevation: 2,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.vibration, size: 64, color: Colors.indigo),
              const SizedBox(height: 15),
              const Text(
                "نظام توليد التراخيص لتطبيق الاختبارات",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // حقل إدخال معرّف الجهاز
              TextField(
                controller: _deviceIdController,
                decoration: InputDecoration(
                  labelText: "معرّف جهاز العميل (Device ID)",
                  hintText: "الصق معرّف الجهاز هنا...",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone_android),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () async {
                      ClipboardData? clipboardData = await Clipboard.getData('text/plain');
                      if (clipboardData != null && clipboardData.text != null) {
                        setState(() {
                          _deviceIdController.text = clipboardData.text!.trim();
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // زر توليد المفتاح
              ElevatedButton.icon(
                onPressed: _generateKey,
                icon: const Icon(Icons.key, color: Colors.white),
                label: const Text(
                  "توليد مفتاح التفعيل",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // حقل عرض المفتاح المولد
              TextField(
                controller: _generatedKeyController,
                readOnly: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: Colors.green,
                ),
                decoration: InputDecoration(
                  labelText: "مفتاح التفعيل الناتج",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.green),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy, color: Colors.green),
                    onPressed: _copyToClipboard,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // زر نسخ سريع
              if (_generatedKeyController.text.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy),
                  label: const Text("نسخ المفتاح لإرساله للعميل"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
