import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shopify_store_page.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  
  @override
  void initState() {
    super.initState();
    _checkSavedLanguage();
  }

  Future<void> _checkSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('selected_url');

    if (savedUrl != null && mounted) {
      _navigateToStore(savedUrl);
    }
  }

  Future<void> _selectLanguage(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_url', url);
    _navigateToStore(url);
  }

  void _navigateToStore(String url) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ShopifyStorePage(initialUrl: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // متوافق مع الهوية البصرية لدار النيل
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الشعار المسجل في pubspec.yaml الخاص بك
              Image.asset(
                'assets/splash_logo.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.white);
                },
              ),
              const SizedBox(height: 32),
              const Text(
                "مرحباً بك في متجر دار النيل\nWelcome to Dar Nile Store",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              // زر اللغة العربية
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _selectLanguage("https://darnile.myshopify.com/ar"),
                child: const Text(
                  "العربية",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              
              // زر اللغة الإنجليزية
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _selectLanguage("https://darnile.myshopify.com"),
                child: const Text(
                  "English",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}