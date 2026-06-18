import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF0F2A41),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dar Nile Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F2A41),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F2A41),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    final prefs = await SharedPreferences.getInstance();
    final String? savedUrl = prefs.getString('selected_url');

    if (!mounted) return;

    if (savedUrl != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainStoreScreen(baseUrl: savedUrl),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LanguageScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2A41),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _pulseController,
              child: const Image(
                image: AssetImage('assets/new_logo.png'),
                width: 250,
                height: 250,
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  Future<void> _saveLanguageAndProceed(BuildContext context, String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_url', url);

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainStoreScreen(baseUrl: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2A41),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/new_logo.png'),
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 32),
            const Text(
              "اختر اللغة\nCHOOSE LANGUAGE",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F2A41),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 206, 189, 1),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                onPressed: () => _saveLanguageAndProceed(
                  context,
                  "https://darnile.myshopify.com/ar",
                ),
                child: const Text(
                  "العربية",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F2A41),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 206, 189, 1),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                onPressed: () => _saveLanguageAndProceed(
                  context,
                  "https://darnile.myshopify.com",
                ),
                child: const Text(
                  "English",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainStoreScreen extends StatefulWidget {
  final String baseUrl;
  const MainStoreScreen({super.key, required this.baseUrl});

  @override
  State<MainStoreScreen> createState() => _MainStoreScreenState();
}

class _MainStoreScreenState extends State<MainStoreScreen>
    with SingleTickerProviderStateMixin {
  late final WebViewController _webController;
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late AnimationController _fadeController;
  final InAppReview _inAppReview = InAppReview.instance;
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateConnectionStatus(results);
    });

    _setupFirebaseMessaging();

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F2A41))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _syncBottomNavigation(url);
            _triggerInAppReviewIfNeeded(url);

            // حقن كود جافاسكريبت لإخفاء زر Shop للتسجيل، بالإضافة لزر التواصل العائم
            _webController.runJavaScript("""
              // 1. إخفاء زر تسجيل الدخول بواسطة Shop أو أي خدمات أخرى باستخدام CSS
              try {
                var style = document.createElement('style');
                style.type = 'text/css';
                style.innerHTML = `
                  .shop-pay-button,
                  #shop-pay-button,
                  [data-testid="ShopPay-button"],
                  shop-login-button,
                  .social-login,
                  .social-logins {
                     display: none !important;
                  }
                `;
                document.head.appendChild(style);
              } catch(e) {}

              // 2. فحص مستمر لإخفاء أزرار الشات وزر Shop تحسباً لظهورهم متأخراً
              setInterval(function() {
                var selectors = [
                  '#dummy-chat-button-iframe', 'iframe[id*="chat"]', 'iframe[name*="chat"]', 
                  '.chat-widget', '.floating-chat', 'div[class*="chat-button"]', 
                  'div[class*="contact-button"]', '[aria-label*="Contact Us"]', '[aria-label*="Contact"]',
                  '.shop-pay-button', '#shop-pay-button', '[data-testid="ShopPay-button"]', 'shop-login-button'
                ];
                
                selectors.forEach(function(selector) {
                  var elements = document.querySelectorAll(selector);
                  elements.forEach(function(el) {
                    if (el) {
                      el.style.display = 'none';
                      el.style.setProperty('display', 'none', 'important');
                    }
                  });
                });
              }, 500);
            """);
          },
          onWebResourceError: (WebResourceError error) {
            if (error.description.contains('net::ERR_INTERNET_DISCONNECTED') ||
                error.description.contains('net::ERR_NAME_NOT_RESOLVED')) {
              setState(() {
                _isOnline = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final String url = request.url;

            // التعامل فقط مع تطبيقات الموبايل الخارجية (واتساب، خرائط، اتصال)
            if (url.startsWith("geo:") ||
                url.startsWith("intent://") ||
                url.startsWith("whatsapp://") ||
                url.startsWith("mailto:") ||
                url.startsWith("tel:") ||
                url.contains("wa.me") ||
                url.contains("googleusercontent.com/maps") ||
                url.contains("goo.gl/maps")) {
              final Uri nativeUri = Uri.parse(url);
              try {
                if (await canLaunchUrl(nativeUri)) {
                  await launchUrl(
                    nativeUri,
                    mode: LaunchMode.externalApplication,
                  );
                  return NavigationDecision
                      .prevent; // يمنع فتحها جوه التطبيق ويحولها لمتصفح
                }
              } catch (e) {
                debugPrint("External app launch error: $e");
              }
              return NavigationDecision.prevent;
            }

            // أي رابط تاني (منتجات، بوابات دفع، روابط خارجية عادية) هيفتح جوه التطبيق بدون مشاكل
            return NavigationDecision.navigate;
          },
        ),
      );

    _setupUserAgentAndLoad();
  }

  Future<void> _checkForUpdate() async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      debugPrint("In-app update check failed: $e");
    }
  }

  Future<void> _triggerInAppReviewIfNeeded(String url) async {
    if (url.contains('/thank_you') || url.contains('/orders/')) {
      try {
        if (await _inAppReview.isAvailable()) {
          await _inAppReview.requestReview();
        }
      } catch (e) {
        debugPrint("In-app review error: $e");
      }
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      if (token != null) {
        await Clipboard.setData(ClipboardData(text: token));
      }
      await messaging.subscribeToTopic("all_users");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // إصلاح الخطأ: التأكد من أن الشاشة ما زالت معروضة قبل إظهار الإشعار
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF224766),
            content: Text(
              "${message.notification!.title}: ${message.notification!.body}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final List<ConnectivityResult> results = await Connectivity()
        .checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final bool hasInternet = !results.contains(ConnectivityResult.none);
    setState(() {
      _isOnline = hasInternet;
    });

    if (hasInternet) {
      _webController.reload();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _setupUserAgentAndLoad() async {
    try {
      String? defaultUA =
          await _webController.runJavaScriptReturningResult(
                'navigator.userAgent',
              )
              as String?;
      if (defaultUA != null) {
        defaultUA = defaultUA.replaceAll('"', '');
      } else {
        defaultUA =
            "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148";
      }
      await _webController.setUserAgent("$defaultUA DarNileApp");
    } catch (e) {
      await _webController.setUserAgent(
        "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) DarNileApp",
      );
    }
    _webController.loadRequest(Uri.parse(widget.baseUrl));
  }

  void _syncBottomNavigation(String url) {
    int newIndex = _currentIndex;

    if (url.contains('/collections/all')) {
      newIndex = 1;
    } else if (url.contains('/cart')) {
      newIndex = 2;
    } else if (url.contains('/account') || url.contains('/orders')) {
      newIndex = 3;
    } else if (url.contains('/blogs/locations')) {
      newIndex = 4;
    } else if (url == widget.baseUrl || url == "${widget.baseUrl}/") {
      newIndex = 0;
    }

    if (newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    String targetUrl = widget.baseUrl;
    switch (index) {
      case 0:
        targetUrl = widget.baseUrl;
        break;
      case 1:
        targetUrl = "${widget.baseUrl}/collections/all";
        break;
      case 2:
        targetUrl = "${widget.baseUrl}/cart";
        break;
      case 3:
        targetUrl = "${widget.baseUrl}/account";
        break;
      case 4:
        targetUrl = "${widget.baseUrl}/blogs/locations";
        break;
    }
    _webController.loadRequest(Uri.parse(targetUrl));
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF0F2A41),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          if (await _webController.canGoBack()) {
            await _webController.goBack();
            return;
          }

          final now = DateTime.now();
          final isWarning =
              _lastPressedAt == null ||
              now.difference(_lastPressedAt!) > const Duration(seconds: 2);

          if (isWarning) {
            _lastPressedAt = now;
            final bool isArabic = widget.baseUrl.contains('/ar');
            final message = isArabic
                ? "اضغط مرة أخرى للخروج من التطبيق"
                : "Press back again to exit";

            // إصلاح الخطأ: التأكد من أن الشاشة ما زالت معروضة
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF224766),
                duration: const Duration(seconds: 2),
              ),
            );
          } else {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF0F2A41),
          body: Stack(
            children: [
              if (_isOnline)
                Padding(
                  padding: EdgeInsets.only(top: statusBarHeight),
                  child: WebViewWidget(controller: _webController),
                ),
              if (!_isOnline) _buildNoInternetScreen(),
              if (_isLoading && _isOnline) _buildCustomLoaderScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF0F2A41),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            items: widget.baseUrl.contains('/ar')
                ? const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'الرئيسية',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shop),
                      label: 'المتجر',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart),
                      label: 'السلة',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'حسابي',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.location_on),
                      label: 'فروعنا',
                    ),
                  ]
                : const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shop),
                      label: 'Shop',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart),
                      label: 'Cart',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Account',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.location_on),
                      label: 'Locations',
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomLoaderScreen() {
    return Container(
      color: const Color(0xFF0F2A41),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeController,
            child: const Image(
              image: AssetImage('assets/new_logo.png'),
              width: 120,
              height: 120,
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoInternetScreen() {
    final bool isArabic = widget.baseUrl.contains('/ar');
    return Container(
      color: const Color(0xFF0F2A41),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 90, color: Colors.white70),
          const SizedBox(height: 24),
          Text(
            isArabic ? "لا يوجد اتصال بالإنترنت" : "No Internet Connection",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? "يرجى التحقق من باقة البيانات أو شبكة الـ Wi-Fi وإعادة المحاولة"
                : "Please check your data package or Wi-Fi network and try again",
            style: const TextStyle(color: Colors.white60, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: 180,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F2A41),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () async {
                _checkInitialConnectivity();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                isArabic ? "إعادة المحاولة" : "Try Again",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
