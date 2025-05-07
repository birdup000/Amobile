import 'package:agixt/models/agixt/auth/auth.dart';
import 'package:agixt/models/agixt/widgets/agixt_chat.dart'; // Import AGiXTChatWidget
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
  final bool _showWebView = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _setupBluetoothListeners();
    _initializeWebView();
    _ensureConversationId(); // Ensure a conversation ID exists at startup
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

    // Create a CookieManager instance
    final cookieManager = CookieManager();

    // Check if we have a previous conversation ID to restore
    final lastConversationId = await cookieManager.getAgixtConversationId();

    // Determine the URL to load
    String urlToLoad;
    if (lastConversationId != null && lastConversationId != "-") {
      // Navigate to the previous conversation if available
      final uri = Uri.parse(webUrl);
      urlToLoad = uri.replace(path: '/chat/$lastConversationId').toString();
      debugPrint('Navigating to previous conversation: $urlToLoad');
    } else {
      // Otherwise, just go to the main chat page
      final uri = Uri.parse(webUrl);
      urlToLoad = uri.replace(path: '/chat').toString();
    }

    // Initialize the WebView controller
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            setState(() {
              _isWebViewLoaded = true;
            });

            // Extract conversation ID from URL and agent cookie
            _extractConversationIdAndAgentInfo(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            // Extract conversation ID whenever navigation happens
            _extractConversationIdAndAgentInfo(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(urlToLoad));
  }

  // Extract the conversation ID from URL and agent cookie from WebView
  Future<void> _extractConversationIdAndAgentInfo(String url) async {
    if (_webViewController == null) return;

    try {
      debugPrint('Processing URL for extraction: $url');
      
      // Extract conversation ID from URL path if it contains '/chat/'
      if (url.contains('/chat/')) {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        debugPrint('Path segments: $pathSegments');

        // Find the index of 'chat' in the path segments
        final chatIndex = pathSegments.indexOf('chat');
        debugPrint('Chat index in path: $chatIndex');

        // If 'chat' is found and there's a segment after it, that's our conversation ID
        if (chatIndex >= 0 && chatIndex < pathSegments.length - 1) {
          final conversationId = pathSegments[chatIndex + 1];
          debugPrint('Found conversation ID in URL: $conversationId');

          if (conversationId.isNotEmpty) {
            // Store the conversation ID directly
            final cookieManager = CookieManager();
            await cookieManager.saveAgixtConversationId(conversationId);
            debugPrint('Saved conversation ID directly: $conversationId');
            
            // Also use the AGiXTChatWidget method as a backup
            final chatWidget = AGiXTChatWidget();
            await chatWidget.updateConversationIdFromUrl(url);
          }
        } else {
          // Handle case where we're on the /chat/ page but no specific conversation ID
          // Try to get the existing conversation ID or generate a new one
          _ensureConversationId();
        }
      } else {
        // If we're not on a chat page at all, ensure we have a default conversation ID
        _ensureConversationId();
      }

      // Using improved JavaScript to extract the agixt-agent cookie
      final agentCookieScript = '''
      (function() {
        try {
          var cookies = document.cookie.split(';');
          for (var i = 0; i < cookies.length; i++) {
            var cookie = cookies[i].trim();
            if (cookie.startsWith('agixt-agent=')) {
              var value = cookie.substring('agixt-agent='.length);
              console.log('Found agixt-agent cookie:', value);
              return value;
            }
          }
          
          // Try to find the agent from the page content if cookie approach failed
          var agentElement = document.querySelector('.agent-selector .selected');
          if (agentElement) {
            var agentName = agentElement.textContent.trim();
            console.log('Found agent from selector:', agentName);
            return agentName;
          }
          
          return '';
        } catch (e) {
          console.error('Error in cookie extraction:', e);
          return '';
        }
      })()
      ''';

      final agentCookieValue = await _webViewController!
          .runJavaScriptReturningResult(agentCookieScript) as String?;

      debugPrint('Extracted agent value: ${agentCookieValue ?? "null"}');

      if (agentCookieValue != null &&
          agentCookieValue.isNotEmpty &&
          agentCookieValue != 'null' &&
          agentCookieValue != '""') {
        // Store the agent cookie using our CookieManager
        final cookieManager = CookieManager();
        await cookieManager.saveAgixtAgentCookie(agentCookieValue);
        debugPrint('Saved agent value: $agentCookieValue');
      } else {
        // If we didn't get a value, schedule a retry after a delay
        // This helps when the page is still loading or cookies aren't yet set
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _extractAgentInfoRetry();
          }
        });
      }
    } catch (e) {
      debugPrint('Error extracting conversation ID or agent info: $e');
    }
  }
  
  // Ensure we have a valid conversation ID
  Future<void> _ensureConversationId() async {
    try {
      final cookieManager = CookieManager();
      final existingId = await cookieManager.getAgixtConversationId();
      
      // If we don't have a conversation ID or it's invalid, generate a new one
      if (existingId == null || existingId.isEmpty || existingId == 'Not set') {
        final newId = _generateConversationId();
        await cookieManager.saveAgixtConversationId(newId);
        debugPrint('Generated and saved new conversation ID: $newId');
      } else {
        debugPrint('Using existing conversation ID: $existingId');
      }
    } catch (e) {
      debugPrint('Error ensuring conversation ID: $e');
    }
  }
  
  // Generate a new conversation ID
  String _generateConversationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = (1000 + DateTime.now().microsecond % 9000).toString();
    return 'conv-$timestamp-$random';
  }
  
  // Retry extracting agent info after a delay
  Future<void> _extractAgentInfoRetry() async {
    if (_webViewController == null) return;
    
    try {
      debugPrint('Retrying agent extraction...');
      
      // Alternative JavaScript approach focused just on agent extraction
      final altAgentScript = '''
      (function() {
        try {
          // Try cookie approach first
          var cookies = document.cookie.split(';');
          for (var i = 0; i < cookies.length; i++) {
            var cookie = cookies[i].trim();
            if (cookie.startsWith('agixt-agent=')) {
              return cookie.substring('agixt-agent='.length);
            }
          }
          
          // Try DOM inspection
          // Look for agent selector or any UI element that might contain the agent name
          var agentElements = document.querySelectorAll('[data-agent], .agent-name, .model-selector');
          for (var i = 0; i < agentElements.length; i++) {
            var text = agentElements[i].textContent.trim();
            if (text && text.length > 0 && text !== 'null') {
              return text;
            }
          }
          
          return '';
        } catch (e) {
          console.error('Error in alternative agent extraction:', e);
          return '';
        }
      })()
      ''';
      
      final agentValue = await _webViewController!
          .runJavaScriptReturningResult(altAgentScript) as String?;
          
      if (agentValue != null && 
          agentValue.isNotEmpty && 
          agentValue != 'null' &&
          agentValue != '""') {
        final cookieManager = CookieManager();
        await cookieManager.saveAgixtAgentCookie(agentValue);
        debugPrint('Saved agent value from retry: $agentValue');
      }
    } catch (e) {
      debugPrint('Error in agent retry: $e');
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
