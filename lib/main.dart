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
      title: 'مولد مفاتيح تفعيل الأتمتة المصغرة للإختبارات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const GeneratorHomeScreen(),
    );
  }
}

class GeneratorHomeScreen extends StatefulWidget {
  const GeneratorHomeScreen({super.key});

  @override
  State<GeneratorHomeScreen> createState() => _GeneratorHomeScreenState();
}

class _GeneratorHomeScreenState extends State<GeneratorHomeScreen> {
  final TextEditingController _deviceIdController = TextEditingController();
  String _generatedCode = "";
  
  // نفس المفتاح السري المعتمد في تطبيق الكنترول
  static const String _secretSalt = "STUGRA_SCAN_SECRET_KEY_2026";

  void _generateCode() {
    String deviceId = _deviceIdController.text.trim();
    if (deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال معرف الجهاز أولاً!")),
      );
      return;
    }

    var bytes = utf8.encode(deviceId + _secretSalt);
    var digest = sha256.convert(bytes).toString().toUpperCase();

    String part1 = digest.substring(0, 4);
    String part2 = digest.substring(4, 8);

    setState(() {
      _generatedCode = "STUG-$part1-$part2";
    });
  }

  void _copyToClipboard() {
    if (_generatedCode.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedCode));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم نسخ كود التفعيل بنجاح!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مولد مفاتيح كنترول الاختبارات"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.key_sharp, size: 70, color: Colors.teal),
              const SizedBox(height: 16),
              const Text(
                "توليد كود التفعيل للعميل",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // حقل إدخال Device ID
              TextField(
                controller: _deviceIdController,
                decoration: InputDecoration(
                  labelText: "معرف جهاز العميل (Device ID)",
                  hintText: "أدخل أو الصق المعرف هنا",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone_android),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () async {
                      ClipboardData? data = await Clipboard.getData('text/plain');
                      if (data != null && data.text != null) {
                        _deviceIdController.text = data.text!;
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // زر التوليد
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _generateCode,
                icon: const Icon(Icons.bolt),
                label: const TextStyle(fontSize: 18) == null
                    ? const Text("توليد كود التفعيل")
                    : const Text("توليد كود التفعيل", style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 30),

              // عرض كود التفعيل الناتج
              if (_generatedCode.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "كود التفعيل الخاص بالعميل:",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _generatedCode,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy),
                        label: const Text("نسخ الكود لفي الملاحظات أو واتساب"),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
