import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopifyStorePage extends StatefulWidget {
  final String initialUrl;

  const ShopifyStorePage({Key? key, required this.initialUrl}) : super(key: key);

  @override
  State<ShopifyStorePage> createState() => _ShopifyStorePageState();
}

class _ShopifyStorePageState extends State<ShopifyStorePage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // 1. تهيئة الـ WebViewController مع الإعدادات الاحترافية لـ Shopify
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // تفعيل الجافا سكريبت بالكامل
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            
            // 2. معالجة ذكية للروابط الخارجية والروابط التي تبدأ بـ intent أو whatsapp لفتح التطبيق المناسب لها
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent;
            }
            
            // السماح بالتصفح الطبيعي بداخل الـ WebView لروابط المتجر
            return NavigationDecision.navigate;
          },
        ),
      );

    // 3. 🔥 السحر هنا: جلب الـ User Agent الافتراضي للمنصة (iOS/Android) وحقن الكلمة المفتاحية المخصصة
    _getUserAgentAndLoad();
  }

  Future<void> _getUserAgentAndLoad() async {
    // نطلب الـ User Agent الافتراضي من المنصة أولاً
    String? defaultUserAgent = await _controller.runJavaScriptReturningResult('navigator.userAgent') as String?;
    
    // تنظيف النص الناتج من علامات الاقتباس إن وجدت
    if (defaultUserAgent != null) {
      defaultUserAgent = defaultUserAgent.replaceAll('"', '');
    } else {
      defaultUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X)";
    }

    // تعيين الـ User Agent الجديد حاملاً وسم التطبيق الخاص بك
    await _controller.setUserAgent("$defaultUserAgent DarNileApp");
    
    // بعد ضبط الـ User Agent نقوم بتحميل رابط المتجر بأمان لضمان إخفاء الهيدر والفوتر من أول ثانية
    _controller.loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // SafeArea مخصصة لضمان عدم دخول المتجر تحت نوتش الآيفون أو شريط الحالة العلوية
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            // التعامل الذكي مع زر الرجوع الخلفي بدلاً من إغلاق التطبيق فجأة
            if (await _controller.canGoBack()) {
              await _controller.goBack();
              return false;
            }
            return true;
          },
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}