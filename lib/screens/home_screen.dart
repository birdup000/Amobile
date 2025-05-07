import 'package:agixt/models/agixt/auth/auth.dart';
import 'package:agixt/screens/auth/profile_screen.dart';
import 'package:agixt/screens/calendars_screen.dart';
import 'package:agixt/screens/checklist_screen.dart';
import 'package:agixt/screens/agixt_daily.dart';
import 'package:agixt/screens/agixt_stop.dart';
import 'package:agixt/screens/settings_screen.dart';
import 'package:agixt/services/ai_service.dart';
import 'package:agixt/services/cookie_manager.dart';
import 'package:agixt/utils/ui_perfs.dart';
import 'package:agixt/widgets/current_agixt.dart';
import 'package:agixt/widgets/gravatar_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/bluetooth_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BluetoothManager bluetoothManager = BluetoothManager();
  final AIService aiService = AIService();
  final UiPerfs _ui = UiPerfs.singleton;

  String? _userEmail;
  bool _isLoggedIn = true;
  bool _isSideButtonListenerAttached = false;
  WebViewController? _webViewController;
  bool _isWebViewLoaded = false;
  // WebView is now shown by default
  bool _showWebView = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _setupBluetoothListeners();
    _initializeWebView();
  }

  Future<void> _loadUserDetails() async {
    final email = await AuthService.getEmail();
    final isLoggedIn = await AuthService.isLoggedIn();

    if (mounted) {
      setState(() {
        _userEmail = email;
        _isLoggedIn = isLoggedIn;
      });
      
      // For debugging
      print("User email: $_userEmail");
      print("Is logged in: $_isLoggedIn");

      // Redirect to login if not logged in
      if (!_isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else if (_userEmail == null || _userEmail!.isEmpty) {
        // If logged in but email is missing, try to get the user info
        final userInfo = await AuthService.getUserInfo();
        if (userInfo != null && userInfo.email.isNotEmpty) {
          setState(() {
            _userEmail = userInfo.email;
          });
          // Store the email for future use
          await AuthService.storeEmail(userInfo.email);
          print("Updated user email from user info: $_userEmail");
        }
      }
    }
  }

  void _setupBluetoothListeners() {
    // Wait until the glasses are connected to attach the listener
    Future.delayed(const Duration(seconds: 2), () {
      if (bluetoothManager.isConnected && !_isSideButtonListenerAttached) {
        _attachSideButtonListener();
      } else {
        // Try again later
        _setupBluetoothListeners();
      }
    });
  }

  void _attachSideButtonListener() {
    // Monitor for the side button press events from glasses
    if (bluetoothManager.rightGlass != null) {
      bluetoothManager.rightGlass!.onSideButtonPress = () {
        _handleSideButtonPress();
      };
      _isSideButtonListenerAttached = true;
    }
  }

  Future<void> _handleSideButtonPress() async {
    // Check if user is logged in
    if (!await AuthService.isLoggedIn()) {
      bluetoothManager.sendText('Please log in to use AI assistant');
      return;
    }

    // Handle the side button press to activate AI communications
    await aiService.handleSideButtonPress();
  }

  Future<void> _openAGiXTWeb() async {
    final url = await AuthService.getWebUrlWithToken();
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _initializeWebView() async {
    if (!_isLoggedIn) return;
    
    // Get the URL with authentication token
    final webUrl = await AuthService.getWebUrlWithToken();
    final chatUrl = Uri.parse(webUrl).replace(path: '/chat').toString();
    
    // Create a CookieManager instance
    final cookieManager = CookieManager();
    
    // Initialize the WebView controller
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            setState(() {
              _isWebViewLoaded = true;
            });
            
            // Extract the agixt-conversation cookie
            _extractAgixtConversationCookie();
          },
          onNavigationRequest: (NavigationRequest request) {
            // Extract cookies whenever navigation happens
            _extractAgixtConversationCookie();
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(chatUrl));
  }
  
  // Extract the agixt-conversation cookie from WebView
  Future<void> _extractAgixtConversationCookie() async {
    if (_webViewController == null) return;
    
    try {
      // Using JavaScript to extract the agixt-conversation cookie
      final conversationCookieScript = '''
      (function() {
        var cookies = document.cookie.split(';');
        for (var i = 0; i < cookies.length; i++) {
          var cookie = cookies[i].trim();
          if (cookie.startsWith('agixt-conversation=')) {
            return cookie.substring('agixt-conversation='.length);
          }
        }
        return '';
      })()
      ''';
      
      final conversationCookieValue = await _webViewController!.runJavaScriptReturningResult(conversationCookieScript) as String?;
      
      if (conversationCookieValue != null && conversationCookieValue.isNotEmpty && conversationCookieValue != 'null' && conversationCookieValue != '""') {
        // Store the cookie using our CookieManager
        final cookieManager = CookieManager();
        await cookieManager.saveAgixtConversationCookie(conversationCookieValue);
        debugPrint('Extracted agixt-conversation cookie: $conversationCookieValue');
      }
      
      // Using JavaScript to extract the agixt-agent cookie
      final agentCookieScript = '''
      (function() {
        var cookies = document.cookie.split(';');
        for (var i = 0; i < cookies.length; i++) {
          var cookie = cookies[i].trim();
          if (cookie.startsWith('agixt-agent=')) {
            return cookie.substring('agixt-agent='.length);
          }
        }
        return '';
      })()
      ''';
      
      final agentCookieValue = await _webViewController!.runJavaScriptReturningResult(agentCookieScript) as String?;
      
      if (agentCookieValue != null && agentCookieValue.isNotEmpty && agentCookieValue != 'null' && agentCookieValue != '""') {
        // Store the agent cookie using our CookieManager
        final cookieManager = CookieManager();
        await cookieManager.saveAgixtAgentCookie(agentCookieValue);
        debugPrint('Extracted agixt-agent cookie: $agentCookieValue');
      }
    } catch (e) {
      debugPrint('Error extracting cookies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(
        title: Text(AuthService.appName),
        actions: [
          // Profile button with Gravatar
          if (_userEmail != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                },
                child: GravatarImage(
                  email: _userEmail!,
                  size: 40,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: _buildWebView(),
    );
  }

  Widget _buildWebView() {
    if (_webViewController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Column(
      children: [
        Expanded(
          child: WebViewWidget(
            controller: _webViewController!,
          ),
        ),
      ],
    );
  }
}
