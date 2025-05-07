import 'package:flutter/material.dart';
import 'package:agixt/models/agixt/auth/auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agixt/widgets/gravatar_image.dart';
import 'package:agixt/widgets/current_agixt.dart';
import 'package:agixt/utils/ui_perfs.dart';
import 'package:agixt/screens/agixt_daily.dart';
import 'package:agixt/screens/agixt_stop.dart';
import 'package:agixt/screens/checklist_screen.dart';
import 'package:agixt/services/ai_service.dart';
import 'package:agixt/services/bluetooth_manager.dart';
import 'package:agixt/services/cookie_manager.dart'; // Add CookieManager import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _email;
  String? _firstName;
  String? _lastName;
  bool _isLoading = true;
  UserModel? _userModel;
  final UiPerfs _ui = UiPerfs.singleton;
  final BluetoothManager bluetoothManager = BluetoothManager();
  final AIService aiService = AIService();
  
  // Add variables for debugging AGiXT values
  String? _currentAgent;
  String? _currentConversationId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAGiXTDebugInfo(); // Add call to load AGiXT debug info
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    // Get stored email as fallback
    final email = await AuthService.getEmail();

    // Try to get full user info from the server
    final userInfo = await AuthService.getUserInfo();

    setState(() {
      if (userInfo != null) {
        _userModel = userInfo;
        _email = userInfo.email;
        _firstName = userInfo.firstName;
        _lastName = userInfo.lastName;
      } else {
        // If server request fails, use stored email as fallback
        _email = email;
      }
      _isLoading = false;
    });
  }

  // Method to load AGiXT debug information
  Future<void> _loadAGiXTDebugInfo() async {
    final cookieManager = CookieManager();
    
    // Get the current agent from cookie manager
    final agent = await cookieManager.getAgixtAgentCookie();
    
    // Get the current conversation ID from cookie manager
    final conversationId = await cookieManager.getAgixtConversationId();
    
    debugPrint('Debug info - Agent: ${agent ?? "Not set"}, ConversationID: ${conversationId ?? "Not set"}');
    
    if (mounted) {
      setState(() {
        _currentAgent = agent ?? 'Not set';
        _currentConversationId = conversationId ?? 'Not set';
      });
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    await AuthService.logout();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _openAGiXTWeb() async {
    final url = await AuthService.getWebUrlWithToken();
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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

  @override
  Widget build(BuildContext context) {
    final appName = AuthService.appName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Features'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User Profile Section
                  Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // User avatar
                          _email != null
                              ? GravatarImage(
                                  email: _email!,
                                  size: 80,
                                )
                              : const CircleAvatar(
                                  radius: 40,
                                  child: Icon(Icons.person, size: 40),
                                ),

                          const SizedBox(height: 16),

                          // User name and email
                          if (_firstName != null &&
                              _lastName != null &&
                              _firstName!.isNotEmpty &&
                              _lastName!.isNotEmpty) ...[
                            Text(
                              '${_firstName!} ${_lastName!}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],

                          Text(
                            _email ?? 'User',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          if (_userModel != null) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),

                            // Show user timezone
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.access_time,
                                    size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'Timezone: ${_userModel!.timezone}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Show token usage
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.analytics_outlined,
                                    size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Tokens: ${_userModel!.inputTokens} in / ${_userModel!.outputTokens} out',
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            if (_userModel!.companies.isNotEmpty) ...[
                              const SizedBox(height: 8),

                              // Show primary company
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.business,
                                      size: 16, color: Colors.indigo),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Company: ${_userModel!.companies.firstWhere((c) => c.primary, orElse: () => _userModel!.companies.first).name}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ],

                          const SizedBox(height: 16),

                          // Logout button
                          OutlinedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // AI Assistant Card - Moved above Current AGiXT
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.mic, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 10),
                              const Text(
                                'AI Assistant',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Press the side button on your glasses to speak with the AI assistant.',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton.icon(
                            onPressed: _handleSideButtonPress,
                            icon: const Icon(Icons.record_voice_over),
                            label: const Text('Activate Assistant'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 44),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Current AGiXT info
                  CurrentAGiXT(),
                  
                  // Debug Info Card - Show current agent and conversation ID
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bug_report, color: Colors.orange),
                              const SizedBox(width: 10),
                              const Text(
                                'Debug Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Current Agent
                          Row(
                            children: [
                              const Icon(Icons.smart_toy, size: 18, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text(
                                'Current Agent:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _currentAgent ?? 'Not set',
                                  style: const TextStyle(fontFamily: 'monospace'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 18),
                                onPressed: _loadAGiXTDebugInfo,
                                tooltip: 'Refresh',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Current Conversation ID
                          Row(
                            children: [
                              const Icon(Icons.chat, size: 18, color: Colors.green),
                              const SizedBox(width: 8),
                              const Text(
                                'Conversation ID:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _currentConversationId ?? 'Not set',
                                  style: const TextStyle(fontFamily: 'monospace'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Feature Navigation Section
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'App Features',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        // Daily items
                        ListTile(
                          leading: _ui.trainNerdMode
                              ? Image(
                                  image: AssetImage('assets/icons/reference.png'),
                                  height: 24,
                                )
                              : Icon(Icons.sunny),
                          title: Text('Daily Items'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AGiXTDailyPage()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        // Stop items
                        ListTile(
                          leading: _ui.trainNerdMode
                              ? Image(
                                  image: AssetImage('assets/icons/stop.png'),
                                  height: 24,
                                )
                              : Icon(Icons.notifications),
                          title: Text('Stop Items'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AGiXTStopPage()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        // Checklists
                        ListTile(
                          leading: _ui.trainNerdMode
                              ? Image(
                                  image: AssetImage('assets/icons/oorsprong.png'),
                                  height: 24,
                                )
                              : Icon(Icons.checklist),
                          title: Text('Checklists'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AGiXTChecklistPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
